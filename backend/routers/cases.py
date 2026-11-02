
import uuid
from datetime import datetime, timezone
from pathlib import Path

from bson import ObjectId
from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    Query,
    UploadFile,
    status,
)
from fastapi.responses import FileResponse

from database import cases_collection
from routers.auth import get_current_user

router = APIRouter(prefix="/cases", tags=["Cases"])

UPLOAD_DIR = Path(__file__).resolve().parent.parent / "uploads" / "cases"

MAX_IMAGE_SIZE = 5 * 1024 * 1024
MAX_VIDEO_SIZE = 50 * 1024 * 1024
CHUNK_SIZE = 1024 * 1024

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
VIDEO_EXTENSIONS = {".mp4", ".mov", ".webm"}
ALLOWED_EXTENSIONS = IMAGE_EXTENSIONS | VIDEO_EXTENSIONS


def serialize_case(case: dict) -> dict:
    """Convert a MongoDB case document into a JSON-safe response."""
    created_at = case.get("created_at")
    updated_at = case.get("updated_at")

    stored_filename = case.get("media", {}).get("stored_filename")

    return {
        "id": str(case["_id"]),
        "case_number": f"CASE{str(case['_id'])[-6:].upper()}",
        "dog": case.get("dog", {}),
        "notes": case.get("notes", ""),
        "media": {
            **case.get("media", {}),
            "url": (
                f"/api/cases/media/{stored_filename}"
                if stored_filename
                else None
            ),
        },
        "status": case.get("status", "pending"),
        "diagnosis": case.get("diagnosis"),
        "confidence": case.get("confidence"),
        "created_at": (
            created_at.isoformat()
            if isinstance(created_at, datetime)
            else created_at
        ),
        "updated_at": (
            updated_at.isoformat()
            if isinstance(updated_at, datetime)
            else updated_at
        ),
    }


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_case(
    dog_name: str = Form(..., min_length=1, max_length=100),
    age: float = Form(..., ge=0, le=100),
    gender: str = Form(...),
    breed: str = Form(""),
    notes: str = Form(""),
    file: UploadFile = File(...),
    user: dict = Depends(get_current_user),
):
    gender = gender.strip().capitalize()

    if gender not in {"Male", "Female"}:
        raise HTTPException(
            status_code=422,
            detail="Gender must be Male or Female.",
        )

    extension = Path(file.filename or "").suffix.lower()

    if extension in IMAGE_EXTENSIONS:
        max_size = MAX_IMAGE_SIZE
        media_type = "image"
    elif extension in VIDEO_EXTENSIONS:
        max_size = MAX_VIDEO_SIZE
        media_type = "video"
    else:
        raise HTTPException(
            status_code=400,
            detail="Unsupported file type. Upload JPG, PNG, WEBP, MP4, MOV or WEBM.",
        )

    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

    stored_name = f"{uuid.uuid4().hex}{extension}"
    destination = UPLOAD_DIR / stored_name
    size = 0

    try:
        with destination.open("wb") as output:
            while True:
                chunk = file.file.read(CHUNK_SIZE)

                if not chunk:
                    break

                size += len(chunk)

                if size > max_size:
                    raise HTTPException(
                        status_code=413,
                        detail=(
                            "Image must be at most 5 MB."
                            if media_type == "image"
                            else "Video must be at most 50 MB."
                        ),
                    )

                output.write(chunk)

        if size == 0:
            raise HTTPException(
                status_code=400,
                detail="The uploaded file is empty.",
            )

        now = datetime.now(timezone.utc)

        case_document = {
            "user_id": str(user["_id"]),
            "dog": {
                "name": dog_name.strip(),
                "age": age,
                "gender": gender,
                "breed": breed.strip(),
            },
            "notes": notes.strip(),
            "media": {
                "original_filename": Path(file.filename or "").name,
                "stored_filename": stored_name,
                "media_type": media_type,
                "extension": extension,
                "size_bytes": size,
            },
            "status": "pending",
            "diagnosis": None,
            "confidence": None,
            "created_at": now,
            "updated_at": now,
        }

        result = cases_collection.insert_one(case_document)
        case_document["_id"] = result.inserted_id

        return {
            "message": "Case saved successfully.",
            "case": serialize_case(case_document),
        }

    except HTTPException:
        destination.unlink(missing_ok=True)
        raise

    except Exception:
        destination.unlink(missing_ok=True)
        raise HTTPException(
            status_code=500,
            detail="Failed to save the case.",
        )

    finally:
        file.file.close()


@router.get("/")
def get_my_cases(
    limit: int = Query(default=20, ge=1, le=100),
    skip: int = Query(default=0, ge=0),
    user: dict = Depends(get_current_user),
):
    """Return cases belonging only to the authenticated user."""
    user_id = str(user["_id"])

    query = {"user_id": user_id}

    total = cases_collection.count_documents(query)

    cursor = (
        cases_collection.find(query)
        .sort("created_at", -1)
        .skip(skip)
        .limit(limit)
    )

    cases = [serialize_case(case) for case in cursor]

    return {
        "cases": cases,
        "total": total,
        "limit": limit,
        "skip": skip,
    }


@router.get("/media/{filename}")
def get_case_media(
    filename: str,
    user: dict = Depends(get_current_user),
):
    """Serve media only when it belongs to a case owned by this user."""
    safe_filename = Path(filename).name

    if safe_filename != filename:
        raise HTTPException(
            status_code=400,
            detail="Invalid filename.",
        )

    extension = Path(safe_filename).suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Unsupported media type.",
        )

    case = cases_collection.find_one(
        {
            "user_id": str(user["_id"]),
            "media.stored_filename": safe_filename,
        }
    )

    if not case:
        raise HTTPException(
            status_code=404,
            detail="Media not found.",
        )

    file_path = (UPLOAD_DIR / safe_filename).resolve()

    if file_path.parent != UPLOAD_DIR.resolve() or not file_path.is_file():
        raise HTTPException(
            status_code=404,
            detail="Media file not found.",
        )

    return FileResponse(
        path=file_path,
        media_type=(
            "image/jpeg"
            if extension in {".jpg", ".jpeg"}
            else "image/png"
            if extension == ".png"
            else "image/webp"
            if extension == ".webp"
            else "video/mp4"
            if extension == ".mp4"
            else "video/quicktime"
            if extension == ".mov"
            else "video/webm"
        ),
        filename=safe_filename,
    )


@router.get("/{case_id}")
def get_case_by_id(
    case_id: str,
    user: dict = Depends(get_current_user),
):
    """Return a single case belonging to the authenticated user."""
    if not ObjectId.is_valid(case_id):
        raise HTTPException(
            status_code=400,
            detail="Invalid case ID.",
        )

    case = cases_collection.find_one(
        {
            "_id": ObjectId(case_id),
            "user_id": str(user["_id"]),
        }
    )

    if not case:
        raise HTTPException(
            status_code=404,
            detail="Case not found.",
        )

    return {"case": serialize_case(case)}

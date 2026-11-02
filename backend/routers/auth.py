
import os
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr, Field
from pymongo.errors import DuplicateKeyError
from pwdlib import PasswordHash
from database import users_collection, cases_collection
from database import users_collection

load_dotenv()

router = APIRouter(prefix="/auth", tags=["Authentication"])

password_hash = PasswordHash.recommended()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30")
)

if not JWT_SECRET_KEY:
    raise RuntimeError("JWT_SECRET_KEY is missing from your .env file")


class RegisterRequest(BaseModel):
    full_name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)

class ProfileUpdateRequest(BaseModel):
    full_name: str = Field(min_length=2, max_length=100)
    phone: str = Field(default="", max_length=20)

def create_access_token(user_id: str) -> str:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES
    )

    payload = {
        "sub": user_id,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM,
    )


def public_user(user: dict) -> dict:
    return {
        "id": str(user["_id"]),
        "full_name": user["full_name"],
        "email": user["email"],
        "phone": user.get("phone", ""),
        "role": user.get("role", "user"),
    }


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest):
    email = str(payload.email).strip().lower()

    existing_user = users_collection.find_one({"email": email})
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    user = {
    "full_name": payload.full_name.strip(),
    "email": email,
    "password_hash": password_hash.hash(payload.password),
    "role": "user",
    "created_at": datetime.now(timezone.utc),
}

    try:
        result = users_collection.insert_one(user)
    except DuplicateKeyError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    user["_id"] = result.inserted_id

    return {
        "message": "Registration successful.",
        "user": public_user(user),
    }


@router.post("/login")
def login(payload: LoginRequest):
    email = str(payload.email).strip().lower()
    user = users_collection.find_one({"email": email})

    if not user or not password_hash.verify(
        payload.password,
        user["password_hash"],
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    token = create_access_token(str(user["_id"]))

    return {
        "message": "Login successful.",
        "access_token": token,
        "token_type": "bearer",
        "user": public_user(user),
    }


def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET_KEY,
            algorithms=[JWT_ALGORITHM],
        )
        user_id = payload.get("sub")

        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication token.",
            )

    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token.",
        )

    from bson import ObjectId
    from bson.errors import InvalidId

    try:
        object_id = ObjectId(user_id)
    except (InvalidId, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token.",
        )

    user = users_collection.find_one({"_id": object_id})

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists.",
        )

    return user


@router.patch("/me")
def update_my_profile(
    payload: ProfileUpdateRequest,
    user: dict = Depends(get_current_user),
):
    full_name = payload.full_name.strip()
    phone = payload.phone.strip()

    if len(full_name) < 2:
        raise HTTPException(
            status_code=422,
            detail="Name must contain at least 2 characters.",
        )

    users_collection.update_one(
        {"_id": user["_id"]},
        {
            "$set": {
                "full_name": full_name,
                "phone": phone,
                "updated_at": datetime.now(timezone.utc),
            }
        },
    )

    updated_user = users_collection.find_one({"_id": user["_id"]})

    return {
        "message": "Profile updated successfully.",
        "user": public_user(updated_user),
    }
    
def require_admin(user: dict = Depends(get_current_user)):
    role = str(user.get("role", "user")).strip().lower()

    if role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Administrator access required.",
        )

    return user


@router.get("/admin/dashboard")
def get_admin_dashboard(
    admin: dict = Depends(require_admin),
):
    """Return dashboard statistics and recent activity from MongoDB."""

    total_users = users_collection.count_documents({})
    total_cases = cases_collection.count_documents({})
    pending_cases = cases_collection.count_documents(
        {"status": "pending"}
    )

    recent_cases = []

    cursor = (
        cases_collection.find({})
        .sort("created_at", -1)
        .limit(5)
    )

    for case in cursor:
        created_at = case.get("created_at")
        dog = case.get("dog") or {}

        user_id = case.get("user_id")
        owner = None

        if user_id:
            from bson import ObjectId
            from bson.errors import InvalidId

            try:
                owner = users_collection.find_one(
                    {"_id": ObjectId(user_id)},
                    {"full_name": 1, "email": 1},
                )
            except (InvalidId, TypeError):
                owner = None

        recent_cases.append({
            "id": str(case["_id"]),
            "dog_name": dog.get("name", "Unknown"),
            "status": case.get("status", "pending"),
            "diagnosis": case.get("diagnosis"),
            "owner_name": (
                owner.get("full_name") if owner else None
            ),
            "created_at": (
                created_at.isoformat()
                if isinstance(created_at, datetime)
                else created_at
            ),
        })

    return {
        "admin": public_user(admin),
        "statistics": {
            "total_users": total_users,
            "total_cases": total_cases,
            "pending_cases": pending_cases,
        },
        "recent_cases": recent_cases,
    }

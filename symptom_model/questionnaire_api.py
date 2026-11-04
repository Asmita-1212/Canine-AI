
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Any
from uuid import uuid4

from engine import QuestionnaireEngine
from model_adapter import predict_disease
from translations import translate_question


# --------------------------------
# FastAPI application
# --------------------------------

app = FastAPI(
    title="CanineAI API",
    description="Adaptive canine skin disease prediction",
    version="1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# --------------------------------
# Supported languages
# --------------------------------

SUPPORTED_LANGUAGES = ["en", "hi", "mr"]


# --------------------------------
# Active questionnaire sessions
# --------------------------------

sessions = {}


# --------------------------------
# Request models
# --------------------------------

class AnswerRequest(BaseModel):
    question_id: str
    answer: Any


# --------------------------------
# Home endpoint
# --------------------------------

@app.get("/")
def home():

    return {
        "success": True,
        "message": "Welcome to CanineAI API"
    }


# --------------------------------
# Health check
# --------------------------------

@app.get("/health")
def health():

    return {
        "status": "healthy",
        "model": "calibrated_random_forest"
    }


# --------------------------------
# Start questionnaire
# --------------------------------

@app.post("/questionnaire/start")
def start_questionnaire(language: str = "en"):

    if language not in SUPPORTED_LANGUAGES:
        raise HTTPException(
            status_code=400,
            detail="Unsupported language. Use en, hi or mr."
        )

    session_id = str(uuid4())

    engine = QuestionnaireEngine(max_questions=10)

    sessions[session_id] = {
        "engine": engine,
        "language": language,
        "completed": False,
        "result": None
    }

    first_question_id = engine.next_question()

    question = translate_question(
        engine.get_question(first_question_id),
        language
    )

    return {
        "success": True,
        "session_id": session_id,
        "language": language,
        "completed": False,
        "question": question
    }


# --------------------------------
# Submit answer
# --------------------------------

@app.post("/questionnaire/{session_id}/answer")
def submit_answer(session_id: str, request: AnswerRequest):

    session = sessions.get(session_id)

    if session is None:
        raise HTTPException(
            status_code=404,
            detail="Questionnaire session not found"
        )

    if session["completed"]:
        raise HTTPException(
            status_code=400,
            detail="Questionnaire already completed"
        )

    engine = session["engine"]

    try:

        next_question_id = engine.submit_answer(
            request.question_id,
            request.answer
        )

    except (ValueError, KeyError) as error:

        raise HTTPException(
            status_code=400,
            detail=str(error)
        )

    # If more questions are available
    if next_question_id is not None:

        next_question = translate_question(
            engine.get_question(next_question_id),
            session["language"]
        )

        return {
            "success": True,
            "completed": False,
            "question": next_question
        }

    # --------------------------------
    # Generate final prediction
    # --------------------------------

    try:

        model_answers = engine.get_model_answers()

        prediction = predict_disease(model_answers)

        session["completed"] = True
        session["result"] = prediction

        return {
            "success": True,
            "completed": True,
            "prediction": {
                "disease": prediction["predicted_disease"],
                "confidence": prediction["confidence"],
                "message": prediction["message"]
            }
        }

    except Exception as error:

        raise HTTPException(
            status_code=500,
            detail=f"Prediction failed: {str(error)}"
        )


# --------------------------------
# Get questionnaire status
# --------------------------------

@app.get("/questionnaire/{session_id}")
def get_questionnaire_status(session_id: str):

    session = sessions.get(session_id)

    if session is None:
        raise HTTPException(
            status_code=404,
            detail="Questionnaire session not found"
        )

    engine = session["engine"]

    return {
        "session_id": session_id,
        "language": session["language"],
        "completed": session["completed"],
        "asked_questions": engine.asked_questions,
        "result": session["result"]
    }


# --------------------------------
# Delete questionnaire session
# --------------------------------

@app.delete("/questionnaire/{session_id}")
def delete_questionnaire(session_id: str):

    if session_id not in sessions:
        raise HTTPException(
            status_code=404,
            detail="Questionnaire session not found"
        )

    del sessions[session_id]

    return {
        "success": True,
        "message": "Questionnaire session deleted"
    }

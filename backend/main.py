from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers.auth import router as auth_router
from routers.cases import router as cases_router

app = FastAPI(
    title="CanineCare AI API",
    description="AI-powered canine skin disease detection system",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(cases_router, prefix="/api")


@app.get("/")
def root():
    return {
        "message": "Welcome to CanineCare AI API",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "CanineCare AI",
    }
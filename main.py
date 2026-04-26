from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

with open("cv.json") as f:
    cv_data = json.load(f)

@app.get("/cv")
def get_cv():
    return cv_data

@app.get("/health")
def health():
    return {"status": "ok"}
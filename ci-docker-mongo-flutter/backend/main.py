from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from motor.motor_asyncio import AsyncIOMotorClient

MONGO_URL = os.getenv("MONGO_URL", "mongodb://mongo:27017")
MONGO_DB = os.getenv("MONGO_DB", "appdb")

app = FastAPI(title="Backend API", version="1.0.0")

# Enable permissive CORS (handy for local tests / Flutter web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class MessageIn(BaseModel):
    text: str

@app.on_event("startup")
async def startup_event():
    app.state.client = AsyncIOMotorClient(MONGO_URL)
    app.state.db = app.state.client[MONGO_DB]
    # Ensure a default message exists
    doc = await app.state.db.messages.find_one({"_id": "welcome"})
    if not doc:
        await app.state.db.messages.insert_one({"_id": "welcome", "text": "¡Hola desde MongoDB!"})

@app.on_event("shutdown")
async def shutdown_event():
    app.state.client.close()

@app.get("/message")
async def get_message():
    doc = await app.state.db.messages.find_one({"_id": "welcome"})
    return {"message": doc.get("text") if doc else ""}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/message")
async def set_message(payload: MessageIn):
    await app.state.db.messages.update_one(
        {"_id": "welcome"},
        {"$set": {"text": payload.text}},
        upsert=True
    )
    return {"ok": True}
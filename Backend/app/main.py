from fastapi import FastAPI
from app.transactions.router import router as transaction_router
from app.database import database
from app.auth.router import router as auth_router
from app.investment.router import router as investment_router
from dotenv import load_dotenv

load_dotenv()
app = FastAPI(title="FinPilot AI API")


app.include_router(auth_router)
app.include_router(transaction_router)
app.include_router(investment_router)

@app.get("/")
async def home():
    return {"message": "FinPilot Backend Running"}


@app.get("/test-db")
async def test_db():
    collections = await database.list_collection_names()

    return {
        "status": "Connected Successfully",
        "collections": collections,
    }


app = FastAPI()
#suyash pandey

# @app.get("/health")
# async def health():
#     return {
#         "status": "ok",
#         "message": "FinPilotAI backend is running",
#         "description": "Working on the backend of FinPilotAI, a financial management application that helps users track their expenses, manage investments, and make informed financial decisions. The backend is built using FastAPI and MongoDB, providing a robust and scalable solution for handling user data and transactions."
#     }
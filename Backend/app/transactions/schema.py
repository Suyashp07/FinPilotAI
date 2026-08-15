from datetime import datetime
from pydantic import BaseModel


class TransactionCreate(BaseModel):
    title: str
    amount: float
    is_income: bool
    category: str
    description: str
    date: datetime


class TransactionResponse(BaseModel):
    id: str
    title: str
    amount: float
    is_income: bool
    category: str
    description: str
    date: datetime
from pydantic import BaseModel


class InvestmentProfileCreate(BaseModel):
    risk_tolerance: str
    investment_horizon: str
    investment_goal: str
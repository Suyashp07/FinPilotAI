from fastapi import APIRouter, Depends

from app.auth.dependencies import get_current_user

from app.investment.schema import InvestmentProfileCreate

from app.investment.service import (
    save_investment_profile,
    get_investment_profile,
)

from app.transactions.service import (
    get_transactions,
)

from app.investment.ai_recommendation import (
    generate_ai_recommendation,
)


router = APIRouter(
    prefix="/investment",
    tags=["Investment"],
)


# ============================================================
# CREATE / UPDATE INVESTMENT PROFILE
# ============================================================

@router.post("/profile")
async def create_or_update_profile(
    profile: InvestmentProfileCreate,
    current_user: dict = Depends(get_current_user),
):

    user_id = current_user["sub"]

    return await save_investment_profile(
        user_id,
        profile.model_dump(),
    )


# ============================================================
# GET INVESTMENT PROFILE
# ============================================================

@router.get("/profile")
async def fetch_profile(
    current_user: dict = Depends(get_current_user),
):

    user_id = current_user["sub"]

    return await get_investment_profile(
        user_id
    )


# ============================================================
# GET AI INVESTMENT RECOMMENDATION
# ============================================================

@router.get("/recommendation")
async def get_recommendation(
    current_user: dict = Depends(get_current_user),
):

    user_id = current_user["sub"]

    # ========================================================
    # 1. GET INVESTMENT PROFILE
    # ========================================================

    profile_response = await get_investment_profile(
        user_id
    )

    if not profile_response.get("success"):

        return {
            "success": False,
            "message": "Investment profile not found",
        }

    profile = profile_response["profile"]

    # ========================================================
    # 2. GET TRANSACTIONS
    # ========================================================

    transactions = await get_transactions(
        user_id
    )

    print("=================================")
    print("AI INVESTMENT RECOMMENDATION")
    print("USER ID:", user_id)
    print(
        "TRANSACTION COUNT:",
        len(transactions),
    )
    print(
        "TRANSACTIONS:",
        transactions,
    )
    print("=================================")

    # ========================================================
    # 3. CALCULATE REVENUE / EXPENSE
    # ========================================================

    revenue = 0.0
    expense = 0.0

    for transaction in transactions:

        try:

            amount = float(
                transaction["amount"]
            )

        except (
            ValueError,
            TypeError,
        ):

            continue

        if transaction["is_income"]:

            revenue += amount

        else:

            expense += amount

    # ========================================================
    # 4. CALCULATE PROFIT
    # ========================================================

    profit = revenue - expense

    # ========================================================
    # 5. CALCULATE RESERVE
    # ========================================================

    if profit > 0:

        reserve_amount = profit * 0.50

        investable_surplus = (
            profit - reserve_amount
        )

    else:

        reserve_amount = 0.0

        investable_surplus = 0.0

    # ========================================================
    # DEBUG
    # ========================================================

    print("=================================")
    print("FINANCIAL CALCULATION")
    print("REVENUE:", revenue)
    print("EXPENSE:", expense)
    print("PROFIT:", profit)
    print(
        "RESERVE:",
        reserve_amount,
    )
    print(
        "INVESTABLE SURPLUS:",
        investable_surplus,
    )
    print("=================================")

    # ========================================================
    # 6. ASK AI FOR RECOMMENDATION
    # ========================================================

    try:

        ai_recommendation = (
            generate_ai_recommendation(

                revenue=revenue,

                expense=expense,

                profit=profit,

                risk_tolerance=
                    profile["risk_tolerance"],

                investment_horizon=
                    profile["investment_horizon"],

                investment_goal=
                    profile["investment_goal"],

                investable_surplus=
                    investable_surplus,

                reserve_amount=
                    reserve_amount,
            )
        )

    except Exception as e:

        print(
            "AI RECOMMENDATION ERROR:",
            str(e),
        )

        return {
            "success": False,
            "message": (
                "Unable to generate AI "
                "recommendation"
            ),
            "error": str(e),
        }

    # ========================================================
    # 7. FINAL RESPONSE
    # ========================================================

    return {

        "success": True,

        "financials": {

            "revenue": round(
                revenue,
                2,
            ),

            "expense": round(
                expense,
                2,
            ),

            "profit": round(
                profit,
                2,
            ),

            "reserve_amount": round(
                reserve_amount,
                2,
            ),

            "investable_surplus": round(
                investable_surplus,
                2,
            ),
        },

        "profile": profile,

        "recommendation":
            ai_recommendation,
    }
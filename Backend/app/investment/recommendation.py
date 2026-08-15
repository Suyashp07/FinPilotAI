def generate_recommendation(
    revenue: float,
    expense: float,
    profit: float,
    risk_tolerance: str,
    investment_horizon: str,
    investment_goal: str,
):
    """
    Generate a personalized investment recommendation
    using financial performance, risk tolerance,
    investment horizon and investment goal.
    """

    # ============================================================
    # NORMALIZE INPUTS
    # ============================================================

    risk = risk_tolerance.strip().lower()
    horizon = investment_horizon.strip().lower()
    goal = investment_goal.strip().lower()

    # ============================================================
    # FINANCIAL HEALTH METRICS
    # ============================================================

    if revenue > 0:
        expense_ratio = (expense / revenue) * 100
        profit_margin = (profit / revenue) * 100
    else:
        expense_ratio = 0
        profit_margin = 0

    # ============================================================
    # FINANCIAL HEALTH SCORE
    # ============================================================

    health_score = 0

    # Profitability
    if profit > 0:
        health_score += 40

    # Expense management
    if revenue > 0:

        if expense_ratio <= 30:
            health_score += 30

        elif expense_ratio <= 50:
            health_score += 20

        elif expense_ratio <= 70:
            health_score += 10

    # Profit margin
    if profit_margin >= 30:
        health_score += 20

    elif profit_margin >= 15:
        health_score += 15

    elif profit_margin > 0:
        health_score += 10

    # Investment capacity
    if profit > 0:
        health_score += 10

    health_score = max(
        0,
        min(health_score, 100),
    )

    # ============================================================
    # FINANCIAL HEALTH STATUS
    # ============================================================

    if health_score >= 80:
        health_status = "Excellent"

    elif health_score >= 60:
        health_status = "Healthy"

    elif health_score >= 40:
        health_status = "Moderate"

    else:
        health_status = "Needs Improvement"

    # ============================================================
    # LOSS / NO PROFIT SAFETY CHECK
    # ============================================================

    if profit <= 0:

        return {
            "recommendation": (
                "Focus on improving business profitability "
                "before making new investments."
            ),

            "risk_level": "Low",

            "suggested_allocation": 0,

            "allocation_percentage": 0,

            "reserve_amount": 0,

            "investable_surplus": 0,

            "reason": (
                f"Your revenue is ₹{revenue:.2f}, while your "
                f"expenses are ₹{expense:.2f}, resulting in a "
                f"loss of ₹{abs(profit):.2f}."
            ),

            "financial_health": {
                "score": health_score,
                "status": health_status,
                "profit_margin": round(
                    profit_margin,
                    2,
                ),
                "expense_ratio": round(
                    expense_ratio,
                    2,
                ),
            },

            "strategy": {
                "name": "Financial Recovery",
                "description": (
                    "Focus on improving profitability and "
                    "maintaining liquidity before making new "
                    "investments."
                ),
            },

            "allocation": {
                "low_risk": 0,
                "moderate_risk": 0,
                "high_risk": 0,
            },
        }

    # ============================================================
    # BUSINESS RESERVE
    # ============================================================

    reserve = profit * 0.50

    investable_surplus = profit - reserve

    # ============================================================
    # BASE ALLOCATION
    # ============================================================

    if risk == "conservative":

        allocation_percentage = 20

    elif risk == "moderate":

        allocation_percentage = 40

    elif risk == "aggressive":

        allocation_percentage = 60

    else:

        allocation_percentage = 30

    # ============================================================
    # HORIZON ADJUSTMENT
    # ============================================================

    if horizon == "less than 1 year":

        allocation_percentage -= 20

    elif horizon == "1 - 3 years":

        allocation_percentage -= 10

    elif horizon == "3 - 5 years":

        allocation_percentage += 0

    elif horizon == "5+ years":

        allocation_percentage += 10

    # ============================================================
    # GOAL ADJUSTMENT
    # ============================================================

    if goal == "capital preservation":

        allocation_percentage -= 10

    elif goal == "business expansion":

        allocation_percentage -= 10

    elif goal == "wealth creation":

        allocation_percentage += 10

    elif goal == "emergency reserve":

        allocation_percentage -= 20

    # ============================================================
    # FINANCIAL HEALTH ADJUSTMENT
    # ============================================================

    if health_score < 40:

        allocation_percentage -= 20

    elif health_score < 60:

        allocation_percentage -= 10

    # ============================================================
    # KEEP ALLOCATION WITHIN SAFE RANGE
    # ============================================================

    allocation_percentage = max(
        0,
        min(allocation_percentage, 70),
    )

    # ============================================================
    # SUGGESTED INVESTMENT AMOUNT
    # ============================================================

    suggested_amount = (
        investable_surplus
        * allocation_percentage
        / 100
    )

    # ============================================================
    # INVESTMENT STRATEGY
    # ============================================================

    if goal == "emergency reserve":

        strategy_name = "Liquidity First"

        strategy_description = (
            "Prioritize liquid funds and emergency savings "
            "before increasing investment exposure."
        )

    elif goal == "business expansion":

        strategy_name = "Business Reinvestment"

        strategy_description = (
            "Prioritize strengthening and expanding the "
            "business while maintaining sufficient operating "
            "liquidity."
        )

    elif goal == "capital preservation":

        strategy_name = "Capital Preservation"

        strategy_description = (
            "Focus on protecting capital and maintaining "
            "liquidity with limited exposure to high-risk assets."
        )

    elif (
        risk == "aggressive"
        and horizon == "5+ years"
        and goal == "wealth creation"
    ):

        strategy_name = "Growth Focused"

        strategy_description = (
            "Focus on long-term growth while accepting higher "
            "market volatility."
        )

    elif (
        risk == "moderate"
        and horizon in [
            "3 - 5 years",
            "5+ years",
        ]
    ):

        strategy_name = "Balanced Growth"

        strategy_description = (
            "Balance growth opportunities with moderate risk "
            "and maintain adequate financial reserves."
        )

    else:

        strategy_name = "Conservative Growth"

        strategy_description = (
            "Focus on gradual growth while maintaining "
            "financial stability and liquidity."
        )

    # ============================================================
    # INVESTMENT ALLOCATION BREAKDOWN
    # ============================================================

    if strategy_name == "Liquidity First":

        low_risk = 70
        moderate_risk = 20
        high_risk = 10

    elif strategy_name == "Business Reinvestment":

        low_risk = 40
        moderate_risk = 40
        high_risk = 20

    elif strategy_name == "Capital Preservation":

        low_risk = 70
        moderate_risk = 25
        high_risk = 5

    elif strategy_name == "Growth Focused":

        low_risk = 20
        moderate_risk = 30
        high_risk = 50

    elif strategy_name == "Balanced Growth":

        low_risk = 30
        moderate_risk = 50
        high_risk = 20

    else:

        low_risk = 50
        moderate_risk = 40
        high_risk = 10

    # ============================================================
    # RECOMMENDATION TEXT
    # ============================================================

    if goal == "business expansion":

        recommendation = (
            "Prioritize business expansion while maintaining "
            "a strong operating reserve. Invest only the portion "
            "of surplus capital that is not required for near-term "
            "business needs."
        )

    elif goal == "emergency reserve":

        recommendation = (
            "Prioritize building an emergency reserve before "
            "increasing investment exposure. Maintain sufficient "
            "liquid funds to handle unexpected business expenses."
        )

    elif goal == "capital preservation":

        recommendation = (
            "Focus on preserving capital and maintaining liquidity. "
            "Consider lower-risk investments and avoid excessive "
            "exposure to volatile assets."
        )

    elif goal == "wealth creation":

        recommendation = (
            "Focus on long-term wealth creation by investing a "
            "portion of your surplus while maintaining an adequate "
            "business reserve."
        )

    else:

        recommendation = (
            "Consider allocating a portion of your surplus toward "
            "investments while maintaining adequate business liquidity."
        )

    # ============================================================
    # REASON
    # ============================================================

    reason = (
        f"Based on revenue of ₹{revenue:.2f}, expenses of "
        f"₹{expense:.2f}, and profit of ₹{profit:.2f}. "
        f"Your {risk_tolerance} risk tolerance, "
        f"{investment_horizon} investment horizon, and "
        f"{investment_goal} goal were considered when calculating "
        f"the suggested allocation."
    )

    # ============================================================
    # FINAL RESPONSE
    # ============================================================

    return {

        "recommendation": recommendation,

        "risk_level": risk_tolerance,

        "suggested_allocation": round(
            suggested_amount,
            2,
        ),

        "allocation_percentage":
            allocation_percentage,

        "reserve_amount": round(
            reserve,
            2,
        ),

        "investable_surplus": round(
            investable_surplus,
            2,
        ),

        "reason": reason,

        # ========================================================
        # FINANCIAL HEALTH
        # ========================================================

        "financial_health": {

            "score": health_score,

            "status": health_status,

            "profit_margin": round(
                profit_margin,
                2,
            ),

            "expense_ratio": round(
                expense_ratio,
                2,
            ),
        },

        # ========================================================
        # INVESTMENT STRATEGY
        # ========================================================

        "strategy": {

            "name": strategy_name,

            "description": strategy_description,
        },

        # ========================================================
        # ALLOCATION BREAKDOWN
        # ========================================================

        "allocation": {

            "low_risk": low_risk,

            "moderate_risk": moderate_risk,

            "high_risk": high_risk,
        },
    }
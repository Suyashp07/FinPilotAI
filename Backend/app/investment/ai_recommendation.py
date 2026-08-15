import os

from google import genai
from google.genai import types


# ============================================================
# GEMINI CLIENT
# ============================================================

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise RuntimeError(
        "GEMINI_API_KEY is not configured"
    )

client = genai.Client(
    api_key=api_key
)


# ============================================================
# GENERATE AI RECOMMENDATION
# ============================================================

def generate_ai_recommendation(
    revenue: float,
    expense: float,
    profit: float,
    risk_tolerance: str,
    investment_horizon: str,
    investment_goal: str,
    investable_surplus: float,
    reserve_amount: float,
):
    """
    Generate an AI-powered investment recommendation
    using Gemini.

    FinPilot calculates the financial numbers.
    Gemini interprets those numbers and generates
    personalized investment guidance.
    """

    # ========================================================
    # NEGATIVE / ZERO PROFIT
    # ========================================================

    if profit <= 0:

        return {
            "summary": (
                "Your current financial position "
                "does not support new investments."
            ),

            "recommended_action": (
                "Focus on improving profitability "
                "and maintaining sufficient cash "
                "reserves before investing."
            ),

            "investments": [],

            "why_this_recommendation": (
                "Your expenses are equal to or greater "
                "than your current revenue."
            ),

            "disclaimer": (
                "This is general financial guidance "
                "and not personalized financial advice."
            ),
        }

    # ========================================================
    # PROMPT
    # ========================================================

    prompt = f"""
You are FinPilot AI, a financial guidance assistant
for small business owners.

Analyze the following VERIFIED financial information.

FINANCIAL INFORMATION

Revenue:
₹{revenue:.2f}

Expenses:
₹{expense:.2f}

Profit:
₹{profit:.2f}

Business reserve:
₹{reserve_amount:.2f}

Investable surplus:
₹{investable_surplus:.2f}


INVESTMENT PROFILE

Risk tolerance:
{risk_tolerance}

Investment horizon:
{investment_horizon}

Investment goal:
{investment_goal}


YOUR TASK

Create a simple and useful investment recommendation.

The user wants to know:

"Where should I consider investing my available surplus?"

Recommend investment CATEGORIES rather than specific
stocks, companies or specific financial products.

Possible categories include:

- Diversified mutual funds
- Equity-oriented investments
- Fixed income
- Fixed deposits
- Government securities
- Liquid investments
- Emergency reserve

Choose categories based on the user's financial situation
and profile.

IMPORTANT RULES:

1. Do not guarantee returns.

2. Do not promise profits.

3. Do not recommend specific stocks.

4. Do not invent financial information.

5. Consider the user's risk tolerance.

6. Consider the investment horizon.

7. Consider the investment goal.

8. Consider the current profit and investable surplus.

9. The total allocation percentage must equal 100.

10. The total recommended investment amounts must not
    exceed ₹{investable_surplus:.2f}.

11. Keep explanations simple and understandable.

12. Give practical recommendations rather than generic
    financial education.

13. The recommendation should clearly tell the user
    what categories they can consider.

14. If the user has a short investment horizon, avoid
    recommending unnecessarily high-risk categories.

15. Maintain the business reserve and do not recommend
    investing the reserve amount.

Return only the requested structured JSON.
"""

    # ========================================================
    # GEMINI REQUEST
    # ========================================================

    response = client.models.generate_content(

        model="gemini-3.5-flash",

        contents=prompt,

        config=types.GenerateContentConfig(

            response_mime_type="application/json",

            response_schema={

                "type": "object",

                "properties": {

                    "summary": {
                        "type": "string",
                    },

                    "recommended_action": {
                        "type": "string",
                    },

                    "investments": {

                        "type": "array",

                        "items": {

                            "type": "object",

                            "properties": {

                                "name": {
                                    "type": "string",
                                },

                                "risk": {
                                    "type": "string",
                                },

                                "percentage": {
                                    "type": "number",
                                },

                                "amount": {
                                    "type": "number",
                                },

                                "reason": {
                                    "type": "string",
                                },
                            },

                            "required": [
                                "name",
                                "risk",
                                "percentage",
                                "amount",
                                "reason",
                            ],
                        },
                    },

                    "why_this_recommendation": {
                        "type": "string",
                    },

                    "disclaimer": {
                        "type": "string",
                    },
                },

                "required": [
                    "summary",
                    "recommended_action",
                    "investments",
                    "why_this_recommendation",
                    "disclaimer",
                ],
            },
        ),
    )

    # ========================================================
    # PARSE RESPONSE
    # ========================================================

    if not response.text:

        raise RuntimeError(
            "Gemini returned an empty response"
        )

    import json

    try:

        result = json.loads(
            response.text
        )

    except json.JSONDecodeError as e:

        raise RuntimeError(
            f"Invalid Gemini JSON response: {e}"
        )

    return result
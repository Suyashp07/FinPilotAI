from app.database import database


async def save_investment_profile(
    user_id: str,
    profile_data: dict,
):
    profiles = database["investment_profiles"]

    existing_profile = await profiles.find_one({
        "user_id": user_id
    })

    profile = {
        "user_id": user_id,
        "risk_tolerance": profile_data["risk_tolerance"],
        "investment_horizon": profile_data["investment_horizon"],
        "investment_goal": profile_data["investment_goal"],
    }

    if existing_profile:

        await profiles.update_one(
            {
                "user_id": user_id
            },
            {
                "$set": profile
            },
        )

        return {
            "success": True,
            "message": "Investment profile updated",
        }

    await profiles.insert_one(profile)

    return {
        "success": True,
        "message": "Investment profile created",
    }


async def get_investment_profile(
    user_id: str,
):
    profiles = database["investment_profiles"]

    profile = await profiles.find_one({
        "user_id": user_id
    })

    if not profile:
        return {
            "success": False,
            "message": "Investment profile not found",
        }

    return {
        "success": True,
        "profile": {
            "risk_tolerance": profile["risk_tolerance"],
            "investment_horizon": profile["investment_horizon"],
            "investment_goal": profile["investment_goal"],
        },
    }
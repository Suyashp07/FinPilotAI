from app.database import database
from app.auth.utils import (
    hash_password,
    verify_password,
    create_access_token,
)
from app.auth.otp_service import create_and_send_otp
from bson import ObjectId


async def register_user(
    name: str,
    email: str,
    password: str,
):

    users = database["users"]

    # Check if email already exists
    existing_user = await users.find_one({
        "email": email
    })

    if existing_user:
        return {
            "success": False,
            "message": "Email already registered",
        }

    # Send OTP before creating the actual user
    await create_and_send_otp(email)

    # Store registration data temporarily
    pending_users = database["pending_users"]

    # Remove old pending registration
    await pending_users.delete_many({
        "email": email
    })

    await pending_users.insert_one({
        "name": name,
        "email": email,
        "password": hash_password(password),
    })

    return {
        "success": True,
        "message": "OTP sent to your email",
        "email": email,
    }


async def verify_registration(
    email: str,
):

    pending_users = database["pending_users"]
    users = database["users"]

    pending_user = await pending_users.find_one({
        "email": email
    })

    if not pending_user:
        return {
            "success": False,
            "message": "Registration request not found",
        }

    # Check again that user doesn't already exist
    existing_user = await users.find_one({
        "email": email
    })

    if existing_user:
        await pending_users.delete_one({
            "_id": pending_user["_id"]
        })

        return {
            "success": False,
            "message": "Email already registered",
        }

    user = {
        "name": pending_user["name"],
        "email": pending_user["email"],
        "password": pending_user["password"],
    }

    result = await users.insert_one(user)

    # Delete temporary registration
    await pending_users.delete_one({
        "_id": pending_user["_id"]
    })

    return {
        "success": True,
        "message": "User created successfully",
        "user_id": str(result.inserted_id),
    }


async def login_user(
    email: str,
    password: str,
):

    users = database["users"]

    user = await users.find_one({
        "email": email
    })

    if not user:
        return {
            "success": False,
            "message": "Invalid email or password",
        }

    if not verify_password(
        password,
        user["password"],
    ):
        return {
            "success": False,
            "message": "Invalid email or password",
        }

    token = create_access_token({
        "sub": str(user["_id"]),
        "email": user["email"],
    })

    return {
        "success": True,
        "access_token": token,
        "token_type": "bearer",
    }


async def get_user_by_id(
    user_id: str,
):

    users = database["users"]

    user = await users.find_one({
        "_id": ObjectId(user_id)
    })

    if not user:
        return None

    return {
        "id": str(user["_id"]),
        "name": user["name"],
        "email": user["email"],
    }
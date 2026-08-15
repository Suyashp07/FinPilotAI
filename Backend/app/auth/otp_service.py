import random
from datetime import datetime, timedelta, timezone

from app.database import database
from app.auth.email_service import send_otp_email


OTP_EXPIRY_MINUTES = 5


def generate_otp() -> str:
    return str(random.randint(100000, 999999))


async def create_and_send_otp(email: str):

    otp = generate_otp()

    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=OTP_EXPIRY_MINUTES
    )

    otp_collection = database["email_otps"]

    # Remove old OTPs for this email
    await otp_collection.delete_many({
        "email": email
    })

    # Store new OTP
    await otp_collection.insert_one({
        "email": email,
        "otp": otp,
        "expires_at": expires_at,
        "verified": False,
    })

    # Send email
    await send_otp_email(
        recipient_email=email,
        otp=otp,
    )

    return {
        "success": True,
        "message": "OTP sent successfully",
    }


async def verify_otp(
    email: str,
    otp: str,
):

    otp_collection = database["email_otps"]

    otp_record = await otp_collection.find_one({
        "email": email,
        "otp": otp,
        "verified": False,
    })

    if not otp_record:
        return {
            "success": False,
            "message": "Invalid OTP",
        }

    expires_at = otp_record["expires_at"]

    # Handle timezone-naive MongoDB datetime
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(
            tzinfo=timezone.utc
        )

    if datetime.now(timezone.utc) > expires_at:

        await otp_collection.delete_one({
            "_id": otp_record["_id"]
        })

        return {
            "success": False,
            "message": "OTP has expired",
        }

    await otp_collection.update_one(
        {
            "_id": otp_record["_id"]
        },
        {
            "$set": {
                "verified": True
            }
        },
    )

    return {
        "success": True,
        "message": "Email verified successfully",
    }
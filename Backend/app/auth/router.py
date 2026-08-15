from fastapi import APIRouter, Depends, HTTPException

from app.auth.schema import (
    LoginRequest,
    RegisterRequest,
    VerifyOTPRequest,
    ResendOTPRequest,
)

from app.auth.service import (
    login_user,
    register_user,
    verify_registration,
    get_user_by_id,
)

from app.auth.otp_service import (
    verify_otp,
    create_and_send_otp,
)

from app.auth.dependencies import get_current_user


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


# ============================================================
# REGISTER
# ============================================================

@router.post("/register")
async def register(
    request: RegisterRequest,
):
    return await register_user(
        request.name,
        request.email,
        request.password,
    )


# ============================================================
# VERIFY OTP
# ============================================================

@router.post("/verify-otp")
async def verify_registration_otp(
    request: VerifyOTPRequest,
):

    result = await verify_otp(
        request.email,
        request.otp,
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["message"],
        )

    return await verify_registration(
        request.email,
    )


# ============================================================
# RESEND OTP
# ============================================================

@router.post("/resend-otp")
async def resend_otp(
    request: ResendOTPRequest,
):

    result = await create_and_send_otp(
        request.email,
    )

    return result


# ============================================================
# LOGIN
# ============================================================

@router.post("/login")
async def login(
    request: LoginRequest,
):
    return await login_user(
        request.email,
        request.password,
    )


# ============================================================
# CURRENT USER
# ============================================================

@router.get("/me")
async def get_me(
    current_user=Depends(get_current_user),
):

    user = await get_user_by_id(
        current_user["sub"]
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    return {
        "success": True,
        "user": user,
    }
from fastapi import APIRouter, Depends, status

from app.auth.dependencies import get_current_user

from app.transactions.schema import TransactionCreate

from app.transactions.service import (
    create_transaction,
    get_transactions,
    update_transaction,
    delete_transaction,
)


router = APIRouter(
    prefix="/transactions",
    tags=["Transactions"],
)


# ============================================================
# CREATE
# ============================================================

@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
)
async def add_transaction(
    transaction: TransactionCreate,
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user["sub"]

    return await create_transaction(
        user_id,
        transaction.model_dump(),
    )


# ============================================================
# GET
# ============================================================

@router.get("")
async def fetch_transactions(
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user["sub"]

    transactions = await get_transactions(
        user_id
    )

    return {
        "success": True,
        "transactions": transactions,
    }


# ============================================================
# UPDATE
# ============================================================

@router.put("/{transaction_id}")
async def edit_transaction(
    transaction_id: str,
    transaction: TransactionCreate,
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user["sub"]

    return await update_transaction(
        user_id,
        transaction_id,
        transaction.model_dump(),
    )


# ============================================================
# DELETE
# ============================================================

@router.delete("/{transaction_id}")
async def remove_transaction(
    transaction_id: str,
    current_user: dict = Depends(get_current_user),
):
    user_id = current_user["sub"]

    return await delete_transaction(
        user_id,
        transaction_id,
    )
from app.database import database
from bson import ObjectId


# ============================================================
# CREATE TRANSACTION
# ============================================================

async def create_transaction(
    user_id: str,
    transaction_data: dict,
):
    transactions = database["transactions"]

    transaction = {
        "user_id": user_id,
        "title": transaction_data["title"],
        "amount": transaction_data["amount"],
        "is_income": transaction_data["is_income"],
        "category": transaction_data["category"],
        "description": transaction_data["description"],
        "date": transaction_data["date"],
    }

    result = await transactions.insert_one(transaction)

    return {
        "success": True,
        "message": "Transaction created successfully",
        "transaction_id": str(result.inserted_id),
    }


# ============================================================
# GET TRANSACTIONS
# ============================================================

async def get_transactions(user_id: str):
    transactions = database["transactions"]

    cursor = transactions.find({
        "user_id": user_id
    }).sort("date", -1)

    result = []

    async for transaction in cursor:
        result.append({
            "id": str(transaction["_id"]),
            "title": transaction["title"],
            "amount": transaction["amount"],
            "is_income": transaction["is_income"],
            "category": transaction["category"],
            "description": transaction["description"],
            "date": transaction["date"],
        })

    return result


# ============================================================
# UPDATE TRANSACTION
# ============================================================

async def update_transaction(
    user_id: str,
    transaction_id: str,
    transaction_data: dict,
):
    transactions = database["transactions"]

    result = await transactions.update_one(
        {
            "_id": ObjectId(transaction_id),
            "user_id": user_id,
        },
        {
            "$set": {
                "title": transaction_data["title"],
                "amount": transaction_data["amount"],
                "is_income": transaction_data["is_income"],
                "category": transaction_data["category"],
                "description": transaction_data["description"],
                "date": transaction_data["date"],
            }
        },
    )

    if result.matched_count == 0:
        return {
            "success": False,
            "message": "Transaction not found",
        }

    return {
        "success": True,
        "message": "Transaction updated successfully",
    }


# ============================================================
# DELETE TRANSACTION
# ============================================================

async def delete_transaction(
    user_id: str,
    transaction_id: str,
):
    transactions = database["transactions"]

    result = await transactions.delete_one({
        "_id": ObjectId(transaction_id),
        "user_id": user_id,
    })

    if result.deleted_count == 0:
        return {
            "success": False,
            "message": "Transaction not found",
        }

    return {
        "success": True,
        "message": "Transaction deleted successfully",
    }
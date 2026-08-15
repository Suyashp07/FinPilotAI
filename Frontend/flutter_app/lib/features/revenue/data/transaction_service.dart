import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/entities/transaction_model.dart';

class TransactionService {
  late final Dio dio;

  TransactionService() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env["API_BASE_URL"]!,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
  }

  // =========================
  // CREATE TRANSACTION
  // =========================

  Future<Response> createTransaction(
    TransactionModel transaction,
    String token,
  ) async {
    return await dio.post(
      "/transactions",
      data: {
        "title": transaction.title,
        "amount": transaction.amount,
        "is_income": transaction.isIncome,
        "category": transaction.category,
        "description": transaction.description,
        "date": transaction.date.toIso8601String(),
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // =========================
  // GET TRANSACTIONS
  // =========================

  Future<Response> getTransactions(String token) async {
    return await dio.get(
      "/transactions",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // =========================
  // DELETE TRANSACTION
  // =========================

  Future<Response> deleteTransaction(
    String id,
    String token,
  ) async {
    return await dio.delete(
      "/transactions/$id",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
  // =========================
// UPDATE TRANSACTION
// =========================

  Future<Response> updateTransaction(
    TransactionModel transaction,
    String token,
  ) async {
    return await dio.put(
      "/transactions/${transaction.id}",
      data: {
        "title": transaction.title,
        "amount": transaction.amount,
        "is_income": transaction.isIncome,
        "category": transaction.category,
        "description": transaction.description,
        "date": transaction.date.toIso8601String(),
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}
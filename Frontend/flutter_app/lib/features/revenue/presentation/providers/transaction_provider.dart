import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/transaction_service.dart';
import '../../domain/entities/transaction_model.dart';

class TransactionNotifier
    extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  final TransactionService _service = TransactionService();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  // =========================
  // LOAD TRANSACTIONS
  // =========================

  Future<void> loadTransactions() async {
    try {
      final token = await _storage.read(
        key: "token",
      );

      if (token == null || token.isEmpty) {
        return;
      }

      final response =
          await _service.getTransactions(token);

      final List transactions =
          response.data["transactions"];

      state = transactions
          .map(
            (json) => TransactionModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();

      print(
        "TRANSACTIONS LOADED: ${state.length}",
      );
    } catch (e) {
      print(
        "LOAD TRANSACTIONS ERROR: $e",
      );
    }
  }

  // =========================
  // ADD TRANSACTION
  // =========================

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final token = await _storage.read(
        key: "token",
      );

      if (token == null || token.isEmpty) {
        throw Exception(
          "Authentication token not found",
        );
      }

      final response =
          await _service.createTransaction(
        transaction,
        token,
      );

      print(
        "CREATE TRANSACTION RESPONSE: ${response.data}",
      );

      if (response.data["success"] == true) {
        await loadTransactions();
      }
    } catch (e) {
      print(
        "ADD TRANSACTION ERROR: $e",
      );

      rethrow;
    }
  }

  // =========================
  // DELETE TRANSACTION
  // =========================

  Future<void> deleteTransaction(
    String id,
  ) async {
    try {
      final token = await _storage.read(
        key: "token",
      );

      if (token == null || token.isEmpty) {
        throw Exception(
          "Authentication token not found",
        );
      }

      final response =
          await _service.deleteTransaction(
        id,
        token,
      );

      if (response.data["success"] == true) {
        state = state
            .where((item) => item.id != id)
            .toList();
      }
    } catch (e) {
      print(
        "DELETE TRANSACTION ERROR: $e",
      );
    }
  }

  // =========================
// UPDATE TRANSACTION
// =========================

Future<void> updateTransaction(
  TransactionModel transaction,
) async {
  try {
    final token = await _storage.read(
      key: "token",
    );

    if (token == null || token.isEmpty) {
      throw Exception(
        "Authentication token not found",
      );
    }

    final response =
        await _service.updateTransaction(
      transaction,
      token,
    );

    print(
      "UPDATE TRANSACTION RESPONSE: ${response.data}",
    );

    if (response.data["success"] == true) {
      await loadTransactions();
    }
  } catch (e) {
    print(
      "UPDATE TRANSACTION ERROR: $e",
    );

    rethrow;
  }
}

  // =========================
  // TOTAL REVENUE
  // =========================

  double get totalRevenue => state
      .where((t) => t.isIncome)
      .fold(
        0.0,
        (sum, t) => sum + t.amount,
      );

  // =========================
  // TOTAL EXPENSE
  // =========================

  double get totalExpense => state
      .where((t) => !t.isIncome)
      .fold(
        0.0,
        (sum, t) => sum + t.amount,
      );

  // =========================
  // TOTAL PROFIT
  // =========================

  double get totalProfit =>
      totalRevenue - totalExpense;
}

final transactionProvider =
    StateNotifierProvider<
      TransactionNotifier,
      List<TransactionModel>
    >(
      (ref) => TransactionNotifier(),
    );
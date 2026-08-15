import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';

final totalRevenueProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalProfitProvider = Provider<double>((ref) {
  final revenue = ref.watch(totalRevenueProvider);
  final expense = ref.watch(totalExpenseProvider);

  return revenue - expense;
});
final cashBalanceProvider = Provider<double>((ref) {
  return ref.watch(totalProfitProvider);
});
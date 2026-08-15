import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';

final revenueChartProvider = Provider<List<FlSpot>>((ref) {
  final transactions = ref.watch(transactionProvider);

  final List<double> weeklyRevenue = List.filled(7, 0);

  for (final transaction in transactions) {
    if (!transaction.isIncome) continue;

    // Monday = 1, Sunday = 7
    final dayIndex = transaction.date.weekday - 1;

    weeklyRevenue[dayIndex] += transaction.amount;
  }

  return List.generate(
    7,
    (index) => FlSpot(
      index.toDouble(),
      weeklyRevenue[index],
    ),
  );
});
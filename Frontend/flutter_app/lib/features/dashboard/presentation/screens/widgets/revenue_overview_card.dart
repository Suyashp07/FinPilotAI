import 'package:flutter/material.dart';
import 'package:flutter_app/features/revenue/presentation/screens/revenue_screen.dart';

class RevenueOverviewCard extends StatelessWidget {
  final double revenue;
  final double expense;
  final double profit;
  final double growth;

  const RevenueOverviewCard({
    super.key,
    required this.revenue,
    required this.expense,
    required this.profit,
    required this.growth,
  });

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(1)}Cr";
    }

    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    }

    if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(1)}K";
    }

    return "₹${amount.toStringAsFixed(0)}";
  }

  void _openRevenue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RevenueScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: () => _openRevenue(context),

        child: Ink(
          width: double.infinity,

          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],

            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Revenue Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          "Your financial performance",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // MAIN REVENUE
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(revenue),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.green,
                          size: 14,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          "${growth.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                "Total Revenue",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                height: 1,
                color: Colors.grey.shade200,
              ),

              const SizedBox(height: 18),

              // METRICS
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      title: "Revenue",
                      value: _formatAmount(revenue),
                      icon: Icons.arrow_downward_rounded,
                      color: Colors.blue,
                    ),
                  ),

                  Expanded(
                    child: _Metric(
                      title: "Expense",
                      value: _formatAmount(expense),
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.red,
                    ),
                  ),

                  Expanded(
                    child: _Metric(
                      title: "Profit",
                      value: _formatAmount(profit),
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Open Revenue Management",
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 5),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Color(0xFF1976D2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _Metric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),

            const SizedBox(width: 5),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
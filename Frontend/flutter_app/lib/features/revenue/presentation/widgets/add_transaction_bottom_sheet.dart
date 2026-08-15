import 'package:flutter/material.dart';
import 'package:flutter_app/features/revenue/presentation/screens/add_expense_screen.dart';
import 'package:flutter_app/features/revenue/presentation/screens/add_revenue_screen.dart';

class AddTransactionBottomSheet extends StatelessWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Add New Transaction",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                ),
              ),
              title: const Text("Add Revenue"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRevenueScreen(),
                  ),
                );// Navigate to Add Revenue Screen
              },
            ),

            const Divider(),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.trending_down,
                  color: Colors.white,
                ),
              ),
              title: const Text("Add Expense"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
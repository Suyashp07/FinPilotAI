import 'package:flutter/material.dart';
import 'package:flutter_app/features/revenue/domain/entities/transaction_model.dart';
import 'package:flutter_app/features/revenue/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_transaction_bottom_sheet.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome
              ? Colors.green.shade100
              : Colors.red.shade100,

          child: Icon(
            transaction.isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,

            color: transaction.isIncome
                ? Colors.green
                : Colors.red,
          ),
        ),

        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.category,
            ),

            Text(
              "${transaction.date.day}/"
              "${transaction.date.month}/"
              "${transaction.date.year}",
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${transaction.isIncome ? '+' : '-'}"
              "₹${transaction.amount.toStringAsFixed(0)}",

              style: TextStyle(
                color: transaction.isIncome
                    ? Colors.green
                    : Colors.red,

                fontWeight: FontWeight.bold,
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "delete") {
                  await _deleteTransaction(
                    context,
                    ref,
                  );
                }

                if (value == "edit") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => EditTransactionBottomSheet(
                      transaction: transaction,
                    ),
                  );
                }
              },

              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 10),
                      Text("Edit"),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Transaction?",
          ),

          content: const Text(
            "This transaction will be permanently deleted.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref
        .read(transactionProvider.notifier)
        .deleteTransaction(
          transaction.id,
        );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Transaction deleted",
        ),
      ),
    );
  }
}
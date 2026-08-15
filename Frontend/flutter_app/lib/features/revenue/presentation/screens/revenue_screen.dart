import 'package:flutter/material.dart';
import 'package:flutter_app/features/revenue/presentation/providers/summary_provider.dart';
import 'package:flutter_app/features/revenue/presentation/widgets/transaction_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/features/revenue/presentation/providers/transaction_provider.dart';
import 'package:flutter_app/features/revenue/presentation/widgets/add_transaction_bottom_sheet.dart';
import 'package:flutter_app/features/revenue/presentation/widgets/revenue_chart.dart';
import 'package:flutter_app/features/revenue/presentation/widgets/summary_card.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() =>
      _RevenueScreenState();
}

class _RevenueScreenState
    extends ConsumerState<RevenueScreen> {

  // ==========================================================
  // FILTER STATE
  // ==========================================================

  String selectedType = "All";

  String selectedCategory = "All Categories";

  String selectedDateRange = "All Time";


  // ==========================================================
  // CATEGORIES
  // ==========================================================

  final List<String> categories = [
    "All Categories",

    // Revenue
    "Product Sales",
    "Client Payment",
    "Investment",
    "Subscription",

    // Expense
    "Office Rent",
    "Salary",
    "Electricity",
    "Travel",
    "Marketing",

    "Other",
  ];


  // ==========================================================
  // DATE FILTER
  // ==========================================================

  bool _isDateInRange(DateTime date) {

    final now = DateTime.now();

    if (selectedDateRange == "All Time") {
      return true;
    }

    if (selectedDateRange == "This Month") {
      return date.year == now.year &&
          date.month == now.month;
    }

    if (selectedDateRange == "Last Month") {

      final lastMonth =
          DateTime(now.year, now.month - 1);

      return date.year == lastMonth.year &&
          date.month == lastMonth.month;
    }

    return true;
  }


  // ==========================================================
  // FILTER TRANSACTIONS
  // ==========================================================

  List<dynamic> _getFilteredTransactions(
    List transactions,
  ) {

    return transactions.where((transaction) {

      // ------------------------------------------------------
      // TYPE FILTER
      // ------------------------------------------------------

      if (selectedType == "Revenue" &&
          !transaction.isIncome) {
        return false;
      }

      if (selectedType == "Expense" &&
          transaction.isIncome) {
        return false;
      }


      // ------------------------------------------------------
      // CATEGORY FILTER
      // ------------------------------------------------------

      if (selectedCategory != "All Categories" &&
          transaction.category != selectedCategory) {
        return false;
      }


      // ------------------------------------------------------
      // DATE FILTER
      // ------------------------------------------------------

      if (!_isDateInRange(transaction.date)) {
        return false;
      }


      return true;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {

    // ========================================================
    // ORIGINAL DATA
    // ========================================================

    final transactions =
        ref.watch(transactionProvider);

    final revenue =
        ref.watch(totalRevenueProvider);

    final expense =
        ref.watch(totalExpenseProvider);

    final profit =
        ref.watch(totalProfitProvider);

    final cash =
        ref.watch(cashBalanceProvider);


    // ========================================================
    // FILTERED DATA
    // ========================================================

    final filteredTransactions =
        _getFilteredTransactions(
      transactions,
    );


    return Scaffold(

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: const Text(
          "Revenue Management",
        ),
      ),


      // ======================================================
      // BODY
      // ======================================================

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ==================================================
          // SUMMARY ROW 1
          // ==================================================

          Row(
            children: [

              Expanded(
                child: SummaryCard(
                  title: "Revenue",
                  value:
                      "₹${revenue.toStringAsFixed(0)}",
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: SummaryCard(
                  title: "Expense",
                  value:
                      "₹${expense.toStringAsFixed(0)}",
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),


          const SizedBox(height: 16),


          // ==================================================
          // SUMMARY ROW 2
          // ==================================================

          Row(
            children: [

              Expanded(
                child: SummaryCard(
                  title: "Profit",
                  value:
                      "₹${profit.toStringAsFixed(0)}",
                  icon: Icons.savings,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: SummaryCard(
                  title: "Cash",
                  value:
                      "₹${cash.toStringAsFixed(0)}",
                  icon:
                      Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
              ),
            ],
          ),


          const SizedBox(height: 24),


          // ==================================================
          // CHART
          // ==================================================

          const RevenueChart(),


          const SizedBox(height: 24),


          // ==================================================
          // TRANSACTIONS HEADER
          // ==================================================

          const Text(
            "Transactions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),


          const SizedBox(height: 16),


          // ==================================================
          // TYPE FILTER
          // ==================================================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: Row(
              children: [

                _buildTypeFilter(
                  "All",
                ),

                const SizedBox(width: 8),

                _buildTypeFilter(
                  "Revenue",
                ),

                const SizedBox(width: 8),

                _buildTypeFilter(
                  "Expense",
                ),
              ],
            ),
          ),


          const SizedBox(height: 16),


          // ==================================================
          // CATEGORY + DATE FILTERS
          // ==================================================

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedDateRange,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Period",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "All Time",
                      child: Text("All Time"),
                    ),
                    DropdownMenuItem(
                      value: "This Month",
                      child: Text("This Month"),
                    ),
                    DropdownMenuItem(
                      value: "Last Month",
                      child: Text("Last Month"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedDateRange = value;
                    });
                  },
                ),
              ),
            ],
          ),


          const SizedBox(height: 20),


          // ==================================================
          // RESULT COUNT
          // ==================================================

          Text(
            "${filteredTransactions.length} transaction"
            "${filteredTransactions.length == 1 ? '' : 's'} found",

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),


          const SizedBox(height: 8),


          // ==================================================
          // NO TRANSACTIONS
          // ==================================================

          if (filteredTransactions.isEmpty)

            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),

                child: Column(
                  children: [

                    Icon(
                      Icons.receipt_long,
                      size: 50,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Text(
                      "No transactions found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),


          // ==================================================
          // TRANSACTION LIST
          // ==================================================

          ...filteredTransactions.map(
            (transaction) =>
                TransactionTile(
              transaction: transaction,
            ),
          ),


          const SizedBox(height: 100),
        ],
      ),


      // ======================================================
      // ADD TRANSACTION
      // ======================================================

      floatingActionButton:
          FloatingActionButton.extended(

        onPressed: () {

          showModalBottomSheet(
            context: context,

            isScrollControlled: true,

            shape:
                const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),

            builder: (_) =>
                const AddTransactionBottomSheet(),
          );
        },

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          "Transaction",
        ),
      ),
    );
  }


  // ==========================================================
  // TYPE FILTER BUTTON
  // ==========================================================

  Widget _buildTypeFilter(
    String type,
  ) {

    final selected =
        selectedType == type;

    return ChoiceChip(
      label: Text(type),

      selected: selected,

      onSelected: (_) {

        setState(() {
          selectedType = type;
        });
      },
    );
  }
}
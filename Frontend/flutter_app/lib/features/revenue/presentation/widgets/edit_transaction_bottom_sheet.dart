
import 'package:flutter/material.dart';
import 'package:flutter_app/features/revenue/domain/entities/transaction_model.dart';
import 'package:flutter_app/features/revenue/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTransactionBottomSheet extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<EditTransactionBottomSheet> createState() =>
      _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState
    extends ConsumerState<EditTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController amountController;
  late final TextEditingController descriptionController;

  late bool isIncome;
  late String selectedCategory;
  late DateTime selectedDate;

  final List<String> incomeCategories = [
    "Product Sales",
    "Client Payment",
    "Investment",
    "Subscription",
    "Other",
  ];

  final List<String> expenseCategories = [
    "Office Rent",
    "Salary",
    "Electricity",
    "Travel",
    "Marketing",
    "Other",
  ];

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );

    descriptionController = TextEditingController(
      text: widget.transaction.description,
    );

    isIncome = widget.transaction.isIncome;
    selectedCategory = widget.transaction.category;
    selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        isIncome ? incomeCategories : expenseCategories;

    // Make sure the existing category is available
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.last;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Transaction",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Income / Expense
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Revenue"),
                      selected: isIncome,
                      onSelected: (selected) {
                        if (!selected) return;

                        setState(() {
                          isIncome = true;
                          selectedCategory =
                              incomeCategories.first;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ChoiceChip(
                      label: const Text("Expense"),
                      selected: !isIncome,
                      onSelected: (selected) {
                        if (!selected) return;

                        setState(() {
                          isIncome = false;
                          selectedCategory =
                              expenseCategories.first;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter amount";
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Transaction Date",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    "${selectedDate.day}/"
                    "${selectedDate.month}/"
                    "${selectedDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _updateTransaction,
                  child: const Text(
                    "Update Transaction",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null) {
      return;
    }

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      title: selectedCategory,
      amount: amount,
      isIncome: isIncome,
      category: selectedCategory,
      description: descriptionController.text.trim(),
      date: selectedDate,
    );

    try {
      await ref
          .read(transactionProvider.notifier)
          .updateTransaction(updatedTransaction);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Transaction updated successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update transaction: $e",
          ),
        ),
      );
    }
  }
}
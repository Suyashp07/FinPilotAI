import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/revenue/presentation/providers/transaction_provider.dart';
import 'package:flutter_app/features/revenue/domain/entities/transaction_model.dart';

class AddRevenueScreen extends ConsumerStatefulWidget  {
  const AddRevenueScreen({super.key});

  @override
  ConsumerState<AddRevenueScreen> createState() =>
      _AddRevenueScreenState();

} 

class _AddRevenueScreenState extends ConsumerState<AddRevenueScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String? selectedCategory;

  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    "Product Sales",
    "Client Payment",
    "Investment",
    "Subscription",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Revenue"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
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
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Select category";
                  }
                  return null;
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

              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text:
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                decoration: const InputDecoration(
                  labelText: "Transaction Date",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  FocusScope.of(context).unfocus();

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
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final transaction = TransactionModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: selectedCategory ?? "Revenue",
                    amount: double.parse(amountController.text),
                    isIncome: true,
                    category: selectedCategory ?? "Other",
                    description: descriptionController.text,
                    date: selectedDate,
                  );

                  try {
                    await ref
                        .read(transactionProvider.notifier)
                        .addTransaction(transaction);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Failed to save revenue: $e",
                          ),
                        ),
                      );
                    }
                  }

                 if (!mounted) return;

if (Navigator.canPop(context)) {
  Navigator.pop(context);
}
                },
                  child: const Text(
                    "Save Revenue",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
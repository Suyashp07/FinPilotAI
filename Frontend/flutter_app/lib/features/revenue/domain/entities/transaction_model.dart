class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String description;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionModel(
      id: json["id"].toString(),
      title: json["title"] ?? "",
      amount: (json["amount"] as num).toDouble(),
      isIncome: json["is_income"] ?? false,
      category: json["category"] ?? "Other",
      description: json["description"] ?? "",
      date: DateTime.parse(json["date"]),
    );
  }
}
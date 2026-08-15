import 'package:flutter/material.dart';

class AIInvestmentCard extends StatelessWidget {
  final String recommendation;
  final String risk;
  final int confidence;

  const AIInvestmentCard({
    super.key,
    required this.recommendation,
    required this.risk,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: const [

                  Icon(
                    Icons.auto_awesome,
                    color: Colors.deepPurple,
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "AI Investment",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Recommended",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                recommendation,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Risk : $risk",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Confidence : $confidence%",
              ),

              const Spacer(),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("View"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
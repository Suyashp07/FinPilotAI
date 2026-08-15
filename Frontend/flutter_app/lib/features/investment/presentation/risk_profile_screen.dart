import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'data/investment_service.dart';

class RiskProfileScreen extends StatefulWidget {
  const RiskProfileScreen({super.key});

  @override
  State<RiskProfileScreen> createState() =>
      _RiskProfileScreenState();
}

class _RiskProfileScreenState
    extends State<RiskProfileScreen> {

  final InvestmentService _service =
      InvestmentService();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  String? selectedRisk;
  String? selectedHorizon;
  String? selectedGoal;

  bool isSaving = false;

  final List<String> riskOptions = [
    "Conservative",
    "Moderate",
    "Aggressive",
  ];

  final List<String> horizonOptions = [
    "Less than 1 year",
    "1-3 years",
    "3-5 years",
    "5+ years",
  ];

  final List<String> goalOptions = [
    "Business Expansion",
    "Wealth Creation",
    "Emergency Reserve",
    "Capital Preservation",
  ];

  Future<void> saveProfile() async {
    if (selectedRisk == null ||
        selectedHorizon == null ||
        selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete your investment profile",
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final token = await _storage.read(
        key: "token",
      );

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final response =
          await _service.saveInvestmentProfile(
        token: token,
        riskTolerance: selectedRisk!,
        investmentHorizon: selectedHorizon!,
        investmentGoal: selectedGoal!,
      );

      print(
        "PROFILE SAVE RESPONSE: ${response.data}",
      );

     if (response.data["success"] == true) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Investment profile saved successfully",
      ),
    ),
  );

  Navigator.pop(context, true);
}
    } catch (e) {
      print(
        "SAVE INVESTMENT PROFILE ERROR: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to save profile: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget buildOptionCard({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: selected
              ? Colors.blue
              : Colors.grey,
        ),
        title: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Investment Profile",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Understand your investment preferences",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "This information helps FinPilot AI "
              "provide investment recommendations "
              "suitable for your business.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Risk Tolerance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...riskOptions.map(
              (option) => buildOptionCard(
                title: option,
                selected:
                    selectedRisk == option,
                onTap: () {
                  setState(() {
                    selectedRisk = option;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Investment Horizon",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...horizonOptions.map(
              (option) => buildOptionCard(
                title: option,
                selected:
                    selectedHorizon == option,
                onTap: () {
                  setState(() {
                    selectedHorizon = option;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Primary Investment Goal",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...goalOptions.map(
              (option) => buildOptionCard(
                title: option,
                selected:
                    selectedGoal == option,
                onTap: () {
                  setState(() {
                    selectedGoal = option;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isSaving ? null : saveProfile,

                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Save Investment Profile",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
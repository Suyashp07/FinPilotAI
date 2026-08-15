import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/investment_service.dart';
import '../risk_profile_screen.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final InvestmentService _service = InvestmentService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = true;
  bool profileExists = false;
  String? errorMessage;

  Map<String, dynamic>? profile;
  Map<String, dynamic>? financials;
  Map<String, dynamic>? recommendation;

  @override
  void initState() {
    super.initState();
    loadInvestmentData();
  }

  Future<void> loadInvestmentData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final profileResponse = await _service.getProfile(token);
      final profileBody = _toMap(profileResponse.data);

      if (profileBody['success'] != true) {
        if (!mounted) return;
        setState(() {
          profileExists = false;
          profile = null;
          financials = null;
          recommendation = null;
          isLoading = false;
        });
        return;
      }

      final loadedProfile = _toMap(profileBody['profile']);

      if (!mounted) return;
      setState(() {
        profileExists = true;
        profile = loadedProfile;
      });

      final recommendationResponse =
          await _service.getRecommendation(token);

      final recommendationBody =
          _toMap(recommendationResponse.data);

      if (recommendationBody['success'] != true) {
        if (!mounted) return;
        setState(() {
          financials = null;
          recommendation = null;
          isLoading = false;
          errorMessage =
              recommendationBody['message']?.toString() ??
              'Unable to generate recommendation.';
        });
        return;
      }

      final loadedFinancials =
          _toMap(recommendationBody['financials']);

      final loadedRecommendation =
          _toMap(recommendationBody['recommendation']);

      if (!mounted) return;
      setState(() {
        financials = loadedFinancials;
        recommendation = loadedRecommendation;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  Future<void> openProfileSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RiskProfileScreen(),
      ),
    );

    if (result == true && mounted) {
      await loadInvestmentData();
    }
  }

  double getNumber(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String formatAmount(dynamic value) {
    return '₹${getNumber(value).toStringAsFixed(0)}';
  }

  double get revenue => getNumber(financials?['revenue']);

  double get expense => getNumber(financials?['expense']);

  double get profit =>
      getNumber(financials?['profit']);

  double get reserve =>
      getNumber(financials?['reserve_amount']);

  double get investableSurplus =>
      getNumber(financials?['investable_surplus']);

  double getProfitMargin() {
    if (revenue <= 0) return 0;
    return (profit / revenue) * 100;
  }

  double getExpenseRatio() {
    if (revenue <= 0) return 0;
    return (expense / revenue) * 100;
  }

  int getHealthScore() {
    if (revenue <= 0) return 0;
    if (profit <= 0) return 20;

    final profitMargin = (profit / revenue) * 100;
    final expenseRatio = (expense / revenue) * 100;

    double score = 50;
    score += profitMargin * 0.5;
    score -= expenseRatio * 0.2;

    return score.clamp(0, 100).round();
  }

  String getHealthStatus() {
    final score = getHealthScore();

    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Healthy';
    if (score >= 40) return 'Moderate';
    return 'Needs Improvement';
  }

  List<Map<String, dynamic>> getInvestments() {
    final raw = recommendation?['investments'];

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  double getRiskPercentage(String risk) {
    double total = 0;

    for (final investment in getInvestments()) {
      final investmentRisk =
          investment['risk']?.toString().toLowerCase();

      if (investmentRisk == risk.toLowerCase()) {
        total += getNumber(investment['percentage']);
      }
    }

    return total.clamp(0, 100);
  }

  String getOverallRisk() {
    final investments = getInvestments();

    if (investments.isEmpty) return '-';

    final low = getRiskPercentage('Low');
    final moderate = getRiskPercentage('Moderate');
    final high = getRiskPercentage('High');

    if (high >= moderate && high >= low) return 'High';
    if (moderate >= low) return 'Moderate';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Invest'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!profileExists) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Invest'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create your Investment Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tell FinPilot AI about your investment '
                  'preferences so we can provide suitable '
                  'investment recommendations.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: openProfileSetup,
                    child: const Text(
                      'Create Investment Profile',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final investments = getInvestments();
    final healthScore = getHealthScore();
    final healthStatus = getHealthStatus();

    final summary =
        recommendation?['summary']?.toString() ??
        'No recommendation available.';

    final recommendedAction =
        recommendation?['recommended_action']?.toString() ??
        'No recommended action available.';

    final whyRecommendation =
        recommendation?['why_this_recommendation']?.toString() ??
        'Financial information is being analyzed.';

    final disclaimer =
        recommendation?['disclaimer']?.toString() ??
        'This is general financial guidance and not personalized financial advice.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Invest'),
        actions: [
          IconButton(
            onPressed: openProfileSetup,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadInvestmentData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (errorMessage != null) ...[
              _errorCard(errorMessage!),
              const SizedBox(height: 16),
            ],

            const Text(
              'Your Investment Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileRow(
                      'Risk',
                      profile?['risk_tolerance'],
                    ),
                    const SizedBox(height: 8),
                    _profileRow(
                      'Horizon',
                      profile?['investment_horizon'],
                    ),
                    const SizedBox(height: 8),
                    _profileRow(
                      'Goal',
                      profile?['investment_goal'],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Financial Snapshot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _financialCard(
                    'Revenue',
                    formatAmount(revenue),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financialCard(
                    'Expense',
                    formatAmount(expense),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _financialCard(
                    'Profit',
                    formatAmount(profit),
                    Icons.savings,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financialCard(
                    'Investable Surplus',
                    formatAmount(investableSurplus),
                    Icons.auto_graph,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _financialCard(
                    'Reserve',
                    formatAmount(reserve),
                    Icons.shield,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financialCard(
                    'Overall Risk',
                    getOverallRisk(),
                    Icons.assessment,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Financial Health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Financial Health',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$healthScore / 100',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: healthScore / 100,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      healthStatus,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _healthMetric(
                            title: 'Profit Margin',
                            value:
                                '${getProfitMargin().toStringAsFixed(2)}%',
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _healthMetric(
                            title: 'Expense Ratio',
                            value:
                                '${getExpenseRatio().toStringAsFixed(2)}%',
                            icon: Icons.trending_down,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'FinPilot AI Recommendation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'AI Investment Guidance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recommended Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendedAction,
                      style: const TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Risk Level: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(getOverallRisk()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Available for Investment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(investableSurplus),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Why this recommendation?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      whyRecommendation,
                      style: const TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Where You Can Consider Investing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These categories are suggested based on your '
              'financial profile and available surplus.',
              style: TextStyle(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            if (investments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No investment categories recommended at this time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ...investments.map(_investmentCard),

            const SizedBox(height: 28),

            const Text(
              'Investment Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _allocationRow(
                      title: 'Low Risk',
                      percentage:
                          getRiskPercentage('Low'),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 18),
                    _allocationRow(
                      title: 'Moderate Risk',
                      percentage:
                          getRiskPercentage('Moderate'),
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 18),
                    _allocationRow(
                      title: 'High Risk',
                      percentage:
                          getRiskPercentage('High'),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      disclaimer,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, dynamic value) {
    return Text(
      '$label: ${value?.toString() ?? '-'}',
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Widget _financialCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _healthMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _investmentCard(
    Map<String, dynamic> investment,
  ) {
    final name =
        investment['name']?.toString() ??
        'Investment';

    final risk =
        investment['risk']?.toString() ?? '-';

    final percentage =
        getNumber(investment['percentage']);

    final amount =
        getNumber(investment['amount']);

    final reason =
        investment['reason']?.toString() ?? '';

    Color riskColor;

    switch (risk.toLowerCase()) {
      case 'low':
        riskColor = Colors.green;
        break;
      case 'moderate':
        riskColor = Colors.orange;
        break;
      case 'high':
        riskColor = Colors.red;
        break;
      default:
        riskColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: riskColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(risk),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested allocation',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 8,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested amount',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Flexible(
                  child: Text(
                    formatAmount(amount),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 15),
              const Text(
                'Why?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                reason,
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _allocationRow({
    required String title,
    required double percentage,
    required Color color,
  }) {
    final safePercentage =
        percentage.clamp(0, 100);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${safePercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: safePercentage / 100,
            minHeight: 8,
            backgroundColor:
                Colors.grey.shade200,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }
}

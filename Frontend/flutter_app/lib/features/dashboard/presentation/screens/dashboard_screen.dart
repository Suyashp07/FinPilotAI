import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/features/dashboard/presentation/screens/widgets/app_header.dart';
import 'package:flutter_app/features/dashboard/presentation/screens/widgets/greeting_section.dart';
import 'package:flutter_app/features/dashboard/presentation/screens/widgets/market_card.dart';
import 'package:flutter_app/features/dashboard/presentation/screens/widgets/revenue_overview_card.dart';

import 'package:flutter_app/features/market/presentation/providers/news_provider.dart';

import 'package:flutter_app/features/revenue/presentation/providers/summary_provider.dart';
import 'package:flutter_app/features/authentication/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onMarketTap;

  const DashboardScreen({
    super.key,
    required this.onMarketTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(totalRevenueProvider);
    final expense = ref.watch(totalExpenseProvider);
    final profit = ref.watch(totalProfitProvider);

    final newsAsync = ref.watch(newsProvider);

    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: const AppHeader(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            24,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              GreetingCard(
                userName: authState.userName ?? "User",
              ),

              const SizedBox(height: 12),

              RevenueOverviewCard(
                revenue: revenue,
                expense: expense,
                profit: profit,
                growth: 12.5,
              ),

              const SizedBox(height: 12),

              newsAsync.when(
                loading: () {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },

                error: (error, stackTrace) {
                  return _MarketErrorCard(
                    onRetry: () {
                      ref.invalidate(newsProvider);
                    },
                  );
                },

                data: (news) {
                  if (news.isEmpty) {
                    return const _EmptyMarketCard();
                  }

                  final featuredNews = news.first;

                  return MarketDashboardCard(
                    title: featuredNews.title,
                    source: featuredNews.source,
                    onTap: onMarketTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// ERROR CARD
// ============================================================

class _MarketErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _MarketErrorCard({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 36,
            color: Colors.grey,
          ),

          const SizedBox(height: 8),

          const Text(
            "Market insights unavailable",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: onRetry,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// EMPTY CARD
// ============================================================

class _EmptyMarketCard extends StatelessWidget {
  const _EmptyMarketCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.newspaper_rounded,
            size: 36,
            color: Colors.grey,
          ),

          SizedBox(height: 8),

          Text(
            "No market insights available",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:flutter_app/features/government/screens/government_screen.dart';
import 'package:flutter_app/features/investment/presentation/screen/investment_screen.dart';
import 'package:flutter_app/features/market/presentation/screens/market_screen.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ==========================================
  // GO TO MARKET TAB
  // ==========================================

  void _goToMarket() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,

        children: [
          DashboardScreen(
            onMarketTap: _goToMarket,
          ),

          const MarketScreen(),

          const InvestmentScreen(),

          const GovernmentScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,

        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "Market",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Schemes",
          ),
        ],
      ),
    );
  }
}
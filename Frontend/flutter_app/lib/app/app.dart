import 'package:flutter/material.dart';
import 'package:flutter_app/features/authentication/presentation/screens/auth_gate.dart';
import 'package:flutter_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/authentication/presentation/screens/splash_screen.dart';
import 'package:flutter_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_app/features/market/presentation/screens/market_screen.dart';
import 'theme.dart';

class FinPilotApp extends StatelessWidget {
  const FinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinPilot AI',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
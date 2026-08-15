import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InvestmentService {
  late final Dio dio;

  InvestmentService() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env["API_BASE_URL"]!,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
  }

  Future<Response> getProfile(String token) async {
    return await dio.get(
      "/investment/profile",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  Future<Response> saveInvestmentProfile({
    required String token,
    required String riskTolerance,
    required String investmentHorizon,
    required String investmentGoal,
  }) async {
    return await dio.post(
      "/investment/profile",
      data: {
        "risk_tolerance": riskTolerance,
        "investment_horizon": investmentHorizon,
        "investment_goal": investmentGoal,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

  // ==========================================================
  // GET AI INVESTMENT RECOMMENDATION
  // ==========================================================

  Future<Response> getRecommendation(
    String token,
  ) async {
    return await dio.get(
      "/investment/recommendation",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }
}
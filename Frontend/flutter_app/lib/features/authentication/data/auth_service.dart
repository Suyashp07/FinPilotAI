import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  late final Dio dio;

  AuthService() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env["API_BASE_URL"]!,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
  }

  // =========================
  // LOGIN
  // =========================

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await dio.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  // =========================
  // REGISTER
  // =========================

  Future<Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await dio.post(
      "/auth/register",
      data: {
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }
  Future<Response> getMe(String token) {
  return dio.get(
    "/auth/me",
    options: Options(
      headers: {
        "Authorization": "Bearer $token",
      },
    ),
  );
}

// =========================
// VERIFY OTP
// =========================

Future<Response> verifyOtp({
  required String email,
  required String otp,
}) async {
  return await dio.post(
    "/auth/verify-otp",
    data: {
      "email": email,
      "otp": otp,
    },
  );
}
}


import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/features/revenue/presentation/providers/transaction_provider.dart';

import '../data/auth_service.dart';


// ============================================================
// AUTH STATUS
// ============================================================

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}


// ============================================================
// AUTH STATE
// ============================================================

class AuthState {
  final AuthStatus status;
  final String? message;
  final String? userName;
  final String? email;

  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.userName,
    this.email,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    String? userName,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message,
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}


// ============================================================
// AUTH NOTIFIER
// ============================================================

class AuthNotifier extends StateNotifier<AuthState> {

  // IMPORTANT:
  // Receive Riverpod Ref so that we can access
  // transactionProvider.

  AuthNotifier(this.ref) : super(const AuthState());

  final Ref ref;

  final AuthService _authService = AuthService();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();


  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login({
    required String email,
    required String password,
  }) async {

    state = state.copyWith(
      status: AuthStatus.loading,
      message: null,
    );

    try {

      // --------------------------------------------------------
      // 1. LOGIN
      // --------------------------------------------------------

      final response = await _authService.login(
        email: email,
        password: password,
      );

      final token = response.data["access_token"];

      if (token == null) {
        throw Exception(
          "Access token not received",
        );
      }


      // --------------------------------------------------------
      // 2. SAVE TOKEN
      // --------------------------------------------------------

      await _storage.write(
        key: "token",
        value: token.toString(),
      );

      print("TOKEN SAVED");


      // --------------------------------------------------------
      // 3. GET CURRENT USER
      // --------------------------------------------------------

      final userResponse =
          await _authService.getMe(
        token.toString(),
      );

      print(
        "ME RESPONSE: ${userResponse.data}",
      );


      // --------------------------------------------------------
      // 4. GET USER NAME
      // --------------------------------------------------------

      final userName =
          userResponse.data["user"]["name"];

      print(
        "USER NAME FROM API: $userName",
      );


      // --------------------------------------------------------
      // 5. UPDATE AUTH STATE
      // --------------------------------------------------------

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userName: userName.toString(),
        message: null,
      );

      print(
        "AUTH STATE USERNAME: ${state.userName}",
      );


      // --------------------------------------------------------
      // 6. LOAD TRANSACTIONS
      // --------------------------------------------------------

      await ref
          .read(transactionProvider.notifier)
          .loadTransactions();

      print(
        "TRANSACTIONS LOADED AFTER LOGIN",
      );

    } catch (e) {

      print(
        "LOGIN ERROR: $e",
      );

      state = state.copyWith(
        status: AuthStatus.error,
        message: _getErrorMessage(e),
      );
    }
  }


  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {

    state = state.copyWith(
      status: AuthStatus.loading,
      message: null,
    );

    try {

      // --------------------------------------------------------
      // 1. REGISTER USER
      // --------------------------------------------------------

      final response =
          await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      print(
        "REGISTER RESPONSE: ${response.data}",
      );


      // --------------------------------------------------------
      // 2. CHECK SUCCESS
      // --------------------------------------------------------

      final success =
          response.data["success"];

      if (success == true) {

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          userName: name,
          email: email,
          message: null,
        );

      } else {

        state = state.copyWith(
          status: AuthStatus.error,
          message:
              response.data["message"] ??
              "Registration failed",
        );
      }

    } catch (e) {

      print(
        "REGISTER ERROR: $e",
      );

      state = state.copyWith(
        status: AuthStatus.error,
        message: _getErrorMessage(e),
      );
    }
  }


  // ============================================================
  // RESTORE SESSION
  // ============================================================

  Future<void> restoreSession() async {

    try {

      // --------------------------------------------------------
      // 1. READ TOKEN
      // --------------------------------------------------------

      final token =
          await _storage.read(
        key: "token",
      );


      // --------------------------------------------------------
      // 2. NO TOKEN
      // --------------------------------------------------------

      if (token == null || token.isEmpty) {

        print(
          "NO SAVED TOKEN",
        );

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          userName: null,
        );

        return;
      }


      print(
        "SAVED TOKEN FOUND",
      );


      // --------------------------------------------------------
      // 3. VERIFY TOKEN / GET USER
      // --------------------------------------------------------

      final response =
          await _authService.getMe(token);


      // --------------------------------------------------------
      // 4. INVALID TOKEN
      // --------------------------------------------------------

      if (response.data["success"] != true) {

        print(
          "TOKEN INVALID",
        );

        await _storage.delete(
          key: "token",
        );

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          userName: null,
        );

        return;
      }


      // --------------------------------------------------------
      // 5. GET USER NAME
      // --------------------------------------------------------

      final userName =
          response.data["user"]["name"];

      print(
        "SESSION RESTORED: $userName",
      );


      // --------------------------------------------------------
      // 6. UPDATE AUTH STATE
      // --------------------------------------------------------

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userName: userName.toString(),
        message: null,
      );


      // --------------------------------------------------------
      // 7. LOAD TRANSACTIONS
      // --------------------------------------------------------

      await ref
          .read(transactionProvider.notifier)
          .loadTransactions();

      print(
        "TRANSACTIONS RESTORED",
      );

    } catch (e) {

      print(
        "SESSION RESTORE ERROR: $e",
      );


      // --------------------------------------------------------
      // INVALID SESSION
      // --------------------------------------------------------

      await _storage.delete(
        key: "token",
      );


      // Clear transaction state as well
      ref.invalidate(
        transactionProvider,
      );


      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        userName: null,
        message: null,
      );
    }
  }


  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {

    // ----------------------------------------------------------
    // 1. DELETE TOKEN
    // ----------------------------------------------------------

    await _storage.delete(
      key: "token",
    );


    // ----------------------------------------------------------
    // 2. CLEAR TRANSACTIONS
    // ----------------------------------------------------------

    ref.invalidate(
      transactionProvider,
    );


    // ----------------------------------------------------------
    // 3. CLEAR AUTH STATE
    // ----------------------------------------------------------

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      userName: null,
      message: null,
    );

    print(
      "USER LOGGED OUT",
    );
  }


  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _getErrorMessage(
    dynamic error,
  ) {

    if (error is DioException) {

      final response =
          error.response;


      if (response != null &&
          response.data is Map<String, dynamic>) {

        return response.data["message"] ??
            response.data["detail"] ??
            "Request failed";
      }


      return "Unable to connect to server";
    }


    return error.toString();
  }
  Future<void> verifyOtp({
  required String email,
  required String otp,
}) async {
  state = state.copyWith(
    status: AuthStatus.loading,
    message: null,
  );

  try {
    final response = await _authService.verifyOtp(
      email: email,
      otp: otp,
    );

    if (response.data["success"] == true) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: response.data["message"],
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        message: response.data["message"] ?? "OTP verification failed",
      );
    }
  } catch (e) {
    state = state.copyWith(
      status: AuthStatus.error,
      message: _getErrorMessage(e),
    );
  }
}
}



// ============================================================
// AUTH PROVIDER
// ============================================================

final authProvider =
    StateNotifierProvider<
      AuthNotifier,
      AuthState
    >(
      (ref) => AuthNotifier(ref),
    );
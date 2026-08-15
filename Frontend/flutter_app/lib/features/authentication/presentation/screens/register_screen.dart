import 'package:flutter/material.dart';
import 'package:flutter_app/features/authentication/presentation/screens/otp_verification_screen.dart';
import 'package:flutter_app/features/authentication/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final isLoading =
        authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const SizedBox(height: 15),

                // =========================
                // ICON
                // =========================

                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,

                  child: const Icon(
                    Icons.person_add,
                    size: 45,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // TITLE
                // =========================

                const Text(
                  "Create your FinPilot Account",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // NAME
                // =========================

                TextFormField(
                  controller: nameController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Enter your name";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =========================
                // EMAIL
                // =========================

                TextFormField(
                  controller: emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  textInputAction:
                      TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Enter your email";
                    }

                    if (!value.contains("@")) {
                      return "Enter a valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =========================
                // PASSWORD
                // =========================

                TextFormField(
                  controller: passwordController,

                  obscureText: obscurePassword,

                  textInputAction:
                      TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: "Password",

                    prefixIcon:
                        const Icon(Icons.lock),

                    border:
                        const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Enter a password";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =========================
                // CONFIRM PASSWORD
                // =========================

                TextFormField(
                  controller:
                      confirmPasswordController,

                  obscureText:
                      obscureConfirmPassword,

                  textInputAction:
                      TextInputAction.done,

                  decoration: InputDecoration(
                    labelText:
                        "Confirm Password",

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    border:
                        const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Confirm your password";
                    }

                    if (value !=
                        passwordController.text) {
                      return "Passwords do not match";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // =========================
                // REGISTER BUTTON
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _registerUser,

                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )

                        : const Text(
                            "REGISTER",

                            style:
                                TextStyle(
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // =========================
                // LOGIN LINK
                // =========================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    const Text(
                      "Already have an account?",
                    ),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              );
                            },

                      child:
                          const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // REGISTER FUNCTION
  // =========================

  Future<void> _registerUser() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  FocusScope.of(context).unfocus();

  final email = emailController.text.trim();

  await ref.read(authProvider.notifier).register(
        name: nameController.text.trim(),
        email: email,
        password: passwordController.text,
      );

  if (!mounted) return;

  final authState = ref.read(authProvider);

  if (authState.status == AuthStatus.unauthenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Registration successful! OTP sent to your email.",
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          email: email,
        ),
      ),
    );
  } else if (authState.status == AuthStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getErrorMessage(authState.message),
        ),
      ),
    );
  }
}

String _getErrorMessage(String? message) {
  if (message == null || message.isEmpty) {
    return "Registration failed";
  }

  if (message.contains("Email already registered")) {
    return "This email is already registered";
  }

  if (message.contains("SocketException")) {
    return "Cannot connect to server";
  }

  return message;
}
}
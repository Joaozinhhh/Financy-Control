import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth/auth_service.dart';

class MockCLIScreen extends StatefulWidget {
  const MockCLIScreen({super.key});

  @override
  State<MockCLIScreen> createState() => _MockCLIScreenState();
}

class _MockCLIScreenState extends State<MockCLIScreen> {
  final AuthService _authService = LocalAuth();
  final String _mockEmail = "email@test.com";
  final String _mockPassword = "password";
  final String _mockUsername = "Test User";

  void _signIn() async {
    try {
      await _authService.signIn(
        email: _mockEmail,
        password: _mockPassword,
      );
      if (!mounted) return;
      context.push(Screen.home.location);
    } catch (e) {
      rethrow;
    }
  }

  void _signUp() async {
    try {
      await _authService.signUp(
        UserInputModel(
          name: _mockUsername,
          email: _mockEmail,
          password: _mockPassword,
        ),
      );
      if (!mounted) return;
      context.pushNamed(Screen.home.name);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock CLI Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _signIn,
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _signUp,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

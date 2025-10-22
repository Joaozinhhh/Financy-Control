import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockCLIScreen extends StatefulWidget {
  const MockCLIScreen({super.key});

  @override
  State<MockCLIScreen> createState() => _MockCLIScreenState();
}

class _MockCLIScreenState extends State<MockCLIScreen> {
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
            onPressed: () => context.push(Screen.signIn.location),
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () => context.push(Screen.resetPassword.location),
            child: const Text('Reset Password'),
          ),
          TextButton(
            onPressed: () => context.push(Screen.signUp.location),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

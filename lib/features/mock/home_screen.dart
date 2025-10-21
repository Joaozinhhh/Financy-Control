import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.push(Screen.transactions.location),
              child: const Text('Transactions'),
            ),
            TextButton(
              onPressed: () => context.goNamed(Screen.root.name),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

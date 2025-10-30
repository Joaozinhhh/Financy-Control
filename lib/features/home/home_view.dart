import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
              onPressed: () => context.push(Screen.statistics.location),
              child: const Text('Statistics'),
            ),
            TextButton(
              onPressed: () => context.push(Screen.reports.location),
              child: const Text('Reports'),
            ),
            TextButton(
              onPressed: () => context.push(Screen.profile.location),
              child: const Text('Profile'),
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

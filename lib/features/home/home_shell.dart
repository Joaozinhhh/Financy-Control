import 'package:financy_control/core/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell with bottom navigation powered by GoRouter's StatefulNavigationShell.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    // If reselecting the current tab, pop to its initial location
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.translations.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.area_chart_outlined),
            selectedIcon: const Icon(Icons.area_chart),
            label: context.translations.navStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: context.translations.navWallet,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.translations.navProfile,
          ),
        ],
      ),
    );
  }
}

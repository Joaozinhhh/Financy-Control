import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/features/home/home_view.dart';
import 'package:financy_control/features/onboarding/auth/reset_password/reset_password_view.dart';
import 'package:financy_control/features/onboarding/auth/sign_in/sign_in_view.dart';
import 'package:financy_control/features/onboarding/auth/sign_up/sign_up_view.dart';
import 'package:financy_control/features/onboarding/splash/splash_view.dart';
import 'package:financy_control/features/profile/profile_view.dart';
import 'package:financy_control/features/reports/reports_view.dart';
import 'package:financy_control/features/statistics/statistics_view.dart';
import 'package:financy_control/features/transactions/transactions_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Screen {
  root('/'),

  splash('/splash'),

  signUp('/sign-up'),
  signIn('/sign-in'),
  resetPassword('/reset-password'),

  home('/home'),
  transactions('transactions', parent: Screen.home),
  transactionCreate('create', parent: Screen.transactions),
  transactionEdit('edit/:id', parent: Screen.transactions),
  categories('categories', parent: Screen.home),
  categoryCreate('create', parent: Screen.categories),
  categoryEdit('edit/:id', parent: Screen.categories),
  statistics('statistics', parent: Screen.home),
  reports('reports', parent: Screen.statistics),

  profile('/profile'),
  updateUserName('update-username', parent: Screen.profile),
  updatePassword('update-password', parent: Screen.profile);

  const Screen(
    this._path, {
    this.parent,
  });

  final String _path;
  final Screen? parent;

  String get location {
    if (parent == null) return _path;
    return parent!.location.endsWith('/')
        ? '${parent!.location}$_path'
        : '${parent!.location}/$_path';
  }
}

final router = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Screen.root._path,
      name: Screen.root.name,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: Screen.splash._path,
      name: Screen.splash.name,
      builder: (context, state) => const Placeholder(),
    ),
    GoRoute(
      path: Screen.home._path,
      name: Screen.home.name,
      builder: (context, state) => const HomeView(),
      routes: [
        GoRoute(
          path: Screen.transactions._path,
          name: Screen.transactions.name,
          builder: (context, state) => const TransactionsView(),
          routes: [
            GoRoute(
              path: Screen.transactionCreate._path,
              name: Screen.transactionCreate.name,
              builder: (context, state) => const TransactionFormView(),
            ),
            GoRoute(
              path: Screen.transactionEdit._path,
              name: Screen.transactionEdit.name,
              builder: (context, state) => TransactionFormView(
                transaction: state.extra as TransactionModel,
              ),
            ),
          ],
        ),
        GoRoute(
          path: Screen.categories._path,
          name: Screen.categories.name,
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: Screen.statistics._path,
          name: Screen.statistics.name,
          builder: (context, state) => const StatisticsView(),
          routes: [
            GoRoute(
              path: Screen.reports._path,
              name: Screen.reports.name,
              builder: (context, state) => const ReportsView(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Screen.profile._path,
      name: Screen.profile.name,
      builder: (context, state) => const ProfileView(),
      routes: [
        GoRoute(
          path: Screen.updateUserName._path,
          name: Screen.updateUserName.name,
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: Screen.updatePassword._path,
          name: Screen.updatePassword.name,
          builder: (context, state) => const Placeholder(),
        ),
      ],
    ),
    GoRoute(
      path: Screen.signUp._path,
      name: Screen.signUp.name,
      builder: (context, state) => const SignUpView(),
    ),
    GoRoute(
      path: Screen.signIn._path,
      name: Screen.signIn.name,
      builder: (context, state) => const SignInView(),
    ),
    GoRoute(
      path: Screen.resetPassword._path,
      name: Screen.resetPassword.name,
      builder: (context, state) => const ResetPasswordView(),
    ),
  ],
);

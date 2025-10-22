import 'package:financy_control/features/mock/home_screen.dart';
import 'package:financy_control/features/mock/mock_cli_screen.dart';
import 'package:financy_control/features/onboarding/auth/reset_password/reset_password_view.dart';
import 'package:financy_control/features/onboarding/auth/sign_in/sign_in_view.dart';
import 'package:financy_control/features/onboarding/auth/sign_up/sign_up_view.dart';
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
  categories('categories', parent: Screen.home),
  statistics('statistics', parent: Screen.home),
  reports('reports', parent: Screen.statistics),

  profile('profile', parent: Screen.home),
  updateUserName('update-username', parent: Screen.profile),
  updatePassword('update-password', parent: Screen.profile),
  deleteAccount('delete-account', parent: Screen.profile);

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
      builder: (context, state) => MockCLIScreen(),
    ),
    GoRoute(
      path: Screen.splash._path,
      name: Screen.splash.name,
      builder: (context, state) => Placeholder(),
    ),
    GoRoute(
      path: Screen.home._path,
      name: Screen.home.name,
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: Screen.transactions._path,
          name: Screen.transactions.name,
          builder: (context, state) => Placeholder(),
        ),
        GoRoute(
          path: Screen.categories._path,
          name: Screen.categories.name,
          builder: (context, state) => Placeholder(),
        ),
        GoRoute(
          path: Screen.statistics._path,
          name: Screen.statistics.name,
          builder: (context, state) => Placeholder(),
          routes: [
            GoRoute(
              path: Screen.reports._path,
              name: Screen.reports.name,
              builder: (context, state) => Placeholder(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Screen.profile._path,
      name: Screen.profile.name,
      builder: (context, state) => Placeholder(),
      routes: [
        GoRoute(
          path: Screen.updateUserName._path,
          name: Screen.updateUserName.name,
          builder: (context, state) => Placeholder(),
        ),
        GoRoute(
          path: Screen.updatePassword._path,
          name: Screen.updatePassword.name,
          builder: (context, state) => Placeholder(),
        ),
        GoRoute(
          path: Screen.deleteAccount._path,
          name: Screen.deleteAccount.name,
          builder: (context, state) => Placeholder(),
        ),
      ],
    ),
    GoRoute(
      path: Screen.signUp._path,
      name: Screen.signUp.name,
      builder: (context, state) => SignUpView(),
    ),
    GoRoute(
      path: Screen.signIn._path,
      name: Screen.signIn.name,
      builder: (context, state) => SignInView(),
    ),
    GoRoute(
      path: Screen.resetPassword._path,
      name: Screen.resetPassword.name,
      builder: (context, state) => ResetPasswordView(),
    ),
  ],
);

import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/features/home/home_shell.dart';
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
  transactionView('view/:id', parent: Screen.transactions),

  statistics('statistics', parent: Screen.home),

  profile('profile', parent: Screen.home),
  reports('reports', parent: Screen.profile) // break
  ;

  const Screen(
    this._path, {
    this.parent,
  });

  final String _path;
  final Screen? parent;

  String get location {
    if (parent == null) return _path;
    return parent!.location.endsWith('/') ? '${parent!.location}$_path' : '${parent!.location}/$_path';
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
    // Authentication routes
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
    // Bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Screen.home._path, // '/home'
              name: Screen.home.name,
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        // Statistics branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Screen.statistics.location, // '/home/statistics'
              name: Screen.statistics.name,
              builder: (context, state) => const StatisticsView(),
            ),
          ],
        ),
        // Transactions branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Screen.transactions.location, // '/home/transactions'
              name: Screen.transactions.name,
              builder: (context, state) => const TransactionsView(),
              routes: [
                GoRoute(
                  path: Screen.transactionCreate._path,
                  name: Screen.transactionCreate.name,
                  builder: (context, state) => const SingleTransactionView.create(),
                ),
                GoRoute(
                  path: Screen.transactionEdit._path,
                  name: Screen.transactionEdit.name,
                  builder: (context, state) => SingleTransactionView.edit(
                    transaction: state.extra as TransactionModel,
                  ),
                ),
                GoRoute(
                  path: Screen.transactionView._path,
                  name: Screen.transactionView.name,
                  builder: (context, state) => SingleTransactionView.view(
                    transaction: state.extra as TransactionModel,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Screen.profile.location, // '/home/profile'
              name: Screen.profile.name,
              builder: (context, state) => const ProfileView(),
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
      ],
    ),
  ],
);

mixin GoRouterAware<T extends StatefulWidget> on State<T> {
  // NOTE: ref https://gist.github.com/MattiaPispisa/7914b5b2cb7c12b2430d14848beff31f

  /// The route to be aware of.
  late final Uri _observerLocation;

  /// The current state of the [_observerLocation].
  late _GoRouterAwareState _state;

  /// go router delegate.
  late GoRouterDelegate _delegate;

  /// The context of the widget.
  late BuildContext _context;

  /// The location of the top route
  Uri? _currentLocation;

  @override
  void initState() {
    _context = context;

    final router = GoRouter.of(_context);

    _state = _GoRouterAwareState._topRoute;
    _observerLocation = router.state.uri;
    _delegate = router.routerDelegate;

    _onChange();
    _delegate.addListener(_onChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _context = context;
    super.didChangeDependencies();
  }

  void _onChange() {
    _currentLocation = GoRouter.of(_context).state.uri;

    if (_currentLocation == null) {
      return;
    }

    /// If the current route is the top route and the current location is the same as the observer location then [_observerLocation] is the top route.
    if (_state.isTopRoute && _sameLocation(_currentLocation!, _observerLocation)) {
      didPush();
      return;
    }

    /// If the current route is pushed next and the current location is the same as the observer location then [_observerLocation] is returned to the top route.
    if (_state.isPushedNext && _sameLocation(_currentLocation!, _observerLocation)) {
      didPopNext();
      _state = _GoRouterAwareState._topRoute;
      return;
    }

    /// If the current route is not the top route and the current location contains the observer location then [_observerLocation] is no longer the top route.
    if (!_sameLocation(_currentLocation!, _observerLocation) &&
        _currentLocation!.path.toString().contains(_observerLocation.path)) {
      _state = _GoRouterAwareState._pushedNext;
      didPushNext();
      return;
    }

    /// If the current route is the top route and the current location does not contain the observer location then [_observerLocation] is popped off.
    if (_state.isTopRoute && !_currentLocation!.path.toString().contains(_observerLocation.path)) {
      didPop();
      _state = _GoRouterAwareState._poppedOff;
      return;
    }

    /// If the current route is popped off and the current location is the same as the observer location then [_observerLocation] is the top route again.
    if (_state.isPoppedOff && _sameLocation(_currentLocation!, _observerLocation)) {
      didChangeTop();
      _state = _GoRouterAwareState._topRoute;
      return;
    }
  }

  /// Check if two locations have the same path.
  bool _sameLocation(Uri a, Uri b) {
    return a.path.toString() == b.path.toString();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  void didPopNext() {}

  /// Called when the current route has been pushed.
  void didPush() {}

  /// Called when the current route has been popped off.
  void didPop() {}

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  void didPushNext() {}

  /// Called when the current route is the top route again.
  void didChangeTop() {}

  @override
  void dispose() {
    _delegate.removeListener(_onChange);
    super.dispose();
  }
}

enum _GoRouterAwareState {
  _pushedNext,
  _topRoute,
  _poppedOff;

  bool get isTopRoute => this == _topRoute;
  bool get isPushedNext => this == _pushedNext;
  bool get isPoppedOff => this == _poppedOff;
}

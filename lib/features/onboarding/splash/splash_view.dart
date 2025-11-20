import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/onboarding/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
    _init();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  Future<void> _init() async {
    final destination = await _viewModel.checkAuthStatus();
    if (!mounted) return;
    context.go(destination.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _viewModel.errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    context.translations.errorCheckingAuthStatus,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _viewModel.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Image.asset('assets/images/logo.png')),
                  const SizedBox(height: 16),
                  const Flexible(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}

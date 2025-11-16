import 'package:financy_control/core/components/buttons.dart';
import 'package:financy_control/core/components/textfields.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'reset_password_view_model.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> with FormValidators {
  final ResetPasswordViewModel _viewModel = ResetPasswordViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff33a8eb),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  constraints: const BoxConstraints.tightFor(height: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints.tight(const Size.square(80)),
                        child: const FittedBox(child: Icon(Icons.lock, color: Color(0xFF38b6ff))),
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'Forgot\n',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Password?',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                    decoration: const BoxDecoration(
                      color: Color(0xFF33a8eb),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        FCTextField(
                          onChanged: _viewModel.setEmail,
                          decoration: const InputDecoration().copyWith(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        FCButton.secondary(
                          onPressed: _viewModel.isLoading
                              ? null
                              : () async {
                                  final success = await _viewModel.resetPassword();
                                  if (success) {
                                    if (!context.mounted) return;
                                    context.go(Screen.signIn.location);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password reset link sent!'),
                                      ),
                                    );
                                  } else if (_viewModel.errorMessage != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_viewModel.errorMessage!),
                                      ),
                                    );
                                  }
                                },
                          child: _viewModel.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Reset Password'),
                        ),
                        const SizedBox(height: 16),
                        FCButton.terciary(
                          onPressed: () {
                            if (!context.mounted) return;
                            context.go(Screen.signIn.location);
                          },
                          style: Theme.of(context).textButtonTheme.style?.copyWith(
                            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                            minimumSize: WidgetStateProperty.all<Size>(const Size(220, 32)),
                          ),
                          child: const Text('Back to Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

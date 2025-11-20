import 'package:financy_control/core/components/buttons.dart';
import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/core/components/textfields.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sign_in_view_model.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with FormValidators {
  final SignInViewModel _viewModel = SignInViewModel();

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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff38b6ff),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Image(
                                  image: AssetImage('assets/images/logo.png'),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top,
                            right: 0,
                            child: launchUrl('https://example.com'), // TODO: replace with actual URL
                          ),
                        ],
                      ),
                      Text(
                        context.translations.financeApp,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: FCTextField(
                          onChanged: _viewModel.setEmail,
                          decoration: const InputDecoration().copyWith(
                            hintText: context.translations.email,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          cursorColor: Theme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: FCTextField(
                          decoration: const InputDecoration().copyWith(
                            hintText: context.translations.password,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: _viewModel.toggleVisibility,
                            ),
                          ),
                          onChanged: _viewModel.setPassword,
                          obscureText: !_viewModel.passwordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Theme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black,
                          validator: validatePassword,
                        ),
                      ),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          FCButton.terciary(
                            style: Theme.of(context).textButtonTheme.style?.copyWith(
                              minimumSize: WidgetStateProperty.all<Size>(const Size(220, 50)),
                              splashFactory: NoSplash.splashFactory,
                            ),
                            onPressed: () {
                              if (!context.mounted) return;
                              context.go(Screen.resetPassword.location);
                            },
                            child: Text(context.translations.forgotPassword),
                          ),
                          FCButton.primary(
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              minimumSize: WidgetStateProperty.all<Size>(const Size(220, 50)),
                            ),
                            onPressed: _viewModel.isLoading || !_viewModel.isFormValid
                                ? null
                                : () async {
                                    final screen = await _viewModel.signIn();
                                    if (screen != null) {
                                      if (!context.mounted) return;
                                      context.go(screen.location);
                                    } else if (_viewModel.errorMessage != null) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _viewModel.errorMessage!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: _viewModel.isLoading
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints.tightFor(
                                      height: 24,
                                      width: 24,
                                    ),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(context.translations.signIn),
                          ),
                          Text(context.translations.or, style: const TextStyle(fontSize: 16)),
                          FCButton.secondary(
                            style: Theme.of(context).textButtonTheme.style?.copyWith(
                              minimumSize: WidgetStateProperty.all<Size>(const Size(220, 50)),
                            ),
                            onPressed: () {
                              if (!context.mounted) return;
                              context.go(Screen.signUp.location);
                            },
                            child: Text(
                              context.translations.dontHaveAccountSignUp,
                            ),
                          ),
                        ],
                      ),
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

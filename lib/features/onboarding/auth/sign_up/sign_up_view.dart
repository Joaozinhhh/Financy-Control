import 'package:financy_control/core/components/buttons.dart';
import 'package:financy_control/core/components/textfields.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'sign_up_view_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with FormValidators {
  final SignUpViewModel _viewModel = SignUpViewModel();

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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 64),
                alignment: Alignment.topLeft,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Vamos',
                          ),
                          Text(
                            'Criar sua',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'conta',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.all(32),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      FCTextField(
                        onChanged: _viewModel.setName,
                        decoration: const InputDecoration().copyWith(
                          hintText: 'Name',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                        validator: validateName,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny('  '),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        onChanged: _viewModel.setEmail,
                        decoration: const InputDecoration().copyWith(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(' '),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        onChanged: _viewModel.setPassword,
                        decoration: const InputDecoration().copyWith(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: _viewModel.toggleVisibility,
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        validator: validatePassword,
                        obscureText: !_viewModel.passwordVisible,
                      ),
                      const SizedBox(height: 16),
                      FCTextField(
                        onChanged: _viewModel.setConfirmPassword,
                        decoration: const InputDecoration().copyWith(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_viewModel.passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: _viewModel.toggleVisibility,
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) => validateConfirmPassword(value, _viewModel.password),
                        obscureText: !_viewModel.passwordVisible,
                      ),
                      const SizedBox(height: 16),
                      FCCheckBoxField(
                        onChanged: _viewModel.setAgreedToTerms,
                        title: const Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FCButton.primary(
                        onPressed: _viewModel.isLoading || !_viewModel.isFormValid
                            ? null
                            : () async {
                                final screen = await _viewModel.signUp();
                                if (screen != null) {
                                  if (!context.mounted) return;
                                  context.go(screen.location);
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
                            ? ConstrainedBox(
                                constraints: const BoxConstraints.tightFor(
                                  height: 24,
                                  width: 24,
                                ),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                      const SizedBox(height: 16),
                      FCButton.terciary(
                        style: Theme.of(context).textButtonTheme.style,
                        onPressed: () {
                          if (!context.mounted) return;
                          context.go(Screen.signIn.location);
                        },
                        child: const Text("Already have an account? Sign In"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  bool _isChecking = true;
  String? _errorMessage;
  UserModel? _user;

  bool get isChecking => _isChecking;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<Screen> checkAuthStatus() async {
    _isChecking = true;
    _errorMessage = null;
    rebuild();

    try {
      // Simulate network delay or initialization check
      await Future.delayed(const Duration(seconds: 1));
      
      _user = _authService.currentUser;

      if (_user != null) {
        return Screen.home;
      } else {
        return Screen.signUp;
      }
    } catch (e) {
      _errorMessage = e.toString();
      // On error, navigate to sign up as fallback
      return Screen.signUp;
    } finally {
      _isChecking = false;
      rebuild();
    }
  }
}

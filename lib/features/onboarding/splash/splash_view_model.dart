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
      final result = await _authService.validateCurrentUser();
      return result.fold(
        (error) {
          _errorMessage = error.message;
          return Screen.signUp;
        },
        (isValid) {
          if (isValid) {
            _user = _authService.currentUser;
            return Screen.home;
          } else {
            return Screen.signIn;
          }
        },
      );
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

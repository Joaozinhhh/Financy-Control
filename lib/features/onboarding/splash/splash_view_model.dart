import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
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
      _user = await mockCheckAuthStatus();

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

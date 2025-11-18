import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class SignInViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;
  bool _passwordVisible = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get passwordVisible => _passwordVisible;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void toggleVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  bool get isFormValid => _email.isNotEmpty && _password.isNotEmpty;

  Future<Screen?> signIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(email: _email, password: _password);
      return result.fold(
        (error) {
          _errorMessage = error.message;
          return null;
        },
        (user) {
          _user = user;
          return Screen.home;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

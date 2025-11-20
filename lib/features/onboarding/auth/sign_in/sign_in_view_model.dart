import 'package:financy_control/core/data/exceptions.dart';
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
  Failure? _failure;
  UserModel? _user;
  bool _passwordVisible = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
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
    _failure = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(email: _email, password: _password);
      return result.fold(
        (error) {
          _failure = error;
          return null;
        },
        (user) {
          _user = user;
          return Screen.home;
        },
      );
    } catch (e) {
      _failure = UnknownFailure(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

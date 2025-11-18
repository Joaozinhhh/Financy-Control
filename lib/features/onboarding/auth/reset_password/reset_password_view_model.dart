import 'package:financy_control/locator.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  String _email = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  Future<bool> resetPassword() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.forgotPassword(_email);
      return result.fold(
        (error) {
          _errorMessage = error.message;
          return false;
        },
        (success) => success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

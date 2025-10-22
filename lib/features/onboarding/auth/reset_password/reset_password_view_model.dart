import 'package:flutter/foundation.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';

class ResetPasswordViewModel extends ChangeNotifier {
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
      final success = await mockForgotPassword(_email);
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

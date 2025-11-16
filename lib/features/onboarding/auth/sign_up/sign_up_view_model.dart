import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/foundation.dart';

class SignUpViewModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  UserModel? _user;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get passwordVisible => _passwordVisible;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  void setAgreedToTerms(bool? agreed) {
    _agreedToTerms = agreed ?? false;
    notifyListeners();
  }

  void toggleVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  bool get isFormValid {
    return _name.isNotEmpty && _email.isNotEmpty && _password.isNotEmpty && _password == _confirmPassword && _agreedToTerms;
  }

  Future<Screen?> signUp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final input = UserInputModel(
        name: _name,
        email: _email,
        password: _password,
      );
      _user = await mockCreateUser(input);
      return Screen.home;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

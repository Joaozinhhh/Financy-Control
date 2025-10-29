import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/foundation.dart';

class SignInViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<Screen?> signIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final input = UserInputModel(email: _email, password: _password);
      _user = await mockLogin(input);
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

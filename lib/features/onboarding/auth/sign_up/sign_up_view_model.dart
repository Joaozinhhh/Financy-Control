import 'package:financy_control/router.dart';
import 'package:flutter/foundation.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:financy_control/core/models/user_model.dart';

class SignUpViewModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

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

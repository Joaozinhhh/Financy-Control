import 'package:financy_control/core/data/data.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';

import 'auth_service.dart';

class LocalAuth implements AuthService {
  LocalAuth._();
  static LocalAuth? _instance;
  factory LocalAuth() => _instance ??= LocalAuth._();

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<DataResult<bool>> forgotPassword(String email) async {
    final response = await mockForgotPassword(email);
    return DataResult.success(response);
  }

  @override
  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await mockLogin(
      UserInputModel(email: email, password: password),
    );
    _currentUser = response;
    return DataResult.success(_currentUser!);
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<DataResult<UserModel>> signUp(UserInputModel userInput) async {
    final response = await mockCreateUser(userInput);
    return DataResult.success(response);
  }
}

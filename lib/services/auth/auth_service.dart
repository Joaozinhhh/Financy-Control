import 'package:financy_control/core/data/data.dart';
import 'package:financy_control/core/models/user_model.dart';

abstract class AuthService {
  Future<DataResult<UserModel>> signUp(UserInputModel userInput);

  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<DataResult<bool>> forgotPassword(String email);

  Future<DataResult<bool>> updateUserName(String newName);

  Future<DataResult<bool>> updateUserPassword(String newPassword);

  UserModel? get currentUser;
}

import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/models/user_model.dart';

abstract class UserRepository {
  Future<DataResult<UserModel>> getUserProfile();
  Future<DataResult<bool>> updateUserName(String name);
  Future<DataResult<bool>> updateUserPassword(String newPassword);
}

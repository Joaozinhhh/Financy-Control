import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/data/exceptions.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/repositories/user_repository.dart';
import 'package:financy_control/services/storage/storage_service.dart';

class MockUserRepository implements UserRepository {
  final StorageService _storage;
  final Duration _delay;

  MockUserRepository({
    required StorageService storage,
    Duration delay = const Duration(milliseconds: 500),
  }) : _storage = storage,
       _delay = delay;

  @override
  Future<DataResult<UserModel>> getUserProfile() async {
    try {
      await Future.delayed(_delay);
      final user = await _storage.getCurrentUser();
      if (user == null) {
        return DataResult.failure(const MockFailure('No user logged in'));
      }
      // Mock photoUrl since it's not in local storage yet
      return DataResult.success(
        UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          photoUrl: 'https://i.pravatar.cc/300',
        ),
      );
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to get user profile'));
    }
  }

  @override
  Future<DataResult<bool>> updateUserName(String name) async {
    try {
      await Future.delayed(_delay);
      final user = await _storage.getCurrentUser();
      if (user == null) {
        return DataResult.failure(const MockFailure('No user logged in'));
      }
      final success = await _storage.updateUserName(user.id, name);
      return DataResult.success(success);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to update user name'));
    }
  }

  @override
  Future<DataResult<bool>> updateUserPassword(String newPassword) async {
    try {
      await Future.delayed(_delay);
      final user = await _storage.getCurrentUser();
      if (user == null) {
        return DataResult.failure(const MockFailure('No user logged in'));
      }
      final success = await _storage.updateUserPassword(user.id, newPassword);
      return DataResult.success(success);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to update password'));
    }
  }
}

class MockFailure implements Failure {
  final String _message;
  const MockFailure(this._message);

  @override
  String get message => _message;
}

import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/data/exceptions.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:uuid/v7.dart';

class MockAuthService implements AuthService {
  final StorageService _storage;
  final Duration _delay;

  MockAuthService({
    required StorageService storage,
    Duration delay = const Duration(milliseconds: 500),
  })  : _storage = storage,
        _delay = delay;

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<DataResult<bool>> forgotPassword(String email) async {
    try {
      await Future.delayed(_delay);
      final user = await _storage.getUserByEmail(email);
      if (user == null) {
        return DataResult.failure(const MockFailure('User not found'));
      }
      return DataResult.success(true);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to reset password'));
    }
  }

  @override
  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(_delay);
      final user = await _storage.verifyCredentials(
        email: email,
        password: password,
      );

      if (user == null) {
        return DataResult.failure(const MockFailure('Invalid email or password'));
      }

      await _storage.setCurrentUser(user.id);
      _currentUser = user;
      return DataResult.success(user);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to sign in'));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(_delay);
    await _storage.clearCurrentUser();
    _currentUser = null;
  }

  @override
  Future<DataResult<UserModel>> signUp(UserInputModel userInput) async {
    try {
      await Future.delayed(_delay);
      final userId = const UuidV7().generate();

      final success = await _storage.saveUser(
        id: userId,
        name: userInput.name ?? 'User',
        email: userInput.email,
        password: userInput.password,
      );

      if (!success) {
        return DataResult.failure(const MockFailure('User already exists'));
      }

      final user = UserModel(
        id: userId,
        name: userInput.name ?? 'User',
        email: userInput.email,
      );

      await _storage.setCurrentUser(userId);
      _currentUser = user;
      return DataResult.success(user);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to sign up'));
    }
  }
  
  // Helper to initialize current user from storage on app start
  Future<void> init() async {
    _currentUser = await _storage.getCurrentUser();
  }
}

class MockFailure implements Failure {
  final String _message;
  const MockFailure(this._message);
  
  @override
  String get message => _message;
}

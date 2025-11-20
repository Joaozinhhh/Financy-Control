import 'package:financy_control/core/data/data.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({required StorageService storage}) : _storage = storage;

  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;
  final StorageService _storage;

  @override
  UserModel? get currentUser => _firebaseAuth.currentUser != null
      ? UserModel(
          id: _firebaseAuth.currentUser!.uid,
          email: _firebaseAuth.currentUser!.email!,
          name: _firebaseAuth.currentUser!.displayName ?? '',
        )
      : null;

  @override
  Future<DataResult<bool>> forgotPassword(String email) {
    try {
      _firebaseAuth.sendPasswordResetEmail(email: email);
      return Future.value(DataResult.success(true));
    } catch (e) {
      return Future.value(DataResult.failure(FirebaseAuthFailure(e.toString())));
    }
  }

  @override
  Future<DataResult<UserModel>> signIn({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? '',
        );
        return DataResult.success(userModel);
      } else {
        return DataResult.failure(const FirebaseAuthFailure("Could not sign in. Please try again."));
      }
    } on FirebaseAuthException catch (e) {
      return Future.value(
        DataResult.failure(FirebaseAuthFailure(e.message ?? "Unable to sign in at this time. Please try again later.")),
      );
    } catch (e) {
      return Future.value(
        DataResult.failure(const FirebaseAuthFailure("Unable to sign in at this time. Please try again later.")),
      );
    }
  }

  @override
  Future<void> signOut() async => await _firebaseAuth.signOut();

  @override
  Future<DataResult<UserModel>> signUp(UserInputModel userInput) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userInput.email,
        password: userInput.password,
      );
      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          name: userInput.name!,
        );
        await _storage.saveUser(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
        );
        return DataResult.success(userModel);
      } else {
        return DataResult.failure(const FirebaseAuthFailure("Could not create user. Please try again."));
      }
    } catch (e) {
      return Future.value(DataResult.failure(FirebaseAuthFailure(e.toString())));
    }
  }

  @override
  Future<DataResult<bool>> updateUserName(String newName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Future.value(DataResult.failure(const FirebaseAuthFailure('No user logged in')));
      }
      await user.updateDisplayName(newName);
      return Future.value(DataResult.success(true));
    } catch (e) {
      return Future.value(DataResult.failure(FirebaseAuthFailure(e.toString())));
    }
  }

  @override
  Future<DataResult<bool>> updateUserPassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Future.value(DataResult.failure(const FirebaseAuthFailure('No user logged in')));
      }
      await user.updatePassword(newPassword);
      return Future.value(DataResult.success(true));
    } catch (e) {
      return Future.value(DataResult.failure(FirebaseAuthFailure(e.toString())));
    }
  }
}

class FirebaseAuthFailure implements Failure {
  const FirebaseAuthFailure(this.message);

  @override
  final String message;

  @override
  String toString() {
    return "FirebaseAuthFailure: $message";
  }
}

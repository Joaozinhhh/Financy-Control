import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/router.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:financy_control/services/profile_image/profile_image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final ProfileImageService _imageService = locator<ProfileImageService>();
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _email = '';
  bool _isLoading = false;
  bool _isAvatarUploading = false;
  String? _avatarBase64;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;
  bool get isAvatarUploading => _isAvatarUploading;
  String? get avatarBase64 => _avatarBase64;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final user = _authService.currentUser;
      if (user != null) {
        _name = user.name;
        _email = user.email;
        // Try load avatar if exists
        final avatarResult = await _imageService.loadAvatar();
        avatarResult.fold(
          (_) => null,
          (b64) => _avatarBase64 = b64,
        );
      } else {
        _errorMessage = 'No user logged in';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<void> pickAndUploadAvatar() async {
    _isAvatarUploading = true;
    rebuild();
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 250,
        imageQuality: 75,
      );
      if (xfile == null) {
        return;
      }
      final result = await _imageService.saveAvatar(xfile);
      result.fold(
        (failure) => _errorMessage = failure.message,
        (b64) => _avatarBase64 = b64,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isAvatarUploading = false;
      rebuild();
    }
  }

  Future<bool> updateUserName(String newName) async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final result = await _authService.updateUserName(newName);
      return result.fold(
        (error) {
          _errorMessage = error.message;
          return false;
        },
        (success) {
          if (success) {
            _name = newName;
          }
          return success;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<bool> updateUserPassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final result = await _authService.updateUserPassword(newPassword);
      return result.fold(
        (error) {
          _errorMessage = error.message;
          return false;
        },
        (success) => success,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<Screen?> logout() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      await _authService.signOut();
      return Screen.signIn;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }
}

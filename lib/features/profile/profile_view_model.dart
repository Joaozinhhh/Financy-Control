import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _photoUrl = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final profile = await mockGetUserProfile();
      _name = profile['name']!;
      _email = profile['email']!;
      _photoUrl = profile['photoUrl']!;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<bool> updateUserName(String newName) async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      final success = await mockUpdateUserName(newName);
      if (success) {
        _name = newName;
      }
      return success;
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
      return await mockUpdateUserPassword(newPassword);
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      return await mockLogout();
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }
}

import 'dart:convert';

import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/core/models/user_model.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local data persistence using SharedPreferences
class LocalStorageService implements StorageService {
  LocalStorageService._();
  static LocalStorageService? _instance;
  factory LocalStorageService() => _instance ??= LocalStorageService._();

  SharedPreferences? _prefs;

  // Storage keys
  static const String _keyUsers = 'users';
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyTransactions = 'transactions';

  /// Initialize SharedPreferences instance
  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _storage {
    if (_prefs == null) {
      throw Exception(
        'LocalStorageService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  // ==================== User Management ====================

  /// Save a new user with password (password stored as hash for basic security)
  @override
  Future<bool> saveUser({
    required String id,
    required String name,
    required String email,
  }) async {
    final users = await _getAllUsers();
    
    // Check if email already exists
    if (users.any((u) => u['email'] == email)) {
      return false;
    }

    users.add({
      'id': id,
      'name': name,
      'email': email,
    });

    return _storage.setString(_keyUsers, jsonEncode(users));
  }

  /// Get all users (returns list of maps with user data including password)
  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    final usersJson = _storage.getString(_keyUsers);
    if (usersJson == null) return [];
    
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.cast<Map<String, dynamic>>();
  }

  /// Verify user credentials
  @override
  Future<UserModel?> verifyCredentials({
    required String email,
    required String password,
  }) async {
    final users = await _getAllUsers();
    
    try {
      final user = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );
      
      return UserModel(
        id: user['id'],
        name: user['name'],
        email: user['email'],
      );
    } catch (e) {
      return null; // User not found or password mismatch
    }
  }

  /// Get user by email
  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final users = await _getAllUsers();
    
    try {
      final user = users.firstWhere((u) => u['email'] == email);
      return UserModel(
        id: user['id'],
        name: user['name'],
        email: user['email'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Set current logged-in user
  @override
  Future<bool> setCurrentUser(String userId) async {
    return _storage.setString(_keyCurrentUserId, userId);
  }

  /// Get current logged-in user
  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = _storage.getString(_keyCurrentUserId);
    if (userId == null) return null;

    final users = await _getAllUsers();
    try {
      final user = users.firstWhere((u) => u['id'] == userId);
      return UserModel(
        id: user['id'],
        name: user['name'],
        email: user['email'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear current user (logout)
  @override
  Future<bool> clearCurrentUser() async {
    return _storage.remove(_keyCurrentUserId);
  }

  /// Update user name
  @override
  Future<bool> updateUserName(String userId, String newName) async {
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u['id'] == userId);
    
    if (index == -1) return false;
    
    users[index]['name'] = newName;
    return _storage.setString(_keyUsers, jsonEncode(users));
  }

  /// Update user password
  @override
  Future<bool> updateUserPassword(
    String userId,
    String newPassword,
  ) async {
    final users = await _getAllUsers();
    final index = users.indexWhere(
      (u) => u['id'] == userId,
    );
    
    if (index == -1) return false;
    
    users[index]['password'] = newPassword;
    return _storage.setString(_keyUsers, jsonEncode(users));
  }

  // ==================== Transaction Management ====================

  /// Save a transaction
  @override
  Future<bool> saveTransaction(TransactionModel transaction) async {
    final transactions = await _getAllTransactions();
    
    // Remove existing transaction with same ID (for updates)
    transactions.removeWhere((t) => t['id'] == transaction.id);
    
    transactions.add(transaction.toJson());
    return _storage.setString(_keyTransactions, jsonEncode(transactions));
  }

  /// Get all transactions (optionally filtered by date range)
  @override
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await _getAllTransactions();
    
    List<TransactionModel> result = transactions
        .map((json) => TransactionModel.fromJson(json))
        .toList();

    // Filter by date range
    if (startDate != null) {
      result = result.where(
        (t) => t.date.millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch,
      ).toList();
    }
    
    if (endDate != null) {
      result = result.where(
        (t) => t.date.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch,
      ).toList();
    }

    return result;
  }

  /// Get all transactions as JSON
  Future<List<Map<String, dynamic>>> _getAllTransactions() async {
    final transactionsJson = _storage.getString(_keyTransactions);
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = jsonDecode(transactionsJson);
    return transactionsList.cast<Map<String, dynamic>>();
  }

  /// Delete a transaction by ID
  @override
  Future<bool> deleteTransaction(String id) async {
    final transactions = await _getAllTransactions();
    transactions.removeWhere((t) => t['id'] == id);
    return _storage.setString(_keyTransactions, jsonEncode(transactions));
  }

  /// Get transaction by ID
  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final transactions = await _getAllTransactions();
    
    try {
      final json = transactions.firstWhere((t) => t['id'] == id);
      return TransactionModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Calculate total balance from all transactions
  @override
  Future<double> getBalance() async {
    final transactions = await getTransactions();
    return transactions.fold<double>(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  // ==================== Utility Methods ====================

  /// Clear all data (useful for testing or reset)
  @override
  Future<bool> clearAll() async {
    await _storage.remove(_keyUsers);
    await _storage.remove(_keyCurrentUserId);
    await _storage.remove(_keyTransactions);
    return true;
  }
}

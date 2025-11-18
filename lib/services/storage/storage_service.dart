import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/core/models/user_model.dart';

abstract class StorageService {
  Future<void> init();

  // User Management
  Future<bool> saveUser({
    required String id,
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel?> verifyCredentials({
    required String email,
    required String password,
  });

  Future<UserModel?> getUserByEmail(String email);

  Future<bool> setCurrentUser(String userId);

  Future<UserModel?> getCurrentUser();

  Future<bool> clearCurrentUser();

  Future<bool> updateUserName(String userId, String newName);

  Future<bool> updateUserPassword(String userId, String newPassword);

  // Transaction Management
  Future<bool> saveTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<bool> deleteTransaction(String id);

  Future<TransactionModel?> getTransactionById(String id);

  Future<double> getBalance();

  // Utility
  Future<bool> clearAll();
}

import 'package:financy_control/core/models/transaction_model.dart';

abstract class StorageService {
  // User Management
  Future<bool> saveUser({
    required String id,
    required String name,
    required String email,
  });

  // Transaction Management
  Future<bool> saveTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<bool> deleteTransaction(String id);

  Future<TransactionModel?> getTransactionById(String id);

  Future<double> getBalance();

  Future<bool> clearAll();
}

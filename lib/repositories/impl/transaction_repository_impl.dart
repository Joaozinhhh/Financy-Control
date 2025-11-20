import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/data/exceptions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
import 'package:financy_control/services/storage/storage_service.dart';
import 'package:uuid/uuid.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final StorageService _storage;

  TransactionRepositoryImpl({required StorageService storage}) : _storage = storage;

  @override
  Future<DataResult<TransactionModel>> createTransaction(
    TransactionInputModel input,
  ) async {
    try {
      final transaction = TransactionModel(
        id: const Uuid().v7(),
        amount: input.category.income ? input.amount ?? 0.0 : -(input.amount ?? 0.0),
        description: input.description,
        date: input.date,
        category: input.category,
      );

      await _storage.saveTransaction(transaction);
      return DataResult.success(transaction);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to create transaction'));
    }
  }

  @override
  Future<DataResult<bool>> deleteTransaction(String id) async {
    try {
      final success = await _storage.deleteTransaction(id);
      if (!success) {
        return DataResult.failure(const MockFailure('Transaction not found'));
      }
      return DataResult.success(true);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to delete transaction'));
    }
  }

  @override
  Future<DataResult<double>> getBalance() async {
    try {
      final balance = await _storage.getBalance();
      return DataResult.success(balance);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to get balance'));
    }
  }

  @override
  Future<DataResult<List<TransactionModel>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await _storage.getTransactions(
        startDate: startDate,
        endDate: endDate,
      );
      return DataResult.success(transactions);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to get transactions'));
    }
  }

  @override
  Future<DataResult<TransactionModel>> updateTransaction(
    String id,
    TransactionInputModel input,
  ) async {
    try {
      final existingTransaction = await _storage.getTransactionById(id);
      if (existingTransaction == null) {
        return DataResult.failure(const MockFailure('Transaction not found'));
      }

      final updatedTransaction = TransactionModel(
        id: id,
        amount: input.category.income
            ? input.amount ?? existingTransaction.amount
            : -(input.amount ?? existingTransaction.amount.abs()),
        description: input.description,
        date: input.date,
        category: input.category,
      );

      await _storage.saveTransaction(updatedTransaction);
      return DataResult.success(updatedTransaction);
    } catch (e) {
      return DataResult.failure(const MockFailure('Failed to update transaction'));
    }
  }
}

class MockFailure implements Failure {
  final String _message;
  const MockFailure(this._message);

  @override
  String get message => _message;
}

import 'package:financy_control/core/data/data_result.dart';
import 'package:financy_control/core/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<DataResult<List<TransactionModel>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<DataResult<TransactionModel>> createTransaction(
    TransactionInputModel transaction,
  );

  Future<DataResult<TransactionModel>> updateTransaction(
    String id,
    TransactionInputModel transaction,
  );

  Future<DataResult<bool>> deleteTransaction(String id);

  Future<DataResult<double>> getBalance();
}

import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/local_storage/local_storage_service.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/foundation.dart';

/// Simple Home ViewModel that loads the current balance and latest
/// transactions from the mock repository.
class HomeViewModel extends ChangeNotifier {
  double _balance = 0.0;
  List<TransactionModel> _latestTransactions = [];

  double get balance => _balance;
  List<TransactionModel> get latestTransactions => List.unmodifiable(_latestTransactions);

  Future<String> get userName async {
    final localStorage = LocalStorageService();
    final user = await localStorage.getCurrentUser();
    return user?.name ?? 'Guest';
  }

  /// Load balance and transactions (keeps only latest N sorted by date desc)
  Future<void> load({int latestCount = 5}) async {
    final transactions = await mockGetTransactions();

    _latestTransactions = transactions.take(latestCount).toList();

    _balance = await mockGetBalance();

    // notify listeners safely using extension
    rebuild();
  }

  /// Helper to compute total income
  double get totalIncome => _latestTransactions.where((t) => t.category.income).fold(0.0, (p, t) => p + t.amount);

  /// Helper to compute total outcome
  double get totalOutcome => _latestTransactions.where((t) => t.category.expense).fold(0.0, (p, t) => p + t.amount);
}

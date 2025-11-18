import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
import 'package:financy_control/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Simple Home ViewModel that loads the current balance and latest
/// transactions from the mock repository.
class HomeViewModel extends ChangeNotifier {
  final TransactionRepository _repository = locator<TransactionRepository>();
  final AuthService _authService = locator<AuthService>();

  double _balance = 0.0;
  List<TransactionModel> _latestTransactions = [];

  double get balance => _balance;
  List<TransactionModel> get latestTransactions => List.unmodifiable(_latestTransactions);

  Future<String> get userName async {
    return _authService.currentUser?.name ?? 'Guest';
  }

  /// Load balance and transactions (keeps only latest N sorted by date desc)
  Future<void> load({int latestCount = 5}) async {
    final transactionsResult = await _repository.getTransactions();
    
    transactionsResult.fold(
      (error) => _latestTransactions = [],
      (data) => _latestTransactions = data.take(latestCount).toList(),
    );

    final balanceResult = await _repository.getBalance();
    balanceResult.fold(
      (error) => _balance = 0.0,
      (data) => _balance = data,
    );

    // notify listeners safely using extension
    rebuild();
  }

  /// Helper to compute total income
  double get totalIncome => _latestTransactions.where((t) => t.category.income).fold(0.0, (p, t) => p + t.amount);

  /// Helper to compute total outcome
  double get totalOutcome => _latestTransactions.where((t) => t.category.expense).fold(0.0, (p, t) => p + t.amount);
}

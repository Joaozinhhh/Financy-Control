import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/material.dart';

class CategoryStatistic {
  final TransactionCategory category;
  final double total;
  final int count;

  CategoryStatistic({
    required this.category,
    required this.total,
    required this.count,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Computed statistics
  double get totalIncome {
    return _transactions
        .where((t) => t.category.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.category.expense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  double get netBalance => totalIncome - totalExpense;

  int get transactionCount => _transactions.length;

  List<CategoryStatistic> get incomeByCategory {
    final Map<TransactionCategory, List<TransactionModel>> grouped = {};
    
    for (final transaction in _transactions.where((t) => t.category.income)) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      return CategoryStatistic(
        category: entry.key,
        total: total,
        count: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  List<CategoryStatistic> get expenseByCategory {
    final Map<TransactionCategory, List<TransactionModel>> grouped = {};
    
    for (final transaction in _transactions.where((t) => t.category.expense)) {
      grouped.putIfAbsent(transaction.category, () => []).add(transaction);
    }

    return grouped.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, t) => sum + t.amount.abs());
      return CategoryStatistic(
        category: entry.key,
        total: total,
        count: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    rebuild();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    rebuild();
  }

  Future<void> fetchStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      _transactions = await mockGetTransactions(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      rebuild();
    }
  }
}

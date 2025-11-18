import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/locator.dart';
import 'package:financy_control/repositories/transaction_repository.dart';
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

class DailyStatistic {
  final DateTime date;
  final double income;
  final double expense;

  DailyStatistic({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  final TransactionRepository _repository = locator<TransactionRepository>();
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
        .fold(0.0, (sum, t) => sum + t.amount);
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
      final total = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      return CategoryStatistic(
        category: entry.key,
        total: total,
        count: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  List<DailyStatistic> get dailyStatistics {
    if (_startDate == null || _endDate == null) return [];
    
    final Map<DateTime, DailyStatistic> grouped = {};
    
    for (final transaction in _transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = DailyStatistic(date: date, income: 0.0, expense: 0.0);
      }
      
      if (transaction.category.income) {
        grouped[date] = DailyStatistic(
          date: date,
          income: grouped[date]!.income + transaction.amount,
          expense: grouped[date]!.expense,
        );
      } else if (transaction.category.expense) {
        grouped[date] = DailyStatistic(
          date: date,
          income: grouped[date]!.income,
          expense: grouped[date]!.expense + transaction.amount,
        );
      }
    }
    
    return grouped.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TransactionModel> get topTransactions {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return sorted.take(5).toList();
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
      final result = await _repository.getTransactions(
        startDate: _startDate,
        endDate: _endDate,
      );
      result.fold(
        (error) => _errorMessage = error.message,
        (data) => _transactions = data,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      rebuild();
    }
  }
}

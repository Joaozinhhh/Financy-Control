import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:flutter/foundation.dart';

class TransactionsViewModel extends ChangeNotifier {
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
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  ValueNotifier<DateTime?> get selectedDate => _selectedDate;
  final ValueNotifier<TransactionCategory> _selectedCategory =
      ValueNotifier<TransactionCategory>(IncomeCategory.other);
  ValueNotifier<TransactionCategory> get selectedCategory => _selectedCategory;

  final ValueNotifier<int> _currentTabIndex = ValueNotifier(0);
  ValueNotifier<int> get currentTabIndex => _currentTabIndex;

  void setSelectedCategory(TransactionCategory category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      rebuild();
    }
  }

  void setSelectedDate(DateTime date) async {
    if (_selectedDate.value != date) {
      _selectedDate.value = date;
      rebuild();
    }
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    rebuild();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    rebuild();
  }

  void setTabIndex(int index) {
    if (_currentTabIndex.value != index) {
      _currentTabIndex.value = index;
      rebuild();
    }
  }

  Future<void> fetchTransactions() async {
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

  Future<TransactionModel?> createTransaction(
    TransactionInputModel input,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      return await mockCreateTransaction(input);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }

  Future<TransactionModel?> updateTransaction(
    String id,
    TransactionInputModel input,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    rebuild();

    try {
      return await mockUpdateTransaction(id, input);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      rebuild();
    }
  }
}

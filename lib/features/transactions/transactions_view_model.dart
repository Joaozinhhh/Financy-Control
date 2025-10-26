import 'package:financy_control/core/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'package:financy_control/core/models/transaction_model.dart';

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

  void setStartDate(DateTime? date) {
    _startDate = date;
    rebuild();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    rebuild();
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
}

import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/services/mock_repository/mock_repository.dart';
import 'transactions_view_model.dart';
import 'package:intl/intl.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final TransactionsViewModel _viewModel = TransactionsViewModel();
  String _selectedRange = 'Day';
  String _currentRangeDisplay = DateFormat.yMMMd().format(DateTime.now());

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewModel.setStartDate(DateTime(now.year, now.month, now.day));
    _viewModel.setEndDate(DateTime(now.year, now.month, now.day, 23, 59, 59));
    _viewModel.addListener(_onViewModelChange);
    _viewModel.fetchTransactions();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  void _updateDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      _selectedRange = range;
      switch (range) {
        case 'Day':
          _currentRangeDisplay = DateFormat.yMMMd().format(now);
          _viewModel.setStartDate(DateTime(now.year, now.month, now.day));
          _viewModel.setEndDate(
            DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'Month':
          _currentRangeDisplay = DateFormat.yMMMM().format(now);
          _viewModel.setStartDate(DateTime(now.year, now.month, 1));
          _viewModel.setEndDate(
            DateTime(now.year, now.month + 1, 0, 23, 59, 59),
          );
          break;
        case 'Year':
          _currentRangeDisplay = DateFormat.y().format(now);
          _viewModel.setStartDate(DateTime(now.year, 1, 1));
          _viewModel.setEndDate(DateTime(now.year, 12, 31, 23, 59, 59));
          break;
      }
    });
    _viewModel.fetchTransactions();
  }

  void _navigateDateRange(String direction) {
    final startDate = _viewModel.startDate;
    final endDate = _viewModel.endDate;
    if (startDate == null || endDate == null) return;

    switch (_selectedRange) {
      case 'Day':
        final offset = direction == 'previous' ? -1 : 1;
        final newDate = startDate.add(Duration(days: offset));
        _viewModel.setStartDate(
          DateTime(newDate.year, newDate.month, newDate.day),
        );
        _viewModel.setEndDate(
          DateTime(newDate.year, newDate.month, newDate.day, 23, 59, 59),
        );
        _currentRangeDisplay = DateFormat.yMMMd().format(newDate);
        break;
      case 'Month':
        final offset = direction == 'previous' ? -1 : 1;
        final newMonth = DateTime(startDate.year, startDate.month + offset, 1);
        _viewModel.setStartDate(newMonth);
        _viewModel.setEndDate(
          DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59),
        );
        _currentRangeDisplay = DateFormat.yMMMM().format(newMonth);
        break;
      case 'Year':
        final offset = direction == 'previous' ? -1 : 1;
        final newYear = DateTime(startDate.year + offset, 1, 1);
        _viewModel.setStartDate(newYear);
        _viewModel.setEndDate(DateTime(newYear.year, 12, 31, 23, 59, 59));
        _currentRangeDisplay = DateFormat.y().format(newYear);
        break;
    }
    _viewModel.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _navigateDateRange('previous'),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PopupMenuButton<String>(
                      constraints: const BoxConstraints.tightFor(width: 100),
                      padding: EdgeInsets.zero,
                      menuPadding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      onSelected: _updateDateRange,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Day',
                          child: Center(child: Text('Day')),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Month',
                          child: Center(child: Text('Month')),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Year',
                          child: Center(child: Text('Year')),
                        ),
                      ],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints.tightFor(
                              width: 100,
                              height: kMinInteractiveDimension,
                            ),
                            child: Center(
                              child: Text(
                                _currentRangeDisplay,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _navigateDateRange('next'),
              ),
            ],
          ),
          Expanded(
            child: _viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _viewModel.errorMessage != null
                ? Center(child: Text('Error: ${_viewModel.errorMessage}'))
                : _viewModel.transactions.isEmpty
                ? const Center(child: Text('No transactions available.'))
                : ListView.builder(
                    itemCount: _viewModel.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _viewModel.transactions[index];
                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(
                          DateFormat.yMMMd().format(transaction.date),
                        ),
                        trailing: Text(transaction.amount.toStringAsFixed(2)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(Screen.transactionCreate.location);
          if (result != null) {
            _viewModel.fetchTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TransactionFormView extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormView({super.key, this.transaction});

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String? _description;
  DateTime? _date;
  bool _isLoading = false;
  String? _errorMessage;
  TransactionCategory _category = ExpenseCategory.other;
  TransactionCategory _selectedCategory = ExpenseCategory.other;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _description = widget.transaction!.description;
      _date = widget.transaction!.date;
      _category = widget.transaction!.category;
    }
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();

    setState(() => _isLoading = true);
    TransactionModel? transaction;
    try {
      if (widget.transaction == null) {
        transaction = await mockCreateTransaction(
          TransactionInputModel(
            amount: _amount,
            description: _description!,
            date: _date!,
            category: _category,
          ),
        );
      } else {
        transaction = await mockUpdateTransaction(
          widget.transaction!.id,
          TransactionInputModel(
            amount: _amount,
            description: _description!,
            date: _date!,
            category: _category,
          ),
        );
      }
      if (!mounted) return;
      context.pop(transaction);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save transaction.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Create Transaction'
              : 'Edit Transaction',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _amount?.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter an amount'
                          : null,
                      onSaved: (value) => _amount = double.tryParse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a description'
                          : null,
                      onSaved: (value) => _description = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _date == null
                                ? 'No date selected'
                                : '${_date!.toLocal()}',
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    RadioGroup<TransactionCategory>(
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Income'),
                          Radio<TransactionCategory>(
                            value: IncomeCategory.other,
                          ),
                          const Text('Expense'),
                          Radio<TransactionCategory>(
                            value: ExpenseCategory.other,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Text('Category: '),
                        const SizedBox(width: 8),
                        PopupMenuButton<TransactionCategory>(
                          initialValue: _category,
                          onSelected: (value) {
                            setState(() {
                              _category = value;
                            });
                          },
                          itemBuilder: (context) {
                            List<TransactionCategory> values = _category.income
                                ? IncomeCategory.values
                                : ExpenseCategory.values;
                            return values
                                .map(
                                  (c) => PopupMenuItem<TransactionCategory>(
                                    value: c,
                                    child: Text(c.description.capitalize()),
                                  ),
                                )
                                .toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_category.description.capitalize()),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

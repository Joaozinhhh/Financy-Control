import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'transactions_view_model.dart';

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

class _TransactionFormViewState extends State<TransactionFormView> with SingleTickerProviderStateMixin {
  double? _amount;
  String? _description;
  final TransactionsViewModel _viewModel = TransactionsViewModel();
  final ValueNotifier<bool> _validatorNotifier = ValueNotifier(false);
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _description = widget.transaction!.description;
      _viewModel.setSelectedDate(widget.transaction!.date);
      _viewModel.setSelectedCategory(widget.transaction!.category);
    }
    _tabController = TabController(length: 2, vsync: this);
    _viewModel.setTabIndex(
      widget.transaction != null
          ? widget.transaction!.category.income
              ? 0
              : 1
          : 0,
    );
  }

  void _processValidationChange() {
    final isValid =
        _amount != null &&
        _description != null &&
        _description!.isNotEmpty &&
        _viewModel.selectedDate.value != null;
    _validatorNotifier.value = isValid;
  }

  @override
  void dispose() {
    _validatorNotifier.dispose();
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _viewModel.setTabIndex(index);
            _viewModel.setSelectedCategory(
              index == 0
                  ? IncomeCategory.other
                  : ExpenseCategory.other,
            );
          },
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    onChanged: (value) {
                      _amount = double.tryParse(value);
                      _processValidationChange();
                    },
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
                    onChanged: (value) {
                      _description = value;
                      _processValidationChange();
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _viewModel.selectedDate,
                          builder: (context, value, child) {
                            return Text(
                              value == null
                                  ? 'No date selected'
                                  : '${value.toLocal()}',
                            );
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                _viewModel.selectedDate.value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            _viewModel.setSelectedDate(pickedDate);
                          }
                          _processValidationChange();
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text('Category: '),
                      const SizedBox(width: 8),
                      ValueListenableBuilder(
                        valueListenable: _viewModel.selectedCategory,
                        builder: (context, value, child) {
                          return PopupMenuButton<TransactionCategory>(
                            initialValue: value,
                            onSelected: (value) {
                              _viewModel.setSelectedCategory(value);
                              _processValidationChange();
                            },
                            itemBuilder: (context) {
                              List<TransactionCategory> values = value.income
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
                                  Text(value.description.capitalize()),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (_viewModel.errorMessage != null)
                    Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: _validatorNotifier,
                    builder: (context, value, child) {
                      return ElevatedButton(
                        onPressed: value
                            ? () {
                                if (widget.transaction == null) {
                                  _viewModel.createTransaction(
                                    TransactionInputModel(
                                      amount: _amount,
                                      description: _description!,
                                      date: _viewModel.selectedDate.value!,
                                      category:
                                          _viewModel.selectedCategory.value,
                                    ),
                                  );
                                } else {
                                  _viewModel.updateTransaction(
                                    widget.transaction!.id,
                                    TransactionInputModel(
                                      amount: _amount,
                                      description: _description!,
                                      date: _viewModel.selectedDate.value!,
                                      category:
                                          _viewModel.selectedCategory.value,
                                    ),
                                  );
                                }
                                context.pop(true);
                              }
                            : null,
                        child: const Text('Save'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

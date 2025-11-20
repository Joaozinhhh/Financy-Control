import 'package:financy_control/core/components/buttons.dart';
import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/core/components/textfields.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/core/models/transaction_model.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'transactions_view_model.dart';

const _fixedSize = Size(220, 50);

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> with GoRouterAware {
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
  void didPopNext() {
    super.didPopNext();
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
        flexibleSpace: kFlexibleSpace,
        title: Text(
          context.translations.transactionsTitle,
        ),
        actions: [launchUrl('https://example.com')], // TODO: replace with actual URL
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xff38b6ff),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 128,
                alignment: Alignment.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                color: Theme.of(context).colorScheme.primary,
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
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Day',
                          child: Center(child: Text(context.translations.day)),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Month',
                          child: Center(child: Text(context.translations.month)),
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          value: 'Year',
                          child: Center(child: Text(context.translations.year)),
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
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _navigateDateRange('next'),
              ),
            ],
          ),
          Expanded(
            child: _viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _viewModel.errorMessage != null
                ? Center(child: Text('${context.translations.error}: ${_viewModel.errorMessage}'))
                : _viewModel.transactions.isEmpty
                ? Center(child: Text(context.translations.noTransactionsAvailable))
                : ListView.builder(
                    itemCount: _viewModel.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _viewModel.transactions[index];
                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(
                          DateFormat.yMMMd().format(transaction.date),
                        ),
                        trailing: Text(
                          NumberFormat.simpleCurrency().format(
                            transaction.amount,
                          ),
                        ),
                        onTap: () async {
                          final result = await context.push(
                            Screen.transactionView.location,
                            extra: transaction,
                          );
                          if (result != null) {
                            _viewModel.fetchTransactions();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await context.push(Screen.transactionCreate.location),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SingleTransactionView extends StatefulWidget {
  const SingleTransactionView.edit({super.key, this.transaction}) : _isEditMode = true;
  const SingleTransactionView.view({super.key, this.transaction}) : _isEditMode = false;
  const SingleTransactionView.create({super.key}) : transaction = null, _isEditMode = true;
  final TransactionModel? transaction;
  final bool _isEditMode;

  @override
  State<SingleTransactionView> createState() => _SingleTransactionViewState();
}

class _SingleTransactionViewState extends State<SingleTransactionView> {
  double? _amount;
  String? _description;
  final TransactionsViewModel _viewModel = TransactionsViewModel();
  final ValueNotifier<bool> _validatorNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount.abs();
      _description = widget.transaction!.description;
      _viewModel.setSelectedDate(widget.transaction!.date);
      _viewModel.setSelectedCategory(widget.transaction!.category);
    }
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
        _amount != null && _description != null && _description!.isNotEmpty && _viewModel.selectedDate.value != null;
    _validatorNotifier.value = isValid;
  }

  @override
  void dispose() {
    _validatorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xff38b6ff),
            ),
          ),
          title: Text(
            widget.transaction == null
                ? context.translations.createTransaction
                : widget._isEditMode
                ? context.translations.editTransaction
                : context.translations.transactionDetails,
          ),
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 64 + MediaQuery.paddingOf(context).top,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xff38b6ff),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              left: 16,
              right: 16,
              top: 64 / 3 + MediaQuery.paddingOf(context).top,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.transaction == null) ...[
                      Card(
                        margin: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _viewModel.currentTabIndex,
                                  builder: (context, currentIndex, child) {
                                    void onPressed() {
                                      _viewModel.setTabIndex(0);
                                      _viewModel.setSelectedCategory(
                                        IncomeCategory.other,
                                      );
                                    }

                                    final child = Text(context.translations.income);

                                    return currentIndex == 0
                                        ? FCButton.primary(
                                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                              minimumSize: WidgetStateProperty.all<Size>(
                                                _fixedSize,
                                              ),
                                            ),
                                            onPressed: onPressed,
                                            child: child,
                                          )
                                        : FCButton.secondary(
                                            style: Theme.of(context).textButtonTheme.style?.copyWith(
                                              minimumSize: WidgetStateProperty.all<Size>(
                                                _fixedSize,
                                              ),
                                            ),
                                            onPressed: onPressed,
                                            child: child,
                                          );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _viewModel.currentTabIndex,
                                  builder: (context, currentIndex, child) {
                                    void onPressed() {
                                      _viewModel.setTabIndex(1);
                                      _viewModel.setSelectedCategory(
                                        ExpenseCategory.other,
                                      );
                                    }

                                    final child = Text(context.translations.expenses);
                                    return currentIndex == 1
                                        ? FCButton.primary(
                                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                              minimumSize: WidgetStateProperty.all<Size>(
                                                _fixedSize,
                                              ),
                                            ),
                                            onPressed: onPressed,
                                            child: child,
                                          )
                                        : FCButton.secondary(
                                            style: Theme.of(context).textButtonTheme.style?.copyWith(
                                              minimumSize: WidgetStateProperty.all<Size>(
                                                _fixedSize,
                                              ),
                                            ),
                                            onPressed: onPressed,
                                            child: child,
                                          );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FCTextField(
                                initialValue: _amount?.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration().copyWith(
                                  labelText: context.translations.amount,
                                ),
                                validator: (value) => value == null || value.isEmpty ? context.translations.enterAmount : null,
                                onChanged: (value) {
                                  _amount = double.tryParse(value);
                                  _processValidationChange();
                                },
                              ),
                              const SizedBox(height: 16),
                              FCTextField(
                                initialValue: _description,
                                decoration: const InputDecoration().copyWith(
                                  labelText: context.translations.description,
                                ),
                                validator: (value) => value == null || value.isEmpty ? context.translations.enterDescription : null,
                                onChanged: (value) {
                                  _description = value;
                                  _processValidationChange();
                                },
                              ),
                              const SizedBox(height: 16),
                              ValueListenableBuilder<TransactionCategory?>(
                                valueListenable: _viewModel.selectedCategory,
                                builder: (context, selected, child) {
                                  final List<TransactionCategory> values =
                                      selected?.income == true || _viewModel.currentTabIndex.value == 0
                                      ? IncomeCategory.values
                                      : ExpenseCategory.values;
                                  return DropdownButtonFormField<TransactionCategory>(
                                    initialValue: selected,
                                    hint: Text(context.translations.selectCategory),
                                    items: values
                                        .map(
                                          (c) => DropdownMenuItem<TransactionCategory>(
                                            value: c,
                                            child: Text(
                                              c.description.capitalize(),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _viewModel.setSelectedCategory(
                                        value,
                                      );
                                      _processValidationChange();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Flexible(
                                child: ValueListenableBuilder<DateTime?>(
                                  valueListenable: _viewModel.selectedDate,
                                  builder: (context, value, child) {
                                    final displayText = value == null
                                        ? ''
                                        : DateFormat.yMMMd().format(
                                            value,
                                          );
                                    return FCTextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: displayText,
                                      ),
                                      decoration: const InputDecoration().copyWith(
                                        labelText: 'Date',
                                        hintText: 'Select a date',
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () async {
                                            final pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: value ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (pickedDate != null) {
                                              _viewModel.setSelectedDate(
                                                pickedDate,
                                              );
                                              _processValidationChange();
                                            }
                                          },
                                        ),
                                      ),
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: value ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (pickedDate != null) {
                                          _viewModel.setSelectedDate(
                                            pickedDate,
                                          );
                                          _processValidationChange();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              if (_viewModel.errorMessage != null)
                                Text(
                                  _viewModel.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              ValueListenableBuilder(
                                valueListenable: _validatorNotifier,
                                builder: (context, value, child) {
                                  return FCButton.primary(
                                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                      minimumSize: WidgetStateProperty.all<Size>(
                                        _fixedSize,
                                      ),
                                    ),
                                    onPressed: value
                                        ? () {
                                            assert(
                                              _viewModel.selectedCategory.value != null,
                                            );
                                            assert(
                                              _viewModel.selectedDate.value != null,
                                            );
                                            if (widget.transaction == null) {
                                              _viewModel.createTransaction(
                                                TransactionInputModel(
                                                  amount: _amount,
                                                  description: _description!,
                                                  date: _viewModel.selectedDate.value!,
                                                  category: _viewModel.selectedCategory.value!,
                                                ),
                                              );
                                            } else {
                                              _viewModel.updateTransaction(
                                                widget.transaction!.id,
                                                TransactionInputModel(
                                                  amount: _amount,
                                                  description: _description!,
                                                  date: _viewModel.selectedDate.value!,
                                                  category: _viewModel.selectedCategory.value!,
                                                ),
                                              );
                                            }
                                            context.pop(true);
                                          }
                                        : null,
                                    child: Text(context.translations.save),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (widget.transaction != null && widget._isEditMode) ...[
                      // edit mode only
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // amount
                              FCTextField(
                                initialValue: widget.transaction!.amount.abs().toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration().copyWith(
                                  labelText: context.translations.amount,
                                ),
                                onChanged: (value) {
                                  _amount = double.tryParse(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              // description
                              FCTextField(
                                initialValue: widget.transaction!.description,
                                decoration: const InputDecoration().copyWith(
                                  labelText: context.translations.description,
                                ),
                                onChanged: (value) {
                                  _description = value;
                                },
                              ),
                              const SizedBox(height: 16),
                              // category
                              DropdownButtonFormField<TransactionCategory>(
                                initialValue: widget.transaction!.category,
                                hint: const Text('Select Category'),
                                items:
                                    (widget.transaction!.category.income
                                            ? IncomeCategory.values
                                            : ExpenseCategory.values)
                                        .cast<TransactionCategory>()
                                        .map(
                                          (c) => DropdownMenuItem<TransactionCategory>(
                                            value: c,
                                            child: Text(
                                              c.description.capitalize(),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  _viewModel.setSelectedCategory(value);
                                },
                              ),
                              const SizedBox(height: 16),
                              // date
                              Flexible(
                                child: ValueListenableBuilder<DateTime?>(
                                  valueListenable: _viewModel.selectedDate,
                                  builder: (context, value, child) {
                                    final displayText = value == null
                                        ? ''
                                        : DateFormat.yMMMd().format(
                                            value,
                                          );
                                    return FCTextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: displayText,
                                      ),
                                      decoration: const InputDecoration().copyWith(
                                        labelText: 'Date',
                                        hintText: 'Select a date',
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () async {
                                            final pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: value ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (pickedDate != null) {
                                              _viewModel.setSelectedDate(
                                                pickedDate,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: value ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (pickedDate != null) {
                                          _viewModel.setSelectedDate(
                                            pickedDate,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              FCButton.primary(
                                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                  minimumSize: WidgetStateProperty.all<Size>(
                                    _fixedSize,
                                  ),
                                ),
                                onPressed: () {
                                  assert(_amount != null);
                                  assert(_description != null);
                                  _viewModel.updateTransaction(
                                    widget.transaction!.id,
                                    TransactionInputModel(
                                      amount: _amount,
                                      description: _description!,
                                      date: widget.transaction!.date,
                                      category: widget.transaction!.category,
                                    ),
                                  );
                                  context.pop(true);
                                },
                                child: Text(context.translations.saveChanges),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (widget.transaction != null && !widget._isEditMode)
                      // view mode only
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // status
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${context.translations.amount}:'),
                                  Text(
                                    NumberFormat.simpleCurrency().format(
                                      widget.transaction!.amount,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${context.translations.date}:'),
                                  Text(
                                    DateFormat.yMMMd().format(
                                      widget.transaction!.date,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // category
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${context.translations.category}:'),
                                  Text(
                                    widget.transaction!.category.description.capitalize(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // description
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${context.translations.description}:'),
                                  Text(
                                    widget.transaction!.description,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // edit button
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: FCButton.primary(
                                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                    minimumSize: WidgetStateProperty.all<Size>(
                                      _fixedSize,
                                    ),
                                  ),
                                  onPressed: () async {
                                    context.replace(
                                      Screen.transactionEdit.location,
                                      extra: widget.transaction,
                                    );
                                  },
                                  child: Text(context.translations.edit),
                                ),
                              ),
                              // delete button
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: FCButton.danger(
                                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                    minimumSize: WidgetStateProperty.all<Size>(_fixedSize),
                                  ),
                                  onPressed: () {
                                    _viewModel.deleteTransaction(
                                      widget.transaction!.id,
                                    );
                                    context.pop(true);
                                  },
                                  child: Text(context.translations.delete),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

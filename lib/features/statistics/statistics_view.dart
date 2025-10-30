import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/statistics/statistics_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final StatisticsViewModel _viewModel = StatisticsViewModel();
  String _selectedRange = 'Month';
  String _currentRangeDisplay = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentRangeDisplay = DateFormat.yMMMM().format(now);
    _viewModel.setStartDate(DateTime(now.year, now.month, 1));
    _viewModel.setEndDate(DateTime(now.year, now.month + 1, 0, 23, 59, 59));
    _viewModel.addListener(_onViewModelChange);
    _viewModel.fetchStatistics();
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
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        _currentRangeDisplay =
            '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(now)}';
        _viewModel.setStartDate(
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        );
        _viewModel.setEndDate(DateTime(now.year, now.month, now.day, 23, 59, 59));
        break;
      case 'Month':
        _currentRangeDisplay = DateFormat.yMMMM().format(now);
        _viewModel.setStartDate(DateTime(now.year, now.month, 1));
        _viewModel.setEndDate(DateTime(now.year, now.month + 1, 0, 23, 59, 59));
        break;
      case 'Year':
        _currentRangeDisplay = DateFormat.y().format(now);
        _viewModel.setStartDate(DateTime(now.year, 1, 1));
        _viewModel.setEndDate(DateTime(now.year, 12, 31, 23, 59, 59));
        break;
    }
    _viewModel.fetchStatistics();
  }

  void _navigateDateRange(String direction) {
    final startDate = _viewModel.startDate;
    final endDate = _viewModel.endDate;
    if (startDate == null || endDate == null) return;

    switch (_selectedRange) {
      case 'Week':
        final offset = direction == 'previous' ? -7 : 7;
        final newStart = startDate.add(Duration(days: offset));
        final newEnd = endDate.add(Duration(days: offset));
        _viewModel.setStartDate(
          DateTime(newStart.year, newStart.month, newStart.day),
        );
        _viewModel.setEndDate(
          DateTime(newEnd.year, newEnd.month, newEnd.day, 23, 59, 59),
        );
        _currentRangeDisplay =
            '${DateFormat.MMMd().format(newStart)} - ${DateFormat.MMMd().format(newEnd)}';
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
    _viewModel.fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.errorMessage != null
              ? Center(child: Text('Error: ${_viewModel.errorMessage}'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date range selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => _navigateDateRange('previous'),
                          ),
                          Flexible(
                            child: PopupMenuButton<String>(
                              onSelected: _updateDateRange,
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'Week',
                                  child: Text('Week'),
                                ),
                                PopupMenuItem(
                                  value: 'Month',
                                  child: Text('Month'),
                                ),
                                PopupMenuItem(
                                  value: 'Year',
                                  child: Text('Year'),
                                ),
                              ],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentRangeDisplay,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _navigateDateRange('next'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Income',
                              amount: _viewModel.totalIncome,
                              color: Colors.green,
                              icon: Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Expenses',
                              amount: _viewModel.totalExpense,
                              color: Colors.red,
                              icon: Icons.arrow_downward,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryCard(
                        title: 'Net Balance',
                        amount: _viewModel.netBalance,
                        color: _viewModel.netBalance >= 0
                            ? Colors.blue
                            : Colors.orange,
                        icon: Icons.account_balance_wallet,
                      ),
                      const SizedBox(height: 24),

                      // Transaction count
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Transactions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${_viewModel.transactionCount}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Income by category
                      if (_viewModel.incomeByCategory.isNotEmpty) ...[
                        Text(
                          'Income by Category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ..._viewModel.incomeByCategory.map(
                          (stat) => _CategoryStatisticTile(
                            statistic: stat,
                            totalAmount: _viewModel.totalIncome,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Expenses by category
                      if (_viewModel.expenseByCategory.isNotEmpty) ...[
                        Text(
                          'Expenses by Category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ..._viewModel.expenseByCategory.map(
                          (stat) => _CategoryStatisticTile(
                            statistic: stat,
                            totalAmount: _viewModel.totalExpense,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      // Empty state
                      if (_viewModel.transactionCount == 0)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions in this period',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStatisticTile extends StatelessWidget {
  final CategoryStatistic statistic;
  final double totalAmount;
  final Color color;

  const _CategoryStatisticTile({
    required this.statistic,
    required this.totalAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalAmount > 0
        ? (statistic.total / totalAmount * 100)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statistic.category.description.capitalize(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '\$${statistic.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${statistic.count} transaction${statistic.count != 1 ? 's' : ''}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

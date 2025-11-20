import 'package:collection/collection.dart';
import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/statistics/statistics_view_model.dart';
import 'package:financy_control/router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import CategoryStatistic export from view model
export 'package:financy_control/features/statistics/statistics_view_model.dart' show CategoryStatistic;

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> with GoRouterAware {
  final StatisticsViewModel _viewModel = StatisticsViewModel();
  String _selectedRange = 'Month';
  String _currentRangeDisplay = '';
  bool _showIncomeCategories = false;

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
  void didPushNext() {
    super.didPushNext();
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
      case 'Day':
        _currentRangeDisplay = DateFormat.yMMMd().format(now);
        _viewModel.setStartDate(DateTime(now.year, now.month, now.day));
        _viewModel.setEndDate(
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
        break;
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        _currentRangeDisplay = '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(endOfWeek)}';
        _viewModel.setStartDate(
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        );
        _viewModel.setEndDate(
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
        );
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
        _currentRangeDisplay = '${DateFormat.MMMd().format(newStart)} - ${DateFormat.MMMd().format(newEnd)}';
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
        flexibleSpace: kFlexibleSpace,
        title: Text(context.translations.statisticsTitle),
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
                alignment: Alignment.center,
                constraints: const BoxConstraints.tightFor(height: 128),
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _viewModel.errorMessage != null
                  ? Center(child: Text('Error: ${_viewModel.errorMessage}'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _RangeButton(
                                  label: context.translations.day,
                                  isSelected: _selectedRange == 'Day',
                                  onTap: () => _updateDateRange('Day'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _RangeButton(
                                  label: context.translations.week,
                                  isSelected: _selectedRange == 'Week',
                                  onTap: () => _updateDateRange('Week'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _RangeButton(
                                  label: context.translations.month,
                                  isSelected: _selectedRange == 'Month',
                                  onTap: () => _updateDateRange('Month'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _RangeButton(
                                  label: context.translations.year,
                                  isSelected: _selectedRange == 'Year',
                                  onTap: () => _updateDateRange('Year'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Date navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () => _navigateDateRange('previous'),
                              ),
                              Text(
                                _currentRangeDisplay,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () => _navigateDateRange('next'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Income and Expense cards
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: context.translations.income,
                                  amount: _viewModel.totalIncome,
                                  color: Colors.green,
                                  icon: Icons.arrow_upward,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  title: context.translations.expenses,
                                  amount: _viewModel.totalExpense,
                                  color: Colors.red,
                                  icon: Icons.arrow_downward,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Chart section
                          if (_viewModel.transactionCount > 0) ...[
                            SegmentedButton<bool>(
                              segments: [
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text(context.translations.expenses),
                                  icon: const Icon(Icons.arrow_downward, size: 16),
                                ),
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text(context.translations.income),
                                  icon: const Icon(Icons.arrow_upward, size: 16),
                                ),
                              ],
                              selected: {_showIncomeCategories},
                              onSelectionChanged: (Set<bool> newSelection) => setState(
                                () => _showIncomeCategories = newSelection.first,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              child: SizedBox(
                                height: 300,
                                child: _CategoryPieChartWidget(
                                  categories: _showIncomeCategories
                                      ? _viewModel.incomeByCategory
                                      : _viewModel.expenseByCategory,
                                  isIncome: _showIncomeCategories,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Top Transactions
                          if (_viewModel.topTransactions.isNotEmpty) ...[
                            Text(
                              context.translations.topTransactions,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            ..._viewModel.topTransactions.map(
                              (transaction) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: transaction.category.income
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.red.withValues(alpha: 0.2),
                                    child: Icon(
                                      transaction.category.income ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: transaction.category.income ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(transaction.description),
                                  subtitle: Text(
                                    '${transaction.category.description.capitalize()} - ${DateFormat.MMMd().format(transaction.date)}',
                                  ),
                                  trailing: Text(
                                    NumberFormat.simpleCurrency().format(transaction.amount),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: transaction.category.income ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
                                      context.translations.noTransactionsInPeriod,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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

class _CategoryPieChartWidget extends StatefulWidget {
  final List<CategoryStatistic> categories;
  final bool isIncome;

  const _CategoryPieChartWidget({
    required this.categories,
    required this.isIncome,
  });

  @override
  State<_CategoryPieChartWidget> createState() => _CategoryPieChartWidgetState();
}

class _CategoryPieChartWidgetState extends State<_CategoryPieChartWidget> {
  int touchedIndex = -1;

  // Predefined colors for categories
  static const List<Color> _categoryColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
    Color(0xFF3B82F6), // Blue
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.isIncome ? 'income' : 'expense'} categories',
        ),
      );
    }

    final total = widget.categories.fold(0.0, (sum, cat) => sum + cat.total);

    return Row(
      children: [
        Expanded(
          flex: 7,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: 48,
              sections: widget.categories.mapIndexed((index, category) {
                final isTouched = index == touchedIndex;
                final percentage = (category.total / total * 100).toStringAsFixed(1);

                return PieChartSectionData(
                  color: _categoryColors[index % _categoryColors.length],
                  value: category.total,
                  title: isTouched ? '$percentage%' : '',
                  radius: isTouched ? 70 : 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.total / total * 100).toStringAsFixed(1);
              final color = _categoryColors[index % _categoryColors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryLegendItem(
                  color: color,
                  label: category.category.description.capitalize(),
                  value: category.total,
                  percentage: percentage,
                  count: category.count,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final String percentage;
  final int count;

  const _CategoryLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

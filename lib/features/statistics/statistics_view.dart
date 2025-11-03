import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/statistics/statistics_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
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
        _currentRangeDisplay =
            '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(endOfWeek)}';
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
                  // Range selector buttons
                  Row(
                    children: [
                      Expanded(
                        child: _RangeButton(
                          label: 'Day',
                          isSelected: _selectedRange == 'Day',
                          onTap: () => _updateDateRange('Day'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RangeButton(
                          label: 'Week',
                          isSelected: _selectedRange == 'Week',
                          onTap: () => _updateDateRange('Week'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RangeButton(
                          label: 'Month',
                          isSelected: _selectedRange == 'Month',
                          onTap: () => _updateDateRange('Month'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RangeButton(
                          label: 'Year',
                          isSelected: _selectedRange == 'Year',
                          onTap: () => _updateDateRange('Year'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _navigateDateRange('previous'),
                      ),
                      Text(
                        _currentRangeDisplay,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
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
                  const SizedBox(height: 24),

                  // Chart section
                  if (_viewModel.transactionCount > 0) ...[
                    Text(
                      'Income vs Expense Trend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 250,
                          child: _LineChartWidget(
                            dailyStats: _viewModel.dailyStatistics,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Top Transactions
                  if (_viewModel.topTransactions.isNotEmpty) ...[
                    Text(
                      'Top Transactions',
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
                              transaction.category.income
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transaction.category.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(transaction.description),
                          subtitle: Text(
                            '${transaction.category.description.capitalize()} • ${DateFormat.MMMd().format(transaction.date)}',
                          ),
                          trailing: Text(
                            '\$${transaction.amount.abs().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: transaction.category.income
                                      ? Colors.green
                                      : Colors.red,
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
                              'No transactions in this period',
                              style: Theme.of(context).textTheme.titleMedium
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
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
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

class _LineChartWidget extends StatelessWidget {
  final List<DailyStatistic> dailyStats;

  const _LineChartWidget({required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final incomeSpots = dailyStats.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.income);
    }).toList();

    final expenseSpots = dailyStats.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.expense);
    }).toList();

    final maxY =
        dailyStats
            .map(
              (stat) => stat.income > stat.expense ? stat.income : stat.expense,
            )
            .reduce((a, b) => a > b ? a : b) +
        10;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: dailyStats.length > 10 ? dailyStats.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailyStats.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.MMMd().format(dailyStats[index].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        minX: 0,
        maxX: (dailyStats.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: false,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: false,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.red,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                Colors.blueGrey.withValues(alpha: 0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final date = dailyStats[flSpot.x.toInt()].date;
                final isIncome = barSpot.barIndex == 0;

                return LineTooltipItem(
                  '${DateFormat.MMMd().format(date)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${isIncome ? 'Income' : 'Expense'}: \$${flSpot.y.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}

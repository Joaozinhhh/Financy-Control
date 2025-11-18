import 'package:financy_control/core/components/constants.dart';
import 'package:financy_control/core/extensions.dart';
import 'package:financy_control/features/reports/reports_view_model.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with GoRouterAware {
  final ReportsViewModel _viewModel = ReportsViewModel();
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
    _viewModel.fetchTransactions();
  }

  @override
  void didChangeTop() {
    super.didChangeTop();
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
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        _currentRangeDisplay = '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(now)}';
        _viewModel.setStartDate(
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        );
        _viewModel.setEndDate(DateTime(now.year, now.month, now.day, 23, 59, 59));
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
      case 'All':
        _currentRangeDisplay = 'All Time';
        _viewModel.setStartDate(null);
        _viewModel.setEndDate(null);
        break;
    }
    _viewModel.fetchTransactions();
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
    _viewModel.fetchTransactions();
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              subtitle: const Text('Share via apps (email, messaging, etc.)'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.generateAndSharePdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print PDF'),
              subtitle: const Text('Print or preview before saving'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.printPdf();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: kFlexibleSpace,
        title: const Text('Reports'),
        actions: [kDefaultUrlLauncher],
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date range selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                color: Theme.of(context).colorScheme.primary,
                                icon: const Icon(Icons.arrow_back),
                                onPressed: _selectedRange == 'All' ? null : () => _navigateDateRange('previous'),
                              ),
                              Flexible(
                                child: DefaultTextStyle(
                                  style: Theme.of(context).textTheme.bodyMedium!,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PopupMenuButton<String>(
                                        constraints: const BoxConstraints.tightFor(width: 100),
                                        padding: EdgeInsets.zero,
                                        menuPadding: EdgeInsets.zero,
                                        onSelected: _updateDateRange,
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'Week',
                                            child: Center(child: Text('Week')),
                                          ),
                                          PopupMenuItem(
                                            value: 'Month',
                                            child: Center(child: Text('Month')),
                                          ),
                                          PopupMenuItem(
                                            value: 'Year',
                                            child: Center(child: Text('Year')),
                                          ),
                                          PopupMenuItem(
                                            value: 'All',
                                            child: Center(child: Text('All Time')),
                                          ),
                                        ],
                                        child: ConstrainedBox(
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                color: Theme.of(context).colorScheme.primary,
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: _selectedRange == 'All' ? null : () => _navigateDateRange('next'),
                              ),
                            ],
                          ),

                          // Summary Section
                          Text(
                            'Report Summary',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _SummaryCard(
                            title: 'Total Income',
                            value: '\$${_viewModel.totalIncome.toStringAsFixed(2)}',
                            color: Colors.green,
                            icon: Icons.arrow_upward,
                          ),
                          const SizedBox(height: 8),
                          _SummaryCard(
                            title: 'Total Expenses',
                            value: '\$${_viewModel.totalExpense.toStringAsFixed(2)}',
                            color: Colors.red,
                            icon: Icons.arrow_downward,
                          ),
                          const SizedBox(height: 8),
                          _SummaryCard(
                            title: 'Net Balance',
                            value: '\$${_viewModel.netBalance.toStringAsFixed(2)}',
                            color: _viewModel.netBalance >= 0 ? Colors.blue : Colors.orange,
                            icon: Icons.account_balance_wallet,
                          ),
                          const SizedBox(height: 8),
                          _SummaryCard(
                            title: 'Total Transactions',
                            value: '${_viewModel.transactions.length}',
                            color: Colors.purple,
                            icon: Icons.list_alt,
                          ),
                          const SizedBox(height: 24),

                          // Category Breakdowns
                          if (_viewModel.incomeCategories.isNotEmpty) ...[
                            Text(
                              'Income Breakdown',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            ..._viewModel.incomeCategories.map(
                              (cat) => _CategoryReportTile(
                                category: cat,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (_viewModel.expenseCategories.isNotEmpty) ...[
                            Text(
                              'Expense Breakdown',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            ..._viewModel.expenseCategories.map(
                              (cat) => _CategoryReportTile(
                                category: cat,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Export Button
                          if (_viewModel.transactions.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _viewModel.isGeneratingPdf ? null : _showExportOptions,
                              icon: _viewModel.isGeneratingPdf
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(
                                _viewModel.isGeneratingPdf ? 'Generating PDF...' : 'Export Report as PDF',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),

                          // Empty state
                          if (_viewModel.transactions.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions in this period',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add some transactions to generate reports',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              value,
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

class _CategoryReportTile extends StatelessWidget {
  final CategoryTotal category;
  final Color color;

  const _CategoryReportTile({
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.category.description.capitalize(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${category.count} transaction${category.count != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${category.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${category.percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
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

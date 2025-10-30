import 'package:financy_control/features/home/home_view_model.dart';
import 'package:financy_control/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
  }

  void _onViewModelChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: Localizations.localeOf(context).toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push(Screen.transactions.location),
            tooltip: 'All transactions',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _viewModel.load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Balance', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        currency.format(_viewModel.balance),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Income', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text(
                                  currency.format(_viewModel.totalIncome),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Outcome', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text(
                                  currency.format(_viewModel.totalOutcome),
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Latest Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_viewModel.latestTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('No recent transactions', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push(Screen.transactions.location),
                        child: const Text('Add or view transactions'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _viewModel.latestTransactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = _viewModel.latestTransactions[index];
                    final isIncome = t.category.income;
                    final amountText = (isIncome ? '+' : '-') + currency.format(t.amount);
                    final amountColor = isIncome ? Colors.green : Colors.red;
                    return ListTile(
                      title: Text(t.description),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(t.date)),
                      trailing: Text(amountText, style: TextStyle(color: amountColor, fontWeight: FontWeight.w600)),
                      onTap: () => context.push(Screen.transactions.location, extra: t),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

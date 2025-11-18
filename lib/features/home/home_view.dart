import 'package:financy_control/core/components/constants.dart';
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

class _HomeViewState extends State<HomeView> with GoRouterAware {
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void didPopNext() {
    super.didPopNext();
    _viewModel.load();
  }

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
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(flexibleSpace: kFlexibleSpace),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.topLeft,
            decoration: const BoxDecoration(
              color: Color(0xFF38b6ff),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 128,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                            ),
                          ),
                          FutureBuilder<String>(
                            future: _viewModel.userName,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                                return Text(
                                  snapshot.data ?? 'Guest',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 128 - 48,
                  left: 16,
                  right: 16,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(height: 180),
                    child: Card(
                      color: const Color(0xFF33a8eb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currency.format(_viewModel.balance),
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF5e17eb),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(
                                            8.0,
                                          ),
                                          child: const SizedBox.square(
                                            dimension: 24,
                                            child: FittedBox(
                                              child: Icon(
                                                Icons.arrow_downward,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Income',
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              currency.format(
                                                _viewModel.totalIncome,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xff5e17eb),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(
                                            8.0,
                                          ),
                                          child: const SizedBox.square(
                                            dimension: 24,
                                            child: FittedBox(
                                              child: Icon(
                                                Icons.arrow_upward,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Outcome',
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              currency.format(
                                                _viewModel.totalOutcome,
                                              ),
                                            ),
                                          ],
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
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: kDefaultUrlLauncher,
                ),
              ],
            ),
          ),
          SizedBox(height: 128 - 48 + MediaQuery.paddingOf(context).top),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Latest Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_viewModel.latestTransactions.isEmpty)
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No recent transactions',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go(Screen.transactions.location),
                        child: const Text('Add or view transactions'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _viewModel.latestTransactions.map((t) {
                    final isIncome = t.category.income;
                    final amountText = currency.format(t.amount);
                    final amountColor = isIncome ? Colors.green : Colors.red;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(t.description),
                          subtitle: Text(
                            DateFormat.yMMMd().format(t.date),
                          ),
                          trailing: Text(
                            amountText,
                            style: TextStyle(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => context.push(
                            Screen.transactionView.location,
                            extra: t,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

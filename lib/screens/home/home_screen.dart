import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsight();
    });
  }

  Future<void> _loadInsight() async {
    final appProvider = context.read<AppProvider>();
    final financeProvider = context.read<FinanceProvider>();
    await financeProvider.generateInsight(appProvider.geminiService);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final recentTransactions = financeProvider.currentMonthTransactions
          ..sort((a, b) => b.date.compareTo(a.date));

        return RefreshIndicator(
          onRefresh: _loadInsight,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(now),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // AI Insight Card
                InsightCard(
                  insight: financeProvider.currentInsight,
                  isLoading: financeProvider.isLoading,
                  onRefresh: _loadInsight,
                  onTap: () {
                    Navigator.of(context).pushNamed('/reports/monthly');
                  },
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Income',
                        value: currencyFormat.format(financeProvider.totalIncome),
                        icon: Icons.arrow_downward,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: StatCard(
                        title: 'Expenses',
                        value: currencyFormat.format(financeProvider.totalExpenses),
                        icon: Icons.arrow_upward,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Net Savings Card
                StatCard(
                  title: 'Net Savings',
                  value: currencyFormat.format(financeProvider.netSavings),
                  icon: Icons.savings,
                  color: financeProvider.netSavings >= 0 
                      ? AppTheme.success 
                      : AppTheme.error,
                  subtitle: financeProvider.totalIncome > 0
                      ? '${financeProvider.savingsRate.toStringAsFixed(1)}% of income'
                      : null,
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all transactions or dashboard
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingSm),

                if (recentTransactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkSurface
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          'Start adding your income and expenses',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.take(5).length,
                    separatorBuilder: (context, index) => 
                        const SizedBox(height: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      return TransactionTile(
                        transaction: recentTransactions[index],
                        onDelete: () {
                          financeProvider.deleteTransaction(
                            recentTransactions[index].id,
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        );
      },
    );
  }
}

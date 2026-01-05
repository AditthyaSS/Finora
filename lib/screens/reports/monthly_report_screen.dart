import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/transaction_tile.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int _selectedMonthOffset = 0;
  String? _aiReport;
  bool _isLoadingReport = false;

  DateTime get _selectedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _selectedMonthOffset);
  }

  Future<void> _generateReport() async {
    setState(() => _isLoadingReport = true);

    final appProvider = context.read<AppProvider>();
    final financeProvider = context.read<FinanceProvider>();
    
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final prevMonth = DateTime(year, month - 1);

    final report = await appProvider.geminiService.generateMonthlyReport(
      month: DateFormat('MMMM yyyy').format(_selectedMonth),
      totalIncome: financeProvider.getIncomeForMonth(year, month),
      totalExpenses: financeProvider.getExpensesForMonth(year, month),
      categoryExpenses: financeProvider.getExpensesByCategoryForMonth(year, month),
      previousMonthExpenses: financeProvider.getExpensesByCategoryForMonth(
        prevMonth.year, 
        prevMonth.month,
      ),
    );

    setState(() {
      _aiReport = report;
      _isLoadingReport = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthFormat = DateFormat('MMMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final year = _selectedMonth.year;
          final month = _selectedMonth.month;
          
          final income = financeProvider.getIncomeForMonth(year, month);
          final expenses = financeProvider.getExpensesForMonth(year, month);
          final savings = income - expenses;
          final transactions = financeProvider.getTransactionsForMonth(year, month);
          final categoryExpenses = financeProvider.getExpensesByCategoryForMonth(year, month);

          final sortedCategories = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Navigator
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() => _selectedMonthOffset--);
                          _generateReport();
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        monthFormat.format(_selectedMonth),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: _selectedMonthOffset < 0
                            ? () {
                                setState(() => _selectedMonthOffset++);
                                _generateReport();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),

                // Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            label: 'Income',
                            value: currencyFormat.format(income),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _SummaryItem(
                            label: 'Expenses',
                            value: currencyFormat.format(expenses),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _SummaryItem(
                            label: 'Savings',
                            value: currencyFormat.format(savings),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // AI Analysis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Analysis',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: _isLoadingReport ? null : _generateReport,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                if (_isLoadingReport)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppTheme.spacingMd),
                        Text('Analyzing your spending patterns...'),
                      ],
                    ),
                  )
                else if (_aiReport != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Text(
                      _aiReport!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  )
                else if (transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 48,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'No data for this month',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Text(
                          'Add some transactions to see AI insights',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppTheme.spacingXl),

                // Category Breakdown
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: AppTheme.spacingMd),

                if (sortedCategories.isEmpty)
                  Text(
                    'No expenses this month',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final category = sortedCategories[index];
                      final percentage = expenses > 0
                          ? (category.value / expenses) * 100
                          : 0.0;

                      return Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.key,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      minHeight: 6,
                                      backgroundColor: isDark
                                          ? AppTheme.darkCard
                                          : Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(category.value),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: AppTheme.spacingXl),

                // All Transactions
                Text(
                  'All Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: AppTheme.spacingMd),

                if (transactions.isEmpty)
                  Text(
                    'No transactions this month',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingSm),
                    itemBuilder: (context, index) {
                      final sorted = transactions
                        ..sort((a, b) => b.date.compareTo(a.date));
                      return TransactionTile(transaction: sorted[index]);
                    },
                  ),

                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

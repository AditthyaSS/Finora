import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMonthOffset = 0;

  DateTime get _selectedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _selectedMonthOffset);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthFormat = DateFormat('MMMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final year = _selectedMonth.year;
        final month = _selectedMonth.month;
        
        final income = financeProvider.getIncomeForMonth(year, month);
        final expenses = financeProvider.getExpensesForMonth(year, month);
        final savings = income - expenses;
        final categoryExpenses = financeProvider.getExpensesByCategoryForMonth(year, month);

        // Sort categories by amount
        final sortedCategories = categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Navigator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() => _selectedMonthOffset--);
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
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Income',
                      value: currencyFormat.format(income),
                      icon: Icons.arrow_downward,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: StatCard(
                      title: 'Expenses',
                      value: currencyFormat.format(expenses),
                      icon: Icons.arrow_upward,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingMd),

              StatCard(
                title: 'Savings',
                value: currencyFormat.format(savings),
                icon: Icons.savings,
                color: savings >= 0 ? AppTheme.success : AppTheme.error,
                subtitle: income > 0
                    ? 'Savings rate: ${((savings / income) * 100).toStringAsFixed(1)}%'
                    : null,
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Expense Breakdown
              Text(
                'Expense Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: AppTheme.spacingMd),

              if (categoryExpenses.isEmpty)
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
                        Icons.pie_chart_outline,
                        size: 48,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'No expenses this month',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Pie Chart
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(sortedCategories, expenses),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          pieTouchData: PieTouchData(enabled: true),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // Category List
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
                        final color = _getCategoryColor(index);

                        return Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurface
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: isDark
                                ? Border.all(
                                    color: AppTheme.darkCard.withOpacity(0.5),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: Text(
                                  category.key,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
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
                  ],
                ),

              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<MapEntry<String, double>> categories,
    double total,
  ) {
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = total > 0 ? (category.value / total) * 100 : 0;

      return PieChartSectionData(
        value: category.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: _getCategoryColor(index),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryTeal,
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFF64748B),
    ];
    return colors[index % colors.length];
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/goal.dart';
import '../../providers/app_provider.dart';
import '../../providers/finance_provider.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  bool _isGeneratingPlan = false;

  Future<void> _generatePlan() async {
    setState(() => _isGeneratingPlan = true);
    
    final appProvider = context.read<AppProvider>();
    final financeProvider = context.read<FinanceProvider>();
    
    await financeProvider.generateGoalPlan(
      appProvider.geminiService,
      widget.goal,
    );
    
    setState(() => _isGeneratingPlan = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                    SizedBox(width: 8),
                    Text('Delete Goal', style: TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final currentGoal = financeProvider.goals.firstWhere(
            (g) => g.id == widget.goal.id,
            orElse: () => widget.goal,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.white, size: 28),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              currentGoal.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                currencyFormat.format(currentGoal.currentAmount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Target',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                currencyFormat.format(currentGoal.targetAmount),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        child: LinearProgressIndicator(
                          value: currentGoal.progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '${(currentGoal.progress * 100).toStringAsFixed(1)}% complete',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Remaining',
                        value: currencyFormat.format(currentGoal.remainingAmount),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: _StatTile(
                        label: 'Days Left',
                        value: '${currentGoal.daysRemaining}',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: _StatTile(
                        label: 'Monthly Target',
                        value: currencyFormat.format(currentGoal.monthlyTarget),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                _StatTile(
                  label: 'Target Date',
                  value: dateFormat.format(currentGoal.targetDate),
                  icon: Icons.calendar_today,
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Add Progress Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddProgressDialog(currentGoal),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Savings'),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // AI Plan Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Goal Plan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (currentGoal.aiPlan != null)
                      IconButton(
                        onPressed: _generatePlan,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate plan',
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMd),

                if (_isGeneratingPlan)
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
                        Text('Finora is creating your personalized plan...'),
                      ],
                    ),
                  )
                else if (currentGoal.aiPlan != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: isDark
                          ? Border.all(color: AppTheme.darkCard.withOpacity(0.5))
                          : null,
                    ),
                    child: Text(
                      currentGoal.aiPlan!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  )
                else
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
                          Icons.auto_awesome,
                          size: 40,
                          color: AppTheme.primaryTeal,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Get a personalized plan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          'Let Finora AI analyze your finances and create a step-by-step plan to reach this goal.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        ElevatedButton.icon(
                          onPressed: _generatePlan,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('Generate Plan'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddProgressDialog(Goal goal) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'Add Savings Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingLg),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Amount Saved',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(controller.text) ?? 0;
                      if (amount > 0) {
                        context.read<FinanceProvider>().updateGoalProgress(
                          goal.id,
                          amount,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Progress'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('This will permanently delete this goal and its progress.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceProvider>().deleteGoal(widget.goal.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatTile({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppTheme.primaryTeal),
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

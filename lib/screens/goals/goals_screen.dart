import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/goal_progress_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        final activeGoals = financeProvider.goals.where((g) => !g.isCompleted).toList();
        final completedGoals = financeProvider.goals.where((g) => g.isCompleted).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Goals',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton.filled(
                    onPressed: () => _showAddGoalDialog(context),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Active Goals
              if (activeGoals.isEmpty && completedGoals.isEmpty)
                _buildEmptyState(context)
              else ...[
                if (activeGoals.isNotEmpty) ...[
                  Text(
                    'Active Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeGoals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final goal = activeGoals[index];
                      return GoalProgressCard(
                        goal: goal,
                        onTap: () => _showGoalDetail(context, goal),
                      );
                    },
                  ),
                ],

                if (completedGoals.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingXl),
                  Text(
                    'Completed Goals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedGoals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final goal = completedGoals[index];
                      return GoalProgressCard(
                        goal: goal,
                        onTap: () => _showGoalDetail(context, goal),
                      );
                    },
                  ),
                ],
              ],

              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: AppTheme.primaryTeal,
              size: 40,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'No goals yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Set a financial goal and let Finora help you create an AI-powered plan to achieve it.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Goal'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 180));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                    'New Financial Goal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Name',
                      hintText: 'e.g., Emergency Fund',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Amount',
                      hintText: 'e.g., 100000',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Target Date',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('d MMMM yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text) ?? 0;
                        
                        if (title.isNotEmpty && amount > 0) {
                          context.read<FinanceProvider>().addGoal(
                            title: title,
                            targetAmount: amount,
                            targetDate: selectedDate,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create Goal'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGoalDetail(BuildContext context, goal) {
    Navigator.of(context).pushNamed('/goals/detail', arguments: goal);
  }
}

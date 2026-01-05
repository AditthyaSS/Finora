import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/goal.dart';

class GoalProgressCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final progress = goal.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isDark ? null : AppTheme.softShadow,
          border: isDark 
              ? Border.all(color: AppTheme.darkCard.withOpacity(0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: AppTheme.primaryTeal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.daysRemaining > 0
                            ? '${goal.daysRemaining} days remaining'
                            : 'Target date passed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: goal.daysRemaining > 0 
                              ? null 
                              : AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(goal.currentAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                Text(
                  currencyFormat.format(goal.targetAmount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark 
                    ? AppTheme.darkCard 
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? AppTheme.success : AppTheme.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% achieved',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.isExpense;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Dismissible(
      key: Key(transaction.id),
      direction: onDelete != null 
          ? DismissDirection.endToStart 
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Icon(Icons.delete, color: AppTheme.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: isDark 
                ? Border.all(color: AppTheme.darkCard.withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isExpense ? AppTheme.error : AppTheme.success)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isExpense ? AppTheme.error : AppTheme.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          transaction.category,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM').format(transaction.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExpense ? AppTheme.error : AppTheme.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

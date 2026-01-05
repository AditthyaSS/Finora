import 'package:flutter/material.dart';
import '../config/theme.dart';

class InsightCard extends StatelessWidget {
  final String? insight;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const InsightCard({
    super.key,
    this.insight,
    this.isLoading = false,
    this.onTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                const Expanded(
                  child: Text(
                    'AI Insight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: 'Refresh insight',
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              Text(
                insight ?? 'Add some transactions to get personalized insights!',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

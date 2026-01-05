import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // API Key Section
          _SectionHeader(title: 'Gemini API'),
          _SettingsTile(
            icon: Icons.key,
            title: 'API Key',
            subtitle: 'Update or remove your Gemini API key',
            onTap: () => _showApiKeyDialog(context),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return _SettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: appProvider.isDarkMode ? 'On' : 'Off',
                trailing: Switch(
                  value: appProvider.isDarkMode,
                  onChanged: (value) => appProvider.setTheme(value),
                  activeColor: AppTheme.primaryTeal,
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // Data Section
          _SectionHeader(title: 'Data Management'),
          _SettingsTile(
            icon: Icons.file_download,
            title: 'Export Data (JSON)',
            subtitle: 'Download all your data as JSON',
            onTap: () => _exportData(context, 'json'),
          ),
          _SettingsTile(
            icon: Icons.table_chart,
            title: 'Export Transactions (CSV)',
            subtitle: 'Download transactions as spreadsheet',
            onTap: () => _exportData(context, 'csv'),
          ),
          _SettingsTile(
            icon: Icons.delete_forever,
            title: 'Reset All Data',
            subtitle: 'Delete all transactions and goals',
            titleColor: AppTheme.error,
            onTap: () => _showResetDialog(context),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          // About Section
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About ${AppConstants.appName}',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () => _showAboutDialog(context),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Security',
            subtitle: 'How we protect your data',
            onTap: () => _showPrivacyDialog(context),
          ),

          const SizedBox(height: AppTheme.spacing2Xl),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController();
    final appProvider = context.read<AppProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New API Key',
                hintText: 'Paste your Gemini API key',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              appProvider.removeApiKey();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            child: const Text(
              'Remove Key',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final success = await appProvider.validateAndSaveApiKey(
                  controller.text.trim(),
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String format) async {
    String? path;
    
    if (format == 'json') {
      path = await ExportService.exportToJson();
    } else {
      path = await ExportService.exportToCsv();
    }

    if (context.mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to: $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your transactions, goals, and chat history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceProvider>().resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset')),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppConstants.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appTagline),
            const SizedBox(height: 16),
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text(
              'Finora is a privacy-first personal finance app that uses AI to help you understand your spending and achieve your financial goals.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔒 Your Data Stays Local',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All your financial data is stored only on your device. We never upload or sync your data to any server.',
              ),
              SizedBox(height: 16),
              Text(
                '🔑 API Key Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your Gemini API key is stored securely on your device and is only used to communicate directly with Google\'s servers.',
              ),
              SizedBox(height: 16),
              Text(
                '📊 No Analytics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We don\'t collect any analytics, usage data, or personal information. Your financial privacy is our priority.',
              ),
              SizedBox(height: 16),
              Text(
                '🚫 No Accounts Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'No email, password, or sign-up required. Just you, your data, and your API key.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingXs,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryTeal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isDark
            ? Border.all(color: AppTheme.darkCard.withOpacity(0.5))
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppTheme.primaryTeal),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}

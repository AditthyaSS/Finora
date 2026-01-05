import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/finance_provider.dart';
import 'home/home_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'chat/chat_screen.dart';
import 'goals/goals_screen.dart';
import 'settings/settings_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    HomeScreen(),
    DashboardScreen(),
    ChatScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Home',
    'Dashboard',
    'Chat',
    'Goals',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _currentIndex != 2 // No app bar for chat screen
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(_titles[_currentIndex]),
              actions: [
                if (_currentIndex == 0 || _currentIndex == 1)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddTransactionSheet(context),
                    tooltip: 'Add Transaction',
                  ),
              ],
            )
          : null,
      drawer: _buildDrawer(context),
      body: SafeArea(
        top: _currentIndex == 2,
        child: AnimatedSwitcher(
          duration: AppTheme.animNormal,
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark 
                  ? AppTheme.darkCard.withOpacity(0.5) 
                  : Colors.grey.shade200,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddTransactionSheet(context),
              backgroundColor: AppTheme.primaryTeal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            // Menu Items
            _DrawerItem(
              icon: Icons.analytics_outlined,
              title: 'Monthly Reports',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports/monthly');
              },
            ),
            _DrawerItem(
              icon: Icons.file_download_outlined,
              title: 'Data Export',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4); // Go to settings
              },
            ),
            _DrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Security',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4); // Go to settings
              },
            ),
            
            const Divider(),

            _DrawerItem(
              icon: Icons.info_outline,
              title: 'About ${AppConstants.appName}',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'expense';
    String? selectedCategory;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final financeProvider = context.read<FinanceProvider>();
          
          final categories = selectedType == 'expense'
              ? financeProvider.expenseCategories
              : financeProvider.incomeCategories;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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

                  // Title
                  Text(
                    'Add Transaction',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // Type Toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedType = 'expense';
                            selectedCategory = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: selectedType == 'expense'
                                  ? AppTheme.error.withOpacity(0.15)
                                  : (isDark ? AppTheme.darkCard : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: selectedType == 'expense'
                                  ? Border.all(color: AppTheme.error)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: selectedType == 'expense'
                                      ? AppTheme.error
                                      : (isDark ? AppTheme.darkTextSecondary : Colors.grey),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: selectedType == 'expense'
                                        ? AppTheme.error
                                        : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedType = 'income';
                            selectedCategory = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: selectedType == 'income'
                                  ? AppTheme.success.withOpacity(0.15)
                                  : (isDark ? AppTheme.darkCard : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: selectedType == 'income'
                                  ? Border.all(color: AppTheme.success)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: selectedType == 'income'
                                      ? AppTheme.success
                                      : (isDark ? AppTheme.darkTextSecondary : Colors.grey),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: selectedType == 'income'
                                        ? AppTheme.success
                                        : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Title Input
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Grocery shopping',
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Amount Input
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹ ',
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.name,
                        child: Row(
                          children: [
                            Icon(cat.iconData, size: 20, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
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

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text) ?? 0;

                        if (title.isNotEmpty && amount > 0 && selectedCategory != null) {
                          financeProvider.addTransaction(
                            title: title,
                            amount: amount,
                            category: selectedCategory!,
                            date: selectedDate,
                            type: selectedType,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType == 'expense'
                            ? AppTheme.error
                            : AppTheme.success,
                      ),
                      child: Text(
                        'Add ${selectedType == 'expense' ? 'Expense' : 'Income'}',
                      ),
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
            const Text(AppConstants.appName),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppConstants.appTagline),
            SizedBox(height: 16),
            Text('Version: ${AppConstants.appVersion}'),
            SizedBox(height: 16),
            Text(
              'A privacy-first AI personal finance companion that helps you understand your spending and achieve your financial goals.',
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
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryTeal),
      title: Text(title),
      onTap: onTap,
    );
  }
}

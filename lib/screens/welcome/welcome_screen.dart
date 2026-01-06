import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/app_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> 
    with SingleTickerProviderStateMixin {
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureKey = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController, 
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _unlockApp() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = context.read<AppProvider>();
    final success = await appProvider.validateAndSaveApiKey(
      _apiKeyController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacing2Xl),
                    
                    // Logo and Branding
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    Center(
                      child: Text(
                        'Welcome to ${AppConstants.appName}',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingSm),
                    
                    Center(
                      child: Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark 
                              ? AppTheme.darkTextSecondary 
                              : AppTheme.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacing2Xl),
                    
                    // API Key Input Section
                    Text(
                      'Enter your Gemini API Key',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: AppTheme.spacingSm),
                    
                    Text(
                      'Your API key is stored locally on your device and is never shared.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    TextFormField(
                      controller: _apiKeyController,
                      obscureText: _obscureKey,
                      decoration: InputDecoration(
                        hintText: 'Paste your Gemini API key here',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKey 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureKey = !_obscureKey);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your API key';
                        }
                        if (value.trim().length < 20) {
                          return 'API key seems too short';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Error Display
                    Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        if (provider.error != null) {
                          return Container(
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            margin: const EdgeInsets.only(
                              bottom: AppTheme.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              border: Border.all(
                                color: AppTheme.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: const TextStyle(
                                      color: AppTheme.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Unlock Button
                    Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _unlockApp,
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Unlock Finora'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    // Skip Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/main');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark 
                                ? AppTheme.darkTextSecondary 
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: isDark 
                                ? AppTheme.darkTextSecondary 
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppTheme.darkSurface 
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryTeal,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingSm),
                              Text(
                                'Why do I need an API key?',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Finora uses Google\'s Gemini AI to analyze your spending '
                            'patterns and provide personalized insights. Your API key '
                            'connects directly to Google\'s servers - we never see or store it.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: Open link to get API key
                            },
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Get a free API key'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    // Privacy Notice
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: isDark 
                                ? AppTheme.darkTextSecondary 
                                : AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Privacy-first • No accounts • Your data stays local',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

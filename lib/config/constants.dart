class AppConstants {
  // App Info
  static const String appName = 'Finora';
  static const String appTagline = 'Your calm AI-powered personal finance companion';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String geminiApiKeyKey = 'gemini_api_key';
  static const String themeKey = 'app_theme';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // Hive Box Names
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';
  static const String categoriesBox = 'categories';
  static const String settingsBox = 'settings';
  static const String chatHistoryBox = 'chat_history';
  
  // Default Categories
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 0xFFEF4444},
    {'name': 'Transportation', 'icon': 'directions_car', 'color': 0xFF3B82F6},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFF59E0B},
    {'name': 'Entertainment', 'icon': 'movie', 'color': 0xFF8B5CF6},
    {'name': 'Bills & Utilities', 'icon': 'receipt_long', 'color': 0xFF06B6D4},
    {'name': 'Health', 'icon': 'medical_services', 'color': 0xFF22C55E},
    {'name': 'Education', 'icon': 'school', 'color': 0xFF6366F1},
    {'name': 'Travel', 'icon': 'flight', 'color': 0xFFEC4899},
    {'name': 'Groceries', 'icon': 'local_grocery_store', 'color': 0xFF14B8A6},
    {'name': 'Other', 'icon': 'more_horiz', 'color': 0xFF64748B},
  ];
  
  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {'name': 'Salary', 'icon': 'work', 'color': 0xFF22C55E},
    {'name': 'Freelance', 'icon': 'laptop', 'color': 0xFF3B82F6},
    {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFF8B5CF6},
    {'name': 'Gift', 'icon': 'card_giftcard', 'color': 0xFFF59E0B},
    {'name': 'Other', 'icon': 'more_horiz', 'color': 0xFF64748B},
  ];
  
  // Gemini Prompts
  static const String insightSystemPrompt = '''
You are Finora, a calm and supportive personal finance assistant. Your role is to analyze spending patterns and provide short, actionable financial insights.

Guidelines:
- Be calm, supportive, and never judgmental
- Keep insights concise (1-2 sentences max)
- Focus on practical, achievable suggestions
- Use specific numbers when helpful
- Emphasize steady progress over drastic changes
''';

  static const String goalPlanningPrompt = '''
You are Finora, helping create a realistic financial goal plan. Based on the user's income, expenses, and target goal, create a structured plan.

Guidelines:
- Break goals into monthly and weekly targets
- Suggest specific expense areas to optimize
- Be encouraging and realistic
- Focus on sustainability, not extreme saving
''';

  static const String chatSystemPrompt = '''
You are Finora, a calm AI personal finance companion. You help users understand their spending patterns and make better financial decisions.

Guidelines:
- Only use the financial data provided by the user
- Never make assumptions about external financial products
- Be friendly, professional, and supportive
- Keep responses clear and actionable
- If you don't have enough data, politely ask for more information
''';
}

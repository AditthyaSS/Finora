import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';

class GeminiService {
  GenerativeModel? _model;
  String? _apiKey;
  String? _selectedModel;

  // List of models to try in order of preference (newest to oldest)
  static const List<String> _availableModels = [
    // Gemini 3 models (preview)
    'gemini-3-pro-preview',
    'gemini-3-flash-preview',
    'gemini-3.0-pro',
    'gemini-3.0-flash',
    // Latest 2.5 models
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    // 2.0 models
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    // 1.5 models
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-1.5-pro-latest',
    'gemini-1.5-pro',
    // Legacy models
    'gemini-pro',
    'gemini-1.0-pro',
    'models/gemini-pro',
  ];

  bool get isInitialized => _model != null;
  String? get selectedModel => _selectedModel;

  String? lastError;

  /// Validates API key and automatically finds a working model
  Future<bool> validateAndInitialize(String apiKey) async {
    lastError = null;
    
    for (final modelName in _availableModels) {
      try {
        print('Trying model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

        // Test the API key with a simple prompt
        final response = await model.generateContent([
          Content.text('Say "Hello" in one word.')
        ]);

        if (response.text != null) {
          _model = model;
          _apiKey = apiKey;
          _selectedModel = modelName;
          print('Successfully connected with model: $modelName');
          return true;
        }
      } on GenerativeAIException catch (e) {
        print('Model $modelName failed: ${e.message}');
        // Continue to try next model
        continue;
      } catch (e) {
        print('Model $modelName error: $e');
        // Continue to try next model
        continue;
      }
    }
    
    lastError = 'No compatible model found. Please check your API key and try again.';
    return false;
  }

  /// Initialize with the first available model (used when loading saved API key)
  Future<void> initialize(String apiKey) async {
    _apiKey = apiKey;
    
    for (final modelName in _availableModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );
        
        // Quick test
        await model.generateContent([Content.text('Hi')]);
        
        _model = model;
        _selectedModel = modelName;
        print('Initialized with model: $modelName');
        return;
      } catch (e) {
        continue;
      }
    }
    
    // Fallback: just use gemini-pro without testing
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    _selectedModel = 'gemini-pro';
  }

  Future<String?> generateInsight({
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryExpenses,
    required Map<String, double> previousMonthExpenses,
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
${AppConstants.insightSystemPrompt}

User's Financial Data This Month:
- Total Income: ₹${totalIncome.toStringAsFixed(0)}
- Total Expenses: ₹${totalExpenses.toStringAsFixed(0)}
- Savings: ₹${(totalIncome - totalExpenses).toStringAsFixed(0)}

Category-wise Expenses:
${categoryExpenses.entries.map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Previous Month Comparison:
${previousMonthExpenses.entries.map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Generate ONE short, actionable financial insight (max 2 sentences). Focus on the most impactful observation.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating insight: $e');
      return null;
    }
  }

  Future<String?> generateGoalPlan({
    required String goalTitle,
    required double targetAmount,
    required int monthsRemaining,
    required double monthlyIncome,
    required double monthlyExpenses,
    required Map<String, double> categoryExpenses,
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
${AppConstants.goalPlanningPrompt}

Goal Details:
- Goal: $goalTitle
- Target Amount: ₹${targetAmount.toStringAsFixed(0)}
- Time Remaining: $monthsRemaining months
- Monthly Saving Needed: ₹${(targetAmount / monthsRemaining).toStringAsFixed(0)}

User's Current Finances:
- Monthly Income: ₹${monthlyIncome.toStringAsFixed(0)}
- Monthly Expenses: ₹${monthlyExpenses.toStringAsFixed(0)}
- Current Monthly Savings: ₹${(monthlyIncome - monthlyExpenses).toStringAsFixed(0)}

Top Expense Categories:
${categoryExpenses.entries.take(5).map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Create a structured, realistic plan to achieve this goal. Include:
1. Monthly saving target
2. 2-3 specific expense reduction suggestions
3. Weekly habits to build
4. One encouragement message

Keep the tone calm and supportive.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating goal plan: $e');
      return null;
    }
  }

  Future<String?> chat({
    required String message,
    required List<Map<String, String>> history,
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryExpenses,
  }) async {
    if (_model == null) return null;

    try {
      final contextPrompt = '''
${AppConstants.chatSystemPrompt}

User's Financial Summary:
- Total Income: ₹${totalIncome.toStringAsFixed(0)}
- Total Expenses: ₹${totalExpenses.toStringAsFixed(0)}
- Net Savings: ₹${(totalIncome - totalExpenses).toStringAsFixed(0)}

Expense Breakdown:
${categoryExpenses.entries.map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Conversation History:
${history.map((h) => '${h['role']}: ${h['content']}').join('\n')}

User: $message
''';

      final response = await _model!.generateContent([Content.text(contextPrompt)]);
      return response.text;
    } catch (e) {
      print('Error in chat: $e');
      return 'I apologize, but I encountered an issue. Please try again.';
    }
  }

  Future<String?> generateMonthlyReport({
    required String month,
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryExpenses,
    required Map<String, double> previousMonthExpenses,
  }) async {
    if (_model == null) return null;

    try {
      final prompt = '''
${AppConstants.insightSystemPrompt}

Generate a calm, supportive monthly financial report for $month.

This Month's Data:
- Total Income: ₹${totalIncome.toStringAsFixed(0)}
- Total Expenses: ₹${totalExpenses.toStringAsFixed(0)}
- Net Savings: ₹${(totalIncome - totalExpenses).toStringAsFixed(0)}

Category Breakdown:
${categoryExpenses.entries.map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Previous Month:
${previousMonthExpenses.entries.map((e) => '- ${e.key}: ₹${e.value.toStringAsFixed(0)}').join('\n')}

Provide:
1. A brief summary of spending patterns
2. Key changes from last month
3. One positive observation
4. One focused improvement suggestion

Keep the tone supportive and non-judgmental. Format with clear sections.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating report: $e');
      return null;
    }
  }

  void dispose() {
    _model = null;
    _apiKey = null;
  }
}

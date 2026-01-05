import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';

class GeminiService {
  GenerativeModel? _model;
  String? _apiKey;

  bool get isInitialized => _model != null;

  String? lastError;

  Future<bool> validateAndInitialize(String apiKey) async {
    lastError = null;
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );

      // Test the API key with a simple prompt
      final response = await model.generateContent([
        Content.text('Say "Hello" in one word.')
      ]);

      if (response.text != null) {
        _model = model;
        _apiKey = apiKey;
        return true;
      }
      lastError = 'No response from API';
      return false;
    } on GenerativeAIException catch (e) {
      lastError = e.message;
      print('Gemini API error: ${e.message}');
      return false;
    } catch (e) {
      lastError = e.toString();
      print('Gemini API validation failed: $e');
      return false;
    }
  }

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
    );
    _apiKey = apiKey;
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

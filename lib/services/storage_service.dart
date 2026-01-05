import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/category.dart';
import '../models/chat_message.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late Box<Transaction> _transactionsBox;
  static late Box<Goal> _goalsBox;
  static late Box<Category> _categoriesBox;
  static late Box<ChatMessage> _chatBox;

  static Future<void> initialize() async {
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }

    // Open boxes
    _transactionsBox = await Hive.openBox<Transaction>(AppConstants.transactionsBox);
    _goalsBox = await Hive.openBox<Goal>(AppConstants.goalsBox);
    _categoriesBox = await Hive.openBox<Category>(AppConstants.categoriesBox);
    _chatBox = await Hive.openBox<ChatMessage>(AppConstants.chatHistoryBox);

    // Initialize default categories if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    int id = 0;
    for (var cat in AppConstants.defaultExpenseCategories) {
      await _categoriesBox.put(
        'expense_$id',
        Category(
          id: 'expense_$id',
          name: cat['name'],
          icon: cat['icon'],
          colorValue: cat['color'],
          type: 'expense',
          isDefault: true,
        ),
      );
      id++;
    }

    id = 0;
    for (var cat in AppConstants.defaultIncomeCategories) {
      await _categoriesBox.put(
        'income_$id',
        Category(
          id: 'income_$id',
          name: cat['name'],
          icon: cat['icon'],
          colorValue: cat['color'],
          type: 'income',
          isDefault: true,
        ),
      );
      id++;
    }
  }

  // API Key Management
  static Future<void> saveApiKey(String key) async {
    await _prefs.setString(AppConstants.geminiApiKeyKey, key);
  }

  static String? getApiKey() {
    return _prefs.getString(AppConstants.geminiApiKeyKey);
  }

  static Future<void> removeApiKey() async {
    await _prefs.remove(AppConstants.geminiApiKeyKey);
  }

  // Theme Management
  static Future<void> saveTheme(bool isDark) async {
    await _prefs.setBool(AppConstants.themeKey, isDark);
  }

  static bool getTheme() {
    return _prefs.getBool(AppConstants.themeKey) ?? true;
  }

  // Transaction Operations
  static Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  static List<Transaction> getTransactionsByMonth(int year, int month) {
    return _transactionsBox.values.where((t) {
      return t.date.year == year && t.date.month == month;
    }).toList();
  }

  static List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactionsBox.values.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Goal Operations
  static Future<void> addGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  static Future<void> updateGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  static Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  static List<Goal> getAllGoals() {
    return _goalsBox.values.toList();
  }

  static List<Goal> getActiveGoals() {
    return _goalsBox.values.where((g) => !g.isCompleted).toList();
  }

  // Category Operations
  static List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  static List<Category> getCategoriesByType(String type) {
    return _categoriesBox.values.where((c) => c.type == type).toList();
  }

  static Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  // Chat Operations
  static Future<void> addChatMessage(ChatMessage message) async {
    await _chatBox.put(message.id, message);
  }

  static List<ChatMessage> getChatHistory() {
    final messages = _chatBox.values.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  static Future<void> clearChatHistory() async {
    await _chatBox.clear();
  }

  // Data Reset
  static Future<void> resetAllData() async {
    await _transactionsBox.clear();
    await _goalsBox.clear();
    await _chatBox.clear();
    await _categoriesBox.clear();
    await _initializeDefaultCategories();
  }

  // Export Data
  static Map<String, dynamic> exportAllData() {
    return {
      'transactions': _transactionsBox.values.map((t) => t.toJson()).toList(),
      'goals': _goalsBox.values.map((g) => g.toJson()).toList(),
      'categories': _categoriesBox.values.map((c) => c.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}

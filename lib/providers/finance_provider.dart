import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

class FinanceProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<Category> _categories = [];
  
  bool _isLoading = false;
  String? _currentInsight;
  String? _error;

  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get currentInsight => _currentInsight;
  String? get error => _error;

  // Computed Properties
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month
    ).toList();
  }

  double get totalIncome {
    return currentMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return currentMonthTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netSavings => totalIncome - totalExpenses;

  double get savingsRate => totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0;

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (var t in currentMonthTransactions.where((t) => t.isExpense)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  List<Category> get expenseCategories => 
    _categories.where((c) => c.type == 'expense').toList();

  List<Category> get incomeCategories => 
    _categories.where((c) => c.type == 'income').toList();

  void loadData() {
    _transactions = StorageService.getAllTransactions();
    _goals = StorageService.getAllGoals();
    _categories = StorageService.getAllCategories();
    notifyListeners();
  }

  // Transaction Operations
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String type,
    String? notes,
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      type: type,
      notes: notes,
    );

    await StorageService.addTransaction(transaction);
    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await StorageService.updateTransaction(transaction);
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await StorageService.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Goal Operations
  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate,
      description: description,
    );

    await StorageService.addGoal(goal);
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    await StorageService.updateGoal(goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index].currentAmount += amount;
      if (_goals[index].currentAmount >= _goals[index].targetAmount) {
        _goals[index].isCompleted = true;
      }
      await StorageService.updateGoal(_goals[index]);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    await StorageService.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // AI Insight
  Future<void> generateInsight(GeminiService geminiService) async {
    if (currentMonthTransactions.isEmpty) {
      _currentInsight = "Start adding your income and expenses to get personalized insights!";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1);
      final previousMonthTransactions = _transactions.where((t) =>
        t.date.year == previousMonth.year && t.date.month == previousMonth.month
      ).toList();

      final previousExpenses = <String, double>{};
      for (var t in previousMonthTransactions.where((t) => t.isExpense)) {
        previousExpenses[t.category] = (previousExpenses[t.category] ?? 0) + t.amount;
      }

      _currentInsight = await geminiService.generateInsight(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        categoryExpenses: expensesByCategory,
        previousMonthExpenses: previousExpenses,
      );
    } catch (e) {
      _error = 'Failed to generate insight';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Goal Plan Generation
  Future<String?> generateGoalPlan(GeminiService geminiService, Goal goal) async {
    try {
      final plan = await geminiService.generateGoalPlan(
        goalTitle: goal.title,
        targetAmount: goal.targetAmount,
        monthsRemaining: goal.daysRemaining ~/ 30,
        monthlyIncome: totalIncome,
        monthlyExpenses: totalExpenses,
        categoryExpenses: expensesByCategory,
      );

      if (plan != null) {
        goal.aiPlan = plan;
        await updateGoal(goal);
      }

      return plan;
    } catch (e) {
      return null;
    }
  }

  // Month-specific data
  List<Transaction> getTransactionsForMonth(int year, int month) {
    return _transactions.where((t) =>
      t.date.year == year && t.date.month == month
    ).toList();
  }

  Map<String, double> getExpensesByCategoryForMonth(int year, int month) {
    final transactions = getTransactionsForMonth(year, month);
    final Map<String, double> result = {};
    for (var t in transactions.where((t) => t.isExpense)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  double getIncomeForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getExpensesForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Reset
  Future<void> resetAllData() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.resetAllData();
    _transactions = [];
    _goals = [];
    _categories = StorageService.getAllCategories();
    _currentInsight = null;

    _isLoading = false;
    notifyListeners();
  }
}

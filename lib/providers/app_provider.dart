import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isDarkMode = true;
  bool _hasApiKey = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get hasApiKey => _hasApiKey;
  String? get error => _error;
  GeminiService get geminiService => _geminiService;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.initialize();
      _isDarkMode = StorageService.getTheme();
      
      final apiKey = StorageService.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        await _geminiService.initialize(apiKey);
        _hasApiKey = true;
      }
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize app: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validateAndSaveApiKey(String apiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isValid = await _geminiService.validateAndInitialize(apiKey);
      
      if (isValid) {
        await StorageService.saveApiKey(apiKey);
        _hasApiKey = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _geminiService.lastError ?? 'Invalid API key. Please check and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to validate API key: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> removeApiKey() async {
    await StorageService.removeApiKey();
    _geminiService.dispose();
    _hasApiKey = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.saveTheme(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await StorageService.saveTheme(_isDarkMode);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

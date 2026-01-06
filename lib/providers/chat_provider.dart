import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadMessages() {
    _messages = StorageService.getChatHistory();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String content,
    required GeminiService geminiService,
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryExpenses,
  }) async {
    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isUser: true,
    );
    
    await StorageService.addChatMessage(userMessage);
    _messages.add(userMessage);
    notifyListeners();

    // Generate AI response
    _isLoading = true;
    notifyListeners();

    try {
      final history = _messages.take(10).map((m) => {
        'role': m.isUser ? 'User' : 'Finora',
        'content': m.content,
      }).toList();

      final response = await geminiService.chat(
        message: content,
        history: history,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        categoryExpenses: categoryExpenses,
      );

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response ?? 'To chat with me, please add your Gemini API key in Settings. It\'s free and takes just a moment!',
        isUser: false,
      );
      
      await StorageService.addChatMessage(aiMessage);
      _messages.add(aiMessage);
    } catch (e) {
      _error = 'Failed to get response';
      
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'I apologize, but I encountered an issue. Please try again.',
        isUser: false,
      );
      
      await StorageService.addChatMessage(errorMessage);
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    await StorageService.clearChatHistory();
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

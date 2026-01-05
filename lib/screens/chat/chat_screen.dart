import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    final appProvider = context.read<AppProvider>();
    final financeProvider = context.read<FinanceProvider>();
    final chatProvider = context.read<ChatProvider>();

    await chatProvider.sendMessage(
      content: message,
      geminiService: appProvider.geminiService,
      totalIncome: financeProvider.totalIncome,
      totalExpenses: financeProvider.totalExpenses,
      categoryExpenses: financeProvider.expensesByCategory,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark 
                    ? AppTheme.darkCard.withOpacity(0.5) 
                    : Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finora AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Your personal finance companion',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Clear chat'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.messages.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  return _MessageBubble(
                    content: message.content,
                    isUser: message.isUser,
                  );
                },
              );
            },
          ),
        ),

        // Loading indicator
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            if (chatProvider.isLoading) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      'Finora is thinking...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark 
                    ? AppTheme.darkCard.withOpacity(0.5) 
                    : Colors.grey.shade200,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your finances...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark 
                          ? AppTheme.darkCard 
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingMd,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.primaryTeal,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Chat with Finora',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Ask questions about your spending, savings, or get personalized financial advice.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'Summarize my month',
                  onTap: () {
                    _messageController.text = 'Summarize my spending this month';
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  label: 'Where am I overspending?',
                  onTap: () {
                    _messageController.text = 'Where am I overspending?';
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  label: 'Tips to save more',
                  onTap: () {
                    _messageController.text = 'Give me tips to save more money';
                    _sendMessage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat history?'),
        content: const Text('This will delete all messages. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const _MessageBubble({
    required this.content,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primaryTeal
              : (isDark ? AppTheme.darkSurface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryTeal),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryTeal,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
// import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_background.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final authProvider = context.read<AuthProvider>();
    final aiService = AIService(apiKey: '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');

    try {
      final response = await aiService.askCoach(text, authProvider.user);
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': response});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': 'Sorry, I\'m having trouble connecting. Please try again later.'
          });
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickPrompt(String prompt) {
    HapticFeedback.mediumImpact();
    _sendMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha:0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: AppColors.glowColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('AI Coach', style: AppTextStyles.headingMedium),
            ],
          ),
        ),
        body: Column(
          children: [
            // Quick Prompts
            if (_messages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Questions',
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickChip('Create my workout plan'),
                        _buildQuickChip('What should I eat today?'),
                        _buildQuickChip('Review my progress'),
                        _buildQuickChip('Best exercises for chest'),
                        _buildQuickChip('How to break a plateau?'),
                      ],
                    ),
                  ],
                ),
              ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.accentPurple.withValues(alpha:0.3)
                            : Colors.white.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: isUser ? const Radius.circular(4) : null,
                          bottomLeft: !isUser ? const Radius.circular(4) : null,
                        ),
                        border: Border.all(
                          color: isUser
                              ? AppColors.accentViolet.withValues(alpha:0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        message['text'],
                        style: AppTextStyles.bodyLarge.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.glowColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

            // Input
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ask your AI coach...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha:0.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () => _sendMessage(_messageController.text),
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.glowColor,
                            ),
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return GestureDetector(
      onTap: () => _sendQuickPrompt(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentViolet.withValues(alpha:0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.glowColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
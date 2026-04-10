import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'chat_provider.dart';
import 'chat_input_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/orthodox_cross_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Do not request permissions here; it causes deadlocks. 
    // ChatInputWidget handles microphone permission on tap.
    Future.microtask(() => context.read<ChatProvider>().loadHistory());
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.appBarGradient,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrthodoxCrossWidget(
              size: 18,
              color: AppTheme.ocuBurgundy.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            const Text('Цифровий Капелан'),
          ],
        ),
        actions: [
          // Кнопка ввімкнення/вимкнення звуку (TTS)
          Consumer<ChatProvider>(
            builder: (context, chat, child) => IconButton(
              icon: Icon(
                chat.isTtsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: chat.isTtsEnabled ? AppTheme.ocuBurgundy : AppTheme.textDim,
              ),
              onPressed: () => chat.toggleTts(),
              tooltip: chat.isTtsEnabled ? 'Вимкнути звук' : 'Увімкнути звук',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.ocuBurgundy),
            onPressed: () => context.read<ChatProvider>().clearMessages(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppTheme.goldAccent.withOpacity(0.3),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return _buildLoadingState();
                }
                
                if (provider.messages.isEmpty) {
                  return _buildEmptyState();
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isUser = message['role'] == 'user';
                    return _ChatBubble(
                      content: message['content']!,
                      isUser: isUser,
                    );
                  },
                );
              },
            ),
          ),
          if (context.watch<ChatProvider>().isLoading)
            const _TypingIndicator(),
          ChatInputWidget(
            onSend: (text) => context.read<ChatProvider>().sendMessage(text),
            isLoading: context.watch<ChatProvider>().isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.goldAccent,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Готуюся до бесіди...',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 16,
              fontFamily: 'Church',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Налаштовую зв\'язок з небесами...',
            style: TextStyle(color: AppTheme.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceLight,
              border: Border.all(
                color: AppTheme.goldAccent.withOpacity(0.3),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldAccent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ]
            ),
            child: const Center(
              child: OrthodoxCrossWidget(
                size: 38,
                color: AppTheme.goldAccent,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 0.8, color: AppTheme.goldAccent.withOpacity(0.5)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: OrthodoxCrossWidget(
                  size: 11,
                  color: AppTheme.ocuBurgundy.withOpacity(0.7),
                ),
              ),
              Container(width: 30, height: 0.8, color: AppTheme.goldAccent.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            'Слава Ісусу Христу!\nЯ тут, щоб підтримати тебе.\nЩо на серці?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 17,
              fontFamily: 'Church',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const _ChatBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 380),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(isUser ? (1 - value) * 18 : (value - 1) * 18, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceLight,
                  border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5)),
                ),
                child: const Center(
                  child: OrthodoxCrossWidget(
                    size: 20,
                    color: AppTheme.ocuBurgundy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.userBubble : AppTheme.aiBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: Border.all(
                    color: isUser 
                        ? Colors.transparent 
                        : AppTheme.ocuBurgundy.withOpacity(0.15),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: MarkdownBody(
                  data: content,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 16,
                      fontFamily: content.contains('Амінь') || content.length > 200 ? 'Church' : null,
                      height: 1.45,
                    ),
                    strong: const TextStyle(
                      color: AppTheme.ocuBurgundy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            child: const Center(
              child: OrthodoxCrossWidget(size: 14, color: AppTheme.goldAccent),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Капелан відповідає ',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppTheme.textDim,
              fontSize: 13,
            ),
          ),
          const _Dot(delay: 0),
          const _Dot(delay: 220),
          const _Dot(delay: 440),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text('.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.ocuBurgundy)),
    );
  }
}

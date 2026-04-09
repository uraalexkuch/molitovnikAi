import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            const _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.userBubble
                    : AppTheme.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: message.isUser
                      ? AppTheme.goldAccent.withOpacity(0.3)
                      : AppTheme.iconsBlue.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: message.isUser
                  ? SelectableText(
                      message.text,
                      style: const TextStyle(
                        color: AppTheme.parchment,
                        fontSize: 15,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text.isEmpty ? '▌' : message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppTheme.parchment,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        strong: const TextStyle(
                          color: AppTheme.goldLight,
                          fontWeight: FontWeight.bold,
                        ),
                        em: const TextStyle(
                          color: AppTheme.parchment,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquote: const TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.goldAccent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.iconsBlue.withOpacity(0.2),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
      ),
      child: const Center(
        child: Text('🕯️', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

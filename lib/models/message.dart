import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  ChatMessage copyWith({String? text}) => ChatMessage(
        id: id,
        text: text ?? this.text,
        isUser: isUser,
        timestamp: timestamp,
      );

  factory ChatMessage.user(String text) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.ai(String text) => ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}_ai',
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );
}

@immutable
class KnowledgeChunk {
  final String id;
  final String content;
  final String source;   // 'bible' | 'prayers' | 'mhz-guides'
  final String location; // напр. "Псалом 22:1" або "Молитва перед боєм"
  final List<double> embedding;

  const KnowledgeChunk({
    required this.id,
    required this.content,
    required this.source,
    required this.location,
    required this.embedding,
  });
}

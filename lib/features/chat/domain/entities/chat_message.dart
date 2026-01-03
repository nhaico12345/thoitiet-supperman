// Entity đại diện cho một tin nhắn trong cuộc trò chuyện với AI.
// Bao gồm: id, text, isUser (người gửi), timestamp.

import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
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

  @override
  List<Object?> get props => [id, text, isUser, timestamp];
}

part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
  });

  @override
  List<Object> get props => [messages, isTyping];
}

class ChatInitial extends ChatState {}

class ChatUpdated extends ChatState {
  const ChatUpdated({
    super.messages,
    super.isTyping,
  });
}

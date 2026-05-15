import 'package:equatable/equatable.dart';
import '../models/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isTyping;
  final MessageEntity? lastReceivedMessage;

  const ChatLoaded({
    required this.messages, 
    this.isTyping = false, 
    this.lastReceivedMessage,
  });

  @override
  List<Object?> get props => [messages, isTyping, lastReceivedMessage];

  ChatLoaded copyWith({
    List<MessageEntity>? messages, 
    bool? isTyping,
    MessageEntity? lastReceivedMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      lastReceivedMessage: lastReceivedMessage,
    );
  }
}

class ChatConversationsLoaded extends ChatState {
  final List<Map<String, dynamic>> conversations;
  const ChatConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

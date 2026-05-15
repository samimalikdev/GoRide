
import 'package:equatable/equatable.dart';
import '../models/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatHistoryFetched extends ChatEvent {
  final String otherUserId;
  const ChatHistoryFetched(this.otherUserId);

  @override
  List<Object?> get props => [otherUserId];
}

class ChatMessageSent extends ChatEvent {
  final String receiverId;
  final String text;
  const ChatMessageSent({required this.receiverId, required this.text});

  @override
  List<Object?> get props => [receiverId, text];
}

class ChatMessageReceived extends ChatEvent {
  final MessageEntity message;
  const ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatConversationsFetched extends ChatEvent {
  final bool silent;
  const ChatConversationsFetched({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

class ChatTypingStatusChanged extends ChatEvent {
  final String receiverId;
  final bool isTyping;
  const ChatTypingStatusChanged({required this.receiverId, required this.isTyping});

  @override
  List<Object?> get props => [receiverId, isTyping];
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/api_service.dart';
import '../models/message_entity.dart';
import 'chat_event.dart';
import 'chat_state.dart';

export 'chat_event.dart';
export 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SocketService socketService;
  final ApiService apiService;
  
  StreamSubscription? _messageSub;
  StreamSubscription? _typingSub;

  ChatBloc({
    required this.socketService,
    required this.apiService,
  }) : super(ChatInitial()) {
    
    on<ChatHistoryFetched>(_onChatHistoryFetched);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatMessageReceived>(_onChatMessageReceived);
    on<ChatConversationsFetched>(_onChatConversationsFetched);
    on<ChatTypingStatusChanged>(_onChatTypingStatusChanged);

    _initSocketListeners();
  }

  void _initSocketListeners() {
    socketService.onMessage((data) {
      if (!isClosed) { 
        final message = MessageEntity.fromJson(
          data, 
          currentUserId: socketService.userId,
        );
        add(ChatMessageReceived(message));
      }
    });

    socketService.onTyping((data) {
      if (!isClosed) { 
        final String senderId = data['senderId'] ?? '';
        final bool isTyping = data['isTyping'] ?? false;
        add(ChatTypingStatusChanged(receiverId: senderId, isTyping: isTyping));
      }
    });

  }

  Future<void> _onChatHistoryFetched(ChatHistoryFetched event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final response = await apiService.get('/chat/history/${event.otherUserId}');
      final List data = response['data'] ?? [];
      final history = data.map((json) => MessageEntity.fromJson(json, currentUserId: socketService.userId)).toList();
      emit(ChatLoaded(messages: history));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onChatMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    print("CHAT_BLOC: Sending message to ${event.receiverId}: ${event.text}");

    if (state is ChatLoaded) {
      final optimisticMsg = MessageEntity(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        senderId: socketService.userId ?? '',
        receiverId: event.receiverId,
        text: event.text,
        createdAt: DateTime.now(),
        isMe: true,
      );
      final current = state as ChatLoaded;
      emit(current.copyWith(messages: [...current.messages, optimisticMsg]));
    }

    socketService.sendMessage(event.receiverId, event.text);
  }

  void _onChatMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    print("CHAT_BLOC: Message received from ${event.message.senderId}");
    final bool isIncoming = event.message.senderId != socketService.userId;

    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      if (currentState.messages.any((m) => m.id == event.message.id)) return;

      List<MessageEntity> updatedMessages;

      if (!isIncoming) {
        final pendingIndex = currentState.messages.lastIndexWhere(
          (m) => m.id.startsWith('pending_') && m.text == event.message.text && m.isMe,
        );
        if (pendingIndex != -1) {
          updatedMessages = List.from(currentState.messages);
          updatedMessages[pendingIndex] = event.message;
        } else {
          updatedMessages = [...currentState.messages, event.message];
        }
      } else {
        updatedMessages = [...currentState.messages, event.message];
      }

      emit(currentState.copyWith(
        messages: updatedMessages,
        lastReceivedMessage: isIncoming ? event.message : null,
      ));
    } else if (state is ChatConversationsLoaded || state is ChatInitial) {
      add(const ChatConversationsFetched(silent: true));
    }
  }

  Future<void> _onChatConversationsFetched(ChatConversationsFetched event, Emitter<ChatState> emit) async {
    if (!event.silent) emit(ChatLoading());
    try {
      final response = await apiService.get('/chat/conversations');
      final List data = response['data'] ?? [];
      final conversations = List<Map<String, dynamic>>.from(data);
      emit(ChatConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onChatTypingStatusChanged(ChatTypingStatusChanged event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isTyping: event.isTyping));
    }
  }

  @override
  Future<void> close() async {
    socketService.stopListener('message');
    socketService.stopListener('typing');
    return super.close();
  }
}

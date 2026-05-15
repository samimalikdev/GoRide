import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final String senderId = json['sender_id'] ?? json['senderId'] ?? '';
    return MessageEntity(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: senderId,
      receiverId: json['receiver_id'] ?? json['receiverId'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      isMe: currentUserId != null && senderId == currentUserId,
    );
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, text, timestamp, isMe];
}

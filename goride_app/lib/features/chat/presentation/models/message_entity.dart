import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isMe;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    this.isMe = false,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final String senderId = json['sender_id'] ?? json['senderId'] ?? '';
    return MessageEntity(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: senderId,
      receiverId: json['receiver_id'] ?? json['receiverId'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      isMe: currentUserId != null && senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, text, imageUrl, createdAt, isMe];
}

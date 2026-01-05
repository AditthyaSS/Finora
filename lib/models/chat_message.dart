import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 3)
class ChatMessage extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late bool isUser;

  @HiveField(3)
  late DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

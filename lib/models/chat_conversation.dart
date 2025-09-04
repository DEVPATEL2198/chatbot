import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'time': time,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      time: json['time'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}

class ChatConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(json['lastMessageAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ChatConversation.fromJsonString(String jsonString) =>
      ChatConversation.fromJson(jsonDecode(jsonString));

  // Generate a title from the first user message
  String generateTitle() {
    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage(
        text: "New Conversation",
        isUser: true,
        time: "",
        timestamp: DateTime.now(),
      ),
    );

    String title = firstUserMessage.text;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }
    return title;
  }

  ChatConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }
}

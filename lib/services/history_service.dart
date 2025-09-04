import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_conversation.dart';

class HistoryService {
  static const String _conversationsKey = 'chat_conversations';
  static const String _currentConversationKey = 'current_conversation_id';

  static HistoryService? _instance;
  static HistoryService get instance => _instance ??= HistoryService._();

  HistoryService._();

  // Save all conversations
  Future<void> saveConversations(List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = conversations.map((c) => c.toJson()).toList();
    await prefs.setString(_conversationsKey, jsonEncode(conversationsJson));
  }

  // Load all conversations
  Future<List<ChatConversation>> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsString = prefs.getString(_conversationsKey);

    if (conversationsString == null || conversationsString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> conversationsJson = jsonDecode(conversationsString);
      return conversationsJson
          .map((json) => ChatConversation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading conversations: $e');
      return [];
    }
  }

  // Save a single conversation
  Future<void> saveConversation(ChatConversation conversation) async {
    final conversations = await loadConversations();
    final existingIndex =
        conversations.indexWhere((c) => c.id == conversation.id);

    if (existingIndex != -1) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.add(conversation);
    }

    // Sort by last message time (newest first)
    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    await saveConversations(conversations);
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final conversations = await loadConversations();
    conversations.removeWhere((c) => c.id == conversationId);
    await saveConversations(conversations);
  }

  // Rename a conversation
  Future<void> renameConversation(
      String conversationId, String newTitle) async {
    final conversations = await loadConversations();
    final index = conversations.indexWhere((c) => c.id == conversationId);

    if (index != -1) {
      conversations[index] = conversations[index].copyWith(title: newTitle);
      await saveConversations(conversations);
    }
  }

  // Clear all conversations
  Future<void> clearAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationsKey);
    await prefs.remove(_currentConversationKey);
  }

  // Set current conversation ID
  Future<void> setCurrentConversationId(String? conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    if (conversationId != null) {
      await prefs.setString(_currentConversationKey, conversationId);
    } else {
      await prefs.remove(_currentConversationKey);
    }
  }

  // Get current conversation ID
  Future<String?> getCurrentConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentConversationKey);
  }

  // Load a specific conversation
  Future<ChatConversation?> loadConversation(String conversationId) async {
    final conversations = await loadConversations();
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Generate unique conversation ID
  String generateConversationId() {
    return 'conv_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Search conversations by title or message content
  Future<List<ChatConversation>> searchConversations(String query) async {
    final conversations = await loadConversations();
    final lowercaseQuery = query.toLowerCase();

    return conversations.where((conversation) {
      // Search in title
      if (conversation.title.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search in messages
      return conversation.messages.any(
          (message) => message.text.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Get conversation statistics
  Future<Map<String, int>> getStatistics() async {
    final conversations = await loadConversations();
    int totalMessages = 0;
    int userMessages = 0;
    int botMessages = 0;

    for (final conversation in conversations) {
      for (final message in conversation.messages) {
        totalMessages++;
        if (message.isUser) {
          userMessages++;
        } else {
          botMessages++;
        }
      }
    }

    return {
      'totalConversations': conversations.length,
      'totalMessages': totalMessages,
      'userMessages': userMessages,
      'botMessages': botMessages,
    };
  }
}

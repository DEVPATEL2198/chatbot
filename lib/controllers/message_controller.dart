import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/api_service.dart';
import '../services/history_service.dart';
import '../models/chat_conversation.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTypeing = false.obs;

  String? _currentConversationId;
  final HistoryService _historyService = HistoryService.instance;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentConversation();
  }

  Future<void> _loadCurrentConversation() async {
    final conversationId = await _historyService.getCurrentConversationId();
    if (conversationId != null) {
      final conversation =
          await _historyService.loadConversation(conversationId);
      if (conversation != null) {
        loadConversation(conversation);
      }
    }
  }

  Future<void> sendMessage(String message) async {
    // Add user message
    final userMessage = {
      'text': message,
      'isUser': true,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    messages.add(userMessage);

    // Create new conversation if needed
    if (_currentConversationId == null) {
      await _createNewConversation();
    }

    responseText.value = "Thinking..";
    isTypeing.value = true;
    update();

    String reply = await GooglleApiService.getApiResponse(message);

    responseText.value = reply;

    // Add bot message
    final botMessage = {
      'text': reply,
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    messages.add(botMessage);

    isTypeing.value = false;
    update();

    // Save conversation to history
    await _saveCurrentConversation();
  }

  Future<void> _createNewConversation() async {
    _currentConversationId = _historyService.generateConversationId();
    await _historyService.setCurrentConversationId(_currentConversationId);
  }

  Future<void> _saveCurrentConversation() async {
    if (_currentConversationId == null || messages.isEmpty) return;

    final chatMessages = messages
        .map((msg) => ChatMessage(
              text: msg['text'] ?? '',
              isUser: msg['isUser'],
              time: msg['time'],
              timestamp: DateTime.now(),
            ))
        .toList();

    final conversation = ChatConversation(
      id: _currentConversationId!,
      title: _generateConversationTitle(),
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      messages: chatMessages,
    );

    await _historyService.saveConversation(conversation);
  }

  String _generateConversationTitle() {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg['isUser'] == true,
      orElse: () => {'text': 'New Conversation'},
    );

    String title = firstUserMessage['text'];
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }
    return title;
  }

  void loadConversation(ChatConversation conversation) {
    _currentConversationId = conversation.id;
    messages.clear();

    for (final msg in conversation.messages) {
      messages.add({
        'text': msg.text,
        'isUser': msg.isUser,
        'time': msg.time,
      });
    }

    _historyService.setCurrentConversationId(_currentConversationId);
    update();
  }

  void startNewConversation() {
    _currentConversationId = null;
    messages.clear();
    responseText.value = "";
    isTypeing.value = false;
    _historyService.setCurrentConversationId(null);
    update();
  }

  bool get hasActiveConversation =>
      _currentConversationId != null && messages.isNotEmpty;

  String? get currentConversationId => _currentConversationId;

  void clearMessages() {
    _currentConversationId = null;
    messages.clear();
    responseText.value = "";
    isTypeing.value = false;
    _historyService.setCurrentConversationId(null);
    update();
  }

  void addMessage(String text, bool isUser) {
    final message = {
      'text': text,
      'isUser': isUser,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    messages.add(message);
    update();
  }

  void addImageMessage(String imagePath, String? text) {
    final message = {
      'type': 'image',
      'imagePath': imagePath,
      'text': text ?? '',
      'isUser': true,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    print('Adding image message: $message'); // Debug log
    messages.add(message);
    update();
  }

  void addBotImageMessage(String imagePath, String? caption) {
    final message = {
      'type': 'image',
      'imagePath': imagePath,
      'text': caption ?? '',
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    messages.add(message);
    update();
  }

  Future<void> sendImageToAI(File imageFile, {String? prompt}) async {
    // Create new conversation if needed
    if (_currentConversationId == null) {
      await _createNewConversation();
    }

    responseText.value = "Thinking..";
    isTypeing.value = true;
    update();

    final reply = await GooglleApiService.getVisionResponse(
      imageFile: imageFile,
      prompt: (prompt != null && prompt.trim().isNotEmpty) ? prompt : null,
      mimeType: _guessMimeType(imageFile.path),
    );

    // Add bot message
    final botMessage = {
      'text': reply,
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    };
    messages.add(botMessage);

    isTypeing.value = false;
    update();

    await _saveCurrentConversation();
  }

  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<void> generateImageFromPrompt(String prompt) async {
    // Ensure a conversation exists
    if (_currentConversationId == null) {
      await _createNewConversation();
    }

    responseText.value = "Generating image..";
    isTypeing.value = true;
    update();

    try {
      final bytes = await GooglleApiService.generateImageBytes(prompt);
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/gen_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Add as bot image message
      addBotImageMessage(file.path, prompt);
    } catch (e) {
      addMessage('Failed to generate image: $e', false);
    } finally {
      isTypeing.value = false;
      update();
      await _saveCurrentConversation();
    }
  }

  Future<bool> saveImageToGallery(String imagePath) async {
    try {
      // Request permissions depending on platform/SDK
      if (Platform.isAndroid) {
        final sdkInt = (await _androidSdkInt());
        if (sdkInt >= 33) {
          await Permission.photos.request();
        } else if (sdkInt >= 29) {
          await Permission.storage.request();
        } else {
          await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        await Permission.photosAddOnly.request();
      }

      final file = File(imagePath);
      if (!await file.exists()) return false;
      // Use gal to save to gallery (handles platform specifics)
      await Gal.putImage(imagePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future _androidSdkInt() async {}
}

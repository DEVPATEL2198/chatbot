import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/theme_controller.dart';
import 'animated_typing_indicator.dart';
import 'message_parser.dart';
import 'package:get/get.dart';
import 'image_viewer.dart';

class CustomChatBubble extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final bool isStreaming;

  const CustomChatBubble({
    super.key,
    required this.messageData,
    this.isStreaming = false,
  });

  // Backward compatibility getters
  String get message => messageData['text'] ?? '';
  bool get isUser => messageData['isUser'] ?? false;
  String get time => messageData['time'] ?? '';
  String? get messageType => messageData['type'];
  String? get imagePath => messageData['imagePath'];

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppTheme.smallSpacing,
          horizontal: AppTheme.mediumSpacing,
        ),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              // Bot Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.smallSpacing),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? AppTheme.userBubbleGradient
                          : AppTheme.getBotBubbleGradient(isDark),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppTheme.xlRadius),
                        topRight: const Radius.circular(AppTheme.xlRadius),
                        bottomLeft: Radius.circular(
                            isUser ? AppTheme.xlRadius : AppTheme.smallRadius),
                        bottomRight: Radius.circular(
                            isUser ? AppTheme.smallRadius : AppTheme.xlRadius),
                      ),
                      border: Border.all(
                        color: AppTheme.getBotBubbleBorder(isDark),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildMessageContent(isDark),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.getHintTextColor(isDark),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: AppTheme.smallSpacing),
              // User Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMessageContent(bool isDark) {
    print('Message data: $messageData'); // Debug all message data
    print('Message type detected: $messageType'); // Debug message type
    print('Image path: $imagePath'); // Debug image path

    switch (messageType) {
      case 'image':
        return _buildImageMessage(isDark);
      default:
        return _buildTextMessage(isDark);
    }
  }

  Widget _buildImageMessage(bool isDark) {
    print('Building image message with path: $imagePath'); // Debug log
    print('Message type: $messageType'); // Debug log

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePath != null)
          GestureDetector(
            onTap: () {
              if (imagePath == null) return;
              Navigator.of(Get.context!).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) =>
                      ImageViewer(imagePath: imagePath!),
                ),
              );
            },
            child: Hero(
              tag: 'image_view_${imagePath!}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image error: $error'); // Debug log
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image not found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTextMessage(isDark),
        ],
      ],
    );
  }

  Widget _buildTextMessage(bool isDark) {
    if (isStreaming) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isNotEmpty)
            MessageParser.buildMessageWidget(
              message,
              isDarkMode: isDark,
            ),
          const SizedBox(height: 8),
          const AnimatedTypingIndicator(),
        ],
      );
    }

    return MessageParser.buildMessageWidget(
      message,
      isDarkMode: isDark,
    );
  }
}

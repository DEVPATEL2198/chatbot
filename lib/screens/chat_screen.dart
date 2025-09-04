import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../controllers/message_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/media_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_chat_bubble.dart';
import '../widgets/animated_typing_indicator.dart';
import '../widgets/welcome_screen.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final MessageController chatMessageController = Get.find();
  final ThemeController themeController = Get.find();
  final MediaController mediaController = Get.put(MediaController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );

    chatMessageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _animateSendButton() {
    _sendButtonController.forward().then((_) {
      _sendButtonController.reverse();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = messageController.text.trim();
    final hasImage = mediaController.selectedImage.value != null;

    if (text.isEmpty && !hasImage) return;

    // Image generation slash-command: /img <prompt>
    if (text.toLowerCase().startsWith('/img ')) {
      final prompt = text.substring(5).trim();
      if (prompt.isEmpty) return;
      // Echo the user command as a normal message for context
      chatMessageController.addMessage('Generate image: $prompt', true);
      messageController.clear();
      _animateSendButton();
      await chatMessageController.generateImageFromPrompt(prompt);
      _scrollToBottom();
      return;
    }

    // Handle image message
    if (hasImage) {
      final imagePath = mediaController.selectedImage.value!.path;
      print('Sending image with path: $imagePath'); // Debug log

      chatMessageController.addImageMessage(
          imagePath, text.isEmpty ? null : text);

      // Send image to AI (Gemini Vision)
      await chatMessageController.sendImageToAI(
        File(imagePath),
        prompt: text.isEmpty ? null : text,
      );

      mediaController.clearSelectedImage();

      // Send to AI for processing (implement based on your API)
      await Future.delayed(const Duration(milliseconds: 500));
      chatMessageController.addMessage(
        "I can see your image! Image analysis will be implemented with the AI integration.",
        false,
      );
    } else {
      // Handle text message
      await chatMessageController.sendMessage(text);
    }

    messageController.clear();
    _animateSendButton();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getBackgroundGradient(isDark),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark),
                _buildMessagesList(isDark),
                Obx(() {
                  if (chatMessageController.isTypeing.value) {
                    return CustomChatBubble(
                      messageData: {
                        'text': chatMessageController.responseText.value,
                        'isUser': false,
                        'time': DateFormat('hh:mm a').format(DateTime.now()),
                      },
                      isStreaming: true,
                    );
                  } else {
                    return const AnimatedTypingIndicator();
                  }
                }),
                _buildInputArea(isDark),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.mediumSpacing,
        vertical: AppTheme.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(isDark).withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppTheme.whiteTextColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Chat Bot',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.getPrimaryTextColor(isDark),
                  ),
                ),
                Obx(() => Text(
                      chatMessageController.isTypeing.value
                          ? 'Typing...'
                          : 'AI Assistant',
                      style: AppTheme.bodySmall.copyWith(
                        color: chatMessageController.isTypeing.value
                            ? AppTheme.primaryStart
                            : AppTheme.getSecondaryTextColor(isDark),
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              try {
                Get.to(() => const HistoryScreen());
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open history screen',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: Icon(
              Icons.history,
              color: AppTheme.getPrimaryTextColor(isDark),
            ),
            tooltip: 'Chat History',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.getPrimaryTextColor(isDark),
            ),
            onSelected: (value) {
              switch (value) {
                case 'new_chat':
                  chatMessageController.clearMessages();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_comment, color: AppTheme.primaryStart),
                    SizedBox(width: AppTheme.smallSpacing),
                    Text('New Chat'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              themeController.toggleTheme();
            },
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: AppTheme.getPrimaryTextColor(isDark),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    return Expanded(
      child: Obx(() {
        if (chatMessageController.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start a conversation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send a message or take a photo to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSecondaryTextColor(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: AppTheme.mediumSpacing,
            bottom: 90, // leave room for floating input bar
          ),
          itemCount: chatMessageController.messages.length,
          itemBuilder: (context, index) {
            final messageData = chatMessageController.messages[index];
            // Subtle slide & fade-in animation per item
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 12),
                    child: child,
                  ),
                );
              },
              child: CustomChatBubble(
                messageData: messageData,
                isStreaming:
                    index == chatMessageController.messages.length - 1 &&
                        chatMessageController.isTypeing.value &&
                        !(messageData['isUser'] ?? false),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected image preview
            Obx(() {
              print(
                  'Image preview check: ${mediaController.selectedImage.value?.path}'); // Debug log
              if (mediaController.selectedImage.value != null) {
                print(
                    'Showing image preview for: ${mediaController.selectedImage.value!.path}'); // Debug log
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getBotBubbleBorder(isDark),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          mediaController.selectedImage.value!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Image selected',
                          style: TextStyle(
                            color: AppTheme.getPrimaryTextColor(isDark),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => mediaController.clearSelectedImage(),
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.getHintTextColor(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(isDark),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppTheme.getBotBubbleBorder(isDark)),
              ),
              child: Row(
                children: [
                  // Camera button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.getBotBubbleBorder(isDark),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        print('Camera button pressed'); // Debug log
                        final image = await mediaController.selectImage();
                        print('Image selected: ${image?.path}'); // Debug log
                        if (image != null) {
                          print(
                              'Image file exists: ${await image.exists()}'); // Debug log
                          // Focus text field after image selection
                          _focusNode.requestFocus();
                          setState(() {}); // refresh send button state
                        } else {
                          print('No image selected'); // Debug log
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Generate image button (uses current text as prompt)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.getBotBubbleBorder(isDark),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final prompt = messageController.text.trim();
                        if (prompt.isEmpty) {
                          Get.snackbar('Prompt required', 'Type what to generate first', snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        chatMessageController.addMessage('Generate image: $prompt', true);
                        messageController.clear();
                        _animateSendButton();
                        await chatMessageController.generateImageFromPrompt(prompt);
                        _scrollToBottom();
                      },
                      icon: Icon(
                        Icons.auto_awesome_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.mediumSpacing,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Add emoji picker functionality here
                          },
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: AppTheme.getHintTextColor(isDark),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallSpacing),
                  Obx(() {
                    final hasImage = mediaController.selectedImage.value != null;
                    final hasText = messageController.text.trim().isNotEmpty;
                    final canSend = hasText || hasImage;
                    return Opacity(
                      opacity: canSend ? 1 : 0.5,
                      child: IgnorePointer(
                        ignoring: !canSend,
                        child: ScaleTransition(
                          scale: _sendButtonAnimation,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: _sendMessage,
                                child: Icon(
                                  Icons.send_rounded,
                                  color: AppTheme.whiteTextColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
    )
    );
  }
}

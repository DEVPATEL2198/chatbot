import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatbot/controllers/message_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/chat_conversation.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ThemeController themeController = Get.find<ThemeController>();
  List<ChatConversation> _conversations = [];
  List<ChatConversation> _filteredConversations = [];
  bool _isLoading = true;
  Map<String, int> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadStatistics();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final conversations = await HistoryService.instance.loadConversations();
      print('Loaded ${conversations.length} conversations from history');
      setState(() {
        _conversations = conversations;
        _filteredConversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load conversations: $e');
    }
  }

  Future<void> _loadStatistics() async {
    final stats = await HistoryService.instance.getStatistics();
    setState(() => _statistics = stats);
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((conv) =>
        conv.title.toLowerCase().contains(query.toLowerCase()) ||
            conv.messages.any(
                    (msg) => msg.text.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  Future<void> _deleteConversation(ChatConversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.instance.deleteConversation(conversation.id);
      _loadConversations();
      _loadStatistics();
      Get.snackbar('Success', 'Conversation deleted');
    }
  }

  Future<void> _renameConversation(ChatConversation conversation) async {
    final TextEditingController renameController =
    TextEditingController(text: conversation.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: renameController,
          decoration: AppTheme.getInputDecoration(
            hintText: "Enter new title...",
          ),
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = renameController.text.trim();
              if (title.isNotEmpty) {
                Navigator.of(context).pop(title);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle != conversation.title) {
      await HistoryService.instance.renameConversation(conversation.id, newTitle);
      _loadConversations();
      Get.snackbar('Success', 'Conversation renamed');
    }
  }

  void _showConversationMenu(ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppTheme.largeRadius)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.hintTextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
            Text(
              conversation.title,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.largeSpacing),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryStart),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameConversation(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryStart),
              title: const Text('Open Conversation'),
              onTap: () {
                Navigator.pop(context);
                _openConversation(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation(conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openConversation(ChatConversation conversation) {
    final messageController = Get.find<MessageController>();
    messageController.loadConversation(conversation);
    Get.back();
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
            'Are you sure you want to delete all conversations? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.instance.clearAllConversations();
      _loadConversations();
      _loadStatistics();
      Get.snackbar('Success', 'All conversations cleared');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(isDark),
        appBar: AppBar(
          title: const Text('Chat History'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.getPrimaryTextColor(isDark),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                themeController.toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: AppTheme.getPrimaryTextColor(isDark),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getBackgroundGradient(isDark),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(isDark),
                _buildStatistics(isDark),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(isDark)
                      : _filteredConversations.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildConversationsList(isDark),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.mediumSpacing),
      child: TextField(
        controller: _searchController,
        decoration: AppTheme.getInputDecoration(
          hintText: "Search conversations...",
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.getHintTextColor(isDark),
          ),
        ),
        onChanged: _filterConversations,
      ),
    );
  }

  Widget _buildStatistics(bool isDark) {
    if (_statistics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing),
      padding: const EdgeInsets.all(AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Conversations', _statistics['totalConversations'] ?? 0, isDark),
          _buildStatItem('Messages', _statistics['totalMessages'] ?? 0, isDark),
          _buildStatItem(
              'Your Messages', _statistics['userMessages'] ?? 0, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, bool isDark) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryStart,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.getSecondaryTextColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryStart,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
            ),
            child: Icon(
              Icons.history,
              size: 40,
              color: AppTheme.whiteTextColor,
            ),
          ),
          const SizedBox(height: AppTheme.largeSpacing),
          Text(
            'No conversations yet',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.getPrimaryTextColor(isDark),
            ),
          ),
          const SizedBox(height: AppTheme.smallSpacing),
          Text(
            'Start chatting to see your conversation history here',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.getSecondaryTextColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.largeSpacing),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.chat),
            label: const Text('Start Chatting'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.mediumSpacing),
      itemCount: _filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = _filteredConversations[index];
        return _buildConversationItem(conversation, isDark);
      },
    );
  }

  Widget _buildConversationItem(ChatConversation conversation, bool isDark) {
    final lastMessage =
    conversation.messages.isNotEmpty ? conversation.messages.last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          onTap: () => _openConversation(conversation),
          onLongPress: () => _showConversationMenu(conversation),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: AppTheme.whiteTextColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.mediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getPrimaryTextColor(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          lastMessage.text,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.getSecondaryTextColor(isDark),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppTheme.getHintTextColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(conversation.lastMessageAt),
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.getSecondaryTextColor(isDark),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${conversation.messages.length} messages',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.getSecondaryTextColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: AppTheme.getHintTextColor(isDark),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

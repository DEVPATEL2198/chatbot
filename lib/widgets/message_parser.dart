import 'package:flutter/material.dart';
import 'code_block_widget.dart';
import '../theme/app_theme.dart';

class MessageContent {
  final String text;
  final bool isCode;
  final String? language;

  MessageContent({
    required this.text,
    this.isCode = false,
    this.language,
  });
}

class MessageParser {
  static List<MessageContent> parseMessage(String message) {
    List<MessageContent> contents = [];

    // Regex to match code blocks with optional language
    final codeBlockRegex =
        RegExp(r'```(\w+)?\n?([\s\S]*?)```', multiLine: true);
    final inlineCodeRegex = RegExp(r'`([^`]+)`');

    int lastIndex = 0;

    // Find all code blocks
    for (final match in codeBlockRegex.allMatches(message)) {
      // Add text before code block
      if (match.start > lastIndex) {
        String beforeText = message.substring(lastIndex, match.start);
        if (beforeText.trim().isNotEmpty) {
          contents.add(MessageContent(text: beforeText.trim()));
        }
      }

      // Add code block
      String language = match.group(1) ?? '';
      String code = match.group(2) ?? '';

      if (code.trim().isNotEmpty) {
        contents.add(MessageContent(
          text: code.trim(),
          isCode: true,
          language: language.isNotEmpty ? language : null,
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < message.length) {
      String remainingText = message.substring(lastIndex);
      if (remainingText.trim().isNotEmpty) {
        contents.add(MessageContent(text: remainingText.trim()));
      }
    }

    // If no code blocks found, return the entire message as text
    if (contents.isEmpty) {
      contents.add(MessageContent(text: message));
    }

    return contents;
  }

  static Widget buildMessageWidget(String message, {bool isDarkMode = false}) {
    final contents = parseMessage(message);

    if (contents.length == 1 && !contents.first.isCode) {
      // Simple text message
      return Text(
        message,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.getPrimaryTextColor(isDarkMode),
          height: 1.4,
        ),
      );
    }

    // Message with code blocks
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contents.map((content) {
        if (content.isCode) {
          return CodeBlockWidget(
            code: content.text,
            language: content.language,
            isDarkMode: isDarkMode,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              content.text,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.getPrimaryTextColor(isDarkMode),
                height: 1.4,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}

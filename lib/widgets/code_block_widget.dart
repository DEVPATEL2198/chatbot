import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String? language;
  final bool isDarkMode;

  const CodeBlockWidget({
    super.key,
    required this.code,
    this.language,
    this.isDarkMode = false,
  });

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copied!',
      'Code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.successColor,
      colorText: AppTheme.whiteTextColor,
      margin: const EdgeInsets.all(AppTheme.mediumSpacing),
      borderRadius: AppTheme.mediumRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.smallSpacing),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF404040) : const Color(0xFFE1E4E8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.mediumSpacing,
              vertical: AppTheme.smallSpacing,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFEBEEF2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.mediumRadius),
                topRight: Radius.circular(AppTheme.mediumRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language?.toUpperCase() ?? 'CODE',
                  style: AppTheme.caption.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                InkWell(
                  onTap: _copyToClipboard,
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: AppTheme.caption.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content with syntax highlighting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                code,
                language: language ?? 'plaintext',
                theme: isDarkMode ? vs2015Theme : githubTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

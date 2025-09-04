import 'package:flutter/material.dart';

class AppTheme {
  // Primary gradient colors
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);
  static const Color secondaryStart = Color(0xFF667eea);
  static const Color secondaryEnd = Color(0xFF764ba2);

  // Chat bubble colors
  static const Color userBubbleStart = Color(0xFF667eea);
  static const Color userBubbleEnd = Color(0xFF764ba2);
  static const Color botBubbleColor = Color(0xFFF5F7FA);
  static const Color botBubbleBorder = Color(0xFFE8ECF4);

  // Background colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Text colors
  static const Color primaryTextColor = Color(0xFF1A1D29);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color hintTextColor = Color(0xFF9CA3AF);
  static const Color whiteTextColor = Color(0xFFFFFFFF);

  // Accent colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFE5E7EB)],
  );

  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  static const BoxShadow bubbleShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  // Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double xlRadius = 20.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double xlSpacing = 32.0;

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1D29),
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1D29),
    letterSpacing: -0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1D29),
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1D29),
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6B7280),
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
    height: 1.2,
  );

  // Chat specific styles
  static const TextStyle userMessageStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFFFFFF),
    height: 1.4,
  );

  static const TextStyle botMessageStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1D29),
    height: 1.4,
  );

  static const TextStyle timeStampStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9CA3AF),
  );

  // Define missing color properties
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color primaryColor = Color(0xFF667eea);

  // Dark mode colors
  static const Color darkBackgroundColor = Color(0xFF0F0F23);
  static const Color darkSurfaceColor = Color(0xFF1A1B3E);
  static const Color darkCardColor = Color(0xFF252659);
  static const Color darkPrimaryTextColor = Color(0xFFE2E8F0);
  static const Color darkSecondaryTextColor = Color(0xFF94A3B8);
  static const Color darkHintTextColor = Color(0xFF64748B);
  static const Color darkBotBubbleColor = Color(0xFF2D2F5A);
  static const Color darkBotBubbleBorder = Color(0xFF3D4073);

  // Dark gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F23), Color(0xFF1A1B3E)],
  );

  // Helper methods for theme-aware colors
  static Color getBackgroundColor(bool isDark) =>
      isDark ? darkBackgroundColor : backgroundColor;

  static Color getSurfaceColor(bool isDark) =>
      isDark ? darkSurfaceColor : surfaceColor;

  static Color getCardColor(bool isDark) => isDark ? darkCardColor : cardColor;

  static Color getPrimaryTextColor(bool isDark) =>
      isDark ? darkPrimaryTextColor : primaryTextColor;

  static Color getSecondaryTextColor(bool isDark) =>
      isDark ? darkSecondaryTextColor : secondaryTextColor;

  static Color getHintTextColor(bool isDark) =>
      isDark ? darkHintTextColor : hintTextColor;

  static Color getBotBubbleColor(bool isDark) =>
      isDark ? darkBotBubbleColor : botBubbleColor;

  static LinearGradient getBackgroundGradient(bool isDark) =>
      isDark ? darkBackgroundGradient : backgroundGradient;

  static LinearGradient getPrimaryGradient(bool isDark) => primaryGradient;

  static Color getWhiteTextColor(bool isDark) => whiteTextColor;

  static Color getPrimaryStart(bool isDark) => primaryStart;

  static Color getSuccessColor(bool isDark) => successColor;

  static Color getErrorColor(bool isDark) => errorColor;

  static Color getBotBubbleBorder(bool isDark) =>
      isDark ? darkBotBubbleBorder : botBubbleBorder;

  // Input decoration
  static InputDecoration getInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Color(0xFFFFFFFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // not const
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // not const
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // not const
        borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  // Theme data (NO const inside here)
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryStart,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1D29),
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1D29)),
      ),
      cardTheme: widget(
        child: CardTheme(
          color: Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 4,
      ),
    );
  }

  // Dark theme data
  static ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryStart,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkPrimaryTextColor,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: darkPrimaryTextColor),
      ),
      cardTheme: widget(
        child: CardTheme(
          color: darkCardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 4,
      ),
    );
  }

  static widget({required CardTheme child}) {}

  static Gradient getBotBubbleGradient(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF2A2A2A),
              const Color(0xFF1E1E1E),
            ]
          : [
              const Color(0xFFF8F9FA),
              const Color(0xFFE9ECEF),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

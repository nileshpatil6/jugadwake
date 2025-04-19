import 'package:flutter/material.dart';

/// App theme and colors for the VoiceFlow app
class AppTheme {
  // VoiceFlow color palette - Blue theme (based on the image)
  static const Color primary = Color(0xFF0EA5E9); // Primary blue
  static const Color lightBlue1 = Color(0xFFE3E8FF); // Lightest blue
  static const Color lightBlue2 = Color(0xFFC5DBFF); // Light blue
  static const Color lightBlue3 = Color(0xFFB7CCFF); // Medium light blue
  static const Color lightBlue4 = Color(0xFF9DB7FF); // Medium blue
  static const Color darkBlue = Color(0xFF1A1F3B); // Dark blue
  static const Color navyText = Color(0xFF1A1F3B); // Navy for text
  static const Color secondaryText = Color(0xFF5A6272); // Secondary text
  static const Color tertiaryText = Color(0xFF8A92A6); // Tertiary text

  // Status colors
  static const Color secondary = Color(0xFFFF6B6B); // Red for status
  static const Color success = Color(0xFF4CAF50); // Green for status

  // Legacy colors (for backward compatibility)
  static const Color accent1 = Color(0xFF9C6ADE); // Purple accent
  static const Color accent2 = Color(0xFF00C39A); // Teal accent

  // Background colors
  static const Color background = Color(0xFFF5F7FF); // Light background
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textDark = navyText;
  static const Color textLight = secondaryText;
  static const Color borderColor = lightBlue2;

  // Create the theme data
  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        surfaceContainer: background,
        surface: cardBackground,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: navyText),
        titleTextStyle: TextStyle(
          color: navyText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      textTheme: const TextTheme(
        // VoiceFlow specific text styles
        displayLarge: TextStyle(
          color: navyText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineLarge: TextStyle(
          color: navyText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          color: navyText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          color: navyText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: navyText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          color: navyText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          color: navyText,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: navyText,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: secondaryText,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shadowColor: Colors.black.withAlpha(6),
      ),
    );
  }
}

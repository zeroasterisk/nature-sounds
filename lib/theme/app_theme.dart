import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Color Palette ──────────────────────────────────────────────
  static const Color background = Color(0xFF1A1B2E);
  static const Color surface = Color(0xFF242640);
  static const Color primary = Color(0xFF7B8CDE);
  static const Color secondary = Color(0xFF5CC6BA);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSubtitle = Color(0xFF8B8DA3);
  static const Color favoriteHeart = Color(0xFFD4A5A5);
  static const Color timerLavender = Color(0xFFC8B8DB);

  // ── Theme Data ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      cardColor: surface,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      iconTheme: const IconThemeData(color: textSubtitle),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textSubtitle,
          fontSize: 12,
        ),
        labelMedium: TextStyle(
          color: textSubtitle,
          fontSize: 13,
        ),
      ),
    );
  }
}

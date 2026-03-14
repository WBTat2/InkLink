// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color inkRed = Color(0xFFE53935);
  static const Color bg = Color(0xFF0B0B0F);
  static const Color card = Color(0xFF12121A);
  static const Color text = Color(0xFFEDEDED);
  static const Color muted = Color(0xFF9A9AA3);

  static ThemeData dark() {
    final base = ThemeData.dark();

    final scheme = base.colorScheme.copyWith(
      primary: inkRed,
      secondary: inkRed,
      surface: card,
      background: bg,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      // ✅ This makes widgets like ProgressIndicator actually go red
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: inkRed,
        linearTrackColor: Colors.white12,
      ),

      // ✅ FAB / + buttons go red too
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: inkRed,
        foregroundColor: Colors.white,
      ),

      // ✅ Chips (FilterChip etc.) stop doing random purple stuff
      chipTheme: base.chipTheme.copyWith(
        selectedColor: inkRed.withOpacity(0.25),
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(color: text),
        secondaryLabelStyle: const TextStyle(color: text),
        side: const BorderSide(color: Colors.white12),
      ),

      textTheme: base.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: text,
      ),

      dividerColor: Colors.white12,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: inkRed, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: inkRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkRed,
          side: const BorderSide(color: inkRed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: inkRed,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? inkRed.withOpacity(0.55)
              : Colors.white24;
        }),
      ),
    );
  }
}
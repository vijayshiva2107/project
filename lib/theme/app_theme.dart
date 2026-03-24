import 'package:flutter/material.dart';

class AppTheme {
  // ── Core Palette ──────────────────────────────────────────
  static const Color background  = Color(0xFF080A0F);
  static const Color surface     = Color(0xFF10131C);
  static const Color surfaceHigh = Color(0xFF171B27);
  static const Color card        = Color(0xFF1A1E2C);

  static const Color accent      = Color(0xFFE8A020); // warm amber/gold
  static const Color accentDim   = Color(0xFF9A6A14);

  static const Color available   = Color(0xFF22C55E); // emerald
  static const Color busy        = Color(0xFFF59E0B); // amber
  static const Color offline     = Color(0xFF6B7280); // slate

  static const Color textPrimary   = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF8891AA);
  static const Color textMuted     = Color(0xFF4B5268);

  static const Color border        = Color(0xFF1F2435);
  static const Color borderGlass   = Color(0x1AFFFFFF); // white 10%

  // ── Avatar palette ────────────────────────────────────────
  static const List<Color> avatarPalette = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFF14B8A6), Color(0xFF22C55E), Color(0xFFF97316),
    Color(0xFF3B82F6), Color(0xFFE8A020), Color(0xFFF43F5E),
    Color(0xFF0EA5E9),
  ];

  // ── Theme ─────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: available,
        surface: surface,
        error: Color(0xFFEF4444),
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.2),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dividerColor: border,
    );
  }
}

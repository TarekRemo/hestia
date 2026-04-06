import 'package:flutter/material.dart';

class AppTheme {
  // ─── Common Colors ───
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color accentColor = Color(0xFF00D2FF);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53935);
  static const Color positiveColor = Color(0xFF4CAF50);
  static const Color negativeColor = Color(0xFFE53935);

  // ─── Dark Theme Colors ───
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color bgCard = Color(0xFF1D1E33);
  static const Color bgCardLight = Color(0xFF2D2E43);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C3);
  static const Color textMuted = Color(0xFF6C6C80);

  // ─── Light Theme Colors ───
  static const Color bgLightScaffold = Color(0xFFF5F5F7);
  static const Color bgCardLightTheme = Color(0xFFFFFFFF);
  static const Color bgCardLightAccent = Color(0xFFEEEEF2);
  static const Color textPrimaryLt = Color(0xFF1A1A2E);
  static const Color textSecondaryLt = Color(0xFF5A5A6E);
  static const Color textMutedLt = Color(0xFF9E9EB0);

  // ─── Context-aware color helpers ───
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? textPrimary : textPrimaryLt;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? textSecondary : textSecondaryLt;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? textMuted : textMutedLt;

  static Color bgCardOf(BuildContext context) =>
      isDark(context) ? bgCard : bgCardLightTheme;

  static Color bgCardLightOf(BuildContext context) =>
      isDark(context) ? bgCardLight : bgCardLightAccent;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgDark,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: bgCard,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgCardLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardLight,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: bgCardLight, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── LIGHT THEME ───
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgLightScaffold,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: bgCardLightTheme,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCardLightTheme,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryLt,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimaryLt),
      ),
      cardTheme: CardThemeData(
        color: bgCardLightTheme,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLightAccent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bgCardLightAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryLt),
        hintStyle: const TextStyle(color: textMutedLt),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCardLightTheme,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMutedLt,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardLightAccent,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: textPrimaryLt),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: bgCardLightAccent, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCardLightTheme,
        contentTextStyle: const TextStyle(color: textPrimaryLt),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Box Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardDecorationOf(BuildContext context) => BoxDecoration(
        color: bgCardOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark(context)
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get gradientCardDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textMuted,
  );

  static const TextStyle scoreDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // ─── Context-aware Text Styles ───
  static TextStyle headingLargeOf(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryOf(context),
  );

  static TextStyle headingMediumOf(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimaryOf(context),
  );

  static TextStyle headingSmallOf(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryOf(context),
  );

  static TextStyle bodyLargeOf(BuildContext context) => TextStyle(
    fontSize: 16,
    color: textPrimaryOf(context),
  );

  static TextStyle bodyMediumOf(BuildContext context) => TextStyle(
    fontSize: 14,
    color: textSecondaryOf(context),
  );

  static TextStyle bodySmallOf(BuildContext context) => TextStyle(
    fontSize: 12,
    color: textMutedOf(context),
  );

  static TextStyle scoreDisplayOf(BuildContext context) => TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textPrimaryOf(context),
  );
}

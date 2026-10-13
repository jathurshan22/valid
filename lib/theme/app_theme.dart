import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF6F5F0);
  static const surface = Color(0xFFFFFEFB);
  static const ink = Color(0xFF19352E);
  static const muted = Color(0xFF71817C);
  static const line = Color(0xFFE4E8E4);
  static const primary = Color(0xFF0F6B5A);
  static const primaryDark = Color(0xFF0A5145);
  static const mint = Color(0xFFDDEDE7);
  static const mintSoft = Color(0xFFEDF5F1);
  static const amber = Color(0xFFD58B2B);
  static const amberSoft = Color(0xFFFFF0D9);
  static const danger = Color(0xFFC95D57);
  static const dangerSoft = Color(0xFFFBE6E4);
  static const blue = Color(0xFF607C91);
  static const blueSoft = Color(0xFFE8F0F5);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true);
    const buttonText = TextStyle(fontWeight: FontWeight.w800, fontSize: 14);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.line),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(44, 44),
          highlightColor: AppColors.mintSoft,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(
          color: Color(0xFF98A49F),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
    );
  }
}

class AppRadii {
  static const double card = 24;
  static const double control = 18;
  static const double pill = 999;
}

class AppShadows {
  static const soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F1B3D35),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const sage = Color(0xFF718675);
  static const forest = Color(0xFF2C4235);
  static const cream = Color(0xFFF7F7F1);
  static const brown = Color(0xFF92745D);
  static const line = Color(0xFFE4E8DF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: Brightness.light,
      surface: AppColors.cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.forest,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.forest,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.forest,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.forest,
        ),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

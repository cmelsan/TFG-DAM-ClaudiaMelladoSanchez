import 'package:flutter/material.dart';

/// Paleta de colores de Sabor de Casa.
class AppColors {
  const AppColors._();

  static const primaryGreen = Color(0xFF2F9E8F);
  static const lightGreen = Color(0xFF7ED1C6);
  static const cream = Color(0xFFF6F9F8);
  static const darkGray = Color(0xFF2D3436);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
        ),

        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: const CardThemeData(elevation: 1),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: const CardThemeData(elevation: 1),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}

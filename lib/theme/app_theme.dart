import 'package:flutter/material.dart';

class AppTheme {
  // HTML 디자인에 맞춘 색상 정의
  static const Color primary = Color(0xFFFFE8A3); // #ffe8a3
  static const Color primaryHover = Color(0xFFFFE085); // #ffe085
  static const Color backgroundColor = Color(0xFFF8F8F5); // #f8f8f5
  static const Color textDark = Color(0xFF332F21); // #332f21
  static const Color textLight = Color(0xFFF1EEE6); // #f1eee6
  
  // 기존 색상들 (호환성 유지)
  static const Color lightYellow = Color(0xFFFFE8A3);
  static const Color lightOrange = Color(0xFFFFE085);
  static const Color lightBlue = Color(0xFFB3E5FC);
  static const Color lightPurple = Color(0xFFE1BEE7);
  static const Color lightGreen = Color(0xFFC8E6C9);
  static const Color textPrimary = Color(0xFF332F21);
  static const Color textSecondary = Color(0xFF757575);
  static const Color accentYellow = Color(0xFFFFF176);

  // 테마 생성
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightYellow,
        primary: lightYellow,
        background: backgroundColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 28,
          height: 1.3,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 22,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}


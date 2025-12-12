import 'package:flutter/material.dart';

class AppTheme {
  // 이미지 디자인에 맞춘 색상 정의
  static const Color backgroundColor = Color(0xFFFFFDF7); // 매우 밝은 크림/오프화이트
  static const Color lightYellow = Color(0xFFFFF9C4); // 밝은 노란색
  static const Color lightOrange = Color(0xFFFFE0B2); // 밝은 오렌지
  static const Color lightBlue = Color(0xFFB3E5FC); // 밝은 파란색
  static const Color lightPurple = Color(0xFFE1BEE7); // 밝은 보라색
  static const Color lightGreen = Color(0xFFC8E6C9); // 밝은 초록색
  static const Color textPrimary = Color(0xFF212121); // 검은색
  static const Color textSecondary = Color(0xFF757575); // 어두운 회색
  static const Color accentYellow = Color(0xFFFFF176); // 강조 노란색

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


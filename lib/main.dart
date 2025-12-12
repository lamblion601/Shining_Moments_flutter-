import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/landing/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtMind - 빛나는 순간들',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LandingScreen(),
    );
  }
}

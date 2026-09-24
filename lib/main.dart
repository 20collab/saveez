import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const SaveEzApp());
}

class SaveEzApp extends StatelessWidget {
  const SaveEzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveEz - กระปุกออมเงินออนไลน์',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B8B),
          primary: const Color(0xFFFF6B8B),
          secondary: const Color(0xFFFF8E53),
          background: const Color(0xFFFAF9F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2D3142),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

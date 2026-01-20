import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A6CF7),
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
      ),
      home: const SplashScreen(),
    );
  }
}

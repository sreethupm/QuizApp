import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<Offset> qAnim;
  late Animation<Offset> uizAnim;
  late Animation<Offset> aAnim;
  late Animation<Offset> ppAnim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    qAnim = Tween<Offset>(
      begin: const Offset(-2, 0), // from LEFT
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    uizAnim = Tween<Offset>(
      begin: const Offset(0, -2), // from TOP
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    aAnim = Tween<Offset>(
      begin: const Offset(2, 0), // from RIGHT
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    ppAnim = Tween<Offset>(
      begin: const Offset(0, 2), // from BOTTOM
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Text letter(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A6CF7),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(position: qAnim, child: letter('Q')),
            SlideTransition(position: uizAnim, child: letter('UIZ')),
            const SizedBox(width: 10),
            SlideTransition(position: aAnim, child: letter('A')),
            SlideTransition(position: ppAnim, child: letter('PP')),
          ],
        ),
      ),
    );
  }
}

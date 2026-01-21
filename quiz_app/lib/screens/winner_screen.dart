import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';
import 'mode_selection_screen.dart';

class WinnerScreen extends StatelessWidget {
  final int aScore;
  final int bScore;

  const WinnerScreen({
    super.key,
    required this.aScore,
    required this.bScore,
  });

  @override
  Widget build(BuildContext context) {
    String result;
    Color resultColor;

    if (aScore > bScore) {
      result = "🏆 PLAYER A WINS!";
      resultColor = Colors.tealAccent;
    } else if (bScore > aScore) {
      result = "🏆 PLAYER B WINS!";
      resultColor = Colors.orangeAccent;
    } else {
      result = "🤝 IT'S A DRAW!";
      resultColor = Colors.white;
    }

    // 🔊 Play winner sound once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (aScore != bScore) {
        SoundManager.play('correct.wav');
      } else {
        SoundManager.play('wrong.wav');
      }
    });

    final Random _random = Random();
    final List<IconData> quizIcons = [
      Icons.menu_book_rounded,
      Icons.lightbulb_outline,
      Icons.school_rounded,
      Icons.psychology_alt_rounded,
      Icons.help_outline,
    ];

    Widget floatingIcon(IconData icon) {
      final double dx = (_random.nextDouble() - 0.5) * 300;
      final double dy = (_random.nextDouble() - 0.5) * 300;
      final double size = _random.nextDouble() * 28 + 18;

      return AnimatedBuilder(
        animation: AlwaysStoppedAnimation(1),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(dx, dy),
            child: Opacity(
              opacity: 0.25,
              child: child,
            ),
          );
        },
        child: Icon(icon, size: size, color: Colors.white24),
      );
    }

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...quizIcons.map(floatingIcon),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.white30,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      scoreCard("PLAYER A", aScore, Colors.tealAccent),
                      const SizedBox(width: 20),
                      scoreCard("PLAYER B", bScore, Colors.orangeAccent),
                    ],
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      SoundManager.play('click.wav');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModeSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget scoreCard(String label, int score, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../utils/sound_manager.dart';
import 'mode_selection_screen.dart'; // <-- import ModeSelectionScreen

class ResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final int wrong;

  const ResultScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.wrong,
  });

  @override
  Widget build(BuildContext context) {
    final int answered = correct + wrong;
    final double percent = total > 0 ? correct / total : 0.0;

    // 🔊 Play result sound once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (percent >= 0.5) {
        SoundManager.play('correct.wav'); // 🎉 success
      } else {
        SoundManager.play('wrong.wav'); // 😕 fail
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
      final double dx = (_random.nextDouble() - 0.5) * 220;
      final double dy = (_random.nextDouble() - 0.5) * 220;
      final double size = _random.nextDouble() * 28 + 18;

      return AnimatedBuilder(
        animation: AlwaysStoppedAnimation(1),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(dx, dy),
            child: Opacity(
              opacity: 0.3,
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

              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "RESULT",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CircularPercentIndicator(
                        radius: 130,
                        lineWidth: 14,
                        percent: percent.clamp(0, 1),
                        animation: true,
                        animationDuration: 1200,
                        center: Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.tealAccent,
                        backgroundColor: Colors.white24,
                      ),
                      const SizedBox(height: 36),
                      buildStatRow("Total Questions", total.toString()),
                      buildStatRow("Answered", answered.toString()),
                      buildStatRow("Correct Answers", correct.toString()),
                      buildStatRow("Wrong Answers", wrong.toString(), isError: true),
                      const SizedBox(height: 36),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          SoundManager.play('click.wav');
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
                            (route) => false, // remove all previous routes
                          );
                        },
                        child: const Text("Back to Home"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isError ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

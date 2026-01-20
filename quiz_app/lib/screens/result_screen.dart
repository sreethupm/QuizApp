// result_screen.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int total;
  final int answered;
  final int correct;
  final int wrong;
  final int timeout;

  // Removed const constructor for hot reload
  ResultScreen({
    super.key,
    required this.total,
    required this.answered,
    required this.correct,
    required this.wrong,
    required this.timeout,
  });

  @override
  Widget build(BuildContext context) {
    int effectiveScore = correct - timeout;
    if (effectiveScore < 0) effectiveScore = 0;

    double percent = total > 0 ? (effectiveScore / total) : 0.0;
    percent = percent.clamp(0, 1);

    return Scaffold(
      // 🎨 Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple → Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "RESULT",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                CircularPercentIndicator(
                  radius: 120,
                  lineWidth: 12,
                  percent: percent,
                  animation: true,
                  animationDuration: 1200,
                  center: Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Text("Total Questions: $total",
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                      Text("Answered: $answered",
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                      Text("Correct Answers: $correct",
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                      Text("Wrong Answers: $wrong",
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                      Text("Timeouts: $timeout",
                          style: const TextStyle(fontSize: 18, color: Colors.redAccent)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF6A11CB), // text color matches gradient start
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    );
                  },
                  child: const Text("Retry Quiz"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

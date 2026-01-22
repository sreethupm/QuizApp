import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/api_services.dart';
import '../widgets/option_tile.dart';
import '../utils/sound_manager.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<Question> questions = [];
  bool loading = true;

  int currentIndex = 0;
  int correct = 0;
  int wrong = 0;

  int? selected;
  bool answered = false;

  int timeLeft = 20;
  Timer? timer;

  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();
    loadQuestions();

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  Future<void> loadQuestions() async {
    questions = await ApiService.fetchQuestions();
    setState(() => loading = false);
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 20;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        moveNext();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void answerQuestion(int index, String answer) {
    if (answered) return;
    timer?.cancel();

    setState(() {
      selected = index;
      answered = true;

      if (answer == questions[currentIndex].correctAnswer) {
        correct++;
        SoundManager.play('correct.wav');
      } else {
        wrong++;
        SoundManager.play('wrong.wav');
      }
    });

    Future.delayed(const Duration(milliseconds: 400), moveNext);
  }

  void skipQuestion() {
    timer?.cancel();
    moveNext();
  }

  void moveNext() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selected = null;
        answered = false;
      });
      startTimer();
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            total: questions.length,
            correct: correct,
            wrong: wrong,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _circleController.dispose();
    super.dispose();
  }

  /// 🔵 CENTER GLOWING ROUND ANIMATION
  Widget centerOrb() {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, _) {
        final glow = sin(_circleController.value * pi * 2).abs();
        final size = 180 + 30 * glow;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.35),
                blurRadius: 80,
                spreadRadius: 30,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

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
              centerOrb(),

              /// MAIN QUESTION CARD
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.25),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Question ${currentIndex + 1} / ${questions.length}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: timeLeft / 20,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// OPTIONS
                      ...question.options.asMap().entries.map((entry) {
                        return OptionTile(
                          text: entry.value,
                          isSelected: selected == entry.key,
                          onTap: () =>
                              answerQuestion(entry.key, entry.value),
                        );
                      }),

                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: skipQuestion,
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}

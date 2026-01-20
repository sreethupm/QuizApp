// quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/api_services.dart';
import '../widgets/option_tile.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<Question> questions = [];
  int index = 0;

  // 📊 SCORE & STATS
  int correctAnswers = 0;
  int wrongAnswers = 0;       // wrong answers
  int timeoutAnswers = 0;     // timeout count
  int totalAnswered = 0;      // correct + wrong

  bool loading = true;
  double opacity = 1.0;
  int? selectedOptionIndex;

  // ⏱ TIMER
  Timer? _timer;
  int timeLeft = 30;
  bool isAnswered = false;

  // 🎬 QUESTION NUMBER ANIMATION
  late AnimationController _qnController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    loadData();

    _qnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _qnController, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _qnController, curve: Curves.easeIn));
  }

  Future<void> loadData() async {
    questions = await ApiService.fetchQuestions();
    setState(() => loading = false);
    startTimer();
    _qnController.forward();
  }

  void startTimer() {
    _timer?.cancel();
    timeLeft = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        timer.cancel();
        if (!isAnswered) timeoutAnswers++;
        moveToNext();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void nextQuestion(int optionIndex, String answer) async {
    if (isAnswered) return;

    _timer?.cancel();
    isAnswered = true;

    setState(() => selectedOptionIndex = optionIndex);
    totalAnswered++;

    await Future.delayed(const Duration(milliseconds: 300));

    if (answer == questions[index].correctAnswer) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    moveToNext();
  }

  void moveToNext() async {
    setState(() => opacity = 0);
    await Future.delayed(const Duration(milliseconds: 300));

    if (index < questions.length - 1) {
      setState(() {
        index++;
        opacity = 1;
        selectedOptionIndex = null;
        timeLeft = 30;
        isAnswered = false;
      });

      _qnController.reset();
      _qnController.forward();
      startTimer();
    } else {
      // Navigate to result screen
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            total: questions.length,
            answered: totalAnswered,
            correct: correctAnswers,
            wrong: wrongAnswers,
            timeout: timeoutAnswers,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _qnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔢 QUESTION NUMBER
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Text(
                        "QUESTION ${index + 1}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // changed to white for contrast
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⏱ TIMER
                  Text(
                    "Time Left: $timeLeft s",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeLeft <= 5 ? Colors.red : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ❓ QUESTION
                  Text(
                    questions[index].question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ OPTIONS
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: questions[index].options.asMap().entries.map((entry) {
                      int i = entry.key;
                      String option = entry.value;

                      return OptionTile(
                        text: option,
                        isSelected: selectedOptionIndex == i,
                        onTap: () => nextQuestion(i, option),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

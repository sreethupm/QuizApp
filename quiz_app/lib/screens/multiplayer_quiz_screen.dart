import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/api_services.dart';
import '../widgets/option_tile.dart';
import 'winner_screen.dart';
import '../utils/sound_manager.dart';

class MultiplayerQuizScreen extends StatefulWidget {
  const MultiplayerQuizScreen({super.key});

  @override
  State<MultiplayerQuizScreen> createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends State<MultiplayerQuizScreen>
    with SingleTickerProviderStateMixin {
  bool loading = true;

  // 🔀 Separate shuffled question lists
  late List<Question> aQuestions;
  late List<Question> bQuestions;

  // Player A
  int aIndex = 0, aCorrect = 0, aWrong = 0;
  int? aSelected;
  bool aAnswered = false;
  int aTimeLeft = 20;
  Timer? aTimer;

  // Player B
  int bIndex = 0, bCorrect = 0, bWrong = 0;
  int? bSelected;
  bool bAnswered = false;
  int bTimeLeft = 20;
  Timer? bTimer;

  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    loadData();
  }

  Future<void> loadData() async {
    final fetched = await ApiService.fetchQuestions();

    // 🔁 SAME QUESTIONS, DIFFERENT ORDER
    aQuestions = List<Question>.from(fetched)..shuffle();
    bQuestions = List<Question>.from(fetched)..shuffle();

    setState(() => loading = false);
    startATimer();
    startBTimer();
  }

  // ---------------- TIMERS ----------------

  void startATimer() {
    aTimer?.cancel();
    aTimeLeft = 20;
    aTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (aTimeLeft <= 0) skipA();
      else setState(() => aTimeLeft--);
    });
  }

  void startBTimer() {
    bTimer?.cancel();
    bTimeLeft = 20;
    bTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (bTimeLeft <= 0) skipB();
      else setState(() => bTimeLeft--);
    });
  }

  // ---------------- ANSWERS ----------------

  void answerA(int i, String answer) {
    if (aAnswered) return;

    setState(() {
      aSelected = i;
      aAnswered = true;

      if (answer == aQuestions[aIndex].correctAnswer) {
        aCorrect++;
        SoundManager.play('correct.wav');
      } else {
        aWrong++;
        SoundManager.play('wrong.wav');
      }
    });

    Future.delayed(const Duration(milliseconds: 300), moveNextA);
  }

  void answerB(int i, String answer) {
    if (bAnswered) return;

    setState(() {
      bSelected = i;
      bAnswered = true;

      if (answer == bQuestions[bIndex].correctAnswer) {
        bCorrect++;
        SoundManager.play('correct.wav');
      } else {
        bWrong++;
        SoundManager.play('wrong.wav');
      }
    });

    Future.delayed(const Duration(milliseconds: 300), moveNextB);
  }

  // ---------------- NAVIGATION ----------------

  void skipA() {
    aTimer?.cancel();
    moveNextA();
  }

  void skipB() {
    bTimer?.cancel();
    moveNextB();
  }

  void moveNextA() {
    aTimer?.cancel();
    if (aIndex < aQuestions.length - 1) {
      setState(() {
        aIndex++;
        aSelected = null;
        aAnswered = false;
        aTimeLeft = 20;
      });
      startATimer();
    } else {
      checkFinish();
    }
  }

  void moveNextB() {
    bTimer?.cancel();
    if (bIndex < bQuestions.length - 1) {
      setState(() {
        bIndex++;
        bSelected = null;
        bAnswered = false;
        bTimeLeft = 20;
      });
      startBTimer();
    } else {
      checkFinish();
    }
  }

  void checkFinish() {
    if (aIndex >= aQuestions.length - 1 &&
        bIndex >= bQuestions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            aScore: aCorrect,
            bScore: bCorrect,
          ),
        ),
      );
    }
  }

  // ---------------- UI ----------------

  Widget playerCard({
    required String label,
    required Color accent,
    required Question question,
    required int index,
    required int timeLeft,
    required int? selected,
    required Function(int, String) onTap,
    required VoidCallback onSkip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "PLAYER $label",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Question ${index + 1}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: timeLeft / 20,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(accent),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ...question.options.asMap().entries.map((e) {
                    return OptionTile(
                      text: e.value,
                      isSelected: selected == e.key,
                      onTap: () => onTap(e.key, e.value),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onSkip,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
            ),
            child: const Text("Skip"),
          ),
        ],
      ),
    );
  }

  Widget glowingOrb() {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (_, __) {
        final size =
            220 + 40 * sin(_orbController.value * pi * 2).abs();
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
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
  void dispose() {
    aTimer?.cancel();
    bTimer?.cancel();
    _orbController.dispose();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            glowingOrb(),
            Column(
              children: [
                Expanded(
                  child: Transform.rotate(
                    angle: pi,
                    child: playerCard(
                      label: "A",
                      accent: Colors.lightBlueAccent,
                      question: aQuestions[aIndex],
                      index: aIndex,
                      timeLeft: aTimeLeft,
                      selected: aSelected,
                      onTap: answerA,
                      onSkip: skipA,
                    ),
                  ),
                ),
                Expanded(
                  child: playerCard(
                    label: "B",
                    accent: Colors.tealAccent,
                    question: bQuestions[bIndex],
                    index: bIndex,
                    timeLeft: bTimeLeft,
                    selected: bSelected,
                    onTap: answerB,
                    onSkip: skipB,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

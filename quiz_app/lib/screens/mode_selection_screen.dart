import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';
import 'quiz_screen.dart';
import 'multiplayer_quiz_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedMode;
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027), // dark navy
                Color(0xFF203A43), // teal
                Color(0xFF2C5364), // cyan
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _centerOrb(),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "SELECT MODE",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 50),

                  _modeButton("Single Player", Icons.person),
                  const SizedBox(height: 22),
                  _modeButton("Multiplayer", Icons.people),

                  const SizedBox(height: 50),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: selectedMode != null ? 1 : 0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.95),
                        foregroundColor: const Color(0xFF203A43),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 56,
                          vertical: 18,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 10,
                        shadowColor:
                            Colors.black.withOpacity(0.4),
                      ),
                      onPressed: selectedMode == null
                          ? null
                          : () {
                              SoundManager.play('click.wav');

                              if (selectedMode == "Single Player") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const QuizScreen(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MultiplayerQuizScreen(),
                                  ),
                                );
                              }
                            },
                      child: const Text("START"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔮 Elegant glowing orb (matches splash)
  Widget _centerOrb() {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final glow = sin(_orbController.value * pi * 2).abs();
        final size = 170 + 30 * glow;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.35),
                blurRadius: 70,
                spreadRadius: 25,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎮 Mode button (glassmorphism style)
  Widget _modeButton(String mode, IconData icon) {
    final bool isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () {
        SoundManager.play('click.wav');
        setState(() => selectedMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.92)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 1.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color:
                  isSelected ? const Color(0xFF203A43) : Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              mode,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF203A43)
                    : Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

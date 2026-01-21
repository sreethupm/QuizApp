import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';
import 'mode_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _floatController;

  final Random _random = Random();

  /// IMPORTANT: space is handled properly
  final List<String> _letters = ['Q', 'U', 'I', 'Z', ' ', 'A', 'P', 'P'];
  final List<Offset> _startOffsets = [];

  final List<IconData> quizIcons = [
    Icons.menu_book_rounded,
    Icons.psychology_alt_rounded,
    Icons.lightbulb_outline,
    Icons.school_rounded,
    Icons.help_outline,
  ];

  @override
  void initState() {
    super.initState();

    /// Smaller offsets → prevents drifting to corners
    for (int i = 0; i < _letters.length; i++) {
      _startOffsets.add(
        Offset(
          (_random.nextDouble() * 2) - 1,
          (_random.nextDouble() * 2) - 1,
        ),
      );
    }

    _textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);

    /// 🔊 Play welcome sound
    Future.delayed(const Duration(milliseconds: 200), () {
      SoundManager.play('welcome.wav');
    });

    /// 🚀 Navigation after splash
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  /// 🔤 Smooth elastic letter animation (CENTER SAFE)
  Widget animatedLetter(String letter, Offset startOffset, int index) {
    final animation = CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    );

    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final progress = (animation.value - index * 0.08).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(
            startOffset.dx * (1 - progress) * 60,
            startOffset.dy * (1 - progress) * 60,
          ),
          child: Transform.scale(
            scale: progress,
            child: Opacity(opacity: progress, child: child),
          ),
        );
      },
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 4,
        ),
      ),
    );
  }

  /// 🌟 Floating icons
  Widget floatingIcon(IconData icon) {
    final dx = (_random.nextDouble() - 0.5) * 200;
    final dy = (_random.nextDouble() - 0.5) * 200;
    final size = _random.nextDouble() * 26 + 18;

    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) {
        final anim = sin(_floatController.value * pi * 2);
        return Transform.translate(
          offset: Offset(dx * anim, dy * anim),
          child: Opacity(opacity: 0.3 + anim.abs() * 0.4, child: child),
        );
      },
      child: Icon(icon, size: size, color: Colors.white54),
    );
  }

  /// 🔄 Elegant rotating ring
  Widget rotatingRing() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (_, child) => Transform.rotate(
        angle: _rotateController.value * pi * 2,
        child: child,
      ),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 3),
        ),
      ),
    );
  }

  /// 🧠 Glowing center icon
  Widget pulsingBrain() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) =>
          Transform.scale(scale: 1 + 0.08 * _pulseController.value, child: child),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          boxShadow: [
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.psychology_alt_rounded,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
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
                Color(0xFF203A43), // blue teal
                Color(0xFF2C5364), // elegant cyan
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...quizIcons.map(floatingIcon),
              rotatingRing(),
              pulsingBrain(),

              /// ✅ PERFECTLY CENTERED QUIZ APP TEXT
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _letters.length,
                      (i) => animatedLetter(
                        _letters[i],
                        _startOffsets[i],
                        i,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Test Your Knowledge",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1.5,
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
}

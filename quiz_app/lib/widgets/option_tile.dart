import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  // Customizable colors
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;

  const OptionTile({
    super.key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.selectedColor = const Color(0xFFF06292), // pink accent
    this.unselectedColor = const Color(0x66FFFFFF), // semi-transparent white
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed width based on screen size
    double fixedWidth = MediaQuery.of(context).size.width * 0.42;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: fixedWidth, // fixed width for all options
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown, // prevent text overflow
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? textColor : textColor.withOpacity(0.85),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SwitchColorBtn extends StatelessWidget {
  final String textTrue;
  final String textFalse;
  final List<Color> colorsTrue;
  final List<Color> colorsFalse;
  final bool state;
  final VoidCallback onTap;
  final double width;
  final double height;

  const SwitchColorBtn({
    super.key,
    required this.textTrue,
    required this.textFalse,
    required this.colorsTrue,
    required this.colorsFalse,
    required this.state,
    required this.onTap,
    this.width = 150,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: state
              ? const [Colors.red, Colors.orange]
              : const [Colors.blue, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Text(
              state ? textTrue : textFalse,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

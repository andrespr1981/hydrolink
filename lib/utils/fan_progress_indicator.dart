import 'package:flutter/material.dart';

class FanProgressIndicator extends StatefulWidget {
  final double progress;

  const FanProgressIndicator({super.key, required this.progress});

  @override
  State<FanProgressIndicator> createState() => _FanProgressIndicatorState();
}

class _FanProgressIndicatorState extends State<FanProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant FanProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newDuration = Duration(
      milliseconds: (2000 * (1.0 - widget.progress)).clamp(200, 2000).toInt(),
    );
    _controller.duration = newDuration;
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset('assets/fan.png', height: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

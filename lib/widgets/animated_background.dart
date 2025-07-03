import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Color lineColor;

  const AnimatedBackground({this.lineColor = Colors.cyanAccent});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LinesPainter(
            animationValue: _controller.value,
            lineColor: widget.lineColor,
            random: _random,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LinesPainter extends CustomPainter {
  final double animationValue;
  final Color lineColor;
  final Random random;

  _LinesPainter({
    required this.animationValue,
    required this.lineColor,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.15)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 20; i++) {
      double x = (size.width / 20) * i + random.nextDouble() * 5;
      double startY = (animationValue * size.height + i * 50) % size.height;
      double endY = startY + 40 + random.nextDouble() * 20;

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';

class MatrixRainBackground extends StatefulWidget {
  final Color color;
  final int columnCount;

  const MatrixRainBackground({
    Key? key,
    this.color = Colors.greenAccent,
    this.columnCount = 20,
  }) : super(key: key);

  @override
  _MatrixRainBackgroundState createState() => _MatrixRainBackgroundState();
}

class _MatrixRainBackgroundState extends State<MatrixRainBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_MatrixColumn> _columns;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _columns = List.generate(widget.columnCount, (_) {
      return _MatrixColumn(
        speed: 50 + _random.nextDouble() * 100,
        offset: _random.nextDouble(),
      );
    });
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
      builder: (context, _) {
        return CustomPaint(
          painter: _MatrixPainter(
            columns: _columns,
            animationValue: _controller.value,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixColumn {
  final double speed;
  final double offset;

  _MatrixColumn({required this.speed, required this.offset});
}

class _MatrixPainter extends CustomPainter {
  final List<_MatrixColumn> columns;
  final double animationValue;
  final Color color;
  final Random _random = Random();
  final List<String> charset = '01234654fnhndfnkfnkldflkmlkdfmlbஅஇஉஎஒககஅஇஉஎஒககிகுகெகொ'.split('');

  _MatrixPainter({
    required this.columns,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final textStyle = TextStyle(
      color: color,
      fontSize: 16,
      fontFamily: 'Courier New',
    );

    final columnWidth = size.width / columns.length;

    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];
      double y = (animationValue + column.offset) * size.height * column.speed % size.height;

      for (int j = 0; j < 20; j++) {
        final textSpan = TextSpan(
          text: charset[_random.nextInt(charset.length)],
          style: textStyle.copyWith(
            color: color.withOpacity(0.05 + _random.nextDouble() * 0.7),
          ),
        );

        final tp = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();

        tp.paint(canvas, Offset(i * columnWidth, (y + j * 20) % size.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

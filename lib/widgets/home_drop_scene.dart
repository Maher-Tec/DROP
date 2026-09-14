import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A quiet lake vignette painted on a transparent canvas.
class HomeDropScene extends StatefulWidget {
  final bool dark;
  final bool animate;

  const HomeDropScene({super.key, required this.dark, required this.animate});

  @override
  State<HomeDropScene> createState() => _HomeDropSceneState();
}

class _HomeDropSceneState extends State<HomeDropScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(HomeDropScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;
    widget.animate ? _controller.repeat() : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _HomeDropPainter(
            dark: widget.dark,
            phase: widget.animate ? _controller.value : 0.25,
          ),
          child: const SizedBox(width: 280, height: 190),
        ),
      ),
    );
  }
}

class _HomeDropPainter extends CustomPainter {
  final bool dark;
  final double phase;

  const _HomeDropPainter({required this.dark, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.69);
    final breath = (math.sin(phase * math.pi * 2) + 1) / 2;
    final accent = dark ? DropTheme.dropAccent : DropTheme.lightDropAccent;
    final highlight = dark ? DropTheme.dropHighlight : Colors.white;
    final poolRect = Rect.fromCenter(center: center, width: 246, height: 92);

    canvas.drawOval(
      poolRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: dark ? 0.12 : 0.16),
            accent.withValues(alpha: 0.035),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ).createShader(poolRect),
    );

    for (var i = 0; i < 3; i++) {
      final expansion = i * 24.0 + breath * 7;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 92 + expansion,
          height: 18 + expansion * 0.2,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.4 : 0.9
          ..color = accent.withValues(alpha: 0.30 - i * 0.07),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, 1),
        width: 33 + breath * 4,
        height: 5,
      ),
      Paint()..color = highlight.withValues(alpha: 0.17),
    );

    final floatY = math.sin(phase * math.pi * 2) * 2.5;
    final top = size.height * 0.25 + floatY;
    final drop = Path()
      ..moveTo(center.dx, top)
      ..cubicTo(
        center.dx - 7,
        top + 11,
        center.dx - 24,
        top + 28,
        center.dx - 24,
        top + 47,
      )
      ..cubicTo(
        center.dx - 24,
        top + 67,
        center.dx - 13,
        top + 79,
        center.dx,
        top + 79,
      )
      ..cubicTo(
        center.dx + 13,
        top + 79,
        center.dx + 24,
        top + 67,
        center.dx + 24,
        top + 47,
      )
      ..cubicTo(
        center.dx + 24,
        top + 28,
        center.dx + 7,
        top + 11,
        center.dx,
        top,
      )
      ..close();
    final dropRect = Rect.fromLTWH(center.dx - 24, top, 48, 79);
    canvas.drawPath(
      drop,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlight, accent, dark ? const Color(0xFF217792) : accent],
          stops: const [0, 0.42, 1],
        ).createShader(dropRect),
    );

    final shade = Path()
      ..moveTo(center.dx, top + 1)
      ..cubicTo(
        center.dx + 10,
        top + 19,
        center.dx + 20,
        top + 35,
        center.dx + 18,
        top + 53,
      )
      ..cubicTo(
        center.dx + 16,
        top + 67,
        center.dx + 8,
        top + 75,
        center.dx,
        top + 79,
      )
      ..close();
    canvas.drawPath(
      shade,
      Paint()..color = const Color(0xFF06435E).withValues(alpha: 0.28),
    );
    canvas.drawOval(
      Rect.fromLTWH(center.dx - 13, top + 20, 12, 7),
      Paint()..color = Colors.white.withValues(alpha: 0.62),
    );
    canvas.drawCircle(
      Offset(center.dx - 8, top + 17),
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.78),
    );
  }

  @override
  bool shouldRepaint(_HomeDropPainter oldDelegate) =>
      oldDelegate.dark != dark || oldDelegate.phase != phase;
}

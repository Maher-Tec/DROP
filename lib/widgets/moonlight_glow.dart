import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class MoonlightGlow extends StatefulWidget {
  final double size;
  final bool animate;

  const MoonlightGlow({super.key, this.size = 200, this.animate = true});

  @override
  State<MoonlightGlow> createState() => _MoonlightGlowState();
}

class _MoonlightGlowState extends State<MoonlightGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!animate) {
      _controller.stop();
    }
    if (!DropTheme.isNightTime() && !DropTheme.isEvening()) {
      return const SizedBox.shrink();
    }

    final isDeepNight = DropTheme.isNightTime();
    final baseOpacity = isDeepNight ? 0.25 : 0.15;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmer = sin(_controller.value * pi * 2) * 0.1;

        return CustomPaint(
          painter: _MoonlightPainter(
            shimmerValue: _controller.value,
            baseOpacity: baseOpacity + shimmer,
          ),
          size: Size(widget.size, widget.size * 0.6),
        );
      },
    );
  }
}

class _MoonlightPainter extends CustomPainter {
  final double shimmerValue;
  final double baseOpacity;

  _MoonlightPainter({required this.shimmerValue, required this.baseOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 0);

    final moonGradient = RadialGradient(
      center: Alignment.topCenter,
      radius: 1.0,
      colors: [
        Colors.white.withValues(alpha: baseOpacity.clamp(0.0, 0.4)),
        Colors.white.withValues(alpha: baseOpacity * 0.5),
        Colors.white.withValues(alpha: baseOpacity * 0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final moonRect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height * 2,
    );

    final moonPaint = Paint()..shader = moonGradient.createShader(moonRect);

    canvas.drawOval(moonRect, moonPaint);

    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: (0.15 + shimmerValue * 0.1).clamp(0.0, 0.3),
      )
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final random = Random(42);

    for (int i = 0; i < 8; i++) {
      final yOffset = size.height * 0.3 + (i * size.height * 0.08);
      final xVariation = (random.nextDouble() - 0.5) * size.width * 0.3;
      final width = size.width * (0.1 + random.nextDouble() * 0.15);

      final animatedX =
          center.dx + xVariation + sin(shimmerValue * pi * 2 + i) * 10;

      final linePaint = Paint()
        ..color = shimmerPaint.color.withValues(
          alpha: (0.1 + (1 - i / 8) * 0.15).clamp(0.0, 0.25),
        )
        ..strokeWidth = 1.0 + (1 - i / 8)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(animatedX - width / 2, yOffset),
        Offset(animatedX + width / 2, yOffset),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MoonlightPainter oldDelegate) =>
      oldDelegate.shimmerValue != shimmerValue;
}

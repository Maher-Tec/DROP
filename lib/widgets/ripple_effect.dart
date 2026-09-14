import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class RippleEffect extends StatefulWidget {
  final double size;
  final bool animate;
  final int circleCount;
  final bool expanding;

  const RippleEffect({
    super.key,
    this.size = 280,
    this.animate = true,
    this.circleCount = 5,
    this.expanding = false,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DropTheme.rippleAnimationDuration,
    );

    if (widget.animate) {
      _controller.repeat();
    }
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
          size: Size(widget.size, widget.size),
          painter: RipplePainter(
            animation: _controller.value,
            circleCount: widget.circleCount,
            expanding: widget.expanding,
          ),
        );
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animation;
  final int circleCount;
  final bool expanding;

  RipplePainter({
    required this.animation,
    required this.circleCount,
    this.expanding = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < circleCount; i++) {
      final phaseOffset = i / circleCount;
      final animPhase = (animation + phaseOffset) % 1.0;

      final radius = expanding
          ? maxRadius *
                (0.3 + animPhase * 0.7)
          : maxRadius * (0.2 + (i + 1) / (circleCount + 1) * 0.6) +
                (math.sin(animation * 2 * math.pi + i) * 4);

      final baseOpacity = expanding
          ? (1.0 - animPhase) * 0.4
          : 0.25 - (i * 0.04);
      final opacity =
          baseOpacity * (0.7 + 0.3 * math.sin(animation * 2 * math.pi + i));

      final strokeWidth = 1.2 - (i * 0.15);

      final paint = Paint()
        ..color = DropTheme.rippleColor.withValues(
          alpha: opacity.clamp(0.03, 0.35),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth.clamp(0.5, 1.5);

      if (i > circleCount ~/ 2) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      }

      canvas.drawCircle(center, radius.clamp(0, maxRadius), paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

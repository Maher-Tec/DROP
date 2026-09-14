import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class SplashDroplets extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashDroplets({super.key, this.onComplete});

  @override
  State<SplashDroplets> createState() => _SplashDropletsState();
}

class _SplashDropletsState extends State<SplashDroplets>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Droplet> _droplets;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _droplets = List.generate(12, (_) => _Droplet.random(_random));

    _controller.forward().then((_) {
      widget.onComplete?.call();
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
      builder: (context, child) {
        return CustomPaint(
          painter: _SplashPainter(
            droplets: _droplets,
            progress: _controller.value,
          ),
          size: const Size(200, 150),
        );
      },
    );
  }
}

class _Droplet {
  final double angle;
  final double speed;
  final double size;
  final double delay;

  _Droplet({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });

  factory _Droplet.random(Random random) {
    final baseAngle = -pi / 2;
    final spread = (random.nextDouble() - 0.5) * pi * 0.8;

    return _Droplet(
      angle: baseAngle + spread,
      speed: 30 + random.nextDouble() * 50,
      size: 1.5 + random.nextDouble() * 2.5,
      delay: random.nextDouble() * 0.15,
    );
  }
}

class _SplashPainter extends CustomPainter {
  final List<_Droplet> droplets;
  final double progress;

  _SplashPainter({required this.droplets, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);

    for (final droplet in droplets) {
      final adjustedProgress =
          ((progress - droplet.delay) / (1 - droplet.delay)).clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      final t = adjustedProgress;
      final gravity = 80.0;

      final x = center.dx + cos(droplet.angle) * droplet.speed * t;
      final y =
          center.dy + sin(droplet.angle) * droplet.speed * t + gravity * t * t;

      final opacity = (1 - t * t).clamp(0.0, 1.0) * 0.8;

      final currentSize = droplet.size * (1 - t * 0.5);

      final paint = Paint()
        ..color = DropTheme.dropAccent.withValues(alpha: opacity);

      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
      canvas.drawCircle(Offset(x, y), currentSize, paint);

      paint.maskFilter = null;
      paint.color = Colors.white.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(Offset(x, y), currentSize * 0.4, paint);
    }

    final ringProgress = (progress * 2).clamp(0.0, 1.0);
    final ringOpacity = (1 - ringProgress).clamp(0.0, 0.6);
    final ringRadius = 10 + ringProgress * 40;

    final ringPaint = Paint()
      ..color = DropTheme.rippleColor.withValues(alpha: ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * (1 - ringProgress);

    canvas.drawCircle(center, ringRadius, ringPaint);
  }

  @override
  bool shouldRepaint(_SplashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

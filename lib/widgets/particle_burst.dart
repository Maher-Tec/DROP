import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class ParticleBurst extends StatefulWidget {
  final VoidCallback? onComplete;

  const ParticleBurst({super.key, this.onComplete});

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particles = List.generate(20, (_) => _Particle.random(_random));

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
          painter: _BurstPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: const Size(250, 250),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  factory _Particle.random(Random random) {
    final angle = random.nextDouble() * 2 * pi;

    final colors = [
      DropTheme.dropAccent,
      DropTheme.glowColor,
      Colors.white,
      DropTheme.rippleColor,
    ];

    return _Particle(
      angle: angle,
      speed: 20 + random.nextDouble() * 80,
      size: 1.0 + random.nextDouble() * 3.0,
      color: colors[random.nextInt(colors.length)],
    );
  }
}

class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _BurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final easedProgress = Curves.easeOutQuart.transform(progress);

    for (final particle in particles) {
      final distance = particle.speed * easedProgress;
      final x = center.dx + cos(particle.angle) * distance;
      final y = center.dy + sin(particle.angle) * distance;

      final opacity = (1 - progress * progress).clamp(0.0, 1.0);

      final currentSize = particle.size * (1 - easedProgress * 0.7);

      if (currentSize <= 0 || opacity <= 0) continue;

      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), currentSize * 2, glowPaint);

      final corePaint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.8);

      canvas.drawCircle(Offset(x, y), currentSize, corePaint);
    }

    if (progress < 0.3) {
      final flashProgress = progress / 0.3;
      final flashOpacity = (1 - flashProgress) * 0.6;
      final flashRadius = 30 * flashProgress;

      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: flashOpacity),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: flashRadius));

      canvas.drawCircle(center, flashRadius, flashPaint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

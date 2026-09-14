import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// FLOATING PARTICLES - Premium ambient effect
///
/// Creates a calm, dreamy atmosphere with slowly floating
/// light particles (like dust in moonlight or underwater specs).
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxSize;
  final double minSize;
  final bool showStars; // Enable starfield at night

  const FloatingParticles({
    super.key,
    this.particleCount = 30,
    this.particleColor = Colors.white,
    this.maxSize = 3.0,
    this.minSize = 1.0,
    this.showStars = false,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Very slow movement
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(_random, widget.minSize, widget.maxSize),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNight = DropTheme.isNightTime();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            particleColor: widget.particleColor,
            showStars: widget.showStars && isNight,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x; // 0.0 - 1.0 normalized position
  double y;
  double size;
  double speed;
  double opacity;
  double drift; // Horizontal drift direction
  bool isStar; // For starfield mode

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
    this.isStar = false,
  });

  factory _Particle.random(Random random, double minSize, double maxSize) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: minSize + random.nextDouble() * (maxSize - minSize),
      speed: 0.02 + random.nextDouble() * 0.05, // Very slow upward drift
      opacity: 0.1 + random.nextDouble() * 0.4,
      drift: (random.nextDouble() - 0.5) * 0.02, // Subtle horizontal movement
      isStar: random.nextDouble() > 0.7, // 30% chance to be a star
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color particleColor;
  final bool showStars;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.particleColor,
    required this.showStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate animated position
      final animatedY = (particle.y - progress * particle.speed) % 1.0;
      final animatedX = (particle.x + progress * particle.drift) % 1.0;

      final x = animatedX * size.width;
      final y = animatedY * size.height;

      // Pulsing opacity for twinkling effect
      final twinkle = (sin(progress * 2 * pi + particle.x * 10) + 1) / 2;
      final opacity = particle.opacity * (0.5 + twinkle * 0.5);

      final paint = Paint()
        ..color = particleColor.withValues(alpha: opacity.clamp(0.0, 1.0));

      if (showStars && particle.isStar) {
        // Draw star shape
        _drawStar(canvas, Offset(x, y), particle.size * 1.5, paint);
      } else {
        // Draw circular particle with soft edge
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
        canvas.drawCircle(Offset(x, y), particle.size, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Simple 4-point star
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 4;
      final outerX = center.dx + cos(angle) * radius;
      final outerY = center.dy + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      // Inner point
      final innerAngle = angle + pi / 4;
      final innerX = center.dx + cos(innerAngle) * radius * 0.3;
      final innerY = center.dy + sin(innerAngle) * radius * 0.3;
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/theme_service.dart';
import 'floating_particles.dart';
import 'moonlight_glow.dart';

class LakeBackground extends StatefulWidget {
  final Widget child;
  final bool animate;
  final bool showWaves;
  final bool showReflections;
  final bool showParticles;
  final bool showMoonlight;

  const LakeBackground({
    super.key,
    required this.child,
    this.animate = true,
    this.showWaves = true,
    this.showReflections = true,
    this.showParticles = true,
    this.showMoonlight = true,
  });

  @override
  State<LakeBackground> createState() => _LakeBackgroundState();
}

class _LakeBackgroundState extends State<LakeBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _shimmerController;
  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    if (widget.animate) {
      _animating = true;
      _waveController.repeat();
      _shimmerController.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(LakeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) _syncAnimation();
  }

  void _syncAnimation() {
    final shouldAnimate =
        widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate == _animating) return;
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _waveController.repeat();
      _shimmerController.repeat();
    } else {
      _waveController.stop();
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.isDarkMode;
    final animate = _animating;
    final isNight = DropTheme.isNightTime() || DropTheme.isEvening();

    final staticLayer = Stack(
      children: [
        if (widget.showParticles && animate)
          Positioned.fill(
            child: FloatingParticles(
              particleCount: isNight ? 40 : 25,
              particleColor: isNight ? Colors.white : DropTheme.softWhite,
              showStars: isNight,
              maxSize: isNight ? 2.5 : 2.0,
            ),
          ),

        if (widget.showMoonlight && isNight)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: MoonlightGlow(size: size.width * 0.8, animate: animate),
            ),
          ),

        widget.child,
      ],
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _shimmerController]),
      child: staticLayer,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? DropTheme.timeAwareGradient
                : DropTheme.getLakeGradient(false),
          ),
          child: Stack(
            children: [
              if (widget.showWaves && animate)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: WavePatternPainter(
                        animation: _waveController.value,
                      ),
                    ),
                  ),
                ),

              if (widget.showReflections && animate)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: WaterReflectionPainter(
                        animation: _shimmerController.value,
                      ),
                    ),
                  ),
                ),

              if (child != null) child,
            ],
          ),
        );
      },
    );
  }
}

class WavePatternPainter extends CustomPainter {
  final double animation;

  WavePatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final yBase = size.height * (0.4 + i * 0.12);
      final phase = animation * 2 * math.pi + (i * 0.8);

      final paint = Paint()
        ..color = DropTheme.waterBlue.withValues(
          alpha: (0.08 - (i * 0.01)).clamp(0.01, 0.1),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final path = Path();
      path.moveTo(0, yBase);

      for (double x = 0; x <= size.width; x += 20) {
        final y =
            yBase +
            math.sin((x / size.width * 4 * math.pi) + phase) * 3 +
            math.sin((x / size.width * 2 * math.pi) + phase * 0.7) * 2;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class WaterReflectionPainter extends CustomPainter {
  final double animation;

  WaterReflectionPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final reflections = [
      _Reflection(0.2, 0.15, 0.3, 0.08, 0.0),
      _Reflection(0.7, 0.25, 0.25, 0.06, 0.3),
      _Reflection(0.5, 0.5, 0.35, 0.05, 0.6),
      _Reflection(0.3, 0.7, 0.2, 0.04, 0.9),
    ];

    for (final ref in reflections) {
      final phase = (animation + ref.phase) % 1.0;
      final yOffset = math.sin(phase * 2 * math.pi) * size.height * 0.015;
      final xOffset = math.cos(phase * 2 * math.pi) * 10;

      paint.color = DropTheme.softWhite.withValues(alpha: ref.opacity);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.width * ref.x + xOffset,
            size.height * ref.y + yOffset,
          ),
          width: size.width * ref.width,
          height: size.height * 0.05,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaterReflectionPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _Reflection {
  final double x;
  final double y;
  final double width;
  final double opacity;
  final double phase;

  _Reflection(this.x, this.y, this.width, this.opacity, this.phase);
}

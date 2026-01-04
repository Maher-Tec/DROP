import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'floating_particles.dart';
import 'moonlight_glow.dart';

/// Premium realistic lake background with animated water surface
/// Features: deep blue gradient, subtle waves, light reflections, shimmer,
/// floating particles, moonlight at night, starfield
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

  @override
  void initState() {
    super.initState();
    
    // Very slow wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    
    // Subtle shimmer/reflection animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    
    if (widget.animate) {
      _waveController.repeat();
      _shimmerController.repeat();
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
    final isNight = DropTheme.isNightTime() || DropTheme.isEvening();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _shimmerController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: DropTheme.timeAwareGradient,
          ),
          child: Stack(
            children: [
              // Subtle wave patterns
              if (widget.showWaves && widget.animate)
                Positioned.fill(
                  child: CustomPaint(
                    painter: WavePatternPainter(
                      animation: _waveController.value,
                    ),
                  ),
                ),
              
              // Light reflections on water
              if (widget.showReflections && widget.animate)
                Positioned.fill(
                  child: CustomPaint(
                    painter: WaterReflectionPainter(
                      animation: _shimmerController.value,
                    ),
                  ),
                ),
              
              // Floating particles (dust specs, enhanced at night)
              if (widget.showParticles && widget.animate)
                Positioned.fill(
                  child: FloatingParticles(
                    particleCount: isNight ? 40 : 25,
                    particleColor: isNight ? Colors.white : DropTheme.softWhite,
                    showStars: isNight,
                    maxSize: isNight ? 2.5 : 2.0,
                  ),
                ),
              
              // Moonlight glow at night
              if (widget.showMoonlight && isNight)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MoonlightGlow(
                      size: size.width * 0.8,
                      animate: widget.animate,
                    ),
                  ),
                ),
              
              // Content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

/// Paints subtle, slow-moving wave patterns
class WavePatternPainter extends CustomPainter {
  final double animation;
  
  WavePatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple very subtle wave lines across the screen
    for (int i = 0; i < 5; i++) {
      final yBase = size.height * (0.4 + i * 0.12);
      final phase = animation * 2 * math.pi + (i * 0.8);
      
      final paint = Paint()
        ..color = DropTheme.waterBlue.withValues(alpha: (0.08 - (i * 0.01)).clamp(0.01, 0.1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      final path = Path();
      path.moveTo(0, yBase);
      
      for (double x = 0; x <= size.width; x += 20) {
        final y = yBase + 
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

/// Paints very subtle light reflections on the water surface
class WaterReflectionPainter extends CustomPainter {
  final double animation;
  
  WaterReflectionPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    
    // Multiple floating light patches (moonlight reflections)
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

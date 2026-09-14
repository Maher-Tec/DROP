import 'package:flutter/material.dart';
import '../config/theme.dart';

/// DROP TRAIL - Motion blur trailing effect behind falling drop
///
/// Creates a sequence of fading, smaller drops that follow the main drop
/// to simulate motion blur and add premium feel to the falling animation.
class DropTrail extends StatelessWidget {
  final double fallProgress; // 0.0 to 1.0
  final double startY;
  final double endY;

  const DropTrail({
    super.key,
    required this.fallProgress,
    required this.startY,
    required this.endY,
  });

  @override
  Widget build(BuildContext context) {
    if (fallProgress < 0.05 || fallProgress > 0.95) {
      return const SizedBox.shrink();
    }

    final currentY = startY + (endY - startY) * fallProgress;

    return CustomPaint(
      size: Size(40, currentY - startY + 60),
      painter: _TrailPainter(
        progress: fallProgress,
        currentY: currentY,
        startY: startY,
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  final double progress;
  final double currentY;
  final double startY;

  _TrailPainter({
    required this.progress,
    required this.currentY,
    required this.startY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Draw trail segments (fading ghosts of the drop)
    const trailCount = 8;
    final trailSpacing = 12.0 * progress.clamp(0.3, 1.0);

    for (int i = trailCount; i >= 1; i--) {
      final opacity = (1.0 - (i / trailCount)) * 0.4 * progress;
      final scale = 1.0 - (i / trailCount) * 0.5;
      final yOffset = size.height - 30 - (i * trailSpacing);

      if (yOffset < 0) continue;

      // Trail drop shape (simplified)
      final paint = Paint()
        ..color = DropTheme.dropAccent.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final dropPath = Path();
      final dropWidth = 12.0 * scale;
      final dropHeight = 18.0 * scale;

      // Teardrop shape
      dropPath.moveTo(centerX, yOffset);
      dropPath.quadraticBezierTo(
        centerX + dropWidth,
        yOffset + dropHeight * 0.6,
        centerX,
        yOffset + dropHeight,
      );
      dropPath.quadraticBezierTo(
        centerX - dropWidth,
        yOffset + dropHeight * 0.6,
        centerX,
        yOffset,
      );

      canvas.drawPath(dropPath, paint);

      // Subtle glow for each trail segment
      final glowPaint = Paint()
        ..color = DropTheme.glowColor.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(
        Offset(centerX, yOffset + dropHeight * 0.5),
        dropWidth * 0.8,
        glowPaint,
      );
    }

    // Motion blur streaks
    final streakPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          DropTheme.dropAccent.withValues(alpha: 0.0),
          DropTheme.dropAccent.withValues(alpha: 0.15 * progress),
          DropTheme.dropAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(centerX - 2, 0, 4, size.height - 30));

    // Central motion streak
    canvas.drawRect(
      Rect.fromLTWH(centerX - 1.5, 10, 3, size.height - 50),
      streakPaint,
    );
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Premium water droplet with realistic gradient and glow
/// Used as the central visual element on splash screen
class WaterDrop extends StatelessWidget {
  final double size;
  final bool showGlow;
  final double glowOpacity;
  final double glowBlur;
  
  const WaterDrop({
    super.key,
    this.size = 50,
    this.showGlow = true,
    this.glowOpacity = 0.6,
    this.glowBlur = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.5,
      height: size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft glow - luminous blue
          if (showGlow)
            Container(
              width: size * 2,
              height: size * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DropTheme.glowColor.withValues(alpha: glowOpacity * 0.25),
                    blurRadius: glowBlur * 1.8,
                    spreadRadius: glowBlur * 0.6,
                  ),
                  BoxShadow(
                    color: DropTheme.dropAccent.withValues(alpha: glowOpacity * 0.15),
                    blurRadius: glowBlur * 2.5,
                    spreadRadius: glowBlur * 1.2,
                  ),
                ],
              ),
            ),
          
          // The droplet itself - premium gradient
          CustomPaint(
            size: Size(size, size * 1.35),
            painter: PremiumDropletPainter(),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for premium water drop shape with realistic shading
class PremiumDropletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height;
    
    // Main drop gradient - deep blue to lighter blue
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DropTheme.dropHighlight,
          DropTheme.dropAccent,
          DropTheme.glowColor,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Create smooth teardrop path
    final path = Path();
    path.moveTo(centerX, bottomY);
    path.quadraticBezierTo(
      -size.width * 0.1,
      size.height * 0.38,
      centerX,
      0,
    );
    path.quadraticBezierTo(
      size.width * 1.1,
      size.height * 0.38,
      centerX,
      bottomY,
    );
    path.close();
    
    canvas.drawPath(path, mainPaint);
    
    // Inner highlight - reflects light
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5))
      ..style = PaintingStyle.fill;
    
    // Small highlight ellipse
    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromCenter(
        center: Offset(centerX - size.width * 0.15, size.height * 0.22),
        width: size.width * 0.25,
        height: size.height * 0.12,
      ),
    );
    canvas.drawPath(highlightPath, highlightPaint);
    
    // Tiny specular highlight
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - size.width * 0.18, size.height * 0.18),
        width: size.width * 0.08,
        height: size.height * 0.04,
      ),
      specularPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

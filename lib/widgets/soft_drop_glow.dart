import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Soft symbolic drop glow for home screen
/// Represents "where the drop will fall" - not button-like
class SoftDropGlow extends StatefulWidget {
  final double size;
  final bool animate;
  
  const SoftDropGlow({
    super.key,
    this.size = 60,
    this.animate = true,
  });

  @override
  State<SoftDropGlow> createState() => _SoftDropGlowState();
}

class _SoftDropGlowState extends State<SoftDropGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.animate) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 3,
          height: widget.size * 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost glow - very diffuse
              Container(
                width: widget.size * 2.5,
                height: widget.size * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DropTheme.glowColor.withValues(
                        alpha: 0.06 * _pulseAnimation.value,
                      ),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
              
              // Middle glow layer
              Container(
                width: widget.size * 1.8,
                height: widget.size * 1.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DropTheme.dropAccent.withValues(
                        alpha: 0.12 * _pulseAnimation.value,
                      ),
                      blurRadius: 50,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
              
              // Inner glow - core brightness
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DropTheme.dropHighlight.withValues(
                        alpha: 0.18 * _pulseAnimation.value,
                      ),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              
              // Symbolic drop - subtle, not a button
              Transform.scale(
                scale: 0.9 + (0.1 * _pulseAnimation.value),
                child: CustomPaint(
                  size: Size(widget.size * 0.4, widget.size * 0.55),
                  painter: _SymbolicDropPainter(
                    opacity: 0.5 + (0.2 * _pulseAnimation.value),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Paints a subtle, symbolic water drop shape
class _SymbolicDropPainter extends CustomPainter {
  final double opacity;
  
  _SymbolicDropPainter({this.opacity = 0.6});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          DropTheme.dropHighlight.withValues(alpha: opacity),
          DropTheme.dropAccent.withValues(alpha: opacity * 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final centerX = size.width / 2;
    
    path.moveTo(centerX, size.height);
    path.quadraticBezierTo(0, size.height * 0.4, centerX, 0);
    path.quadraticBezierTo(size.width, size.height * 0.4, centerX, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SymbolicDropPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

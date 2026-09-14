import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/theme_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../widgets/drop_trail.dart';
import '../widgets/particle_burst.dart';
import '../widgets/splash_droplets.dart';
import 'after_drop_screen.dart';

class DropAnimationScreen extends StatefulWidget {
  final String thought;

  const DropAnimationScreen({super.key, required this.thought});

  @override
  State<DropAnimationScreen> createState() => _DropAnimationScreenState();
}

class _DropAnimationScreenState extends State<DropAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _textFadeController;
  late AnimationController _dropFormController;
  late AnimationController _dropFallController;
  late AnimationController _rippleController;

  late Animation<double> _textFade;
  late Animation<double> _textScale;
  late Animation<double> _dropForm;
  late Animation<double> _dropFall;
  late Animation<double> _dropFade;
  late Animation<double> _rippleExpand;
  late Animation<double> _rippleFade;

  bool _showText = true;
  bool _showDrop = false;
  bool _showRipples = false;
  bool _showSplash = false;
  bool _showBurst = false;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAnimationSequence();
    });
  }

  void _initAnimations() {
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );
    _textScale = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );

    _dropFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dropForm = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropFormController, curve: Curves.easeOutBack),
    );

    _dropFallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _dropFall = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dropFallController,
        curve: DropTheme.dropFallCurve,
      ),
    );
    _dropFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dropFallController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _rippleExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimationSequence() async {
    if (!mounted) return;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    await Future.delayed(Duration(milliseconds: reducedMotion ? 100 : 300));
    if (!mounted) return;
    _textFadeController.forward();

    await Future.delayed(Duration(milliseconds: reducedMotion ? 250 : 900));
    if (!mounted) return;
    setState(() {
      _showText = false;
      _showDrop = true;
    });
    _dropFormController.forward();

    await Future.delayed(Duration(milliseconds: reducedMotion ? 180 : 400));
    if (!mounted) return;
    _dropFallController.forward();

    await Future.delayed(Duration(milliseconds: reducedMotion ? 600 : 1000));
    if (!mounted) return;
    soundService.playWaterDrop();
    HapticService.waterDropImpact();
    setState(() {
      _showRipples = true;
      _showSplash = !reducedMotion;
      _showBurst = !reducedMotion;
      _showFlash = !reducedMotion;
    });
    _rippleController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _showFlash = false);

    await Future.delayed(const Duration(milliseconds: 1600));
    _navigateToAfterDrop();
  }

  void _navigateToAfterDrop() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AfterDropScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    _dropFormController.dispose();
    _dropFallController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = DropTheme.fontScale(context);
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.isDarkMode;

    final impactY = size.height * 0.62;
    final startY = size.height * 0.32;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: DropTheme.getLakeGradient(isDarkMode),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showText && widget.thought.isNotEmpty)
              AnimatedBuilder(
                animation: Listenable.merge([_textFade, _textScale]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: Transform.scale(
                      scale: _textScale.value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.1,
                        ),
                        child: Text(
                          widget.thought,
                          style: DropTheme.getBodyStyle(
                            isDarkMode,
                          ).copyWith(fontSize: 20 * fontScale, height: 1.6),
                          textAlign: TextAlign.center,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),

            if (_showDrop)
              AnimatedBuilder(
                animation: Listenable.merge([_dropForm, _dropFall, _dropFade]),
                builder: (context, child) {
                  final currentY =
                      startY + (_dropFall.value * (impactY - startY));

                  return Stack(
                    children: [
                      if (_dropFall.value > 0.05 && _dropFall.value < 0.95)
                        Positioned(
                          top: startY,
                          left: size.width / 2 - 20,
                          child: Opacity(
                            opacity: _dropFade.value * 0.8,
                            child: DropTrail(
                              fallProgress: _dropFall.value,
                              startY: startY,
                              endY: impactY,
                            ),
                          ),
                        ),
                      Positioned(
                        top: currentY,
                        left: size.width / 2 - 12,
                        child: Opacity(
                          opacity: (_dropFade.value * _dropForm.value).clamp(
                            0.0,
                            1.0,
                          ),
                          child: Transform.scale(
                            scale: _dropForm.value.clamp(0.0, 1.5),
                            child: _buildPremiumDrop(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            if (_showRipples)
              Positioned(
                top: impactY - 10,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rippleExpand, _rippleFade]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _rippleFade.value,
                      child: CustomPaint(
                        size: Size(size.width, 200),
                        painter: _PremiumRipplePainter(
                          progress: _rippleExpand.value,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_showSplash)
              Positioned(
                top: impactY - 80,
                left: size.width / 2 - 100,
                child: const SplashDroplets(),
              ),

            if (_showBurst)
              Positioned(
                top: impactY - 125,
                left: size.width / 2 - 125,
                child: const ParticleBurst(),
              ),

            if (_showFlash)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _showFlash ? 0.4 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumDrop() {
    return Container(
      width: 24,
      height: 34,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: DropTheme.glowColor.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(painter: _FallingDropPainter()),
    );
  }
}

class _FallingDropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          DropTheme.dropHighlight,
          DropTheme.dropAccent,
          DropTheme.glowColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;

    path.moveTo(centerX, size.height);
    path.quadraticBezierTo(-size.width * 0.1, size.height * 0.4, centerX, 0);
    path.quadraticBezierTo(
      size.width * 1.1,
      size.height * 0.4,
      centerX,
      size.height,
    );
    path.close();

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - size.width * 0.15, size.height * 0.22),
        width: size.width * 0.2,
        height: size.height * 0.08,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PremiumRipplePainter extends CustomPainter {
  final double progress;

  _PremiumRipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 10);

    for (int i = 0; i < 5; i++) {
      final delay = i * 0.12;
      final adjustedProgress = ((progress - delay) / (1 - delay)).clamp(
        0.0,
        1.0,
      );

      if (adjustedProgress <= 0) continue;

      final maxRadius = size.width * 0.42 * (1 + i * 0.25);
      final radius = maxRadius * adjustedProgress;
      final opacity = (1.0 - adjustedProgress) * (0.45 - i * 0.07);

      final paint = Paint()
        ..color = DropTheme.rippleColor.withValues(
          alpha: opacity.clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.8 - (i * 0.2)).clamp(0.5, 2.0);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 0.35,
        ),
        paint,
      );
    }

    if (progress < 0.3) {
      final splashOpacity = (1 - progress / 0.3) * 0.6;
      final splashPaint = Paint()
        ..color = DropTheme.dropHighlight.withValues(alpha: splashOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 30 + progress * 40,
          height: 10 + progress * 10,
        ),
        splashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PremiumRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

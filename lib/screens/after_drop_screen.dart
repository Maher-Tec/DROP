import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/ai_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../widgets/lake_background.dart';
import 'home_screen.dart';

/// AFTER DROP SCREEN - Premium Pro Max
/// 
/// Purpose: Closure without words + personalized affirmation.
/// 
/// UI:
/// - Calm lake with fading ripples
/// - "It's gone." followed by AI-generated affirmation
/// - Gentle haptic feedback
/// - Auto-fade back to Home
class AfterDropScreen extends StatefulWidget {
  const AfterDropScreen({super.key});

  @override
  State<AfterDropScreen> createState() => _AfterDropScreenState();
}

class _AfterDropScreenState extends State<AfterDropScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _textFade;
  late Animation<double> _affirmationFade;
  late Animation<double> _rippleFade;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  String _affirmation = '';
  bool _showAffirmation = false;

  @override
  void initState() {
    super.initState();
    
    // Trigger gentle closure haptic
    HapticService.closurePulse();
    
    // Load AI affirmation
    _loadAffirmation();
    
    // Adjust duration for time of day (slower at night) - longer to read affirmation
    final baseDuration = const Duration(milliseconds: 7000); // Much longer to read
    final adjustedDuration = DropTheme.adjustedDuration(baseDuration);
    
    // Main fade sequence
    _fadeController = AnimationController(
      vsync: this,
      duration: adjustedDuration,
    );
    
    // "It's gone." text: fade in → hold → fade out
    _textFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50, // Hold longer
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_fadeController);
    
    // Affirmation: delayed fade in
    _affirmationFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 45, // Hold affirmation longer
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_fadeController);
    
    // Ripples slowly fade out
    _rippleFade = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    // Gentle glow pulse (slower at night)
    _glowController = AnimationController(
      vsync: this,
      duration: DropTheme.adjustedDuration(const Duration(seconds: 5)),
    );
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    _glowController.repeat(reverse: true);
    
    // Show affirmation after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showAffirmation = true);
    });
    
    // Auto-transition back to home - give plenty of time
    final transitionDelay = DropTheme.adjustedDuration(const Duration(seconds: 8));
    Future.delayed(transitionDelay, _navigateToHome);
  }

  Future<void> _loadAffirmation() async {
    // Try AI first, falls back to preset
    final affirmation = await AIService.generateAffirmation();
    if (mounted) {
      setState(() => _affirmation = affirmation);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    
    // Resume relax ambient sound
    soundService.playRelax();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: DropTheme.adjustedDuration(
          const Duration(milliseconds: 800),
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = DropTheme.fontScale(context);
    
    return Scaffold(
      body: GestureDetector(
        onTap: _navigateToHome,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            gradient: DropTheme.timeAwareGradient,
          ),
          child: LakeBackground(
            animate: false, // Still, calm water
            showWaves: false,
            showReflections: true,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeController, _glowAnimation]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fading ripple remnants
                      CustomPaint(
                        size: Size(size.width * 0.9, 100),
                        painter: _FadingRipplesPainter(
                          opacity: _rippleFade.value,
                        ),
                      ),
                      
                      // Soft center glow
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: DropTheme.glowColor.withValues(
                                alpha: _glowAnimation.value * _textFade.value * 0.25,
                              ),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      
                      // Text content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // \"It's gone.\" text
                          Opacity(
                            opacity: _textFade.value,
                            child: Text(
                              "It's gone.",
                              style: DropTheme.closureStyle.copyWith(
                                fontSize: 24 * fontScale,
                              ),
                            ),
                          ),
                          
                          // Tap to continue hint
                          if (_showAffirmation)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Opacity(
                                opacity: _affirmationFade.value * 0.4,
                                child: Text(
                                  'tap to continue',
                                  style: DropTheme.hintStyle.copyWith(
                                    fontSize: 11 * fontScale,
                                    color: DropTheme.softWhite.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints subtle fading ripples from the drop impact
class _FadingRipplesPainter extends CustomPainter {
  final double opacity;
  
  _FadingRipplesPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 4; i++) {
      final radius = 50.0 + (i * 35);
      final ringOpacity = opacity * (0.35 - i * 0.07);
      
      if (ringOpacity <= 0) continue;
      
      final paint = Paint()
        ..color = DropTheme.rippleColor.withValues(
          alpha: ringOpacity.clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 0.35,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FadingRipplesPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

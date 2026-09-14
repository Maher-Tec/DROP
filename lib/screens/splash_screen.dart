import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../widgets/ripple_effect.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// SPLASH SCREEN - Premium Pro Max
///
/// Purpose: Set the emotional tone immediately.
/// User should feel: "This app is quiet, safe, and intentional."
///
/// UI:
/// - Deep blue → teal gradient background
/// - One slow water ripple expanding from center
/// - App name: DROP
/// - Subtitle: "Let it go."
/// - Auto-transition after 2.5 seconds
/// - Starts playing relax ambient sound
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _rippleExpandController;
  late Animation<double> _rippleExpandAnimation;
  late AnimationController _dropPulseController;
  late Animation<double> _dropPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Start playing relaxing ambient sound
    soundService.playRelax();

    // Immersive full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Ripple expand animation
    _rippleExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _rippleExpandAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _rippleExpandController, curve: Curves.easeOut),
    );

    // Drop pulse animation
    _dropPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _dropPulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _dropPulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _rippleExpandController.forward();
    _dropPulseController.repeat(reverse: true);

    // Check onboarding and auto-transition
    _checkOnboardingAndNavigate();
  }

  void _checkOnboardingAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(DropTheme.splashDuration);

    if (!mounted) return;

    // Check if onboarding is completed
    final onboardingCompleted = await OnboardingScreen.isCompleted();

    if (onboardingCompleted) {
      _navigateToHome();
    } else {
      _navigateToOnboarding();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: DropTheme.fadeTransitionDuration,
      ),
    );
  }

  void _navigateToOnboarding() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: DropTheme.fadeTransitionDuration,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rippleExpandController.dispose();
    _dropPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = DropTheme.isSmallDevice(context);
    // Responsive sizing
    final rippleSize = size.width * 0.85;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: DropTheme.backgroundGradient),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rippleExpandAnimation,
              _dropPulseAnimation,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Expanding ripple circles
                  Transform.scale(
                    scale: MediaQuery.disableAnimationsOf(context)
                        ? 1
                        : _rippleExpandAnimation.value,
                    child: RippleEffect(
                      size: rippleSize,
                      animate: true,
                      circleCount: 5,
                      expanding: true,
                    ),
                  ),

                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Premium Logo ("The Pure Drop") with circular mask
                      Transform.scale(
                        scale: MediaQuery.disableAnimationsOf(context)
                            ? 1
                            : _dropPulseAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withValues(alpha: 0.15),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: isSmall
                                  ? size.width * 0.7
                                  : size.width * 0.6,
                              fit: BoxFit.contain,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../widgets/ripple_effect.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

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

    soundService.playRelax();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _rippleExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _rippleExpandAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _rippleExpandController, curve: Curves.easeOut),
    );

    _dropPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _dropPulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _dropPulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _rippleExpandController.forward();
    _dropPulseController.repeat(reverse: true);

    _checkOnboardingAndNavigate();
  }

  void _checkOnboardingAndNavigate() async {
    await Future.delayed(DropTheme.splashDuration);

    if (!mounted) return;

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

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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

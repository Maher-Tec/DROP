import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../services/haptic_service.dart';
import '../widgets/water_drop.dart';
import '../widgets/ripple_effect.dart';
import 'home_screen.dart';

/// ONBOARDING SCREEN - First-time user experience
///
/// Beautiful 3-screen intro:
/// 1. Welcome - "DROP"
/// 2. Philosophy - "No judgment. No history. Just release."
/// 3. Demo - Sample drop animation
///
/// Only shows on first launch.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  /// Check if onboarding has been completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0; // For parallax effect

  // Demo animation controllers
  late AnimationController _demoDropController;
  late Animation<double> _demoDropFall;
  late Animation<double> _demoDropFade;
  late AnimationController _demoRippleController;
  bool _showDemoRipple = false;

  @override
  void initState() {
    super.initState();

    // Demo drop animation
    _demoDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _demoDropFall = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _demoDropController, curve: Curves.easeInQuad),
    );
    _demoDropFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _demoDropController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _demoRippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Listen to page scroll for parallax
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_pageController.page != null) {
      setState(() => _pageOffset = _pageController.page!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _demoDropController.dispose();
    _demoRippleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);

    // Haptic feedback on page change
    HapticService.softTap();

    // Start demo animation on last page
    if (page == 2) {
      Future.delayed(const Duration(milliseconds: 500), _startDemoAnimation);
    }
  }

  void _startDemoAnimation() async {
    // Guard against calling after dispose
    if (!mounted || _currentPage != 2) return;

    _demoDropController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _currentPage != 2) return;

    setState(() => _showDemoRipple = true);
    _demoRippleController.forward();

    // Reset and loop
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted || _currentPage != 2) return;

    _demoDropController.reset();
    _demoRippleController.reset();
    setState(() => _showDemoRipple = false);
    Future.delayed(const Duration(milliseconds: 500), _startDemoAnimation);
  }

  void _completeOnboarding() async {
    await OnboardingScreen.markCompleted();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const HomeScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = DropTheme.fontScale(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: DropTheme.timeAwareGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button (top right)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _completeOnboarding,
                    child: Text(
                      'skip',
                      style: DropTheme.hintStyle.copyWith(
                        fontSize: 14 * fontScale,
                        color: DropTheme.softWhite.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildWelcomePage(size, fontScale),
                    _buildPhilosophyPage(size, fontScale),
                    _buildDemoPage(size, fontScale),
                  ],
                ),
              ),

              // Page indicator and continue button
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: size.height * 0.05,
                ),
                child: Column(
                  children: [
                    // Page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? DropTheme.dropAccent
                                : DropTheme.softWhite.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DropTheme.dropAccent.withValues(alpha: 0.25),
                              DropTheme.glowColor.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: DropTheme.dropAccent.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _currentPage == 2 ? 'Begin' : 'Continue',
                          textAlign: TextAlign.center,
                          style: DropTheme.buttonStyle.copyWith(
                            fontSize: 16 * fontScale,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(Size size, double fontScale) {
    // Parallax offset for this page (page 0)
    final parallaxOffset = MediaQuery.disableAnimationsOf(context)
        ? 0.0
        : (_pageOffset - 0) * size.width * 0.15;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Water drop - moves slower (background layer)
        Transform.translate(
          offset: Offset(parallaxOffset * 0.3, 0),
          child: WaterDrop(
            size: 60,
            showGlow: true,
            glowOpacity: 0.5,
            glowBlur: 40,
          ),
        ),

        SizedBox(height: DropTheme.spacing(context, 40)),

        // Title - moves medium speed
        Transform.translate(
          offset: Offset(parallaxOffset * 0.5, 0),
          child: Text(
            'DROP',
            style: DropTheme.titleStyle.copyWith(fontSize: 48 * fontScale),
          ),
        ),

        SizedBox(height: DropTheme.spacing(context, 16)),

        // Tagline - moves faster (foreground layer)
        Transform.translate(
          offset: Offset(parallaxOffset * 0.7, 0),
          child: Text(
            'Let it go.',
            style: DropTheme.taglineStyle.copyWith(fontSize: 18 * fontScale),
          ),
        ),
      ],
    );
  }

  Widget _buildPhilosophyPage(Size size, double fontScale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Philosophy statements
          _buildPhilosophyLine('No judgments.', fontScale),
          SizedBox(height: DropTheme.spacing(context, 24)),
          _buildPhilosophyLine('No history.', fontScale),
          SizedBox(height: DropTheme.spacing(context, 24)),
          _buildPhilosophyLine('Just release.', fontScale),

          SizedBox(height: DropTheme.spacing(context, 60)),

          // Explanation
          Text(
            'One thought at a time.\nWrite it. Drop it. Let it go.',
            textAlign: TextAlign.center,
            style: DropTheme.hintStyle.copyWith(
              fontSize: 14 * fontScale,
              height: 1.6,
              color: DropTheme.softWhite.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyLine(String text, double fontScale) {
    return Text(
      text,
      style: DropTheme.closureStyle.copyWith(
        fontSize: 26 * fontScale,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDemoPage(Size size, double fontScale) {
    final impactY = size.height * 0.45;
    final startY = size.height * 0.15;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Demo drop animation
        AnimatedBuilder(
          animation: _demoDropController,
          builder: (context, child) {
            final currentY =
                startY + (_demoDropFall.value * (impactY - startY));

            return Positioned(
              top: MediaQuery.disableAnimationsOf(context) ? startY : currentY,
              child: Opacity(
                opacity: MediaQuery.disableAnimationsOf(context)
                    ? 1
                    : _demoDropFade.value.clamp(0.0, 1.0),
                child: WaterDrop(
                  size: 30,
                  showGlow: true,
                  glowOpacity: 0.4,
                  glowBlur: 20,
                ),
              ),
            );
          },
        ),

        // Ripple effect on impact
        if (_showDemoRipple && !MediaQuery.disableAnimationsOf(context))
          Positioned(
            // RippleEffect paints circles. Flattening the whole canvas gives
            // the lake a side-view perspective and keeps the impact point on
            // the droplet's vertical axis.
            top: impactY - 28,
            child: AnimatedBuilder(
              animation: _demoRippleController,
              builder: (context, child) {
                return Opacity(
                  opacity: (1 - _demoRippleController.value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scaleX: 0.5 + _demoRippleController.value * 0.5,
                    scaleY: 0.22,
                    child: const RippleEffect(
                      size: 200,
                      animate: false,
                      circleCount: 3,
                    ),
                  ),
                );
              },
            ),
          ),

        // Instructions
        Positioned(
          bottom: size.height * 0.15,
          child: Column(
            children: [
              Text(
                'Watch it disappear.',
                style: DropTheme.bodyStyle.copyWith(fontSize: 20 * fontScale),
              ),
              SizedBox(height: DropTheme.spacing(context, 16)),
              Text(
                'Your thoughts deserve release.',
                style: DropTheme.hintStyle.copyWith(
                  fontSize: 14 * fontScale,
                  color: DropTheme.softWhite.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

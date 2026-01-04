
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../services/drop_service.dart';
import '../services/motivation_service.dart';
import '../services/sound_service.dart';
import '../widgets/breathing_guide.dart';
import '../widgets/lake_background.dart';
import '../widgets/soft_drop_glow.dart';
import '../widgets/bubble_popper.dart';
import 'settings_screen.dart';
import 'write_screen.dart';

/// HOME SCREEN (LAKE) - Premium Pro Max
/// 
/// Purpose: Create safety + calm
/// 
/// States:
/// 1. Ready to drop: "Drop one thought." with tap to start
/// 2. Already dropped: Affirmation, streak, motivation quote
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeInAnimation;
  
  bool _hasDroppedToday = false;
  bool _initialized = false;
  bool _showBreathingGuide = false;
  
  // Completed state
  int _currentStreak = 0;
  String _motivationQuote = '';

  @override
  void initState() {
    super.initState();
    
    // Restore system UI for home screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    // Fade in animation
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    );
    
    // Floating animation for completed state icon
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatController.repeat(reverse: true);
    
    // Play ambient sound
    soundService.playRelax();
    
    _loadState();
  }

  Future<void> _loadState() async {
    await dropService.init();
    if (mounted) {
      setState(() {
        _hasDroppedToday = dropService.hasDroppedToday;
        _currentStreak = dropService.currentStreak;
        _motivationQuote = MotivationService.getRandomQuote();
        _initialized = true;
      });
      _fadeInController.forward();
    }
  }

  void _onTapScreen() {
    if (_hasDroppedToday) return;
    
    // Start breathing guide
    setState(() => _showBreathingGuide = true);
  }

  void _onBreathingComplete() {
    setState(() => _showBreathingGuide = false);
    _navigateToWrite();
  }

  void _onBreathingSkip() {
    setState(() => _showBreathingGuide = false);
    _navigateToWrite();
  }

  void _navigateToWrite() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WriteScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      // Refresh state when returning
      _loadState();
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      // Refresh state when returning from settings
      _loadState();
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = DropTheme.fontScale(context);
    final isSmall = DropTheme.isSmallDevice(context);
    
    // Responsive sizing
    final dropGlowSize = isSmall ? 45.0 : 55.0;
    final bodyFontSize = 22.0 * fontScale;
    final hintFontSize = 12.0 * fontScale;
    
    if (!_initialized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: DropTheme.timeAwareGradient,
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Main home screen content
          GestureDetector(
            onTap: _hasDroppedToday ? null : _onTapScreen,
            behavior: HitTestBehavior.opaque,
            child: LakeBackground(
              animate: true, // Keep lake animated for calm feel
              showWaves: true,
              showReflections: true,
              child: Stack(
                children: [
                  // ASMR Bubbles when completed
                  if (_hasDroppedToday)
                    const BubblePopper(count: 10),
                  
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: _hasDroppedToday
                            ? _buildCompletedState(size, fontScale, bodyFontSize, hintFontSize, dropGlowSize)
                            : _buildReadyState(size, fontScale, bodyFontSize, hintFontSize, dropGlowSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Breathing guide overlay
          if (_showBreathingGuide)
            BreathingGuide(
              onComplete: _onBreathingComplete,
              onSkip: _onBreathingSkip,
            ),
          
          // Settings gear icon (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: _openSettings,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DropTheme.deepBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: DropTheme.softWhite.withValues(alpha: 0.4),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ready to drop state - with time greeting
  Widget _buildReadyState(Size size, double fontScale, double bodyFontSize, double hintFontSize, double dropGlowSize) {
    final greeting = MotivationService.getTimeGreeting();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Time greeting at top
        SizedBox(height: size.height * 0.08),
        Text(
          greeting,
          style: DropTheme.hintStyle.copyWith(
            fontSize: 14 * fontScale,
            color: DropTheme.softWhite.withValues(alpha: 0.5),
          ),
        ),
        
        // Calm space
        SizedBox(height: size.height * 0.12),
        
        // Symbolic drop glow
        SoftDropGlow(
          size: dropGlowSize,
          animate: true,
        ),
        
        SizedBox(height: DropTheme.spacing(context, 55)),
        
        // Main text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Text(
            'Drop one thought.',
            style: DropTheme.bodyStyle.copyWith(fontSize: bodyFontSize),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Spacer pushes hint to bottom
        const Spacer(),
        
        // "One per day." hint
        Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.08),
          child: Text(
            'One per day.',
            style: DropTheme.hintStyle.copyWith(fontSize: hintFontSize),
          ),
        ),
      ],
    );
  }

  /// Completed state - affirming and calming
  Widget _buildCompletedState(Size size, double fontScale, double bodyFontSize, double hintFontSize, double dropGlowSize) {
    final streakMessage = MotivationService.getStreakMessage(_currentStreak);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Empty calm space at top
        SizedBox(height: size.height * 0.15),
        
        // Completed checkmark with glow - floating animation
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft glow behind
                  SoftDropGlow(
                    size: dropGlowSize * 1.2,
                    animate: true,
                  ),
                  // Checkmark icon inside
                  Container(
                    width: dropGlowSize * 0.8,
                    height: dropGlowSize * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DropTheme.dropAccent.withValues(alpha: 0.15),
                      border: Border.all(
                        color: DropTheme.dropAccent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: DropTheme.dropAccent.withValues(alpha: 0.8),
                      size: dropGlowSize * 0.45,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        SizedBox(height: DropTheme.spacing(context, 40)),
        
        // Main affirmation text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Text(
            'You released today.',
            style: DropTheme.bodyStyle.copyWith(
              fontSize: bodyFontSize,
              color: DropTheme.softWhite,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: DropTheme.spacing(context, 12)),
        
        // V1 CUT: Streak counter hidden for emotional safety
        // Streaks create pressure - keeping calculation internal only
        // if (streakMessage.isNotEmpty)
        //   Text(
        //     streakMessage,
        //     style: DropTheme.hintStyle.copyWith(
        //       fontSize: 14 * fontScale,
        //       color: DropTheme.dropAccent.withValues(alpha: 0.7),
        //     ),
        //   ),
        
        SizedBox(height: DropTheme.spacing(context, 50)),
        
        // V1 CUT: Motivation quote hidden - silence is more powerful
        // Less talking = more safety
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
        //   child: Text(
        //     '"$_motivationQuote"',
        //     style: DropTheme.hintStyle.copyWith(
        //       fontSize: 15 * fontScale,
        //       fontStyle: FontStyle.italic,
        //       color: DropTheme.softWhite.withValues(alpha: 0.55),
        //       height: 1.5,
        //     ),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        
        // Spacer pushes bottom content
        const Spacer(),
        
        // Soft ripple circles at bottom (completed indicator)
        Opacity(
          opacity: 0.3,
          child: CustomPaint(
            size: Size(size.width * 0.7, 60),
            painter: _CompletedRipplesPainter(),
          ),
        ),
        
        SizedBox(height: DropTheme.spacing(context, 20)),
        
        // \"Come back tomorrow\" hint (Styled like screenshot)
        Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.08),
          child: Text(
            'Come back tomorrow.',
            style: DropTheme.hintStyle.copyWith(
              fontSize: 11 * fontScale,
              color: DropTheme.softWhite.withValues(alpha: 0.15),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints subtle completed ripples
class _CompletedRipplesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 3; i++) {
      final radius = 40.0 + (i * 30);
      final opacity = 0.3 - (i * 0.08);
      
      final paint = Paint()
        ..color = DropTheme.rippleColor.withValues(alpha: opacity.clamp(0.05, 0.3))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 0.3,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/haptic_service.dart';

/// BREATHING GUIDE - Pre-Write Calming Exercise
/// 
/// A simple 3-breath exercise to calm the user before writing.
/// 
/// Features:
/// - Expanding/contracting circle animation
/// - "Breathe in..." / "Breathe out..." text
/// - 3 breath cycles
/// - Optional skip button
class BreathingGuide extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  
  const BreathingGuide({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends State<BreathingGuide>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  int _currentBreath = 1;
  bool _isBreathingIn = true;
  static const int _totalBreaths = 3;

  @override
  void initState() {
    super.initState();
    
    // Single breath cycle: 4 seconds in, 4 seconds out
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    // Start breathing
    _startBreathing();
  }

  void _startBreathing() async {
    for (int i = 0; i < _totalBreaths; i++) {
      if (!mounted) return;
      
      // Breathe in
      setState(() {
        _currentBreath = i + 1;
        _isBreathingIn = true;
      });
      HapticService.gentleTap();
      await _breathController.forward();
      
      if (!mounted) return;
      
      // Breathe out
      setState(() => _isBreathingIn = false);
      HapticService.gentleTap();
      await _breathController.reverse();
    }
    
    // Complete
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = DropTheme.fontScale(context);
    final circleBaseSize = size.width * 0.4;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: DropTheme.timeAwareGradient,
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Skip button (top right)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: widget.onSkip ?? widget.onComplete,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'skip',
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 14 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Breath counter
                Text(
                  'Breath $_currentBreath of $_totalBreaths',
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 12 * fontScale,
                    color: DropTheme.softWhite.withValues(alpha: 0.4),
                  ),
                ),
                
                SizedBox(height: size.height * 0.08),
                
                // Breathing circle
                AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Container(
                      width: circleBaseSize * _breathAnimation.value,
                      height: circleBaseSize * _breathAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            DropTheme.dropAccent.withValues(
                              alpha: 0.3 * _breathAnimation.value,
                            ),
                            DropTheme.glowColor.withValues(
                              alpha: 0.15 * _breathAnimation.value,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        border: Border.all(
                          color: DropTheme.dropAccent.withValues(
                            alpha: 0.4 * _breathAnimation.value,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DropTheme.glowColor.withValues(
                              alpha: 0.2 * _breathAnimation.value,
                            ),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                SizedBox(height: size.height * 0.08),
                
                // Instruction text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isBreathingIn ? 'Breathe in...' : 'Breathe out...',
                    key: ValueKey(_isBreathingIn),
                    style: DropTheme.bodyStyle.copyWith(
                      fontSize: 22 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

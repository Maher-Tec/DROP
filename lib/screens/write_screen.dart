// V1 CUT: dart:math removed - no more random placeholders
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../widgets/lake_background.dart';
import 'drop_animation_screen.dart';

/// WRITE SCREEN - Premium Pro Max (Enhanced)
/// 
/// Purpose: Create a warm, safe space for expression
/// 
/// Enhancements:
/// - Rotating encouraging placeholders
/// - Soft glowing input area
/// - Encouraging micro-copy that adapts
/// - Warmer, more inviting colors
/// - Gentle breathing animation on input container
class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  // V1 CUT: Single placeholder only - silence is safety
  // Rotating placeholders felt like someone watching
  // static const List<String> _placeholders = [...]
  static const String _singlePlaceholder = 'Just one thought...';
  
  // V1 CUT: Encouragements hidden - less talking = more safety
  // static const List<String> _encouragements = [...]
  
  // V1: Removed rotating placeholder
  // late String _currentPlaceholder;
  // String _encouragement = '';
  // bool _showEncouragement = false;

  @override
  void initState() {
    super.initState();
    
    // V1 CUT: Removed random placeholder selection
    // _currentPlaceholder = _placeholders[Random().nextInt(_placeholders.length)];
    
    _textController.addListener(_onTextChanged);
    
    // Play low-volume relax ambient sound while writing
    soundService.playRelaxLow();
    
    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    
    // Gentle glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
    
    // Auto-focus after transition
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    
    // V1 CUT: Encouragement while typing disabled - silence is safety
    // if (textLength > 20 && !_showEncouragement) {
    //   setState(() {
    //     _showEncouragement = true;
    //     _encouragement = _encouragements[Random().nextInt(_encouragements.length)];
    //   });
    //   Future.delayed(const Duration(seconds: 4), () {
    //     if (mounted) setState(() => _showEncouragement = false);
    //   });
    // }
  }

  void _close() {
    // Resume normal relax sound when going back
    soundService.playRelax();
    Navigator.of(context).pop();
  }

  void _dropThought() {
    if (!_hasText) return;
    
    final thought = _textController.text.trim();
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DropAnimationScreen(thought: thought),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final fontScale = DropTheme.fontScale(context);
    final isSmall = DropTheme.isSmallDevice(context);
    
    // Responsive sizing
    final inputFontSize = (isSmall ? 20.0 : 24.0) * fontScale;
    final buttonFontSize = 16.0 * fontScale;
    final horizontalPadding = size.width * (isSmall ? 0.06 : 0.08);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LakeBackground(
        animate: true, // Keep particles active
        showWaves: false,
        showReflections: true,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: Column(
                    children: [
                      // Soft top bar with encouraging header
                      _buildTopBar(context, fontScale),
                      
                      // V1 CUT: Too much talking - header removed
                      // _buildHeader(fontScale),
                      
                      // Breathing space
                      SizedBox(height: size.height * 0.04),
                      
                      // Premium glowing text input
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: _buildPremiumInput(inputFontSize),
                        ),
                      ),
                      
                      // V1 CUT: Encouragement message hidden - silence is safety
                      // _buildEncouragement(fontScale),
                      
                      // Drop button
                      _buildDropButton(context, buttonFontSize),
                      
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gentler back button
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: DropTheme.softWhite.withValues(alpha: 0.35),
                    size: 26,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'back',
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 13 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.3),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Privacy indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: DropTheme.dropAccent.withValues(alpha: 0.4),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'private',
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 11 * fontScale,
                    color: DropTheme.dropAccent.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'This is your safe space',
            style: DropTheme.bodyStyle.copyWith(
              fontSize: 16 * fontScale,
              color: DropTheme.softWhite.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing is saved. Nothing is judged.',
            style: DropTheme.hintStyle.copyWith(
              fontSize: 12 * fontScale,
              color: DropTheme.softWhite.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumInput(double fontSize) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: DropTheme.dropAccent.withValues(alpha: _glowAnimation.value * 0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DropTheme.deepBlue.withValues(alpha: 0.2),
                DropTheme.deepBlue.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: DropTheme.dropAccent.withValues(alpha: _glowAnimation.value * 0.15),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: null,
              textAlign: TextAlign.center,
              style: DropTheme.inputStyle.copyWith(
                fontSize: fontSize,
                height: 1.6,
                color: DropTheme.softWhite.withValues(alpha: 0.95),
              ),
              decoration: InputDecoration(
                // No borders - text floats
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                
                // V1: Single placeholder only
                hintText: _singlePlaceholder,
                hintStyle: DropTheme.placeholderStyle.copyWith(
                  fontSize: fontSize,
                  color: DropTheme.softWhite.withValues(alpha: 0.3),
                  fontStyle: FontStyle.italic,
                ),
                
                // No counter
                counterText: '',
              ),
              cursorColor: DropTheme.dropAccent.withValues(alpha: 0.8),
              cursorWidth: 2.0,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
        );
      },
    );
  }

  // V1 CUT: Encouragement method disabled - silence is safety
  // Widget _buildEncouragement(double fontScale) {
  //   return AnimatedOpacity(
  //     opacity: _showEncouragement ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 500),
  //     child: Padding(
  //       padding: const EdgeInsets.only(bottom: 16),
  //       child: Text(
  //         _encouragement,
  //         style: DropTheme.hintStyle.copyWith(
  //           fontSize: 13 * fontScale,
  //           color: DropTheme.dropAccent.withValues(alpha: 0.5),
  //           fontStyle: FontStyle.italic,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDropButton(BuildContext context, double fontSize) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedOpacity(
      opacity: _hasText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: _hasText ? Offset.zero : const Offset(0, 0.5),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: _hasText ? _dropThought : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.12,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DropTheme.dropAccent.withValues(alpha: 0.25),
                  DropTheme.glowColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: DropTheme.dropAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: DropTheme.dropAccent.withValues(alpha: 0.2),
                  blurRadius: 25,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  color: DropTheme.softWhite.withValues(alpha: 0.8),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Let it go',
                  style: DropTheme.buttonStyle.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

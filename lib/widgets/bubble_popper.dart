import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';

/// BUBBLE POPPER - ASMR Interaction
/// 
/// Users can tap floating bubbles to pop them with haptic and visual feedback.
class BubblePopper extends StatefulWidget {
  final int count;
  const BubblePopper({super.key, this.count = 8});

  @override
  State<BubblePopper> createState() => _BubblePopperState();
}

class _BubblePopperState extends State<BubblePopper> with TickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initBubbles();
  }

  void _initBubbles() {
    for (int i = 0; i < widget.count; i++) {
      _bubbles.add(_createBubble());
    }
  }

  _Bubble _createBubble() {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + _random.nextInt(3000)),
    );
    
    final bubble = _Bubble(
      position: Offset(
        _random.nextDouble() * 0.8 + 0.1, // 10% to 90% width
        _random.nextDouble() * 0.5 + 0.3, // 30% to 80% height
      ),
      size: 20.0 + _random.nextDouble() * 30.0,
      color: Colors.white.withValues(alpha: 0.15 + _random.nextDouble() * 0.1),
      controller: controller,
    );

    controller.repeat(reverse: true);
    return bubble;
  }

  void _popBubble(int index) {
    if (_bubbles[index].popped) return;

    setState(() {
      _bubbles[index].popped = true;
    });

    // ASMR Haptic & Sound
    HapticService.softTap();
    soundService.playPop();

    // Remove and replace after a delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _bubbles[index].controller.dispose();
          _bubbles[index] = _createBubble();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final b in _bubbles) {
      b.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _bubbles.asMap().entries.map((entry) {
            final i = entry.key;
            final bubble = entry.value;

            return Positioned(
              left: bubble.position.dx * constraints.maxWidth,
              top: bubble.position.dy * constraints.maxHeight,
              child: AnimatedBuilder(
                animation: bubble.controller,
                builder: (context, child) {
                  final vOff = sin(bubble.controller.value * 2 * pi) * 12;
                  final hOff = cos(bubble.controller.value * 1.5 * pi) * 6;
                  
                  return GestureDetector(
                    onTap: () => _popBubble(i),
                    child: AnimatedOpacity(
                      opacity: bubble.popped ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: bubble.popped ? 1.4 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Transform.translate(
                          offset: Offset(hOff, vOff),
                          child: Stack(
                            children: [
                              // Main 3D Sphere Body
                              Container(
                                width: bubble.size,
                                height: bubble.size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.3, -0.3),
                                    colors: [
                                      Colors.white.withValues(alpha: 0.35),
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                      Colors.white.withValues(alpha: 0.15),
                                    ],
                                    stops: const [0.0, 0.3, 0.8, 1.0],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              // Highlight Glint
                              Positioned(
                                top: bubble.size * 0.15,
                                left: bubble.size * 0.15,
                                child: Container(
                                  width: bubble.size * 0.25,
                                  height: bubble.size * 0.2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Rim Reflection
                              Positioned(
                                bottom: bubble.size * 0.15,
                                right: bubble.size * 0.15,
                                child: Container(
                                  width: bubble.size * 0.3,
                                  height: bubble.size * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Bubble {
  final Offset position;
  final double size;
  final Color color;
  final AnimationController controller;
  bool popped = false;

  _Bubble({
    required this.position,
    required this.size,
    required this.color,
    required this.controller,
  });
}

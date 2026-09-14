import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/theme_service.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import '../widgets/lake_background.dart';
import 'home_screen.dart';

class AfterDropScreen extends StatefulWidget {
  const AfterDropScreen({super.key});
  @override
  State<AfterDropScreen> createState() => _AfterDropScreenState();
}

class _AfterDropScreenState extends State<AfterDropScreen> {
  bool _staying = false;
  bool _leaving = false;
  @override
  void initState() {
    super.initState();
    HapticService.closurePulse();
    soundService.playRelax();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _done() {
    if (_leaving) return;
    _leaving = true;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeService>().isDarkMode;
    final text = DropTheme.getTextColor(dark);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        body: LakeBackground(
          animate: !_staying,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 44,
                      color: DropTheme.getAccentColor(dark),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _staying ? 'Take your time.' : "It's gone.",
                      textAlign: TextAlign.center,
                      style: DropTheme.getClosureStyle(
                        dark,
                      ).copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 48),
                    if (!_staying)
                      TextButton(
                        onPressed: () => setState(() => _staying = true),
                        style: TextButton.styleFrom(foregroundColor: text),
                        child: const Text('Stay a moment'),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _done,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        minimumSize: const Size(180, 48),
                      ),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

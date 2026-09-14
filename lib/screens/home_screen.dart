import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../services/theme_service.dart';
import '../widgets/breathing_guide.dart';
import '../widgets/home_drop_scene.dart';
import '../widgets/lake_background.dart';
import 'settings_screen.dart';
import 'write_screen.dart';

/// A fresh start on every visit. No activity state is recorded.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _breathing = false;
  bool _opening = false;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = soundService.enabled;
    soundService.playRelax();
  }

  Future<void> _open(Widget screen) async {
    if (_opening) return;
    _opening = true;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
      ),
    );
    if (!mounted) return;
    _opening = false;
    setState(() => _soundEnabled = soundService.enabled);
    soundService.playRelax();
  }

  void _finishBreathing() => setState(() => _breathing = false);

  Future<void> _toggleSound() async {
    final enabled = !_soundEnabled;
    setState(() => _soundEnabled = enabled);
    await soundService.setEnabled(enabled);
    if (mounted) setState(() => _soundEnabled = soundService.enabled);
  }

  Future<void> _toggleMotion(ThemeService theme) async {
    await theme.setReducedMotion(!theme.reducedMotion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    final dark = theme.isDarkMode;
    final reduceMotion =
        theme.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final text = DropTheme.getTextColor(dark);
    final accent = DropTheme.getAccentColor(dark);

    return PopScope(
      canPop: !_breathing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _breathing) _finishBreathing();
      },
      child: Scaffold(
        body: Stack(
          children: [
            LakeBackground(
              animate: !reduceMotion,
              showReflections: false,
              showParticles: false,
              showMoonlight: false,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          children: [
                            _Header(
                              text: text,
                              soundEnabled: _soundEnabled,
                              motionEnabled: !theme.reducedMotion,
                              onSound: _toggleSound,
                              onMotion: () => _toggleMotion(theme),
                              onSettings: () => _open(const SettingsScreen()),
                            ),
                            const SizedBox(height: 18),
                            ExcludeSemantics(
                              child: HomeDropScene(
                                dark: dark,
                                animate: !reduceMotion,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'One thought at a time.',
                              textAlign: TextAlign.center,
                              style: DropTheme.getBodyStyle(dark).copyWith(
                                fontSize: 27,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A quiet place to put down what feels heavy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: text.withValues(alpha: 0.66),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 30),
                            FilledButton.icon(
                              onPressed: () => _open(const WriteScreen()),
                              icon: const Icon(Icons.edit_outlined, size: 19),
                              label: const Text('Write a thought'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: dark
                                    ? const Color(0xFF071824)
                                    : Colors.white,
                                minimumSize: const Size.fromHeight(58),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuietAction(
                                    icon: Icons.water_drop_outlined,
                                    label: 'Without words',
                                    text: text,
                                    onTap: () => _open(
                                      const WriteScreen(wordless: true),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuietAction(
                                    icon: Icons.air_rounded,
                                    label: 'Breathe',
                                    text: text,
                                    onTap: () =>
                                        setState(() => _breathing = true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: text.withValues(alpha: 0.46),
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    'Your thoughts are never saved or sent.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: text.withValues(alpha: 0.52),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_breathing)
              Positioned.fill(
                child: BreathingGuide(
                  onComplete: _finishBreathing,
                  onSkip: _finishBreathing,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color text;
  final bool soundEnabled;
  final bool motionEnabled;
  final VoidCallback onSound;
  final VoidCallback onMotion;
  final VoidCallback onSettings;

  const _Header({
    required this.text,
    required this.soundEnabled,
    required this.motionEnabled,
    required this.onSound,
    required this.onMotion,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Text(
            'DROP',
            style: TextStyle(
              color: text.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 4.5,
            ),
          ),
          const Spacer(),
          _HeaderControl(
            tooltip: soundEnabled ? 'Turn music off' : 'Turn music on',
            icon: soundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            active: soundEnabled,
            text: text,
            onPressed: onSound,
          ),
          const SizedBox(width: 4),
          _HeaderControl(
            tooltip: motionEnabled ? 'Turn animation off' : 'Turn animation on',
            icon: motionEnabled
                ? Icons.animation_rounded
                : Icons.motion_photos_off_rounded,
            active: motionEnabled,
            text: text,
            onPressed: onMotion,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Settings',
            onPressed: onSettings,
            icon: Icon(
              Icons.tune_rounded,
              size: 23,
              color: text.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderControl extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool active;
  final Color text;
  final VoidCallback onPressed;

  const _HeaderControl({
    required this.tooltip,
    required this.icon,
    required this.active,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: active ? text.withValues(alpha: 0.10) : null,
      ),
      icon: Icon(icon, size: 21, color: text.withValues(alpha: 0.76)),
    );
  }
}

class _QuietAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color text;
  final VoidCallback onTap;

  const _QuietAction({
    required this.icon,
    required this.label,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: text.withValues(alpha: 0.88),
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: text.withValues(alpha: 0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

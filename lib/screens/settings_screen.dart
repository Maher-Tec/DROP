import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../services/theme_service.dart';
import '../widgets/lake_background.dart';
import '../widgets/reminder_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled = soundService.enabled;

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await soundService.setEnabled(value);
  }

  Future<void> _toggleNightMode(bool value) async {
    await context.read<ThemeService>().setNightMode(value);
  }

  Future<void> _toggleReducedMotion(bool value) async {
    await context.read<ThemeService>().setReducedMotion(value);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = DropTheme.fontScale(context);
    final themeService = context.watch<ThemeService>();
    final isDarkMode = themeService.isDarkMode;
    final nightModeOverride = themeService.nightModeOverride;
    final reducedMotion = themeService.reducedMotion;

    return Scaffold(
      body: LakeBackground(
        animate: !reducedMotion,
        showWaves: false,
        showReflections: false,
        showParticles: false,
        showMoonlight: false,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(fontScale, isDarkMode),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Reminders', fontScale, isDarkMode),
                      const SizedBox(height: 12),
                      const ReminderSettings(),

                      const SizedBox(height: 32),

                      _buildSectionTitle(
                        'Sound & Haptics',
                        fontScale,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        icon: Icons.volume_up_rounded,
                        title: 'Music',
                        subtitle: 'Background music; the drop sound always plays',
                        value: _soundEnabled,
                        onChanged: _toggleSound,
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),

                      if (_soundEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildVolumeSlider(fontScale, isDarkMode),
                        ),

                      const SizedBox(height: 32),

                      _buildSectionTitle('Appearance', fontScale, isDarkMode),
                      const SizedBox(height: 12),

                      _buildThemeToggle(fontScale),

                      const SizedBox(height: 12),
                      _buildSettingTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Always Night Mode',
                        subtitle: 'Override automatic time-based theme',
                        value: nightModeOverride,
                        onChanged: _toggleNightMode,
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingTile(
                        icon: Icons.accessibility_new_rounded,
                        title: 'Reduced Motion',
                        subtitle: 'Minimize animations',
                        value: reducedMotion,
                        onChanged: _toggleReducedMotion,
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 32),

                      _buildSectionTitle('About', fontScale, isDarkMode),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.water_drop_rounded,
                        title: 'DROP',
                        subtitle: 'One thought at a time.',
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy',
                        subtitle:
                            "Your words aren't saved or sent by DROP. No activity history is kept. Only preferences and whether you've seen the introduction stay on this device. Your keyboard operates separately.",
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Made with love',
                        subtitle: 'For your peace of mind',
                        fontScale: fontScale,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double fontScale, bool isDarkMode) {
    final textColor = DropTheme.getTextColor(isDarkMode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: textColor.withValues(alpha: 0.5),
                    size: 26,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'back',
                    style: DropTheme.getHintStyle(
                      isDarkMode,
                    ).copyWith(fontSize: 13 * fontScale),
                  ),
                ],
              ),
            ),
          ),

          Text(
            'Settings',
            style: DropTheme.getBodyStyle(
              isDarkMode,
            ).copyWith(fontSize: 17 * fontScale),
          ),

          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontScale, bool isDarkMode) {
    return Text(
      title.toUpperCase(),
      style: DropTheme.getHintStyle(isDarkMode).copyWith(
        fontSize: 11 * fontScale,
        color: DropTheme.getAccentColor(isDarkMode).withValues(alpha: 0.7),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVolumeSlider(double fontScale, bool isDarkMode) {
    final text = DropTheme.getTextColor(isDarkMode);
    final accent = DropTheme.getAccentColor(isDarkMode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? DropTheme.deepBlue.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: text.withValues(alpha: 0.58),
            size: 20,
          ),
          Expanded(
            child: Slider(
              value: soundService.volume,
              min: 0.0,
              max: 1.0,
              activeColor: accent,
              inactiveColor: text.withValues(alpha: 0.16),
              onChanged: (value) async {
                await soundService.setVolume(value);
                setState(() {});
              },
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: text.withValues(alpha: 0.58),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required double fontScale,
    required bool isDarkMode,
  }) {
    final text = DropTheme.getTextColor(isDarkMode);
    final accent = DropTheme.getAccentColor(isDarkMode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? DropTheme.deepBlue.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.82), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DropTheme.bodyStyle.copyWith(
                    fontSize: 15 * fontScale,
                    color: text.withValues(alpha: 0.90),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 12 * fontScale,
                    color: text.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double fontScale,
    required bool isDarkMode,
  }) {
    final text = DropTheme.getTextColor(isDarkMode);
    final accent = DropTheme.getAccentColor(isDarkMode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? DropTheme.deepBlue.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent.withValues(alpha: 0.72), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DropTheme.bodyStyle.copyWith(
                    fontSize: 14 * fontScale,
                    color: text.withValues(alpha: 0.84),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 11 * fontScale,
                    color: text.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(double fontScale) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final isDark = themeService.isDarkMode;

        return GestureDetector(
          onTap: () async {
            await themeService.toggleTheme();
            if (mounted) setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        DropTheme.deepBlue.withValues(alpha: 0.4),
                        DropTheme.oceanBlue.withValues(alpha: 0.3),
                      ]
                    : [
                        DropTheme.lightDropAccent.withValues(alpha: 0.15),
                        DropTheme.lightGlow.withValues(alpha: 0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? DropTheme.softWhite.withValues(alpha: 0.1)
                    : DropTheme.lightDropAccent.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(isDark),
                    color: isDark
                        ? DropTheme.dropAccent.withValues(alpha: 0.7)
                        : DropTheme.lightDropAccent.withValues(alpha: 0.8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: DropTheme.bodyStyle.copyWith(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? DropTheme.softWhite.withValues(alpha: 0.9)
                              : DropTheme.darkTealText.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isDark ? 'Dark ocean mode' : 'Light water mode',
                          key: ValueKey(isDark),
                          style: DropTheme.hintStyle.copyWith(
                            fontSize: 12 * fontScale,
                            color: isDark
                                ? DropTheme.softWhite.withValues(alpha: 0.45)
                                : DropTheme.darkTealText.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DropTheme.dropAccent.withValues(alpha: 0.2)
                        : DropTheme.lightDropAccent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDark ? 'Dark' : 'Light',
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 12 * fontScale,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DropTheme.dropAccent
                          : DropTheme.lightDropAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

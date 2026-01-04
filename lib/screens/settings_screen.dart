import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../services/sound_service.dart';
import '../widgets/lake_background.dart';
import '../widgets/reminder_settings.dart';
import 'history_screen.dart';

/// SETTINGS SCREEN - Premium Pro Max
/// 
/// Features:
/// - Daily reminder toggle with time picker
/// - Sound on/off toggle
/// - Night mode override
/// - Reduced motion mode
/// - About / Privacy info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _nightModeOverride = false;
  bool _reducedMotion = false;
  bool _loading = true;
  
  SharedPreferences? _prefs;
  
  static const String _soundKey = 'sound_enabled';
  static const String _nightModeKey = 'night_mode_override';
  static const String _reducedMotionKey = 'reduced_motion';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _soundEnabled = _prefs?.getBool(_soundKey) ?? true;
        _nightModeOverride = _prefs?.getBool(_nightModeKey) ?? false;
        _reducedMotion = _prefs?.getBool(_reducedMotionKey) ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await _prefs?.setBool(_soundKey, value);
    
    if (value) {
      soundService.playRelax();
    } else {
      soundService.stopAmbient();
    }
  }

  Future<void> _toggleNightMode(bool value) async {
    setState(() => _nightModeOverride = value);
    await _prefs?.setBool(_nightModeKey, value);
    // Theme will pick this up on next build
  }

  Future<void> _toggleReducedMotion(bool value) async {
    setState(() => _reducedMotion = value);
    await _prefs?.setBool(_reducedMotionKey, value);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = DropTheme.fontScale(context);
    
    return Scaffold(
      body: LakeBackground(
        animate: !_reducedMotion,
        showWaves: false,
        showReflections: true,
        showParticles: !_reducedMotion,
        showMoonlight: true,
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Top bar
                    _buildTopBar(fontScale),
                    
                    // Settings content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Reminders', fontScale),
                            const SizedBox(height: 12),
                            const ReminderSettings(),
                            
                            const SizedBox(height: 32),
                            
                            _buildSectionTitle('Sound & Haptics', fontScale),
                            const SizedBox(height: 12),
                            _buildSettingTile(
                              icon: Icons.volume_up_rounded,
                              title: 'Ambient Sound',
                              subtitle: 'Relaxing background music',
                              value: _soundEnabled,
                              onChanged: _toggleSound,
                              fontScale: fontScale,
                            ),
                            
                            // Volume slider (only visible when sound enabled)
                            if (_soundEnabled)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _buildVolumeSlider(fontScale),
                              ),
                            
                            const SizedBox(height: 32),
                            
                            _buildSectionTitle('Appearance', fontScale),
                            const SizedBox(height: 12),
                            _buildSettingTile(
                              icon: Icons.dark_mode_rounded,
                              title: 'Always Night Mode',
                              subtitle: 'Override automatic time-based theme',
                              value: _nightModeOverride,
                              onChanged: _toggleNightMode,
                              fontScale: fontScale,
                            ),
                            const SizedBox(height: 12),
                            _buildSettingTile(
                              icon: Icons.accessibility_new_rounded,
                              title: 'Reduced Motion',
                              subtitle: 'Minimize animations',
                              value: _reducedMotion,
                              onChanged: _toggleReducedMotion,
                              fontScale: fontScale,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            _buildSectionTitle('Your Journey', fontScale),
                            const SizedBox(height: 12),
                            _buildTappableTile(
                              icon: Icons.calendar_month_rounded,
                              title: 'History & Stats',
                              subtitle: 'View your drop calendar and streaks',
                              fontScale: fontScale,
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, _) => const HistoryScreen(),
                                    transitionsBuilder: (context, animation, _, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            _buildSectionTitle('About', fontScale),
                            const SizedBox(height: 12),
                            _buildInfoTile(
                              icon: Icons.water_drop_rounded,
                              title: 'DROP',
                              subtitle: 'Version 1.0.0',
                              fontScale: fontScale,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Privacy',
                              subtitle: 'Your thoughts are never saved or shared',
                              fontScale: fontScale,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoTile(
                              icon: Icons.favorite_border_rounded,
                              title: 'Made with love',
                              subtitle: 'For your peace of mind',
                              fontScale: fontScale,
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

  Widget _buildTopBar(double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Title
          Text(
            'Settings',
            style: DropTheme.bodyStyle.copyWith(
              fontSize: 17 * fontScale,
              color: DropTheme.softWhite.withValues(alpha: 0.8),
            ),
          ),
          
          // Spacer for balance
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontScale) {
    return Text(
      title.toUpperCase(),
      style: DropTheme.hintStyle.copyWith(
        fontSize: 11 * fontScale,
        color: DropTheme.dropAccent.withValues(alpha: 0.6),
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildVolumeSlider(double fontScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DropTheme.deepBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DropTheme.softWhite.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: DropTheme.softWhite.withValues(alpha: 0.4),
            size: 20,
          ),
          Expanded(
            child: Slider(
              value: soundService.volume,
              min: 0.0,
              max: 1.0,
              activeColor: DropTheme.dropAccent,
              inactiveColor: DropTheme.softWhite.withValues(alpha: 0.15),
              onChanged: (value) async {
                await soundService.setVolume(value);
                setState(() {});
              },
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: DropTheme.softWhite.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTappableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double fontScale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DropTheme.deepBlue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DropTheme.softWhite.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: DropTheme.dropAccent.withValues(alpha: 0.6),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DropTheme.bodyStyle.copyWith(
                      fontSize: 15 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 12 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: DropTheme.softWhite.withValues(alpha: 0.3),
              size: 22,
            ),
          ],
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DropTheme.deepBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DropTheme.softWhite.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: DropTheme.softWhite.withValues(alpha: 0.5),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DropTheme.bodyStyle.copyWith(
                    fontSize: 15 * fontScale,
                    color: DropTheme.softWhite.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 12 * fontScale,
                    color: DropTheme.softWhite.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: DropTheme.dropAccent,
            thumbColor: WidgetStatePropertyAll(DropTheme.softWhite),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DropTheme.deepBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DropTheme.softWhite.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: DropTheme.dropAccent.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DropTheme.bodyStyle.copyWith(
                    fontSize: 14 * fontScale,
                    color: DropTheme.softWhite.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DropTheme.hintStyle.copyWith(
                    fontSize: 11 * fontScale,
                    color: DropTheme.softWhite.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

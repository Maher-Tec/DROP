import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound Service - Manages all audio playback in DROP
/// 
/// Audio Flow:
/// 1. relax.mp3 - Plays from app open until user clicks to write (loops)
/// 2. let it go.mp3 - Plays while user is writing (loops)
/// 3. water drop.mp3 - Plays on drop animation
/// 4. Back to relax.mp3
class SoundService {
  // Simple asset paths - audioplayers adds 'assets/' prefix automatically
  static const String _relaxSound = 'sound/relax.mp3';
  static const String _letItGoSound = 'sound/let it go.mp3';
  static const String _waterDropSound = 'sound/water drop.mp3';
  static const String _popSound = 'sound/pop.mp3'; // ASMR bubble pop
  
  // Volume control
  static const String _volumeKey = 'sound_volume';
  double _volume = 0.5; // 0.0 to 1.0
  
  // Audio players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  String? _currentAmbient;
  
  /// Get current volume level
  double get volume => _volume;
  
  /// Initialize the sound service
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Load saved volume
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble(_volumeKey) ?? 0.5;
    
    // Set release mode for better performance
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _effectPlayer.setReleaseMode(ReleaseMode.release);
    
    _isInitialized = true;
  }
  
  /// Set volume level (0.0 to 1.0)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _ambientPlayer.setVolume(_volume);
    
    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
  }
  
  /// Play relaxing ambient sound (loops until stopped)
  Future<void> playRelax() async {
    await init();
    if (_currentAmbient == _relaxSound) return;
    
    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(_volume); // Use saved volume
    await _ambientPlayer.play(AssetSource(_relaxSound));
    _currentAmbient = _relaxSound;
  }
  
  /// Play relaxing ambient sound at LOW volume (for writing screen)
  Future<void> playRelaxLow() async {
    await init();
    
    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(0.15); // Very low volume for focus
    await _ambientPlayer.play(AssetSource(_relaxSound));
    _currentAmbient = _relaxSound;
  }
  
  /// Play "let it go" ambient sound while writing (loops)
  Future<void> playLetItGo() async {
    await init();
    if (_currentAmbient == _letItGoSound) return;
    
    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(0.5);
    await _ambientPlayer.play(AssetSource(_letItGoSound));
    _currentAmbient = _letItGoSound;
  }
  
  /// Play water drop sound effect (one-shot)
  Future<void> playWaterDrop() async {
    await init();
    await _effectPlayer.setVolume(0.7);
    await _effectPlayer.play(AssetSource(_waterDropSound));
  }
  
  /// Stop all ambient sounds
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
    _currentAmbient = null;
  }
  
  /// Pause ambient sound
  Future<void> pauseAmbient() async {
    await _ambientPlayer.pause();
  }
  
  /// Resume ambient sound
  Future<void> resumeAmbient() async {
    await _ambientPlayer.resume();
  }
  
  /// Fade out ambient sound
  Future<void> fadeOutAmbient({Duration duration = const Duration(milliseconds: 500)}) async {
    const steps = 10;
    final stepDuration = duration ~/ steps;
    double volume = 0.4;
    
    for (int i = 0; i < steps; i++) {
      volume -= 0.04;
      await _ambientPlayer.setVolume(volume.clamp(0.0, 1.0));
      await Future.delayed(stepDuration);
    }
    await _ambientPlayer.stop();
    _currentAmbient = null;
  }
  
  /// Play ASMR bubble pop sound (One-shot for overlapping)
  Future<void> playPop() async {
    await init();
    // Create a one-shot player for immediate overlap
    final player = AudioPlayer();
    await player.setVolume(_volume * 0.6);
    await player.play(AssetSource(_popSound));
    
    // Auto-dispose after sound finishes (approx 1s)
    Future.delayed(const Duration(seconds: 1), () {
      player.dispose();
    });
  }
  
  /// Dispose all players
  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _effectPlayer.dispose();
  }
}

/// Global singleton instance
final soundService = SoundService();

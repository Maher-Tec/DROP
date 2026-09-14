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
  static const double _dropEffectVolume = 0.5;

  // Volume control
  static const String _volumeKey = 'sound_volume';
  double _volume = 0.5; // 0.0 to 1.0

  // Audio players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _enabled = true;
  bool _foreground = true;
  int _playbackRevision = 0;
  final Set<AudioPlayer> _popPlayers = {};
  bool get enabled => _enabled;
  String? _currentAmbient;

  /// Get current volume level
  double get volume => _volume;

  /// Initialize the sound service
  Future<void> init() async {
    if (_isInitialized) return;

    // Load saved volume
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble(_volumeKey) ?? 0.5;
    _enabled = prefs.getBool('sound_enabled') ?? true;

    // Set release mode for better performance
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _effectPlayer.setReleaseMode(ReleaseMode.release);

    _isInitialized = true;
  }

  Future<void> setEnabled(bool value) async {
    await init();
    _enabled = value;
    _playbackRevision++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    if (!value) {
      await stopAmbient();
      for (final player in _popPlayers.toList()) {
        await player.stop();
      }
    } else {
      await playRelax();
    }
  }

  /// Set volume level (0.0 to 1.0)
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _ambientPlayer.setVolume(_volume);
    for (final player in _popPlayers.toList()) {
      await player.setVolume(_volume * 0.6);
    }

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
  }

  /// Play relaxing ambient sound (loops until stopped)
  Future<void> playRelax() async {
    await init();
    if (!_enabled || !_foreground) return;
    if (_currentAmbient == _relaxSound) return;
    final revision = _playbackRevision;

    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(_volume); // Use saved volume
    if (!_canPlay(revision)) return;
    await _ambientPlayer.play(AssetSource(_relaxSound));
    if (!_canPlay(revision)) {
      await _ambientPlayer.stop();
      return;
    }
    _currentAmbient = _relaxSound;
  }

  /// Play relaxing ambient sound at LOW volume (for writing screen)
  Future<void> playRelaxLow() async {
    await init();
    if (!_enabled || !_foreground) return;
    final revision = _playbackRevision;

    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(_volume * 0.3); // Very low volume for focus
    if (!_canPlay(revision)) return;
    await _ambientPlayer.play(AssetSource(_relaxSound));
    if (!_canPlay(revision)) {
      await _ambientPlayer.stop();
      return;
    }
    _currentAmbient = _relaxSound;
  }

  /// Play "let it go" ambient sound while writing (loops)
  Future<void> playLetItGo() async {
    await init();
    if (!_enabled || !_foreground) return;
    if (_currentAmbient == _letItGoSound) return;
    final revision = _playbackRevision;

    await _ambientPlayer.stop();
    await _ambientPlayer.setVolume(_volume);
    if (!_canPlay(revision)) return;
    await _ambientPlayer.play(AssetSource(_letItGoSound));
    if (!_canPlay(revision)) {
      await _ambientPlayer.stop();
      return;
    }
    _currentAmbient = _letItGoSound;
  }

  /// Play water drop sound effect (one-shot)
  Future<void> playWaterDrop() async {
    await init();
    if (!_foreground) return;
    await _effectPlayer.setVolume(_dropEffectVolume);
    if (!_foreground) return;
    await _effectPlayer.play(AssetSource(_waterDropSound));
    if (!_foreground) await _effectPlayer.stop();
  }

  bool _canPlay(int revision) =>
      _enabled && _foreground && revision == _playbackRevision;

  /// Stop all ambient sounds
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
    _currentAmbient = null;
  }

  /// Pause ambient sound
  Future<void> pauseAmbient() async {
    _foreground = false;
    _playbackRevision++;
    await _ambientPlayer.pause();
    await _effectPlayer.stop();
    for (final player in _popPlayers.toList()) {
      await player.stop();
    }
  }

  /// Resume ambient sound
  Future<void> resumeAmbient() async {
    _foreground = true;
    await init();
    if (!_enabled) return;
    if (_currentAmbient == null) {
      await playRelax();
    } else {
      await _ambientPlayer.resume();
    }
  }

  /// Fade out ambient sound
  Future<void> fadeOutAmbient({
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await init();
    if (!_enabled || _currentAmbient == null) return;

    const steps = 10;
    final stepDuration = duration ~/ steps;
    double volume = _ambientPlayer.volume;
    final decrement = volume / steps;

    for (int i = 0; i < steps; i++) {
      volume -= decrement;
      await _ambientPlayer.setVolume(volume.clamp(0.0, 1.0));
      await Future.delayed(stepDuration);
    }
    await _ambientPlayer.stop();
    _currentAmbient = null;
  }

  /// Play ASMR bubble pop sound (One-shot for overlapping)
  Future<void> playPop() async {
    await init();
    if (!_enabled || !_foreground) return;
    // Create a one-shot player for immediate overlap
    final player = AudioPlayer();
    _popPlayers.add(player);
    await player.setVolume(_volume * 0.6);
    await player.play(AssetSource(_popSound));

    // Auto-dispose after sound finishes (approx 1s)
    Future.delayed(const Duration(seconds: 1), () {
      if (_popPlayers.remove(player)) player.dispose();
    });
  }

  /// Stops playback and releases the one-shot pop players.
  ///
  /// The ambient/effect players are intentionally kept alive: this service
  /// is a process-lifetime singleton, and actually disposing its `final`
  /// players would leave it silently unable to play again if the widget
  /// tree that called this is ever rebuilt within the same engine.
  Future<void> dispose() async {
    await _ambientPlayer.stop();
    await _effectPlayer.stop();
    _currentAmbient = null;
    for (final player in _popPlayers.toList()) {
      await player.dispose();
    }
    _popPlayers.clear();
  }
}

/// Global singleton instance
final soundService = SoundService();

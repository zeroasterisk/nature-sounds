import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound.dart';

/// Wraps [AudioPlayer] from just_audio.
/// Provides play-with-loop, stop, fade-out, and volume control.
class NatureAudioService {
  final AudioPlayer _player = AudioPlayer();

  Sound? _currentSound;
  Sound? get currentSound => _currentSound;

  bool get isPlaying => _player.playing;

  double _volume = 1.0;
  double get volume => _volume;

  Timer? _fadeTimer;

  NatureAudioService();

  /// Play [sound] with seamless looping.
  /// Replaces any currently playing sound.
  Future<void> play(Sound sound) async {
    // Cancel any active fade
    _fadeTimer?.cancel();
    _fadeTimer = null;

    try {
      await _player.stop();
      await _player.setVolume(_volume);
      await _player.setAsset(sound.assetPath);
      await _player.setLoopMode(LoopMode.one);
      _currentSound = sound;
      await _player.play();
    } catch (e) {
      // Asset might not exist yet — handle gracefully
      debugPrint('NatureAudioService: could not play ${sound.id}: $e');
      _currentSound = sound; // still set it so UI reflects the attempt
    }
  }

  /// Stop playback immediately.
  Future<void> stop() async {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    await _player.stop();
    _currentSound = null;
    await _player.setVolume(1.0);
    _volume = 1.0;
  }

  /// Gradually reduce volume to zero over [duration], then stop.
  void fadeOut({Duration duration = const Duration(minutes: 2)}) {
    _fadeTimer?.cancel();

    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) {
      stop();
      return;
    }

    int remaining = totalSeconds;
    _fadeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        _fadeTimer = null;
        stop();
        return;
      }
      // easeOut-style curve: quicker at start, gentle tail
      final t = remaining / totalSeconds;
      final curved = Curves.easeOut.transform(t);
      _player.setVolume(curved * _volume);
    });
  }

  /// Set master volume (0.0 – 1.0).
  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  void dispose() {
    _fadeTimer?.cancel();
    _player.dispose();
  }
}

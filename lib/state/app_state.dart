import 'package:flutter/foundation.dart';
import '../models/sound.dart';
import '../services/audio_service.dart';
import '../services/timer_service.dart';
import '../services/prefs_service.dart';

/// Single ChangeNotifier that combines audio, timer, and preferences.
class AppState extends ChangeNotifier {
  final NatureAudioService _audio = NatureAudioService();
  late final TimerService _timer;
  final PrefsService _prefs = PrefsService();

  AppState() {
    _timer = TimerService(
      onFadeStart: _onFadeStart,
      onComplete: _onTimerComplete,
      onTick: _onTimerTick,
    );
  }

  // ── Getters ──────────────────────────────────────────────────

  Sound? get currentSound => _audio.currentSound;
  bool get isPlaying => _audio.isPlaying;
  double get volume => _audio.volume;

  SleepDuration get selectedDuration => _timer.selectedDuration;
  Duration get remaining => _timer.remaining;
  String get remainingLabel => _timer.remainingLabel;
  bool get isFading => _timer.isFading;

  List<String> get favoriteIds => _prefs.favorites;
  List<String> get recentIds => _prefs.recents;

  bool isFavorite(String soundId) => _prefs.isFavorite(soundId);

  /// Initialize preferences (call once at startup).
  Future<void> init() async {
    await _prefs.init();
    notifyListeners();
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> playSoundById(String id) async {
    final sound = Sound.findById(id);
    if (sound == null) return;

    await _audio.play(sound);
    await _prefs.addRecent(id);

    // If a finite timer is selected, restart it for the new sound
    if (_timer.selectedDuration != SleepDuration.infinity) {
      _timer.setDuration(_timer.selectedDuration);
    }

    notifyListeners();
  }

  Future<void> stopPlayback() async {
    _timer.cancel();
    await _audio.stop();
    notifyListeners();
  }

  void setDuration(SleepDuration d) {
    _timer.setDuration(d);
    notifyListeners();
  }

  Future<void> toggleFavorite(String soundId) async {
    await _prefs.toggleFavorite(soundId);
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    await _audio.setVolume(v);
    notifyListeners();
  }

  // ── Timer callbacks ──────────────────────────────────────────

  void _onFadeStart() {
    _audio.fadeOut(duration: const Duration(minutes: 2));
  }

  void _onTimerComplete() {
    _audio.stop();
    notifyListeners();
  }

  void _onTimerTick() {
    notifyListeners();
  }

  // ── Cleanup ──────────────────────────────────────────────────

  @override
  void dispose() {
    _timer.dispose();
    _audio.dispose();
    super.dispose();
  }
}

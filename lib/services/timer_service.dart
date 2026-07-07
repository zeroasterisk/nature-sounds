import 'dart:async';

/// Predefined sleep durations.
enum SleepDuration {
  infinity,
  sixHours,
  fourHours,
  twoHours,
  oneHour,
  thirtyMinutes,
}

extension SleepDurationExt on SleepDuration {
  String get label {
    switch (this) {
      case SleepDuration.infinity:
        return '∞'; // ∞
      case SleepDuration.sixHours:
        return '6h';
      case SleepDuration.fourHours:
        return '4h';
      case SleepDuration.twoHours:
        return '2h';
      case SleepDuration.oneHour:
        return '1h';
      case SleepDuration.thirtyMinutes:
        return '30m';
    }
  }

  Duration? get duration {
    switch (this) {
      case SleepDuration.infinity:
        return null;
      case SleepDuration.sixHours:
        return const Duration(hours: 6);
      case SleepDuration.fourHours:
        return const Duration(hours: 4);
      case SleepDuration.twoHours:
        return const Duration(hours: 2);
      case SleepDuration.oneHour:
        return const Duration(hours: 1);
      case SleepDuration.thirtyMinutes:
        return const Duration(minutes: 30);
    }
  }
}

/// Countdown timer that fires [onFadeStart] at 2 minutes remaining
/// and [onComplete] when the timer reaches zero.
class TimerService {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  SleepDuration _selectedDuration = SleepDuration.infinity;

  final void Function()? onFadeStart;
  final void Function()? onComplete;
  final void Function()? onTick;

  Duration get remaining => _remaining;
  SleepDuration get selectedDuration => _selectedDuration;
  bool get isRunning => _timer != null;

  /// Whether we are in the final 2-minute fade period.
  bool get isFading =>
      isRunning &&
      _remaining.inSeconds > 0 &&
      _remaining.inSeconds <= 120;

  TimerService({this.onFadeStart, this.onComplete, this.onTick});

  /// Set the duration and start (or restart) the countdown.
  /// Pass [SleepDuration.infinity] to cancel any running timer.
  void setDuration(SleepDuration d) {
    _selectedDuration = d;
    _timer?.cancel();
    _timer = null;

    final dur = d.duration;
    if (dur == null) {
      _remaining = Duration.zero;
      onTick?.call();
      return;
    }

    _remaining = dur;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    onTick?.call();
  }

  void _tick() {
    _remaining -= const Duration(seconds: 1);

    if (_remaining.inSeconds == 120) {
      onFadeStart?.call();
    }

    if (_remaining <= Duration.zero) {
      _remaining = Duration.zero;
      _timer?.cancel();
      _timer = null;
      onComplete?.call();
    }

    onTick?.call();
  }

  /// Cancel the timer without triggering callbacks.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = Duration.zero;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Format remaining time for display.
  String get remainingLabel {
    if (_remaining == Duration.zero) return '';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

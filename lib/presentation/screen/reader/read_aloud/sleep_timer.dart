import 'dart:async';

enum SleepTimerChoice { off, minutes15, minutes30, minutes60, endOfChapter }

/// Stops read-aloud after a delay or at the next chapter change.
class SleepTimer {
  SleepTimer({
    required this.onExpired,
    Timer Function(Duration, void Function())? createTimer,
  }) : _createTimer = createTimer ?? Timer.new;

  final void Function() onExpired;
  final Timer Function(Duration, void Function()) _createTimer;

  Timer? _timer;
  SleepTimerChoice _choice = SleepTimerChoice.off;
  String? _chapter;

  SleepTimerChoice get choice => _choice;

  /// [chapter] is the chapter being read now, so end of chapter finishes
  /// it rather than the next one.
  void set(SleepTimerChoice choice, {String? chapter}) {
    _timer?.cancel();
    _timer = null;
    _chapter = choice == SleepTimerChoice.endOfChapter ? chapter : null;
    _choice = choice;
    final minutes = switch (choice) {
      SleepTimerChoice.minutes15 => 15,
      SleepTimerChoice.minutes30 => 30,
      SleepTimerChoice.minutes60 => 60,
      SleepTimerChoice.off || SleepTimerChoice.endOfChapter => null,
    };
    if (minutes != null) {
      _timer = _createTimer(Duration(minutes: minutes), _expire);
    }
  }

  /// Reports the chapter now being read. Without a chapter from [set], the
  /// first report sets the one to finish.
  void chapterChanged(String chapter) {
    if (_choice != SleepTimerChoice.endOfChapter) return;
    final current = _chapter;
    if (current == null) {
      _chapter = chapter;
    } else if (chapter != current) {
      _expire();
    }
  }

  void cancel() => set(SleepTimerChoice.off);

  void _expire() {
    _timer?.cancel();
    _timer = null;
    _choice = SleepTimerChoice.off;
    _chapter = null;
    onExpired();
  }
}

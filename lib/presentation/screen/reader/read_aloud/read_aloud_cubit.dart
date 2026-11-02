import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';

/// Why read-aloud cannot start.
enum ReadAloudProblem { noEngine, noVoice }

class ReadAloudState {
  const ReadAloudState({
    this.active = false,
    this.status = ReadAloudStatus.idle,
    this.voices = const [],
    this.voice,
    this.speed = 1,
    this.sleep = SleepTimerChoice.off,
    this.problem,
  });

  /// The player is shown.
  final bool active;
  final ReadAloudStatus status;

  /// Offline voices for the book's language first, then the rest.
  final List<ReadAloudVoice> voices;
  final ReadAloudVoice? voice;
  final double speed;
  final SleepTimerChoice sleep;
  final ReadAloudProblem? problem;

  bool get isPlaying =>
      status == ReadAloudStatus.playing || status == ReadAloudStatus.loading;

  ReadAloudState copyWith({
    bool? active,
    ReadAloudStatus? status,
    List<ReadAloudVoice>? voices,
    ReadAloudVoice? Function()? voice,
    double? speed,
    SleepTimerChoice? sleep,
    ReadAloudProblem? Function()? problem,
  }) {
    return ReadAloudState(
      active: active ?? this.active,
      status: status ?? this.status,
      voices: voices ?? this.voices,
      voice: voice == null ? this.voice : voice(),
      speed: speed ?? this.speed,
      sleep: sleep ?? this.sleep,
      problem: problem == null ? this.problem : problem(),
    );
  }
}

/// Drives one book's read-aloud: voice choice, speed, sleep timer and the
/// play/pause state reported by the engine.
class ReadAloudCubit extends Cubit<ReadAloudState> {
  ReadAloudCubit(
    this._service,
    this._settingsRepository, {
    required this.language,
    Timer Function(Duration, void Function())? createTimer,
  }) : super(const ReadAloudState()) {
    _sleepTimer = SleepTimer(
      onExpired: _sleepExpired,
      createTimer: createTimer,
    );
    _statusSubscription = _service.statusChanges.listen(_onStatus);
    _chapterSubscription = _service.chapterChanges.listen((chapter) {
      _chapter = chapter;
      _sleepTimer.chapterChanged(chapter);
    });
  }

  final ReadAloudService _service;
  final SettingsRepository _settingsRepository;

  /// The book's language tag, used to pick a voice.
  final String? language;

  late final SleepTimer _sleepTimer;
  late final StreamSubscription<ReadAloudStatus> _statusSubscription;
  late final StreamSubscription<String> _chapterSubscription;
  var _settings = const SettingsEntity();
  var _started = false;
  String? _chapter;

  /// Shows the player and starts reading, unless no voice can read the book.
  Future<void> open() async {
    try {
      _settings = await _settingsRepository.getSettings();
    } catch (_) {
      // Defaults still let the book be read aloud.
    }
    List<ReadAloudVoice> voices;
    try {
      voices = await _service.voices();
    } catch (_) {
      voices = const [];
    }
    final voice = pickReadAloudVoice(
      voices,
      language: language,
      savedId: _settings.readAloudVoices[_voiceKey],
    );
    emit(
      state.copyWith(
        active: true,
        voices: _sorted(voices),
        voice: () => voice,
        speed: _settings.readAloudSpeed,
        problem: () => voices.isEmpty
            ? ReadAloudProblem.noEngine
            : voice == null
            ? ReadAloudProblem.noVoice
            : null,
      ),
    );
    if (state.problem == null) await play();
  }

  Future<void> play() async {
    if (state.isPlaying) return;
    if (_started && state.status == ReadAloudStatus.paused) {
      await _service.resume();
      return;
    }
    emit(state.copyWith(status: ReadAloudStatus.loading));
    _started = true;
    await _service.start(_options);
  }

  Future<void> pause() => _service.pause();

  Future<void> next() => _service.next();

  Future<void> previous() => _service.previous();

  /// Stops reading and hides the player.
  Future<void> stop() async {
    _sleepTimer.cancel();
    if (_started) await _service.stop();
    _started = false;
    if (!isClosed) {
      emit(
        state.copyWith(
          active: false,
          status: ReadAloudStatus.idle,
          sleep: SleepTimerChoice.off,
        ),
      );
    }
  }

  Future<void> setSpeed(double speed) async {
    emit(state.copyWith(speed: speed));
    await _save(_settings.copyWith(readAloudSpeed: speed));
    await _service.update(_options);
  }

  Future<void> setVoice(ReadAloudVoice voice) async {
    emit(state.copyWith(voice: () => voice, problem: () => null));
    await _save(
      _settings.copyWith(
        readAloudVoices: {..._settings.readAloudVoices, _voiceKey: voice.id},
      ),
    );
    await _service.update(_options);
  }

  void setSleep(SleepTimerChoice choice) {
    _sleepTimer.set(choice, chapter: _chapter);
    emit(state.copyWith(sleep: choice));
  }

  String get _voiceKey => language ?? '';

  ReadAloudOptions get _options => ReadAloudOptions(
    speed: state.speed,
    voiceId: state.voice?.id,
    language: language,
    skipPageNumbers: _settings.readAloudSkipPageNumbers,
  );

  /// Voices for the book's language first, then the rest by language.
  List<ReadAloudVoice> _sorted(List<ReadAloudVoice> voices) {
    final base = (language ?? '').toLowerCase().split(RegExp('[-_]')).first;
    int rank(ReadAloudVoice voice) =>
        voice.language.toLowerCase().startsWith(base) && base.isNotEmpty
        ? 0
        : 1;
    return [...voices]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.language.compareTo(b.language);
    });
  }

  void _onStatus(ReadAloudStatus status) {
    if (status == ReadAloudStatus.idle) _started = false;
    if (!isClosed) emit(state.copyWith(status: status));
  }

  void _sleepExpired() {
    unawaited(stop());
  }

  Future<void> _save(SettingsEntity settings) async {
    _settings = settings;
    try {
      await _settingsRepository.saveSettings(settings);
    } catch (_) {
      // The choice still applies for this session.
    }
  }

  /// Stops playback and releases the engine streams.
  @override
  Future<void> close() async {
    _sleepTimer.cancel();
    if (_started) await _service.stop();
    await _statusSubscription.cancel();
    await _chapterSubscription.cancel();
    await super.close();
  }
}

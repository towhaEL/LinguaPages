import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/settings/drift_settings_repository.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';

const _us = ReadAloudVoice(id: 'us', name: 'US', language: 'en-US');
const _gb = ReadAloudVoice(id: 'gb', name: 'GB', language: 'en-GB');
const _fr = ReadAloudVoice(id: 'fr', name: 'FR', language: 'fr-FR');

void main() {
  group('pickReadAloudVoice', () {
    test('prefers the saved voice, then exact, then base language', () {
      const voices = [_fr, _gb, _us];

      expect(pickReadAloudVoice(voices, language: 'en-US', savedId: 'gb'), _gb);
      expect(pickReadAloudVoice(voices, language: 'en_us'), _us);
      expect(pickReadAloudVoice(voices, language: 'en-AU'), _gb);
      expect(pickReadAloudVoice(voices, language: 'de'), isNull);
      expect(pickReadAloudVoice(voices, language: null), _fr);
      // A saved voice that was uninstalled falls back to the language.
      expect(pickReadAloudVoice(voices, language: 'fr', savedId: 'gone'), _fr);
    });
  });

  group('SleepTimer', () {
    late _FakeTimers timers;
    late int expired;
    late SleepTimer timer;

    setUp(() {
      timers = _FakeTimers();
      expired = 0;
      timer = SleepTimer(
        onExpired: () => expired++,
        createTimer: timers.create,
      );
    });

    test('stops after the chosen minutes and can be cancelled', () {
      timer.set(SleepTimerChoice.minutes30);
      expect(timers.last!.duration, const Duration(minutes: 30));

      timers.last!.fire();
      expect(expired, 1);
      expect(timer.choice, SleepTimerChoice.off);

      timer.set(SleepTimerChoice.minutes15);
      timer.cancel();
      expect(timers.last!.isActive, isFalse);
    });

    test('end of chapter stops when the chapter changes', () {
      timer
        ..set(SleepTimerChoice.endOfChapter, chapter: 'c1.xhtml')
        ..chapterChanged('c1.xhtml');
      expect(expired, 0);

      timer.chapterChanged('c2.xhtml');
      expect(expired, 1);
    });

    test('without a known chapter, the first report is the one to finish', () {
      timer
        ..set(SleepTimerChoice.endOfChapter)
        ..chapterChanged('c3.xhtml')
        ..chapterChanged('c3.xhtml');
      expect(expired, 0);

      timer.chapterChanged('c4.xhtml');
      expect(expired, 1);
    });
  });

  group('ReadAloudCubit', () {
    late LinguaPageDatabase database;
    late DriftSettingsRepository settings;
    late _FakeService service;
    late _FakeTimers timers;
    late ReadAloudCubit cubit;

    setUp(() {
      database = LinguaPageDatabase(NativeDatabase.memory());
      settings = DriftSettingsRepository(database);
      service = _FakeService();
      timers = _FakeTimers();
      cubit = ReadAloudCubit(
        service,
        settings,
        language: 'en-GB',
        createTimer: timers.create,
      );
    });

    tearDown(() async {
      await cubit.close();
      await database.close();
    });

    test('opens with a voice for the book and starts reading', () async {
      service.installed = [_fr, _us, _gb];

      await cubit.open();

      expect(cubit.state.active, isTrue);
      expect(cubit.state.voice, _gb);
      expect(cubit.state.voices.first.language, startsWith('en'));
      expect(service.calls, ['start']);
      expect(service.lastOptions!.voiceId, 'gb');
    });

    test('reports a missing engine or voice instead of starting', () async {
      await cubit.open();
      expect(cubit.state.problem, ReadAloudProblem.noEngine);

      service.installed = [_fr];
      await cubit.open();
      expect(cubit.state.problem, ReadAloudProblem.noVoice);
      expect(service.calls, isEmpty);
    });

    test('pause and play resume rather than restart', () async {
      service.installed = [_gb];
      await cubit.open();
      service.status(ReadAloudStatus.playing);
      await pumpEventQueue();
      expect(cubit.state.isPlaying, isTrue);

      await cubit.pause();
      service.status(ReadAloudStatus.paused);
      await pumpEventQueue();
      await cubit.play();

      expect(service.calls, ['start', 'pause', 'resume']);
    });

    test('speed and voice are saved for next time', () async {
      service.installed = [_us, _gb];
      await cubit.open();

      await cubit.setSpeed(1.5);
      await cubit.setVoice(_us);

      final saved = await settings.getSettings();
      expect(saved.readAloudSpeed, 1.5);
      expect(saved.readAloudVoices, {'en-GB': 'us'});
      expect(service.lastOptions!.speed, 1.5);
      expect(service.lastOptions!.voiceId, 'us');
    });

    test('the sleep timer stops reading and hides the player', () async {
      service.installed = [_gb];
      await cubit.open();
      cubit.setSleep(SleepTimerChoice.minutes15);

      timers.last!.fire();
      await pumpEventQueue();

      expect(service.calls.last, 'stop');
      expect(cubit.state.active, isFalse);
      expect(cubit.state.sleep, SleepTimerChoice.off);
    });
  });
}

class _FakeService implements ReadAloudService {
  List<ReadAloudVoice> installed = [];
  final calls = <String>[];
  ReadAloudOptions? lastOptions;
  final _status = StreamController<ReadAloudStatus>.broadcast();
  final _chapters = StreamController<String>.broadcast();

  void status(ReadAloudStatus value) => _status.add(value);

  @override
  Stream<ReadAloudStatus> get statusChanges => _status.stream;

  @override
  Stream<String> get chapterChanges => _chapters.stream;

  @override
  Future<List<ReadAloudVoice>> voices() async => installed;

  @override
  Future<void> start(ReadAloudOptions options) async {
    calls.add('start');
    lastOptions = options;
  }

  @override
  Future<void> update(ReadAloudOptions options) async => lastOptions = options;

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> stop() async => calls.add('stop');

  @override
  Future<void> next() async => calls.add('next');

  @override
  Future<void> previous() async => calls.add('previous');

  @override
  Future<bool> openVoiceSettings() async => true;
}

class _FakeTimers {
  _FakeTimer? last;

  Timer create(Duration duration, void Function() callback) =>
      last = _FakeTimer(duration, callback);
}

class _FakeTimer implements Timer {
  _FakeTimer(this.duration, this._callback);

  final Duration duration;
  final void Function() _callback;
  var _active = true;

  void fire() {
    if (!_active) return;
    _active = false;
    _callback();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

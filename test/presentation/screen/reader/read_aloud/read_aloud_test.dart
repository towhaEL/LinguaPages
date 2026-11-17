import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/reader/tts/flutter_tts_read_aloud_service.dart';
import 'package:lingua_pages/data/repository_impl/settings/drift_settings_repository.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';

const _us = ReadAloudVoice(id: 'us', name: 'US', language: 'en-US');
const _gb = ReadAloudVoice(id: 'gb', name: 'GB', language: 'en-GB');
const _fr = ReadAloudVoice(id: 'fr', name: 'FR', language: 'fr-FR');

void main() {
  test('splits text into sentences with their offsets', () {
    const text = 'Chapter 1\n\nIt rained. Did it stop? "Yes!" she said…\nEnd';

    final sentences = splitSentences(text);

    expect(sentences.map((s) => s.text), [
      'Chapter 1',
      'It rained.',
      'Did it stop?',
      '"Yes!"',
      'she said…',
      'End',
    ]);
    for (final sentence in sentences) {
      expect(
        text.substring(sentence.start, sentence.end).trim(),
        sentence.text,
      );
    }
  });

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

  group('ReadAloudSession', () {
    late LinguaPageDatabase database;
    late DriftSettingsRepository settings;
    late _FakeSave save;
    late ReadAloudSession session;

    BookEntity book(String id) => BookEntity(
      id: id,
      title: 'Book $id',
      author: null,
      format: DocumentFormat.txt,
      sourceUri: '',
      sourceFileName: '$id.txt',
      contentFingerprint: id,
      addedAt: DateTime(2026),
      progress: .1,
    );

    Future<(ReadAloudCubit, _FakeService)> start(String id) async {
      final service = _FakeService()..installed = [_gb];
      final cubit = ReadAloudCubit(service, settings, language: 'en-GB');
      await session.begin(
        book: book(id),
        cubit: cubit,
        service: service,
        usesReadium: false,
      );
      await cubit.open();
      return (cubit, service);
    }

    setUp(() {
      database = LinguaPageDatabase(NativeDatabase.memory());
      settings = DriftSettingsRepository(database);
      save = _FakeSave();
      session = ReadAloudSession(save);
    });

    tearDown(() async {
      await session.end();
      await database.close();
    });

    test('follows the reading position and saves it when stopped', () async {
      final (cubit, service) = await start('a');
      expect(session.active, isTrue);
      expect(session.isFor('a'), isTrue);
      expect(session.progress, .1);

      service.position(
        const ReadAloudPosition(progress: .3, locatorJson: 'here'),
      );
      await pumpEventQueue();
      expect(session.progress, .3);
      expect(session.locatorJson, 'here');

      await cubit.stop();
      await pumpEventQueue();
      expect(session.active, isFalse);
      expect(session.book, isNull);
      expect(save.calls, [('a', .3, 'here')]);
    });

    test('releases what closed readers left, except a document a reader '
        'still shows', () async {
      await start('a');
      final released = <String>[];
      session
        ..adopt(() async => released.add('engine'))
        ..adopt(() async => released.add('document'), sharesReader: true)
        ..readerOpened('a');

      await session.end();
      expect(released, ['engine']);
    });

    test('with no reader open, every release runs', () async {
      await start('a');
      final released = <String>[];
      session
        ..readerOpened('a')
        ..readerClosed('a')
        ..adopt(() async => released.add('document'), sharesReader: true);

      await session.end();
      expect(released, ['document']);
    });

    test('shows the share read but saves the reader\'s own count', () async {
      final (cubit, service) = await start('a');
      service.position(
        const ReadAloudPosition(progress: .3, savedProgress: .5),
      );
      await pumpEventQueue();
      expect(session.progress, .3);
      expect(session.savedProgress, .5);

      await cubit.stop();
      await pumpEventQueue();
      expect(save.calls, [('a', .5, null)]);
    });

    test('saves where listening stopped even after an earlier save', () async {
      final (cubit, service) = await start('a');
      service.position(const ReadAloudPosition(progress: .4));
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(save.calls, [('a', .4, null)]);

      await cubit.stop();
      await pumpEventQueue();
      expect(save.calls, [('a', .4, null), ('a', .4, null)]);
    });

    test('starting another book stops the first', () async {
      final (_, first) = await start('a');
      await start('b');
      expect(first.calls, contains('stop'));
      expect(session.isFor('b'), isTrue);
      expect(session.isFor('a'), isFalse);
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
  Stream<ReadAloudRange> get spokenRanges => const Stream.empty();

  final _positions = StreamController<ReadAloudPosition>.broadcast();

  void position(ReadAloudPosition value) => _positions.add(value);

  @override
  Stream<ReadAloudPosition> get positionChanges => _positions.stream;

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

class _FakeSave implements SaveReadingProgressUseCase {
  final calls = <(String, double, String?)>[];

  @override
  Future<void> execute({
    required String bookId,
    required double progress,
    String? readingLocatorJson,
  }) async {
    calls.add((bookId, progress, readingLocatorJson));
  }
}

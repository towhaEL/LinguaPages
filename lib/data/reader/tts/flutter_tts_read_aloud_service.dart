import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:lingua_pages/data/reader/readium/readium_read_aloud_service.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';

/// A sentence of the document with its offsets.
class TextSentence {
  const TextSentence(this.start, this.end, this.text);

  final int start;
  final int end;
  final String text;
}

/// Splits [text] at sentence ends and line breaks, dropping blank runs.
List<TextSentence> splitSentences(String text) => [
  for (final match in RegExp(
    r'[^.!?…\n]+(?:[.!?…]+["”’)\]]*)?',
  ).allMatches(text))
    if (match.group(0)!.trim().isNotEmpty)
      TextSentence(match.start, match.end, match.group(0)!.trim()),
];

/// Read-aloud for the fallback text engines, one sentence at a time through
/// the platform's text-to-speech engine. There is no media notification, so
/// it relies on the app staying alive in the background.
class FlutterTtsReadAloudService implements ReadAloudService {
  FlutterTtsReadAloudService({
    required String text,
    required int Function() startOffset,
    required String? Function(int offset) chapterAt,
    FlutterTts? tts,
  }) : _sentences = splitSentences(text),
       _startOffset = startOffset,
       _chapterAt = chapterAt,
       _tts = tts ?? FlutterTts();

  final List<TextSentence> _sentences;
  final int Function() _startOffset;
  final String? Function(int offset) _chapterAt;
  final FlutterTts _tts;

  final _status = StreamController<ReadAloudStatus>.broadcast();
  final _ranges = StreamController<ReadAloudRange>.broadcast();
  final _chapters = StreamController<String>.broadcast();

  var _index = 0;
  var _running = false;

  /// Set to end the loop once the current sentence is interrupted.
  var _halt = false;

  /// Where to continue after an interrupted sentence (next/previous).
  int? _jumpTo;

  /// Text offset the first sentence is cut at, so reading starts at the top
  /// of the page on screen even mid-sentence.
  int? _startAt;

  @override
  Stream<ReadAloudStatus> get statusChanges => _status.stream;

  @override
  Stream<ReadAloudRange> get spokenRanges => _ranges.stream;

  @override
  Stream<String> get chapterChanges => _chapters.stream;

  @override
  Future<List<ReadAloudVoice>> voices() async {
    final voices = await _tts.getVoices as List<Object?>? ?? const [];
    return [
      for (final voice in voices)
        if (voice
            case {'name': final String name, 'locale': final String locale}
            when voice['network_required'] != '1' &&
                !'${voice['features']}'.contains('notInstalled'))
          ReadAloudVoice(id: name, name: name, language: locale),
    ];
  }

  @override
  Future<void> start(ReadAloudOptions options) async {
    await _tts.awaitSpeakCompletion(true);
    await update(options);
    final from = _startOffset();
    final index = _sentences.indexWhere((sentence) => sentence.end > from);
    _index = index < 0 ? 0 : index;
    _startAt = from;
    unawaited(_run());
  }

  @override
  Future<void> update(ReadAloudOptions options) async {
    // flutter_tts doubles the rate on Android, where 1 is normal speed.
    await _tts.setSpeechRate(options.speed / 2);
    final voiceId = options.voiceId;
    if (voiceId != null) {
      final voice = (await voices()).where((v) => v.id == voiceId).firstOrNull;
      if (voice != null) {
        await _tts.setVoice({'name': voice.id, 'locale': voice.language});
      }
    } else if (options.language != null) {
      await _tts.setLanguage(options.language!);
    }
  }

  @override
  Future<void> pause() async {
    _halt = true;
    await _tts.stop();
    _status.add(ReadAloudStatus.paused);
  }

  @override
  Future<void> resume() async => unawaited(_run());

  @override
  Future<void> stop() async {
    _halt = true;
    await _tts.stop();
    _status.add(ReadAloudStatus.idle);
  }

  @override
  Future<void> next() => _jump(1);

  @override
  Future<void> previous() => _jump(-1);

  @override
  Future<bool> openVoiceSettings() => openSystemVoiceSettings();

  /// [sentence] from [_startAt] on, when reading starts inside it.
  TextSentence _clipped(TextSentence sentence) {
    final from = _startAt;
    if (from == null || from <= sentence.start || from >= sentence.end) {
      return sentence;
    }
    final rest = sentence.text.substring(
      (from - sentence.start).clamp(0, sentence.text.length),
    );
    return TextSentence(from, sentence.end, rest.trim());
  }

  Future<void> _jump(int by) async {
    if (_sentences.isEmpty) return;
    final target = (_index + by).clamp(0, _sentences.length - 1);
    if (_running) {
      _jumpTo = target;
      await _tts.stop();
    } else {
      _index = target;
      final sentence = _sentences[target];
      _ranges.add(ReadAloudRange(sentence.start, sentence.end));
    }
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    _halt = false;
    _status.add(ReadAloudStatus.playing);
    String? chapter;
    while (!_halt && _index < _sentences.length) {
      final sentence = _clipped(_sentences[_index]);
      _startAt = null;
      _ranges.add(ReadAloudRange(sentence.start, sentence.end));
      final current = _chapterAt(sentence.start);
      if (current != null && current != chapter) {
        chapter = current;
        _chapters.add(current);
      }
      await _tts.speak(sentence.text);
      final jump = _jumpTo;
      _jumpTo = null;
      if (jump != null) {
        _index = jump;
      } else if (!_halt) {
        _index++;
      }
    }
    _running = false;
    if (!_halt) _status.add(ReadAloudStatus.idle);
  }
}

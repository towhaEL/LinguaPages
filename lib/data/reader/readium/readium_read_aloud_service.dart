import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter/services.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';

/// Opens Android's text-to-speech settings; false elsewhere.
Future<bool> openSystemVoiceSettings() async {
  try {
    return await const MethodChannel(
          'lingua_pages/text_actions',
        ).invokeMethod<bool>('openTtsSettings') ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Read-aloud for EPUB and PDF through Readium's TTS navigator, which also
/// runs the media notification and lock-screen controls.
class ReadiumReadAloudService implements ReadAloudService {
  ReadiumReadAloudService({
    required Locator? Function() currentLocator,
    FlutterReadium? readium,
  }) : _currentLocator = currentLocator,
       _readium = readium ?? FlutterReadium();

  final FlutterReadium _readium;

  /// The page on screen, so reading starts there rather than at the
  /// chapter's beginning.
  final Locator? Function() _currentLocator;
  var _enabled = false;

  @override
  Stream<ReadAloudStatus> get statusChanges =>
      _readium.onTimebasedPlayerStateChanged.map(
        (state) => switch (state.state) {
          TimebasedState.playing => ReadAloudStatus.playing,
          TimebasedState.loading => ReadAloudStatus.loading,
          TimebasedState.paused => ReadAloudStatus.paused,
          TimebasedState.ended ||
          TimebasedState.failure ||
          TimebasedState.none => ReadAloudStatus.idle,
        },
      );

  @override
  Stream<String> get chapterChanges => _readium.onTimebasedPlayerStateChanged
      .map((state) => state.currentLocator?.href)
      .where((href) => href != null)
      .cast<String>();

  @override
  Future<List<ReadAloudVoice>> voices() async {
    final voices = await _readium.ttsGetAvailableVoices();
    return [
      for (final voice in voices)
        if (!voice.networkRequired)
          ReadAloudVoice(
            id: voice.identifier,
            name: voice.label ?? voice.name,
            language: voice.language,
          ),
    ];
  }

  @override
  Future<void> start(ReadAloudOptions options) async {
    await _readium.ttsEnable(_preferences(options));
    _enabled = true;
    await _applyVoice(options);
    await _readium.play(_currentLocator());
  }

  @override
  Future<void> update(ReadAloudOptions options) async {
    if (!_enabled) return;
    await _readium.ttsSetPreferences(_preferences(options));
    await _applyVoice(options);
  }

  @override
  Future<void> pause() => _readium.pause();

  @override
  Future<void> resume() => _readium.resume();

  @override
  Future<void> stop() async {
    _enabled = false;
    await _readium.stop();
  }

  @override
  Future<void> next() => _readium.next();

  @override
  Future<void> previous() => _readium.previous();

  @override
  Future<bool> openVoiceSettings() => openSystemVoiceSettings();

  // TTSPreferences.voices is honoured on Android only; ttsSetVoice covers iOS.
  Future<void> _applyVoice(ReadAloudOptions options) async {
    final voiceId = options.voiceId;
    if (voiceId != null) await _readium.ttsSetVoice(voiceId, options.language);
  }

  TTSPreferences _preferences(ReadAloudOptions options) {
    final voiceId = options.voiceId;
    final language = options.language;
    return TTSPreferences(
      speed: options.speed,
      voices: voiceId != null && language != null ? {language: voiceId} : {},
      pageBreakBehavior: options.skipPageNumbers
          ? PageBreakBehavior.skip
          : PageBreakBehavior.readAsIs,
    );
  }
}

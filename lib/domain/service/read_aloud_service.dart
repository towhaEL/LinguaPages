enum ReadAloudStatus { idle, loading, playing, paused }

/// A text-to-speech voice installed on the device.
class ReadAloudVoice {
  const ReadAloudVoice({
    required this.id,
    required this.name,
    required this.language,
  });

  final String id;
  final String name;

  /// A BCP 47 tag such as `en-US`.
  final String language;
}

class ReadAloudOptions {
  const ReadAloudOptions({
    this.speed = 1,
    this.voiceId,
    this.language,
    this.skipPageNumbers = true,
  });

  /// 1 is the voice's normal rate.
  final double speed;
  final String? voiceId;

  /// The language [voiceId] is for; null makes it the default voice.
  final String? language;
  final bool skipPageNumbers;
}

/// A stretch of the document's text, by offsets into it.
class ReadAloudRange {
  const ReadAloudRange(this.start, this.end);

  final int start;
  final int end;
}

/// Reads the open book aloud with the device's own voices.
abstract interface class ReadAloudService {
  Stream<ReadAloudStatus> get statusChanges;

  /// The sentence being spoken, for engines that leave highlighting and page
  /// turning to the reader. Readium does both itself and emits nothing.
  Stream<ReadAloudRange> get spokenRanges;

  /// A stable id of the chapter being read, for the end-of-chapter timer.
  Stream<String> get chapterChanges;

  /// Voices that work offline. Network voices are left out: they would send
  /// the book's text to the voice provider.
  Future<List<ReadAloudVoice>> voices();

  /// Starts reading from the current position.
  Future<void> start(ReadAloudOptions options);

  Future<void> update(ReadAloudOptions options);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> next();

  Future<void> previous();

  /// Opens the system screen for installing voices; false if there is none.
  Future<bool> openVoiceSettings();
}

/// The voice to use for [language]: the one saved for it if still
/// installed, else the first voice for the exact language, else one for the
/// same base language (`en` for `en-GB`). Null when none speaks it.
ReadAloudVoice? pickReadAloudVoice(
  List<ReadAloudVoice> voices, {
  required String? language,
  String? savedId,
}) {
  final saved = voices.where((voice) => voice.id == savedId).firstOrNull;
  if (saved != null) return saved;
  if (language == null || language.isEmpty) {
    return voices.firstOrNull;
  }
  String norm(String tag) => tag.toLowerCase().replaceAll('_', '-');
  String base(String tag) => norm(tag).split('-').first;
  final wanted = norm(language);
  return voices.where((voice) => norm(voice.language) == wanted).firstOrNull ??
      voices.where((voice) => base(voice.language) == base(wanted)).firstOrNull;
}

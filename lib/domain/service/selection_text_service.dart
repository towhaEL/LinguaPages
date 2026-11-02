/// An installed app that accepts selected text (Android `PROCESS_TEXT`).
class TextApp {
  const TextApp({required this.id, required this.label});

  final String id;
  final String label;
}

/// Hands selected text to other apps. LinguaPages itself sends nothing.
abstract interface class SelectionTextService {
  Future<void> searchWeb(String text);

  Future<List<TextApp>> textApps();

  Future<void> sendToApp(TextApp app, String text);
}

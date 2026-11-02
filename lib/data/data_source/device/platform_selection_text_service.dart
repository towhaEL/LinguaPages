import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/selection_text_service.dart';
import 'package:url_launcher/url_launcher.dart';

@LazySingleton(as: SelectionTextService)
class PlatformSelectionTextService implements SelectionTextService {
  static const _channel = MethodChannel('lingua_pages/text_actions');

  // Flutter's built-in Android PROCESS_TEXT bridge; empty elsewhere.
  final ProcessTextService _processText = DefaultProcessTextService();

  @override
  Future<void> searchWeb(String text) async {
    try {
      final handled = await _channel.invokeMethod<bool>('webSearch', text);
      if (handled ?? false) return;
    } on MissingPluginException {
      // Not Android: open a search page instead.
    } on PlatformException {
      // Fall through to the search page.
    }
    // shortcut: a fixed engine where the OS has no web-search intent; offer a
    // choice if iOS ships.
    await launchUrl(
      Uri.https('duckduckgo.com', '/', {'q': text}),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<List<TextApp>> textApps() async {
    final actions = await _processText.queryTextActions();
    return [
      for (final action in actions) TextApp(id: action.id, label: action.label),
    ];
  }

  @override
  Future<void> sendToApp(TextApp app, String text) async {
    // Read-only: an app's reply never replaces book text.
    await _processText.processTextAction(app.id, text, true);
  }
}

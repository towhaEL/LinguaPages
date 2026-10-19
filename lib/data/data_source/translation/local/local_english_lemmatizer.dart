import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/lemmatizer.dart';

/// Small deterministic lemmatizer used by the bundled English fixture.
///
/// It deliberately favours stable lookup behavior over linguistic guesses.
/// A full language pack can replace this implementation through the same
/// domain interface.
@LazySingleton(as: Lemmatizer)
class LocalEnglishLemmatizer implements Lemmatizer {
  static const _irregular = {
    'was': 'be',
    'were': 'be',
    'is': 'be',
    'are': 'be',
    'am': 'be',
    'read': 'read',
    'reads': 'read',
    'reading': 'read',
    'readers': 'reader',
  };

  @override
  Future<String> lemmatize({
    required String word,
    required String language,
  }) async {
    final normalized = word.trim().toLowerCase();
    if (normalized.isEmpty || language.toLowerCase() != 'en') {
      return normalized;
    }
    final irregular = _irregular[normalized];
    if (irregular != null) return irregular;

    if (normalized.length > 4 && normalized.endsWith('ies')) {
      return '${normalized.substring(0, normalized.length - 3)}y';
    }
    if (normalized.length > 4 && normalized.endsWith('ing')) {
      final stem = normalized.substring(0, normalized.length - 3);
      final hasDoubledFinalConsonant =
          stem.length > 2 && stem[stem.length - 1] == stem[stem.length - 2];
      return hasDoubledFinalConsonant
          ? stem.substring(0, stem.length - 1)
          : stem;
    }
    if (normalized.length > 3 && normalized.endsWith('ed')) {
      return normalized.substring(0, normalized.length - 2);
    }
    if (normalized.length > 3 && normalized.endsWith('es')) {
      return normalized.substring(0, normalized.length - 2);
    }
    if (normalized.length > 3 && normalized.endsWith('s')) {
      return normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}

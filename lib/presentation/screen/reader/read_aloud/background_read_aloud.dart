import 'package:flutter/foundation.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/data/reader/readium/readium_document_session.dart';
import 'package:lingua_pages/data/reader/readium/readium_read_aloud_service.dart';
import 'package:lingua_pages/data/reader/tts/flutter_tts_read_aloud_service.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_engine_factory.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';

/// Whether [format] is read through Readium rather than a fallback engine.
bool readsWithReadium(DocumentFormat format) {
  if (kIsWeb) return false;
  if (format != DocumentFormat.epub) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// Starts reading [book] aloud from where it was left, without opening the
/// reader; the mini player controls it. Resumes it if it is already being
/// read. False when the book could not be opened or has no text to read.
Future<bool> listenInBackground(BookEntity book) async {
  final session = injector<ReadAloudSession>();
  if (session.isFor(book.id)) {
    final cubit = session.cubit!;
    if (!cubit.state.isPlaying) await cubit.play();
    return true;
  }
  return readsWithReadium(book.format)
      ? _listenWithReadium(book, session)
      : _listenWithEngine(book, session);
}

Future<bool> _listenWithReadium(
  BookEntity book,
  ReadAloudSession session,
) async {
  // Readium holds one document at a time, so another book reading aloud
  // through it stops first.
  await session.end();
  final readium = ReadiumDocumentSession();
  final Publication publication;
  try {
    publication = await readium.open(book.sourceUri);
  } catch (_) {
    await readium.close().catchError((Object _) {});
    return false;
  }
  final locatorJson = book.readingLocatorJson;
  Locator? saved;
  if (locatorJson != null && locatorJson.isNotEmpty) {
    try {
      saved = Locator.fromJsonString(locatorJson);
    } catch (_) {
      // Read from the start instead.
    }
  }
  final service = ReadiumReadAloudService(currentLocator: () => saved);
  final cubit = ReadAloudCubit(
    service,
    injector<SettingsRepository>(),
    language: publication.metadata.languages.firstOrNull ?? book.languageCode,
  );
  await session.begin(
    book: book,
    cubit: cubit,
    service: service,
    usesReadium: true,
  );
  // A reader opened on this book later shows the same document.
  session.adopt(readium.close, sharesReader: true);
  await cubit.open();
  return true;
}

Future<bool> _listenWithEngine(
  BookEntity book,
  ReadAloudSession session,
) async {
  final engine = injector<DocumentEngineFactory>().create(book);
  final DocumentInfo info;
  final List<DocumentTocEntry> contents;
  try {
    info = await engine.open();
    contents = await engine.tableOfContentsEntries();
  } catch (_) {
    await engine.close().catchError((Object _) {});
    return false;
  }
  final text = engine.text;
  if (text.trim().isEmpty) {
    await engine.close().catchError((Object _) {});
    return false;
  }
  final settingsRepository = injector<SettingsRepository>();
  var settings = const SettingsEntity();
  try {
    settings = await settingsRepository.getSettings();
  } catch (_) {
    // Defaults still place reading close enough.
  }
  final pageCount = info.pageCount ?? 1;
  final scrolling =
      settings.readerMode == ReaderMode.continuous &&
      info.layout == DocumentLayout.reflowable;
  // Inverts how the reader saves progress, so listening picks up on the
  // page the book was left at.
  final startOffset = scrolling || pageCount <= 1
      ? (book.progress * text.length).round().clamp(0, text.length)
      : engine.pageStartOffset(
          ((pageCount * book.progress).round() - 1).clamp(0, pageCount - 1),
        );

  String? chapterAt(int offset) {
    String? chapter;
    for (final entry in contents) {
      if (entry.locator case TextLocator(
        offset: final start,
      ) when start <= offset) {
        chapter = entry.title;
      }
    }
    return chapter;
  }

  final service = FlutterTtsReadAloudService(
    text: text,
    startOffset: () => startOffset,
    chapterAt: chapterAt,
    progressAt: (offset) => scrolling || pageCount <= 1
        ? offset / text.length
        : (engine.pageIndexForOffset(offset) + 1) / pageCount,
  );
  final cubit = ReadAloudCubit(
    service,
    settingsRepository,
    language: book.languageCode,
  );
  await session.begin(
    book: book,
    cubit: cubit,
    service: service,
    usesReadium: false,
  );
  session.adopt(engine.close);
  await cubit.open();
  return true;
}

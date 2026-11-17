import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';

/// The one book being read aloud, kept alive across screens so the mini
/// player can follow the user out of the reader and back.
///
/// The reader that starts reading hands over its cubit and engine; when it
/// closes mid-session it hands over whatever must be released later, such as
/// the open document. Reading position is saved here while no reader is.
@lazySingleton
class ReadAloudSession extends ChangeNotifier {
  ReadAloudSession(this._saveReadingProgress);

  static const _saveDebounce = Duration(milliseconds: 800);

  final SaveReadingProgressUseCase _saveReadingProgress;

  BookEntity? _book;
  ReadAloudCubit? _cubit;
  ReadAloudService? _service;
  var _usesReadium = false;
  ReadAloudPosition? _position;
  final _progress = ValueNotifier<double>(0);

  StreamSubscription<ReadAloudState>? _stateSubscription;
  StreamSubscription<ReadAloudPosition>? _positionSubscription;
  final _releases = <({Future<void> Function() release, bool sharesReader})>[];

  /// Readers open per book id, so a document a reader still shows is not
  /// released under it.
  final _openReaders = <String, int>{};

  Timer? _saveTimer;
  ReadAloudPosition? _unsaved;

  BookEntity? get book => _book;
  ReadAloudCubit? get cubit => _cubit;
  ReadAloudService? get service => _service;

  /// Whether reading goes through Readium, which holds one document at a
  /// time for the whole app.
  bool get usesReadium => _usesReadium;

  /// The player is shown.
  bool get active => _cubit?.state.active ?? false;

  /// How far reading has reached, or the book's own progress before the
  /// first sentence.
  double get progress => _progress.value;

  /// [progress] as the reader saves it, to reopen the book at.
  double get savedProgress => _position?.savedProgress ?? progress;

  /// [progress], for widgets that follow only it.
  ValueListenable<double> get progressListenable => _progress;

  /// The engine locator of the sentence being read, to reopen the reader at.
  String? get locatorJson => _position?.locatorJson;

  bool isFor(String bookId) => _cubit != null && _book?.id == bookId;

  /// Starts a session for [book], ending any other first.
  Future<void> begin({
    required BookEntity book,
    required ReadAloudCubit cubit,
    required ReadAloudService service,
    required bool usesReadium,
  }) async {
    if (_cubit != null) await end();
    _book = book;
    _cubit = cubit;
    _service = service;
    _usesReadium = usesReadium;
    _position = null;
    _progress.value = book.progress;
    _stateSubscription = cubit.stream.listen((state) {
      if (!state.active) {
        unawaited(end());
      } else {
        notifyListeners();
      }
    });
    _positionSubscription = service.positionChanges.listen(_onPosition);
    notifyListeners();
  }

  /// Keeps [release] until the session ends. [sharesReader] marks a
  /// document that another reader of the same book may still be showing.
  void adopt(Future<void> Function() release, {bool sharesReader = false}) {
    _releases.add((release: release, sharesReader: sharesReader));
  }

  void readerOpened(String bookId) {
    _openReaders[bookId] = (_openReaders[bookId] ?? 0) + 1;
  }

  void readerClosed(String bookId) {
    final count = (_openReaders[bookId] ?? 1) - 1;
    if (count <= 0) {
      _openReaders.remove(bookId);
    } else {
      _openReaders[bookId] = count;
    }
  }

  /// Stops reading, saves where it got to and releases what readers left.
  Future<void> end() async {
    final cubit = _cubit;
    final book = _book;
    if (cubit == null) return;
    _cubit = null;
    _service = null;
    _book = null;
    await _stateSubscription?.cancel();
    await _positionSubscription?.cancel();
    _stateSubscription = null;
    _positionSubscription = null;
    // Saved again even if already saved: a reader closing mid-session
    // saves its own page over it.
    _unsaved = _position;
    await _flush(book);
    _position = null;
    final readerOpen = book != null && _openReaders.containsKey(book.id);
    final releases = [..._releases];
    _releases.clear();
    notifyListeners();
    await cubit.close();
    for (final entry in releases) {
      if (entry.sharesReader && readerOpen) continue;
      try {
        await entry.release();
      } catch (_) {
        // Nothing more to release it for.
      }
    }
  }

  void _onPosition(ReadAloudPosition position) {
    _position = position;
    _progress.value = position.progress;
    _unsaved = position;
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, () => unawaited(_flush(_book)));
    notifyListeners();
  }

  Future<void> _flush(BookEntity? book) async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final position = _unsaved;
    _unsaved = null;
    if (book == null || position == null) return;
    try {
      await _saveReadingProgress.execute(
        bookId: book.id,
        progress: position.savedProgress ?? position.progress,
        readingLocatorJson: position.locatorJson,
      );
    } catch (_) {
      // The next sentence retries with a newer position.
    }
  }
}

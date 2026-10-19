import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/data/reader/readium/readium_document_session.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/exceptions/vocabulary_limit_exception.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:lingua_pages/domain/service/document_engine_factory.dart';
import 'package:lingua_pages/domain/service/annotation_markdown_exporter.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/domain/use_cases/vocabulary/lookup_word_use_case.dart';
import 'package:lingua_pages/domain/use_cases/vocabulary/save_vocabulary_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

@RoutePage()
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({required this.book, super.key});

  final BookEntity book;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  static const _progressDebounce = Duration(milliseconds: 650);

  late final bool _usesReadium;
  DocumentEngine? _engine;
  late final ReadiumDocumentSession _readiumSession;
  late final SaveReadingProgressUseCase _saveReadingProgress;
  late final BookmarkRepository _bookmarkRepository;
  late final HighlightRepository _highlightRepository;
  late final ReviewRepository _reviewRepository;
  late final LookupWordUseCase _lookupWord;
  late final SaveVocabularyUseCase _saveVocabulary;
  late final SettingsRepository _settingsRepository;

  SettingsEntity _settings = const SettingsEntity();
  DocumentInfo? _info;
  Publication? _publication;
  List<String> _tableOfContents = const [];
  List<DocumentTocEntry> _localTableOfContents = const [];
  List<Link> _readiumTableOfContents = const [];
  final _continuousPageKey = GlobalKey<_ContinuousReflowablePageState>();
  Uint8List? _pageBytes;
  String? _pageText;
  List<Uint8List>? _continuousPages;
  int _pageIndex = 0;
  bool _isOpening = true;
  bool _isRendering = false;
  String? _errorMessage;
  Locator? _currentReadiumLocator;
  var _continuousProgress = 0.0;
  var _isShowingHighlightActions = false;
  Timer? _progressTimer;
  double? _pendingProgress;
  String? _pendingReadingLocatorJson;
  Future<void>? _progressFlush;
  StreamSubscription<ReadiumReaderStatus>? _readiumStatusSubscription;
  StreamSubscription<Locator>? _readiumLocatorSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usesReadium = _shouldUseReadium(widget.book.format);
    _saveReadingProgress = injector<SaveReadingProgressUseCase>();
    _bookmarkRepository = injector<BookmarkRepository>();
    _highlightRepository = injector<HighlightRepository>();
    _reviewRepository = injector<ReviewRepository>();
    _lookupWord = injector<LookupWordUseCase>();
    _saveVocabulary = injector<SaveVocabularyUseCase>();
    _settingsRepository = injector<SettingsRepository>();
    _loadReaderSettings();
    if (_usesReadium) {
      _readiumSession = ReadiumDocumentSession();
      _readiumStatusSubscription = _readiumSession.onStatusChanged.listen(
        _handleReadiumStatus,
      );
      _readiumLocatorSubscription = _readiumSession.onLocatorChanged.listen(
        _handleReadiumLocator,
      );
      _openReadiumDocument();
    } else {
      _engine = injector<DocumentEngineFactory>().create(widget.book);
      _openDocument();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WakelockPlus.disable());
    _progressTimer?.cancel();
    unawaited(_flushPendingProgress());
    unawaited(_readiumStatusSubscription?.cancel());
    unawaited(_readiumLocatorSubscription?.cancel());
    if (_usesReadium) {
      unawaited(_readiumSession.close());
    } else {
      unawaited(_engine?.close());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _progressTimer?.cancel();
      unawaited(_flushPendingProgress());
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final readerPalette = _readerPalette(_settings.readerTheme);

    return Scaffold(
      backgroundColor: readerPalette.background,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_isOpening && (_publication != null || _info != null))
            IconButton(
              onPressed: _showSearch,
              icon: const Icon(Icons.search_rounded),
              tooltip: context.l10n.readerSearch,
            ),
          if (!_isOpening && (_publication != null || _info != null))
            IconButton(
              onPressed: _createBookmark,
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: context.l10n.readerBookmark,
            ),
          if (!_isOpening && (_publication != null || _info != null))
            IconButton(
              onPressed: _showBookmarks,
              icon: const Icon(Icons.bookmarks_outlined),
              tooltip: context.l10n.readerBookmarks,
            ),
          if (!_isOpening && (_publication != null || _info != null))
            IconButton(
              onPressed: _showAnnotations,
              icon: const Icon(Icons.collections_bookmark_outlined),
              tooltip: context.l10n.readerAnnotations,
            ),
          if (!_isOpening && (_publication != null || _info != null))
            IconButton(
              onPressed: _showReaderSettings,
              icon: const Icon(Icons.tune_rounded),
              tooltip: context.l10n.readerSettings,
            ),
          if (!_usesReadium &&
              widget.book.format == DocumentFormat.pdf &&
              !_isOpening &&
              _info?.pageCount != null)
            IconButton(
              onPressed: _showPdfThumbnails,
              icon: const Icon(Icons.view_sidebar_outlined),
              tooltip: context.l10n.readerThumbnails,
            ),
          if (_tableOfContents.isNotEmpty)
            IconButton(
              onPressed: _showTableOfContents,
              icon: const Icon(Icons.list_alt_rounded),
              tooltip: context.l10n.readerContents,
            ),
        ],
      ),
      body: _buildBody(context, info),
      bottomNavigationBar:
          _usesReadium ||
              info == null ||
              _errorMessage != null ||
              (_settings.readerMode == ReaderMode.continuous &&
                  info.layout == DocumentLayout.reflowable)
          ? null
          : _buildPageControls(context, info),
    );
  }

  Widget _buildBody(BuildContext context, DocumentInfo? info) {
    if (_errorMessage != null) {
      return _ReaderError(
        message: _errorMessage!,
        onRetry: _usesReadium ? _openReadiumDocument : _openDocument,
      );
    }

    if (_usesReadium) {
      final publication = _publication;
      if (_isOpening || publication == null) {
        return _buildLoading(context);
      }
      return ReadiumReaderWidget(
        publication: publication,
        initialLocator: _savedLocator,
        loadingWidget: _buildLoading(context),
        selectionActions: [
          SelectionAction(id: 'highlight', title: context.l10n.readerHighlight),
          SelectionAction(id: 'lookup', title: context.l10n.readerLookup),
        ],
        onSelectionAction: _handleReadiumSelectionAction,
      );
    }

    if (_isOpening || info == null) {
      return _buildLoading(context);
    }

    if (info.layout == DocumentLayout.reflowable &&
        _settings.readerMode == ReaderMode.continuous) {
      final pages = _continuousPages;
      if (pages == null) return _buildLoading(context);
      return _ContinuousReflowablePage(
        key: _continuousPageKey,
        pages: pages,
        fontSize: _settings.fontSize,
        lineSpacing: _settings.lineSpacing,
        margin: _settings.margin,
        textAlignment: _settings.readerTextAlignment,
        backgroundColor: _readerPalette(_settings.readerTheme).background,
        textColor: _readerPalette(_settings.readerTheme).text,
        initialProgress: widget.book.progress,
        onProgressChanged: _handleContinuousProgress,
      );
    }

    if (info.layout == DocumentLayout.fixed &&
        info.format == DocumentFormat.pdf &&
        _settings.readerPdfMode == ReaderPdfMode.text) {
      final pageText = _pageText;
      if (pageText == null) return _buildLoading(context);
      return _PdfTextPage(
        text: pageText,
        fontSize: _settings.fontSize,
        lineSpacing: _settings.lineSpacing,
        margin: _settings.margin,
        textAlignment: _settings.readerTextAlignment,
        backgroundColor: _readerPalette(_settings.readerTheme).background,
        textColor: _readerPalette(_settings.readerTheme).text,
        onSelectionChanged: _handleFallbackSelection,
      );
    }

    if (_pageBytes == null) return _buildLoading(context);

    final page = info.layout == DocumentLayout.fixed
        ? _FixedPage(
            bytes: _pageBytes!,
            isRendering: _isRendering,
            backgroundColor: _readerPalette(_settings.readerTheme).background,
            fit: _settings.readerPdfFit,
          )
        : _ReflowablePage(
            bytes: _pageBytes!,
            fontSize: _settings.fontSize,
            lineSpacing: _settings.lineSpacing,
            margin: _settings.margin,
            textAlignment: _settings.readerTextAlignment,
            backgroundColor: _readerPalette(_settings.readerTheme).background,
            textColor: _readerPalette(_settings.readerTheme).text,
            onSelectionChanged: _handleFallbackSelection,
          );
    return Stack(
      children: [
        Positioned.fill(child: page),
        if (!_usesReadium && _settings.readerMode == ReaderMode.paginated)
          Positioned.fill(
            child: _ReaderTapZones(
              previousLabel: context.l10n.readerPreviousPage,
              nextLabel: context.l10n.readerNextPage,
              onPrevious: _pageIndex == 0 || _isRendering
                  ? null
                  : () => _renderPage(_pageIndex - 1),
              onNext:
                  info.pageCount == null ||
                      _pageIndex >= info.pageCount! - 1 ||
                      _isRendering
                  ? null
                  : () => _renderPage(_pageIndex + 1),
            ),
          ),
        if (_isRendering)
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(child: LinearProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(context.l10n.readerLoading),
        ],
      ),
    );
  }

  Widget _buildPageControls(BuildContext context, DocumentInfo info) {
    final pageCount = info.pageCount ?? 1;
    final progress = pageCount <= 1 ? 1.0 : (_pageIndex + 1) / pageCount;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        color: context.colors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progress),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _pageIndex == 0 || _isRendering
                      ? null
                      : () => _renderPage(_pageIndex - 1),
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: context.l10n.readerPreviousPage,
                ),
                Text(context.l10n.readerPageOf(_pageIndex + 1, pageCount)),
                IconButton(
                  onPressed: _pageIndex >= pageCount - 1 || _isRendering
                      ? null
                      : () => _renderPage(_pageIndex + 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: context.l10n.readerNextPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument() async {
    if (mounted) {
      setState(() {
        _isOpening = true;
        _errorMessage = null;
        _info = null;
        _pageBytes = null;
        _pageText = null;
        _continuousPages = null;
        _tableOfContents = const [];
        _localTableOfContents = const [];
      });
    }

    try {
      final info = await _engine!.open();
      final contents = await _engine!.tableOfContentsEntries();
      final pageCount = info.pageCount ?? 1;
      final initialPage = ((pageCount - 1) * widget.book.progress)
          .round()
          .clamp(0, pageCount - 1);
      if (!mounted) return;
      setState(() {
        _info = info;
        _localTableOfContents = contents;
        _tableOfContents = contents.map((entry) => entry.title).toList();
        _pageIndex = initialPage;
        _continuousProgress = widget.book.progress;
        _continuousPages = null;
      });
      if (info.layout == DocumentLayout.reflowable &&
          _settings.readerMode == ReaderMode.continuous) {
        await _renderContinuousPages(pageCount);
      } else {
        await _renderPage(initialPage, saveProgress: false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _renderPage(int pageIndex, {bool saveProgress = true}) async {
    final info = _info;
    if (info == null || _isRendering) return;
    final pageCount = info.pageCount ?? 1;
    if (pageIndex < 0 || pageIndex >= pageCount) return;

    setState(() => _isRendering = true);
    try {
      final isPdfTextMode =
          info.format == DocumentFormat.pdf &&
          _settings.readerPdfMode == ReaderPdfMode.text;
      final bytes = isPdfTextMode ? null : await _engine!.renderPage(pageIndex);
      final pageText = isPdfTextMode
          ? await _engine!.pageText(pageIndex)
          : null;
      if (!mounted) return;
      setState(() {
        _pageIndex = pageIndex;
        _pageBytes = bytes;
        _pageText = pageText;
      });
      if (saveProgress) {
        _queueProgress(
          progress: pageCount <= 1 ? 1 : (pageIndex + 1) / pageCount,
        );
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isRendering = false);
    }
  }

  Future<void> _renderContinuousPages(int pageCount) async {
    final pages = <Uint8List>[];
    for (var index = 0; index < pageCount; index++) {
      final bytes = await _engine!.renderPage(index);
      if (bytes != null) pages.add(bytes);
    }
    if (!mounted) return;
    setState(() => _continuousPages = pages);
  }

  Future<void> _openReadiumDocument() async {
    if (mounted) {
      setState(() {
        _isOpening = true;
        _errorMessage = null;
        _publication = null;
        _readiumTableOfContents = const [];
        _tableOfContents = const [];
        _localTableOfContents = const [];
      });
    }

    try {
      final publication = await _readiumSession.open(widget.book.sourceUri);
      await _readiumSession.applySettings(
        settings: _settings,
        format: widget.book.format,
      );
      final contents = publication.tocFlattened;
      if (!mounted) return;
      setState(() {
        _publication = publication;
        _currentReadiumLocator = _savedLocator;
        _readiumTableOfContents = contents;
        _tableOfContents = contents
            .map((link) => link.title?.trim())
            .map(
              (title) =>
                  title == null || title.isEmpty ? 'Untitled section' : title,
            )
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  void _handleReadiumStatus(ReadiumReaderStatus status) {
    if (!mounted || !status.isError) return;
    setState(() {
      _errorMessage = 'The native reader could not display this book.';
    });
  }

  Future<void> _handleReadiumLocator(Locator locator) async {
    _currentReadiumLocator = locator;
    final totalProgression = locator.locations?.totalProgression;
    final progress = (totalProgression ?? widget.book.progress).clamp(0.0, 1.0);
    _queueProgress(
      progress: progress,
      readingLocatorJson: jsonEncode(locator.toJson()),
    );
  }

  void _queueProgress({required double progress, String? readingLocatorJson}) {
    _pendingProgress = progress.clamp(0.0, 1.0);
    _pendingReadingLocatorJson = readingLocatorJson;
    _progressTimer?.cancel();
    _progressTimer = Timer(_progressDebounce, () {
      unawaited(_flushPendingProgress());
    });
  }

  Future<void> _flushPendingProgress() {
    final activeFlush = _progressFlush;
    if (activeFlush != null) return activeFlush;

    final progress = _pendingProgress;
    if (progress == null) return Future<void>.value();
    final readingLocatorJson = _pendingReadingLocatorJson;
    _pendingProgress = null;
    _pendingReadingLocatorJson = null;

    final flush = _saveReadingProgress
        .execute(
          bookId: widget.book.id,
          progress: progress,
          readingLocatorJson: readingLocatorJson,
        )
        .catchError((_) {
          // A persistence failure must not interrupt reading. A later page or
          // locator event can retry the newest state.
        });
    _progressFlush = flush;
    return flush.whenComplete(() {
      _progressFlush = null;
      if (_pendingProgress != null) {
        unawaited(_flushPendingProgress());
      }
    });
  }

  Future<void> _goToReadiumContents(Link link) async {
    Navigator.of(context).pop();
    try {
      await _readiumSession.goToLocator(link.toLocator());
    } catch (_) {
      // Navigation failures should not take down the open reader.
    }
  }

  Future<void> _goToLocalContents(DocumentTocEntry entry) async {
    Navigator.of(context).pop();
    final locator = entry.locator;
    final engine = _engine;
    final info = _info;
    if (locator == null || engine == null || info == null) return;

    try {
      final pageIndex = await engine.pageIndexForLocator(locator);
      if (pageIndex == null) return;
      if (info.layout == DocumentLayout.reflowable &&
          _settings.readerMode == ReaderMode.continuous) {
        _continuousPageKey.currentState?.jumpToPage(
          pageIndex,
          pageCount: info.pageCount ?? 1,
        );
        return;
      }
      await _renderPage(pageIndex);
    } catch (_) {
      // A stale outline destination should not interrupt reading.
    }
  }

  Future<List<_ReaderSearchHit>> _searchReader(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    if (_usesReadium) {
      final results = await _readiumSession.search(normalizedQuery);
      return results
          .map(
            (result) => _ReaderSearchHit(
              title: result.chapterTitle ?? context.l10n.readerSearchResult,
              snippet: _readiumSnippet(result),
              onSelected: () => _readiumSession.goToLocator(result.locator),
            ),
          )
          .toList(growable: false);
    }

    final engine = _engine;
    if (engine == null) return const [];
    final results = await engine.search(normalizedQuery);
    return results
        .map(
          (result) => _ReaderSearchHit(
            title: result.chapterTitle,
            snippet: result.text,
            onSelected: () => _goToLocalSearchResult(result),
          ),
        )
        .toList(growable: false);
  }

  String? _readiumSnippet(TextSearchResult result) {
    final text = result.locator.text;
    if (text == null) return null;
    return [
      text.before,
      text.highlight,
      text.after,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');
  }

  Future<void> _goToLocalSearchResult(DocumentSearchResult result) async {
    final locator = result.locator;
    final pageIndex = switch (locator) {
      PdfLocator(:final page) => page - 1,
      TextLocator(:final offset) => offset ~/ 2400,
      EpubLocator() => 0,
    };
    await _renderPage(pageIndex);
  }

  Future<void> _showSearch() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ReaderSearchSheet(search: _searchReader),
    );
  }

  Future<void> _createBookmark() async {
    final locator = _currentDocumentLocator;
    if (locator == null) return;

    final bookmark = BookmarkEntity(
      id: 'bookmark-${DateTime.now().microsecondsSinceEpoch}',
      bookId: widget.book.id,
      title: _bookmarkTitle(locator),
      locator: locator,
      createdAt: DateTime.now(),
    );
    try {
      await _bookmarkRepository.create(bookmark);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.readerBookmarkAdded)),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.readerBookmarkFailed)),
        );
    }
  }

  Future<void> _showBookmarks() async {
    try {
      final bookmarks = await _bookmarkRepository.getByBookId(widget.book.id);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _ReaderBookmarksSheet(
          bookmarks: bookmarks,
          onSelected: (bookmark) {
            Navigator.of(context).pop();
            unawaited(_goToBookmark(bookmark));
          },
          onDeleted: (bookmark) => _bookmarkRepository.delete(bookmark.id),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.readerBookmarkFailed)),
      );
    }
  }

  Future<void> _showAnnotations() async {
    try {
      final results = await Future.wait<Object>([
        _bookmarkRepository.getByBookId(widget.book.id),
        _highlightRepository.getByBookId(widget.book.id),
      ]);
      if (!mounted) return;
      final annotations = [
        ...(results[0] as List<BookmarkEntity>).map(_ReaderAnnotation.bookmark),
        ...(results[1] as List<HighlightEntity>).map(
          _ReaderAnnotation.highlight,
        ),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _ReaderAnnotationsSheet(
          annotations: annotations,
          onSelected: (annotation) {
            Navigator.of(context).pop();
            unawaited(_goToDocumentLocator(annotation.locator));
          },
          onDeleted: _deleteAnnotation,
          onEdited: _editHighlight,
          onExport: () async {
            final messenger = ScaffoldMessenger.of(context);
            final copiedMessage = context.l10n.readerExportCopied;
            final markdown = const AnnotationMarkdownExporter().export(
              bookTitle: widget.book.title,
              highlights: results[1] as List<HighlightEntity>,
              bookmarks: results[0] as List<BookmarkEntity>,
            );
            await Clipboard.setData(ClipboardData(text: markdown));
            if (!mounted) return;
            messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.readerAnnotationFailed)),
      );
    }
  }

  Future<void> _deleteAnnotation(_ReaderAnnotation annotation) {
    final bookmark = annotation.bookmark;
    if (bookmark != null) return _bookmarkRepository.delete(bookmark.id);
    return _highlightRepository.delete(annotation.highlight!.id);
  }

  Future<HighlightEntity?> _editHighlight(HighlightEntity highlight) async {
    final controller = TextEditingController(text: highlight.note ?? '');
    var color = highlight.color;
    try {
      final result = await showDialog<HighlightEntity>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(context.l10n.readerEditHighlight),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.selectedText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: context.l10n.readerNote,
                      hintText: context.l10n.readerNoteHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.readerHighlightColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: HighlightColor.values
                        .map(
                          (value) => ChoiceChip(
                            label: Text(_highlightColorLabel(context, value)),
                            selected: color == value,
                            onSelected: (_) => setState(() => color = value),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  highlight.copyWith(
                    color: color,
                    note: controller.text.trim(),
                    clearNote: controller.text.trim().isEmpty,
                    updatedAt: DateTime.now(),
                  ),
                ),
                child: Text(context.l10n.save),
              ),
            ],
          ),
        ),
      );
      if (result == null) return null;
      await _highlightRepository.update(result);
      return result;
    } finally {
      controller.dispose();
    }
  }

  DocumentLocator? get _currentDocumentLocator {
    if (_usesReadium) {
      final locator = _currentReadiumLocator ?? _savedLocator;
      if (locator == null) return null;
      final locatorJson = jsonEncode(locator.toJson());
      if (widget.book.format == DocumentFormat.pdf) {
        return PdfLocator(
          page: locator.locations?.position ?? 1,
          locatorJson: locatorJson,
        );
      }
      return EpubLocator(
        cfi: locator.locations?.partialCfi ?? locator.href,
        locatorJson: locatorJson,
      );
    }

    final info = _info;
    if (info == null) return null;
    if (info.format == DocumentFormat.pdf) {
      return PdfLocator(page: _pageIndex + 1);
    }

    final pageIndex = _settings.readerMode == ReaderMode.continuous
        ? ((_continuousProgress * ((info.pageCount ?? 1) - 1)).round())
        : _pageIndex;
    return TextLocator(offset: pageIndex * 2400);
  }

  String _bookmarkTitle(DocumentLocator locator) {
    return switch (locator) {
      PdfLocator(:final page) => context.l10n.readerBookmarkPage(page),
      TextLocator(:final offset) => context.l10n.readerBookmarkProgress(
        ((offset / 2400) + 1).round(),
      ),
      EpubLocator() => context.l10n.readerBookmarkPosition,
    };
  }

  Future<void> _goToBookmark(BookmarkEntity bookmark) {
    return _goToDocumentLocator(bookmark.locator);
  }

  Future<void> _goToDocumentLocator(DocumentLocator locator) async {
    final nativeLocatorJson = switch (locator) {
      EpubLocator(:final locatorJson) => locatorJson,
      PdfLocator(:final locatorJson) => locatorJson,
      TextLocator() => null,
    };
    if (_usesReadium && nativeLocatorJson != null) {
      final nativeLocator = Locator.fromJsonString(nativeLocatorJson);
      if (nativeLocator != null) {
        try {
          await _readiumSession.goToLocator(nativeLocator);
        } catch (_) {
          // A stale native destination should not interrupt the reader.
        }
      }
      return;
    }

    final info = _info;
    final engine = _engine;
    if (info == null || engine == null) return;
    final pageIndex = switch (locator) {
      PdfLocator(:final page) => page - 1,
      TextLocator(:final offset) => offset ~/ 2400,
      EpubLocator() => 0,
    };
    if (info.layout == DocumentLayout.reflowable &&
        _settings.readerMode == ReaderMode.continuous) {
      _continuousPageKey.currentState?.jumpToPage(
        pageIndex,
        pageCount: info.pageCount ?? 1,
      );
      return;
    }
    await _renderPage(pageIndex);
  }

  Future<void> _handleReadiumSelectionAction(SelectionActionEvent event) async {
    final selectedText = event.selectedText?.trim();
    if (selectedText == null || selectedText.isEmpty) return;
    final locator = _documentLocatorFromReadium(event.locator);
    if (event.actionId == 'highlight') {
      await _saveHighlight(
        selectedText: selectedText,
        locator: locator,
        color: HighlightColor.yellow,
      );
    } else if (event.actionId == 'lookup') {
      await _showLookupSheet(selectedText, locator);
    }
  }

  void _handleFallbackSelection(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    if (selection.isCollapsed || _isShowingHighlightActions) return;
    final info = _info;
    final pageText =
        _pageText ??
        (_pageBytes == null
            ? null
            : utf8.decode(_pageBytes!, allowMalformed: true));
    if (info == null || pageText == null || pageText.isEmpty) return;

    final start = math.min(selection.baseOffset, selection.extentOffset);
    final end = math.max(selection.baseOffset, selection.extentOffset);
    if (start < 0 || end > pageText.length || start == end) return;
    final selectedText = pageText.substring(start, end).trim();
    if (selectedText.isEmpty) return;
    final locator = info.format == DocumentFormat.pdf
        ? PdfLocator(page: _pageIndex + 1, textOffset: start)
        : TextLocator(offset: _pageIndex * 2400 + start);
    unawaited(_showSelectionActionSheet(selectedText, locator));
  }

  Future<void> _showSelectionActionSheet(
    String selectedText,
    DocumentLocator locator,
  ) async {
    _isShowingHighlightActions = true;
    try {
      final action = await showModalBottomSheet<_SelectionAction>(
        context: context,
        showDragHandle: true,
        builder: (context) => const _SelectionActionSheet(),
      );
      if (action == _SelectionAction.highlight) {
        await _showHighlightColorSheet(selectedText, locator);
      } else if (action == _SelectionAction.lookup) {
        await _showLookupSheet(selectedText, locator);
      }
    } finally {
      _isShowingHighlightActions = false;
    }
  }

  Future<void> _showHighlightColorSheet(
    String selectedText,
    DocumentLocator locator,
  ) async {
    _isShowingHighlightActions = true;
    try {
      final color = await showModalBottomSheet<HighlightColor>(
        context: context,
        showDragHandle: true,
        builder: (context) => _HighlightColorSheet(),
      );
      if (color != null) {
        await _saveHighlight(
          selectedText: selectedText,
          locator: locator,
          color: color,
        );
      }
    } finally {
      _isShowingHighlightActions = false;
    }
  }

  Future<void> _showLookupSheet(
    String selectedText,
    DocumentLocator locator,
  ) async {
    final word = _lookupWordFromSelection(selectedText);
    if (word.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ReaderLookupSheet(
        word: word,
        lookup: () => _lookupWord.execute(
          word: word,
          sourceLanguage: _settings.sourceLanguage,
          targetLanguage: _settings.targetLanguage,
        ),
        onSave: (entry) => _saveVocabularyItem(
          word: word,
          selectedText: selectedText,
          locator: locator,
          entry: entry,
        ),
        onHighlight: () => _saveHighlight(
          selectedText: selectedText,
          locator: locator,
          color: HighlightColor.yellow,
        ),
      ),
    );
  }

  String _lookupWordFromSelection(String selectedText) {
    final firstWord = selectedText.trim().split(RegExp(r'\s+')).first;
    return firstWord.replaceAll(
      RegExp(r'^[^\p{L}]+|[^\p{L}]+$', unicode: true),
      '',
    );
  }

  Future<void> _saveVocabularyItem({
    required String word,
    required String selectedText,
    required DocumentLocator locator,
    required DictionaryEntry entry,
  }) async {
    try {
      final item = await _saveVocabulary.execute(
        VocabItemEntity(
          id: 'vocab-${DateTime.now().microsecondsSinceEpoch}',
          word: word,
          lemma: entry.lemma,
          sourceSentence: selectedText,
          translation: entry.translation,
          bookId: widget.book.id,
          locator: locator,
          sourceLanguage: _settings.sourceLanguage,
          targetLanguage: _settings.targetLanguage,
          createdAt: DateTime.now(),
        ),
      );
      await _reviewRepository.createForVocabItem(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.readerWordSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error is VocabularyLimitException
                  ? context.l10n.readerVocabularyLimitReached(error.limit)
                  : context.l10n.readerWordSaveFailed,
            ),
          ),
        );
    }
  }

  Future<void> _saveHighlight({
    required String selectedText,
    required DocumentLocator locator,
    required HighlightColor color,
  }) async {
    final highlight = HighlightEntity(
      id: 'highlight-${DateTime.now().microsecondsSinceEpoch}',
      bookId: widget.book.id,
      selectedText: selectedText,
      locator: locator,
      color: color,
      createdAt: DateTime.now(),
    );
    try {
      await _highlightRepository.create(highlight);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.readerHighlightSaved)),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.readerHighlightFailed)),
        );
    }
  }

  DocumentLocator _documentLocatorFromReadium(Locator locator) {
    final locatorJson = jsonEncode(locator.toJson());
    if (widget.book.format == DocumentFormat.pdf) {
      return PdfLocator(
        page: locator.locations?.position ?? 1,
        locatorJson: locatorJson,
      );
    }
    return EpubLocator(
      cfi: locator.locations?.partialCfi ?? locator.href,
      locatorJson: locatorJson,
    );
  }

  Future<void> _loadReaderSettings() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!mounted) return;
      setState(() => _settings = settings);
      _applyWakeLock(settings.keepScreenAwake);
      if (_usesReadium && _publication != null) {
        await _readiumSession.applySettings(
          settings: settings,
          format: widget.book.format,
        );
      }
    } catch (_) {
      // Default settings keep the reader usable when preferences cannot load.
    }
  }

  void _handleReaderSettingsChanged(SettingsEntity settings) {
    final modeChanged = _settings.readerMode != settings.readerMode;
    final pdfModeChanged = _settings.readerPdfMode != settings.readerPdfMode;
    setState(() => _settings = settings);
    _applyWakeLock(settings.keepScreenAwake);
    unawaited(_persistReaderSettings(settings));
    if (_usesReadium && _publication != null) {
      unawaited(
        _readiumSession.applySettings(
          settings: settings,
          format: widget.book.format,
        ),
      );
    }
    if (!_usesReadium && modeChanged) {
      unawaited(_openDocument());
    } else if (!_usesReadium && pdfModeChanged) {
      unawaited(_renderPage(_pageIndex));
    }
  }

  void _applyWakeLock(bool enabled) {
    unawaited(enabled ? WakelockPlus.enable() : WakelockPlus.disable());
  }

  void _handleContinuousProgress(double progress) {
    _continuousProgress = progress;
    _queueProgress(progress: progress);
  }

  Future<void> _persistReaderSettings(SettingsEntity settings) async {
    try {
      await _settingsRepository.saveSettings(settings);
    } catch (_) {
      // Reading preferences are best effort and should not interrupt reading.
    }
  }

  Future<void> _showReaderSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ReaderSettingsSheet(
        settings: _settings,
        isPdf: widget.book.format == DocumentFormat.pdf,
        isFallbackPdf:
            !_usesReadium && widget.book.format == DocumentFormat.pdf,
        onChanged: _handleReaderSettingsChanged,
      ),
    );
  }

  Future<void> _showPdfThumbnails() async {
    final engine = _engine;
    final pageCount = _info?.pageCount;
    if (engine == null || pageCount == null) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _PdfThumbnailSheet(
        pageCount: pageCount,
        currentPage: _pageIndex,
        renderThumbnail: engine.renderPageThumbnail,
        onSelected: (pageIndex) {
          Navigator.of(context).pop();
          unawaited(_renderPage(pageIndex));
        },
      ),
    );
  }

  Future<void> _showTableOfContents() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    context.l10n.readerContents,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _tableOfContents.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final isReadium = _readiumTableOfContents.isNotEmpty;
                      final localEntry = isReadium
                          ? null
                          : _localTableOfContents[index];
                      return ListTile(
                        leading: Text('${index + 1}'),
                        title: Text(_tableOfContents[index]),
                        onTap: isReadium
                            ? () => _goToReadiumContents(
                                _readiumTableOfContents[index],
                              )
                            : localEntry?.locator == null
                            ? null
                            : () => _goToLocalContents(localEntry!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Locator? get _savedLocator {
    final locatorJson = widget.book.readingLocatorJson;
    if (locatorJson == null || locatorJson.isEmpty) return null;
    return Locator.fromJsonString(locatorJson);
  }

  bool _shouldUseReadium(DocumentFormat format) {
    if (kIsWeb) return false;
    if (format != DocumentFormat.epub && format != DocumentFormat.pdf) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}

class _FixedPage extends StatefulWidget {
  const _FixedPage({
    required this.bytes,
    required this.isRendering,
    required this.backgroundColor,
    required this.fit,
  });

  final Uint8List bytes;
  final bool isRendering;
  final Color backgroundColor;
  final ReaderPdfFit fit;

  @override
  State<_FixedPage> createState() => _FixedPageState();
}

class _FixedPageState extends State<_FixedPage> {
  static const _minScale = 1.0;
  static const _maxScale = 4.0;
  static const _scaleStep = .5;

  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void didUpdateWidget(covariant _FixedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bytes != widget.bytes || oldWidget.fit != widget.fit) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  double get _scale => _transformationController.value.getMaxScaleOnAxis();

  void _setScale(double scale) {
    final nextScale = scale.clamp(_minScale, _maxScale).toDouble();
    setState(() {
      _transformationController.value = Matrix4.diagonal3Values(
        nextScale,
        nextScale,
        1,
      );
    });
  }

  void _zoomIn() => _setScale(_scale + _scaleStep);

  void _zoomOut() => _setScale(_scale - _scaleStep);

  void _resetZoom() => _setScale(_minScale);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minScale,
              maxScale: _maxScale,
              child: Center(
                child: widget.fit == ReaderPdfFit.width
                    ? SizedBox(
                        width: double.infinity,
                        child: Image.memory(
                          widget.bytes,
                          fit: BoxFit.fitWidth,
                          gaplessPlayback: widget.isRendering,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Text('Unable to display this page.'),
                              ),
                        ),
                      )
                    : Image.memory(
                        widget.bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: widget.isRendering,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text('Unable to display this page.'),
                            ),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: .92),
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _zoomIn,
                    icon: const Icon(Icons.add_rounded),
                    tooltip: context.l10n.readerZoomIn,
                  ),
                  IconButton(
                    onPressed: _resetZoom,
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    tooltip: context.l10n.readerResetZoom,
                  ),
                  IconButton(
                    onPressed: _zoomOut,
                    icon: const Icon(Icons.remove_rounded),
                    tooltip: context.l10n.readerZoomOut,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfThumbnailSheet extends StatefulWidget {
  const _PdfThumbnailSheet({
    required this.pageCount,
    required this.currentPage,
    required this.renderThumbnail,
    required this.onSelected,
  });

  final int pageCount;
  final int currentPage;
  final Future<Uint8List?> Function(int pageIndex) renderThumbnail;
  final ValueChanged<int> onSelected;

  @override
  State<_PdfThumbnailSheet> createState() => _PdfThumbnailSheetState();
}

class _PdfThumbnailSheetState extends State<_PdfThumbnailSheet> {
  final Map<int, Future<Uint8List?>> _thumbnailFutures = {};

  Future<Uint8List?> _thumbnailFor(int pageIndex) => _thumbnailFutures
      .putIfAbsent(pageIndex, () => widget.renderThumbnail(pageIndex));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                context.l10n.readerThumbnails,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: .68,
                ),
                itemCount: widget.pageCount,
                itemBuilder: (context, index) {
                  final isSelected = index == widget.currentPage;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => widget.onSelected(index),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: FutureBuilder<Uint8List?>(
                                future: _thumbnailFor(index),
                                builder: (context, snapshot) {
                                  final bytes = snapshot.data;
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    );
                                  }
                                  if (bytes == null) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  return Image.memory(
                                    bytes,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                            child: Text(
                              context.l10n.readerPageOf(
                                index + 1,
                                widget.pageCount,
                              ),
                              style: Theme.of(context).textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinuousReflowablePage extends StatefulWidget {
  const _ContinuousReflowablePage({
    super.key,
    required this.pages,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
    required this.textAlignment,
    required this.backgroundColor,
    required this.textColor,
    required this.initialProgress,
    required this.onProgressChanged,
  });

  final List<Uint8List> pages;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;
  final double initialProgress;
  final ValueChanged<double> onProgressChanged;

  @override
  State<_ContinuousReflowablePage> createState() =>
      _ContinuousReflowablePageState();
}

class _ContinuousReflowablePageState extends State<_ContinuousReflowablePage> {
  late final ScrollController _scrollController;
  var _readyForProgress = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent > 0) {
        _scrollController.jumpTo(
          position.maxScrollExtent * widget.initialProgress.clamp(0.0, 1.0),
        );
      }
      _readyForProgress = true;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_readyForProgress || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final progress = position.maxScrollExtent <= 0
        ? 1.0
        : (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
    widget.onProgressChanged(progress);
  }

  void jumpToPage(int pageIndex, {required int pageCount}) {
    if (!_scrollController.hasClients) return;
    final progress = pageCount <= 1
        ? 0.0
        : (pageIndex / (pageCount - 1)).clamp(0.0, 1.0);
    unawaited(
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent * progress,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: widget.textColor,
      fontSize: widget.fontSize,
      height: widget.lineSpacing,
    );
    return ColoredBox(
      color: widget.backgroundColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          widget.margin,
          widget.margin + 12,
          widget.margin,
          widget.margin * 2.5,
        ),
        itemCount: widget.pages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (context, index) => SelectableText(
          utf8.decode(widget.pages[index], allowMalformed: true),
          textAlign: _readerTextAlign(widget.textAlignment),
          style: textStyle,
        ),
      ),
    );
  }
}

class _PdfTextPage extends StatelessWidget {
  const _PdfTextPage({
    required this.text,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
    required this.textAlignment,
    required this.backgroundColor,
    required this.textColor,
    required this.onSelectionChanged,
  });

  final String text;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;
  final SelectionChangedCallback onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(margin, margin + 12, margin, margin * 2.5),
        child: SelectableText(
          text.isEmpty ? 'No extractable text on this page.' : text,
          onSelectionChanged: onSelectionChanged,
          textAlign: _readerTextAlign(textAlignment),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontSize: fontSize,
            height: lineSpacing,
          ),
        ),
      ),
    );
  }
}

class _ReaderTapZones extends StatelessWidget {
  const _ReaderTapZones({
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final String previousLabel;
  final String nextLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: previousLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onPrevious,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const Spacer(flex: 2),
        Expanded(
          child: Semantics(
            button: true,
            label: nextLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onNext,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReflowablePage extends StatelessWidget {
  const _ReflowablePage({
    required this.bytes,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
    required this.textAlignment,
    required this.backgroundColor,
    required this.textColor,
    required this.onSelectionChanged,
  });

  final Uint8List bytes;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;
  final SelectionChangedCallback onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(margin, margin + 12, margin, margin * 2.5),
        child: SelectableText(
          utf8.decode(bytes, allowMalformed: true),
          onSelectionChanged: onSelectionChanged,
          textAlign: _readerTextAlign(textAlignment),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textColor,
            fontSize: fontSize,
            height: lineSpacing,
          ),
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56),
            const SizedBox(height: 12),
            Text(
              context.l10n.readerOpenError,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderPalette {
  const _ReaderPalette({required this.background, required this.text});

  final Color background;
  final Color text;
}

_ReaderPalette _readerPalette(ReaderTheme theme) => switch (theme) {
  ReaderTheme.light => const _ReaderPalette(
    background: Color(0xFFFFFFFF),
    text: Color(0xFF1A1A1A),
  ),
  ReaderTheme.sepia => const _ReaderPalette(
    background: Color(0xFFF6EFD9),
    text: Color(0xFF4A3B2A),
  ),
  ReaderTheme.dark => const _ReaderPalette(
    background: Color(0xFF121212),
    text: Color(0xFFE9E9E9),
  ),
};

TextAlign _readerTextAlign(ReaderTextAlignment alignment) =>
    switch (alignment) {
      ReaderTextAlignment.left => TextAlign.left,
      ReaderTextAlignment.center => TextAlign.center,
      ReaderTextAlignment.justify => TextAlign.justify,
    };

class _ReaderSettingsSheet extends StatefulWidget {
  const _ReaderSettingsSheet({
    required this.settings,
    required this.isPdf,
    required this.isFallbackPdf,
    required this.onChanged,
  });

  final SettingsEntity settings;
  final bool isPdf;
  final bool isFallbackPdf;
  final ValueChanged<SettingsEntity> onChanged;

  @override
  State<_ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<_ReaderSettingsSheet> {
  late SettingsEntity _settings = widget.settings;

  void _update(SettingsEntity settings) {
    setState(() => _settings = settings);
    widget.onChanged(settings);
  }

  String _themeLabel(BuildContext context, ReaderTheme theme) =>
      switch (theme) {
        ReaderTheme.light => context.l10n.readerThemeLight,
        ReaderTheme.sepia => context.l10n.readerThemeSepia,
        ReaderTheme.dark => context.l10n.readerThemeDark,
      };

  String _alignmentLabel(BuildContext context, ReaderTextAlignment alignment) =>
      switch (alignment) {
        ReaderTextAlignment.left => context.l10n.readerAlignmentLeft,
        ReaderTextAlignment.center => context.l10n.readerAlignmentCenter,
        ReaderTextAlignment.justify => context.l10n.readerAlignmentJustified,
      };

  String _modeLabel(BuildContext context, ReaderMode mode) => switch (mode) {
    ReaderMode.paginated => context.l10n.readerModePaginated,
    ReaderMode.continuous => context.l10n.readerModeContinuous,
  };

  String _pdfFitLabel(BuildContext context, ReaderPdfFit fit) => switch (fit) {
    ReaderPdfFit.page => context.l10n.readerPdfFitPage,
    ReaderPdfFit.width => context.l10n.readerPdfFitWidth,
  };

  String _pdfModeLabel(BuildContext context, ReaderPdfMode mode) =>
      switch (mode) {
        ReaderPdfMode.visual => context.l10n.readerPdfModeVisual,
        ReaderPdfMode.text => context.l10n.readerPdfModeText,
      };

  @override
  Widget build(BuildContext context) {
    final fontSize = _settings.fontSize.clamp(14.0, 28.0).toDouble();
    final lineSpacing = _settings.lineSpacing.clamp(1.2, 2.2).toDouble();
    final margin = _settings.margin.clamp(8.0, 32.0).toDouble();
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .62,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.readerSettings,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.readerTheme,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReaderTheme.values
                    .map(
                      (theme) => ChoiceChip(
                        label: Text(_themeLabel(context, theme)),
                        selected: _settings.readerTheme == theme,
                        onSelected: (_) =>
                            _update(_settings.copyWith(readerTheme: theme)),
                      ),
                    )
                    .toList(growable: false),
              ),
              if (widget.isPdf) ...[
                const SizedBox(height: 20),
                Text(
                  context.l10n.readerPdfFit,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReaderPdfFit.values
                      .map(
                        (fit) => ChoiceChip(
                          label: Text(_pdfFitLabel(context, fit)),
                          selected: _settings.readerPdfFit == fit,
                          onSelected: (_) =>
                              _update(_settings.copyWith(readerPdfFit: fit)),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              if (widget.isFallbackPdf) ...[
                const SizedBox(height: 20),
                Text(
                  context.l10n.readerPdfMode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReaderPdfMode.values
                      .map(
                        (mode) => ChoiceChip(
                          label: Text(_pdfModeLabel(context, mode)),
                          selected: _settings.readerPdfMode == mode,
                          onSelected: (_) =>
                              _update(_settings.copyWith(readerPdfMode: mode)),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _settings.keepScreenAwake,
                onChanged: (value) =>
                    _update(_settings.copyWith(keepScreenAwake: value)),
                title: Text(context.l10n.readerKeepScreenAwake),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.readerMode,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReaderMode.values
                    .map(
                      (mode) => ChoiceChip(
                        label: Text(_modeLabel(context, mode)),
                        selected: _settings.readerMode == mode,
                        onSelected: (_) =>
                            _update(_settings.copyWith(readerMode: mode)),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.readerAlignment,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReaderTextAlignment.values
                    .map(
                      (alignment) => ChoiceChip(
                        label: Text(_alignmentLabel(context, alignment)),
                        selected: _settings.readerTextAlignment == alignment,
                        onSelected: (_) => _update(
                          _settings.copyWith(readerTextAlignment: alignment),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 20),
              _ReaderSlider(
                label: context.l10n.readerTextSize,
                valueLabel: '${fontSize.round()} px',
                value: fontSize,
                min: 14,
                max: 28,
                divisions: 14,
                onChanged: (value) =>
                    _update(_settings.copyWith(fontSize: value)),
              ),
              _ReaderSlider(
                label: context.l10n.readerLineSpacing,
                valueLabel: lineSpacing.toStringAsFixed(1),
                value: lineSpacing,
                min: 1.2,
                max: 2.2,
                divisions: 10,
                onChanged: (value) =>
                    _update(_settings.copyWith(lineSpacing: value)),
              ),
              _ReaderSlider(
                label: context.l10n.readerMargins,
                valueLabel: '${margin.round()} px',
                value: margin,
                min: 8,
                max: 32,
                divisions: 12,
                onChanged: (value) =>
                    _update(_settings.copyWith(margin: value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderSlider extends StatelessWidget {
  const _ReaderSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(valueLabel)],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ReaderSearchHit {
  const _ReaderSearchHit({
    required this.title,
    required this.onSelected,
    this.snippet,
  });

  final String title;
  final String? snippet;
  final Future<void> Function() onSelected;
}

class _ReaderBookmarksSheet extends StatefulWidget {
  const _ReaderBookmarksSheet({
    required this.bookmarks,
    required this.onSelected,
    required this.onDeleted,
  });

  final List<BookmarkEntity> bookmarks;
  final ValueChanged<BookmarkEntity> onSelected;
  final Future<void> Function(BookmarkEntity bookmark) onDeleted;

  @override
  State<_ReaderBookmarksSheet> createState() => _ReaderBookmarksSheetState();
}

enum _SelectionAction { highlight, lookup }

class _SelectionActionSheet extends StatelessWidget {
  const _SelectionActionSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.highlight_outlined),
            title: Text(context.l10n.readerHighlight),
            onTap: () => Navigator.of(context).pop(_SelectionAction.highlight),
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text(context.l10n.readerLookup),
            onTap: () => Navigator.of(context).pop(_SelectionAction.lookup),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ReaderLookupSheet extends StatefulWidget {
  const _ReaderLookupSheet({
    required this.word,
    required this.lookup,
    required this.onSave,
    required this.onHighlight,
  });

  final String word;
  final Future<DictionaryEntry?> Function() lookup;
  final Future<void> Function(DictionaryEntry entry) onSave;
  final Future<void> Function() onHighlight;

  @override
  State<_ReaderLookupSheet> createState() => _ReaderLookupSheetState();
}

class _ReaderLookupSheetState extends State<_ReaderLookupSheet> {
  late final Future<DictionaryEntry?> _entryFuture = widget.lookup();

  Future<void> _copy(DictionaryEntry entry) async {
    await Clipboard.setData(
      ClipboardData(text: '${entry.lemma}: ${entry.translation}'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.readerWordCopied)));
  }

  Future<void> _save(DictionaryEntry entry) async {
    await widget.onSave(entry);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _highlight() async {
    await widget.onHighlight();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .48,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: FutureBuilder<DictionaryEntry?>(
            future: _entryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.readerLookupFor(widget.word),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text(context.l10n.readerLookupFailed));
              }
              final entry = snapshot.data;
              if (entry == null) {
                return Center(child: Text(context.l10n.readerNoTranslation));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.readerLookupFor(widget.word),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    entry.translation,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (entry.partOfSpeech != null) ...[
                    const SizedBox(height: 4),
                    Text(entry.partOfSpeech!),
                  ],
                  if (entry.example != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      entry.example!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copy(entry),
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(context.l10n.readerCopy),
                      ),
                      OutlinedButton.icon(
                        onPressed: _highlight,
                        icon: const Icon(Icons.highlight_outlined),
                        label: Text(context.l10n.readerHighlight),
                      ),
                      FilledButton.icon(
                        onPressed: () => _save(entry),
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(context.l10n.readerSaveWord),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HighlightColorSheet extends StatelessWidget {
  const _HighlightColorSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.readerHighlightColor,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HighlightColor.values
                  .map(
                    (color) => ChoiceChip(
                      label: Text(_highlightColorLabel(context, color)),
                      avatar: CircleAvatar(
                        backgroundColor: _highlightColor(color),
                      ),
                      selected: false,
                      onSelected: (_) => Navigator.of(context).pop(color),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderAnnotation {
  const _ReaderAnnotation.bookmark(BookmarkEntity value)
    : bookmark = value,
      highlight = null;

  const _ReaderAnnotation.highlight(HighlightEntity value)
    : bookmark = null,
      highlight = value;

  final BookmarkEntity? bookmark;
  final HighlightEntity? highlight;

  String get id => bookmark?.id ?? highlight!.id;
  DateTime get createdAt => bookmark?.createdAt ?? highlight!.createdAt;
  DocumentLocator get locator => bookmark?.locator ?? highlight!.locator;
  String get title => bookmark?.title ?? highlight!.selectedText;
  bool get isHighlight => highlight != null;
}

class _ReaderAnnotationsSheet extends StatefulWidget {
  const _ReaderAnnotationsSheet({
    required this.annotations,
    required this.onSelected,
    required this.onDeleted,
    required this.onEdited,
    required this.onExport,
  });

  final List<_ReaderAnnotation> annotations;
  final ValueChanged<_ReaderAnnotation> onSelected;
  final Future<void> Function(_ReaderAnnotation annotation) onDeleted;
  final Future<HighlightEntity?> Function(HighlightEntity highlight) onEdited;
  final Future<void> Function() onExport;

  @override
  State<_ReaderAnnotationsSheet> createState() =>
      _ReaderAnnotationsSheetState();
}

class _ReaderAnnotationsSheetState extends State<_ReaderAnnotationsSheet> {
  late final List<_ReaderAnnotation> _annotations = [...widget.annotations];
  String? _busyId;

  Future<void> _delete(_ReaderAnnotation annotation) async {
    setState(() => _busyId = annotation.id);
    try {
      await widget.onDeleted(annotation);
      if (!mounted) return;
      setState(() {
        _annotations.removeWhere((item) => item.id == annotation.id);
        _busyId = null;
      });
    } catch (_) {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _edit(_ReaderAnnotation annotation) async {
    final highlight = annotation.highlight;
    if (highlight == null) return;
    setState(() => _busyId = annotation.id);
    try {
      final updated = await widget.onEdited(highlight);
      if (!mounted) return;
      if (updated != null) {
        final index = _annotations.indexWhere(
          (item) => item.id == annotation.id,
        );
        if (index >= 0) {
          setState(() {
            _annotations[index] = _ReaderAnnotation.highlight(updated);
            _busyId = null;
          });
        }
      } else {
        setState(() => _busyId = null);
      }
    } catch (_) {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.readerAnnotations,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onExport,
                    icon: const Icon(Icons.copy_all_outlined),
                    tooltip: context.l10n.readerExportAnnotations,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _annotations.isEmpty
                  ? Center(child: Text(context.l10n.readerAnnotationEmpty))
                  : ListView.separated(
                      itemCount: _annotations.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final annotation = _annotations[index];
                        final isBusy = _busyId == annotation.id;
                        return ListTile(
                          leading: Icon(
                            annotation.isHighlight
                                ? Icons.highlight_outlined
                                : Icons.bookmark_outline_rounded,
                          ),
                          title: Text(
                            annotation.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            annotation.highlight?.note ??
                                (annotation.isHighlight
                                    ? context.l10n.readerHighlight
                                    : context.l10n.readerBookmark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: isBusy
                              ? null
                              : () => widget.onSelected(annotation),
                          trailing: isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (annotation.isHighlight)
                                      IconButton(
                                        onPressed: () => _edit(annotation),
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip:
                                            context.l10n.readerEditHighlight,
                                      ),
                                    IconButton(
                                      onPressed: () => _delete(annotation),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                      tooltip:
                                          context.l10n.readerDeleteAnnotation,
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _highlightColorLabel(BuildContext context, HighlightColor color) =>
    switch (color) {
      HighlightColor.yellow => context.l10n.readerHighlightYellow,
      HighlightColor.green => context.l10n.readerHighlightGreen,
      HighlightColor.blue => context.l10n.readerHighlightBlue,
      HighlightColor.pink => context.l10n.readerHighlightPink,
    };

Color _highlightColor(HighlightColor color) => switch (color) {
  HighlightColor.yellow => const Color(0xFFFFD54F),
  HighlightColor.green => const Color(0xFF81C784),
  HighlightColor.blue => const Color(0xFF64B5F6),
  HighlightColor.pink => const Color(0xFFF48FB1),
};

class _ReaderBookmarksSheetState extends State<_ReaderBookmarksSheet> {
  late final List<BookmarkEntity> _bookmarks = [...widget.bookmarks];
  String? _deletingId;

  Future<void> _delete(BookmarkEntity bookmark) async {
    setState(() => _deletingId = bookmark.id);
    try {
      await widget.onDeleted(bookmark);
      if (!mounted) return;
      setState(() {
        _bookmarks.removeWhere((item) => item.id == bookmark.id);
        _deletingId = null;
      });
    } catch (_) {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                context.l10n.readerBookmarks,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: _bookmarks.isEmpty
                  ? Center(child: Text(context.l10n.readerBookmarkEmpty))
                  : ListView.separated(
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        final isDeleting = _deletingId == bookmark.id;
                        return ListTile(
                          leading: const Icon(Icons.bookmark_outline_rounded),
                          title: Text(bookmark.title),
                          subtitle: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatShortDate(bookmark.createdAt),
                          ),
                          onTap: isDeleting
                              ? null
                              : () => widget.onSelected(bookmark),
                          trailing: IconButton(
                            onPressed: isDeleting
                                ? null
                                : () => _delete(bookmark),
                            icon: isDeleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline_rounded),
                            tooltip: context.l10n.readerBookmarkDelete,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderSearchSheet extends StatefulWidget {
  const _ReaderSearchSheet({required this.search});

  final Future<List<_ReaderSearchHit>> Function(String query) search;

  @override
  State<_ReaderSearchSheet> createState() => _ReaderSearchSheetState();
}

class _ReaderSearchSheetState extends State<_ReaderSearchSheet> {
  final _queryController = TextEditingController();
  List<_ReaderSearchHit> _results = const [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final results = await widget.search(query);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _errorMessage = context.l10n.readerSearchFailed;
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                context.l10n.readerSearch,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: context.l10n.readerSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: _isSearching ? null : _search,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    tooltip: context.l10n.readerSearch,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _results.isEmpty
                  ? Center(child: Text(context.l10n.readerSearchNoResults))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: const Icon(Icons.find_in_page_outlined),
                          title: Text(
                            result.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: result.snippet == null
                              ? null
                              : Text(
                                  result.snippet!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          onTap: () async {
                            await result.onSelected();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/data/reader/readium/readium_document_session.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:lingua_pages/domain/service/document_engine_factory.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
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
  late final SettingsRepository _settingsRepository;

  SettingsEntity _settings = const SettingsEntity();
  DocumentInfo? _info;
  Publication? _publication;
  List<String> _tableOfContents = const [];
  List<DocumentTocEntry> _localTableOfContents = const [];
  List<Link> _readiumTableOfContents = const [];
  final _continuousPageKey = GlobalKey<_ContinuousReflowablePageState>();
  Uint8List? _pageBytes;
  List<Uint8List>? _continuousPages;
  int _pageIndex = 0;
  bool _isOpening = true;
  bool _isRendering = false;
  String? _errorMessage;
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
          );
    return Stack(
      children: [
        Positioned.fill(child: page),
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
      final bytes = await _engine!.renderPage(pageIndex);
      if (!mounted) return;
      setState(() {
        _pageIndex = pageIndex;
        _pageBytes = bytes;
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

  Future<void> _loadReaderSettings() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!mounted) return;
      setState(() => _settings = settings);
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
    setState(() => _settings = settings);
    unawaited(_persistReaderSettings(settings));
    if (_usesReadium && _publication != null) {
      unawaited(
        _readiumSession.applySettings(
          settings: settings,
          format: widget.book.format,
        ),
      );
    }
    if (!_usesReadium && modeChanged) unawaited(_openDocument());
  }

  void _handleContinuousProgress(double progress) {
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

class _ReflowablePage extends StatelessWidget {
  const _ReflowablePage({
    required this.bytes,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
    required this.textAlignment,
    required this.backgroundColor,
    required this.textColor,
  });

  final Uint8List bytes;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(margin, margin + 12, margin, margin * 2.5),
        child: SelectableText(
          utf8.decode(bytes, allowMalformed: true),
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
    required this.onChanged,
  });

  final SettingsEntity settings;
  final bool isPdf;
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

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/data/reader/readium/readium_document_session.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:lingua_pages/domain/service/document_engine_factory.dart';
import 'package:lingua_pages/domain/service/screen_brightness_service.dart';
import 'package:lingua_pages/domain/service/volume_key_service.dart';
import 'package:lingua_pages/domain/service/annotation_markdown_exporter.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/screen/premium/widgets/premium_paywall_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/highlight_editor_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/marked_text.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_chrome.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_tap_zones.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';
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
  late final SettingsRepository _settingsRepository;
  late final PremiumCubit _premium;

  /// Saved settings. May hold premium items the user no longer has.
  SettingsEntity _settings = const SettingsEntity();

  /// The settings sheet's live choice, including a premium preview, while
  /// the sheet is open.
  SettingsEntity? _sheetSettings;
  StreamSubscription<PremiumState>? _premiumSubscription;

  /// This book's highlights, drawn on the page by every renderer.
  List<HighlightEntity> _highlights = const [];
  var _readiumReady = false;

  /// Top and bottom bars. Readium toggles this on a centre tap and hides it
  /// on a page turn; the fallback pages do the same through their gestures.
  final _chromeVisible = ValueNotifier<bool>(true);
  double? _readiumProgress;
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
  Timer? _progressTimer;
  double? _pendingProgress;
  String? _pendingReadingLocatorJson;
  Future<void>? _progressFlush;
  StreamSubscription<ReadiumReaderStatus>? _readiumStatusSubscription;
  StreamSubscription<Locator>? _readiumLocatorSubscription;
  late final VolumeKeyService _volumeKeys;
  late final ScreenBrightnessService _brightness;
  StreamSubscription<PageTurn>? _pageTurnSubscription;

  /// The edge-swipe brightness, once the reader has set one.
  double? _readerBrightness;
  bool _adjustingBrightness = false;

  /// Screen settings this reader changed and must undo on exit.
  bool _changedSystemUi = false;
  bool _changedOrientation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usesReadium = _shouldUseReadium(widget.book.format);
    _saveReadingProgress = injector<SaveReadingProgressUseCase>();
    _bookmarkRepository = injector<BookmarkRepository>();
    _highlightRepository = injector<HighlightRepository>();
    _settingsRepository = injector<SettingsRepository>();
    _premium = injector<PremiumCubit>();
    _volumeKeys = injector<VolumeKeyService>();
    _brightness = injector<ScreenBrightnessService>();
    _pageTurnSubscription = _volumeKeys.pageTurns.listen(_turnPage);
    _chromeVisible.addListener(_rebuild);
    _premiumSubscription = _premium.stream.listen((_) {
      if (!mounted) return;
      final previous = _display;
      setState(() {});
      _applyDisplay(previous);
    });
    _loadReaderSettings();
    unawaited(_loadHighlights());
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
    unawaited(_premiumSubscription?.cancel());
    unawaited(_pageTurnSubscription?.cancel());
    unawaited(_volumeKeys.setEnabled(enabled: false));
    if (_readerBrightness != null) unawaited(_brightness.reset());
    if (_changedSystemUi) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        ),
      );
    }
    if (_changedOrientation) {
      unawaited(SystemChrome.setPreferredOrientations(const []));
    }
    _chromeVisible.dispose();
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

  /// What the page shows: the sheet's live choice while it is open,
  /// otherwise the saved settings with locked premium items swapped for free
  /// ones.
  SettingsEntity get _display =>
      _sheetSettings ??
      AppearanceCatalog.effective(_settings, premium: _premium.state.unlocked);

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _hideChrome() => _chromeVisible.value = false;

  void _toggleChrome() => _chromeVisible.value = !_chromeVisible.value;

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final theme = _display.readerTheme;
    final ready = !_isOpening && (_publication != null || info != null);
    final chromeVisible = _chromeVisible.value || !ready;
    // Status bar icons follow whatever is behind them.
    final darkBehindStatusBar = chromeVisible || theme.isDarkPage;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkBehindStatusBar
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Color(theme.backgroundArgb),
        body: Stack(
          children: [
            Positioned.fill(child: SafeArea(child: _buildBody(context, info))),
            if (ready && _errorMessage == null && !chromeVisible)
              ..._pageOverlays(context, info),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ReaderChromeSlot(
                visible: chromeVisible,
                edge: VerticalDirection.up,
                child: ReaderTopBar(
                  title: widget.book.title,
                  action: ready
                      ? IconButton(
                          onPressed: _createBookmark,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          tooltip: context.l10n.readerBookmark,
                        )
                      : null,
                ),
              ),
            ),
            if (ready && _errorMessage == null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ReaderChromeSlot(
                  visible: chromeVisible,
                  edge: VerticalDirection.down,
                  child: _buildBottomBar(context, info),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Paged fallback books turn pages with buttons and count pages.
  bool _isPaged(DocumentInfo? info) =>
      !_usesReadium &&
      info != null &&
      info.pageCount != null &&
      !(_display.readerMode == ReaderMode.continuous &&
          info.layout == DocumentLayout.reflowable);

  double _currentProgress(DocumentInfo? info) {
    if (_usesReadium) return _readiumProgress ?? widget.book.progress;
    if (!_isPaged(info)) return _continuousProgress;
    final pageCount = info!.pageCount!;
    return pageCount <= 1 ? 1.0 : (_pageIndex + 1) / pageCount;
  }

  /// The quiet position label shown on the page while the chrome is hidden.
  String? _progressCaption(BuildContext context, DocumentInfo? info) {
    final l10n = context.l10n;
    final percent = l10n.libraryProgressPercent(
      (_currentProgress(info) * 100).round(),
    );
    return switch (_display.readerProgressDisplay) {
      ReaderProgressDisplay.none => null,
      ReaderProgressDisplay.percent => percent,
      ReaderProgressDisplay.page when _isPaged(info) => l10n.readerPageOf(
        _pageIndex + 1,
        info!.pageCount!,
      ),
      // The native reader reports a position, not a page count.
      ReaderProgressDisplay.page =>
        _currentReadiumLocator?.locations?.position?.toString() ?? percent,
    };
  }

  /// Progress caption, corner shortcuts and the brightness strip, shown on
  /// the page while the chrome is hidden.
  List<Widget> _pageOverlays(BuildContext context, DocumentInfo? info) {
    final l10n = context.l10n;
    final ink = Color(_display.readerTheme.textArgb);
    final caption = _progressCaption(context, info);
    Widget corner(String label, VoidCallback onTap) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.square(dimension: 56),
      ),
    );
    return [
      if (caption != null)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          // A page-coloured strip, so the caption never sits on a text line.
          child: IgnorePointer(
            child: ColoredBox(
              color: Color(_display.readerTheme.backgroundArgb),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ink.withValues(alpha: .6),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      if (_display.cornerShortcuts) ...[
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: corner(l10n.readerCornerTheme, _toggleDarkPage),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(child: corner(l10n.readerBookmark, _createBookmark)),
        ),
      ],
      if (_display.edgeBrightness)
        Positioned(
          left: 0,
          top: 72,
          bottom: 72,
          width: 24,
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) => unawaited(_startBrightnessDrag()),
              onVerticalDragUpdate: (details) =>
                  _updateBrightness(details, constraints.maxHeight),
              onVerticalDragEnd: (_) =>
                  setState(() => _adjustingBrightness = false),
              onVerticalDragCancel: () =>
                  setState(() => _adjustingBrightness = false),
            ),
          ),
        ),
      if (_adjustingBrightness && _readerBrightness != null)
        Center(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.brightness_6_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.libraryProgressPercent(
                        (_readerBrightness! * 100).round(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildBottomBar(BuildContext context, DocumentInfo? info) {
    final l10n = context.l10n;
    final pageCount = info?.pageCount;
    // Paged fallback books turn pages with buttons and show "Page n of m".
    final paged =
        !_usesReadium &&
        info != null &&
        pageCount != null &&
        !(_display.readerMode == ReaderMode.continuous &&
            info.layout == DocumentLayout.reflowable);
    final continuous = !_usesReadium && !paged;
    final progress = _currentProgress(info);

    return ReaderBottomBar(
      progress: progress,
      bandColor: context.bands.forFormat(widget.book.format),
      positionLabel: paged
          ? l10n.readerPageOf(_pageIndex + 1, pageCount)
          : l10n.libraryProgressPercent((progress * 100).round()),
      previousLabel: paged ? l10n.readerPreviousPage : null,
      nextLabel: paged ? l10n.readerNextPage : null,
      onPrevious: paged && _pageIndex > 0 && !_isRendering
          ? () => _renderPage(_pageIndex - 1)
          : null,
      onNext: paged && _pageIndex < pageCount - 1 && !_isRendering
          ? () => _renderPage(_pageIndex + 1)
          : null,
      tools: [
        ReaderTool(
          icon: Icons.toc_rounded,
          label: l10n.readerToolContents,
          onPressed: _tableOfContents.isEmpty ? null : _showTableOfContents,
        ),
        ReaderTool(
          icon: Icons.search_rounded,
          label: l10n.readerToolSearch,
          onPressed: _showSearch,
        ),
        ReaderTool(
          icon: Icons.sticky_note_2_outlined,
          label: l10n.readerToolNotes,
          onPressed: _showAnnotations,
        ),
        ReaderTool(
          icon: Icons.text_format_rounded,
          label: l10n.readerToolAppearance,
          onPressed: _showReaderSettings,
        ),
        if (!_usesReadium &&
            widget.book.format == DocumentFormat.pdf &&
            !continuous)
          ReaderTool(
            icon: Icons.view_module_outlined,
            label: l10n.readerToolPages,
            onPressed: _showPdfThumbnails,
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DocumentInfo? info) {
    if (_errorMessage != null) {
      return _ReaderError(
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
        fontFamilyDeclarations: ReadiumDocumentSession.fontFamilies,
        shouldShowControls: _chromeVisible,
        goBackwardSemanticLabel: context.l10n.readerPreviousPage,
        goForwardSemanticLabel: context.l10n.readerNextPage,
        toggleShowControlsSemanticLabel: context.l10n.readerToggleControls,
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
        _display.readerMode == ReaderMode.continuous) {
      final pages = _continuousPages;
      if (pages == null) return _buildLoading(context);
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            _hideChrome();
          } else if (notification.direction == ScrollDirection.forward) {
            _chromeVisible.value = true;
          }
          return false;
        },
        child: _ContinuousReflowablePage(
          key: _continuousPageKey,
          pages: pages,
          fontSize: _display.fontSize,
          lineSpacing: _display.lineSpacing,
          margin: _display.margin,
          textAlignment: _display.readerTextAlignment,
          backgroundColor: Color(_display.readerTheme.backgroundArgb),
          textColor: Color(_display.readerTheme.textArgb),
          fontFamily: _display.readerFont.family,
          textTweaks: _textTweaks,
          darkPage: _display.readerTheme.isDarkPage,
          marksForPage: _textPageMarks,
          onSelectionAction: _handleFallbackSelectionAction,
          initialProgress: widget.book.progress,
          onProgressChanged: _handleContinuousProgress,
        ),
      );
    }

    if (info.layout == DocumentLayout.fixed &&
        info.format == DocumentFormat.pdf &&
        _display.readerPdfMode == ReaderPdfMode.text) {
      final pageText = _pageText;
      if (pageText == null) return _buildLoading(context);
      return _PdfTextPage(
        text: pageText,
        fontSize: _display.fontSize,
        lineSpacing: _display.lineSpacing,
        margin: _display.margin,
        textAlignment: _display.readerTextAlignment,
        backgroundColor: Color(_display.readerTheme.backgroundArgb),
        textColor: Color(_display.readerTheme.textArgb),
        fontFamily: _display.readerFont.family,
        textTweaks: _textTweaks,
        darkPage: _display.readerTheme.isDarkPage,
        marks: _pdfTextPageMarks(_pageIndex),
        onSelectionAction: (selection, action) =>
            _handleFallbackSelectionAction(
              _pageIndex,
              pageText,
              selection,
              action,
            ),
      );
    }

    if (_pageBytes == null) return _buildLoading(context);

    final page = info.layout == DocumentLayout.fixed
        ? _FixedPage(
            bytes: _pageBytes!,
            isRendering: _isRendering,
            backgroundColor: Color(_display.readerTheme.backgroundArgb),
            fit: _display.readerPdfFit,
            colorFilter: _display.readerTheme.isDarkPage
                ? _pageColorFilter(_display.readerImageFilter)
                : null,
          )
        : _ReflowablePage(
            bytes: _pageBytes!,
            fontSize: _display.fontSize,
            lineSpacing: _display.lineSpacing,
            margin: _display.margin,
            textAlignment: _display.readerTextAlignment,
            backgroundColor: Color(_display.readerTheme.backgroundArgb),
            textColor: Color(_display.readerTheme.textArgb),
            fontFamily: _display.readerFont.family,
            textTweaks: _textTweaks,
            darkPage: _display.readerTheme.isDarkPage,
            marks: _textPageMarks(_pageIndex),
            onSelectionAction: (selection, action) =>
                _handleFallbackSelectionAction(
                  _pageIndex,
                  utf8.decode(_pageBytes!, allowMalformed: true),
                  selection,
                  action,
                ),
          );
    return Stack(
      children: [
        Positioned.fill(child: page),
        if (!_usesReadium && _display.readerMode == ReaderMode.paginated)
          Positioned.fill(
            child: ReaderTapZonesOverlay(
              scheme: _display.readerTapZones,
              previousLabel: context.l10n.readerPreviousPage,
              nextLabel: context.l10n.readerNextPage,
              onToggleControls: _toggleChrome,
              onPrevious: _pageIndex == 0 || _isRendering
                  ? null
                  : () {
                      _hideChrome();
                      unawaited(_renderPage(_pageIndex - 1));
                    },
              onNext:
                  info.pageCount == null ||
                      _pageIndex >= info.pageCount! - 1 ||
                      _isRendering
                  ? null
                  : () {
                      _hideChrome();
                      unawaited(_renderPage(_pageIndex + 1));
                    },
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
    final theme = _display.readerTheme;
    // Drawn on the page so opening a book does not flash the chrome colour.
    return ColoredBox(
      color: Color(theme.backgroundArgb),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.bands.forFormat(widget.book.format),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.readerLoading,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Color(theme.textArgb)),
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
      // Paged progress is saved as (page + 1) / pageCount; invert that.
      final initialPage = ((pageCount * widget.book.progress).round() - 1)
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
        settings: _display,
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
    if (!mounted) return;
    if (status == ReadiumReaderStatus.ready && !_readiumReady) {
      _readiumReady = true;
      _drawReadiumHighlights();
    }
    if (!status.isError) return;
    setState(() => _errorMessage = context.l10n.readerOpenErrorBody);
  }

  Future<void> _handleReadiumLocator(Locator locator) async {
    _currentReadiumLocator = locator;
    final totalProgression = locator.locations?.totalProgression;
    final progress = (totalProgression ?? widget.book.progress).clamp(0.0, 1.0);
    if (mounted) setState(() => _readiumProgress = progress);
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
    // The parts are contiguous text, so they join without spaces. Only the
    // end of the preceding text is kept, so the match shows within the
    // snippet's three lines.
    var before = (text.before ?? '').replaceAll(RegExp(r'\s+'), ' ');
    if (before.length > 60) {
      final cut = before.indexOf(' ', before.length - 60);
      before = '…${before.substring(cut < 0 ? before.length - 60 : cut)}';
    }
    final snippet = '$before${text.highlight ?? ''}${text.after ?? ''}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return snippet.isEmpty ? null : snippet;
  }

  Future<void> _goToLocalSearchResult(DocumentSearchResult result) async {
    final locator = result.locator;
    final pageIndex = switch (locator) {
      PdfLocator(:final page) => page - 1,
      TextLocator(:final offset) => _engine?.pageIndexForOffset(offset) ?? 0,
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

  Future<void> _showAnnotations() async {
    try {
      final (bookmarks, highlights) = await (
        _bookmarkRepository.getByBookId(widget.book.id),
        _highlightRepository.getByBookId(widget.book.id),
      ).wait;
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) => NotesSheet(
          notes: [
            ...bookmarks.map(ReaderNote.bookmark),
            ...highlights.map(ReaderNote.highlight),
          ],
          onSelected: (note) {
            Navigator.of(sheetContext).pop();
            unawaited(_goToDocumentLocator(note.locator));
          },
          onDeleted: _deleteNote,
          onEdited: _editHighlight,
          onExport: (highlights, bookmarks) async {
            final messenger = ScaffoldMessenger.of(context);
            final copiedMessage = context.l10n.readerExportCopied;
            await Clipboard.setData(
              ClipboardData(text: _annotationMarkdown(highlights, bookmarks)),
            );
            if (!mounted) return;
            messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
          },
          onShare: (highlights, bookmarks, origin) async {
            await SharePlus.instance.share(
              ShareParams(
                text: _annotationMarkdown(highlights, bookmarks),
                subject: widget.book.title,
                sharePositionOrigin: origin,
              ),
            );
          },
        ),
      );
      // Notes, colours or deletions may have changed in the sheet.
      await _loadHighlights();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.readerAnnotationFailed)),
      );
    }
  }

  String _annotationMarkdown(
    List<HighlightEntity> highlights,
    List<BookmarkEntity> bookmarks,
  ) => const AnnotationMarkdownExporter().export(
    bookTitle: widget.book.title,
    highlights: highlights,
    bookmarks: bookmarks,
  );

  Future<void> _deleteNote(ReaderNote note) {
    final bookmark = note.bookmark;
    if (bookmark != null) return _bookmarkRepository.delete(bookmark.id);
    return _highlightRepository.delete(note.highlight!.id);
  }

  Future<HighlightEntity?> _editHighlight(HighlightEntity highlight) async {
    final choice = await showHighlightEditor(
      context,
      quote: highlight.selectedText,
      darkPage: _display.readerTheme.isDarkPage,
      initial: (color: highlight.color, note: highlight.note),
    );
    if (choice == null) return null;
    final updated = highlight.copyWith(
      color: choice.color,
      note: choice.note,
      clearNote: choice.note == null,
      updatedAt: DateTime.now(),
    );
    await _highlightRepository.update(updated);
    return updated;
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
    return TextLocator(offset: _engine?.pageStartOffset(pageIndex) ?? 0);
  }

  TextStyle get _textTweaks => TextStyle(
    letterSpacing: _display.letterSpacing * _display.fontSize,
    wordSpacing: _display.wordSpacing * _display.fontSize,
    fontWeight: _display.fontWeight == 1
        ? null
        : FontWeight.values[((_display.fontWeight * 4).round() - 1).clamp(
            0,
            FontWeight.values.length - 1,
          )],
  );

  String _bookmarkTitle(DocumentLocator locator) {
    return switch (locator) {
      PdfLocator(:final page) => context.l10n.readerBookmarkPage(page),
      TextLocator(:final offset) => context.l10n.readerBookmarkProgress(
        (_engine?.pageIndexForOffset(offset) ?? 0) + 1,
      ),
      // Readium locators usually carry the chapter title.
      EpubLocator() =>
        _currentReadiumLocator?.title?.trim().isNotEmpty == true
            ? _currentReadiumLocator!.title!.trim()
            : context.l10n.readerBookmarkUntitled,
    };
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
      TextLocator(:final offset) => _engine?.pageIndexForOffset(offset) ?? 0,
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
      await _showHighlightColorSheet(selectedText, locator);
    } else if (event.actionId == 'lookup') {
      await _showLookupSheet(selectedText, locator);
    }
  }

  /// Highlight or Look up chosen from a fallback page's selection toolbar.
  void _handleFallbackSelectionAction(
    int pageIndex,
    String pageText,
    TextSelection selection,
    _SelectionAction action,
  ) {
    final start = math.min(selection.baseOffset, selection.extentOffset);
    final end = math.max(selection.baseOffset, selection.extentOffset);
    if (start < 0 || end > pageText.length || start == end) return;
    final selectedText = pageText.substring(start, end).trim();
    if (selectedText.isEmpty) return;
    final locator = widget.book.format == DocumentFormat.pdf
        ? PdfLocator(page: pageIndex + 1, textOffset: start)
        : TextLocator(
            offset: (_engine?.pageStartOffset(pageIndex) ?? 0) + start,
          );
    unawaited(switch (action) {
      _SelectionAction.highlight => _showHighlightColorSheet(
        selectedText,
        locator,
      ),
      _SelectionAction.lookup => _showLookupSheet(selectedText, locator),
    });
  }

  Future<void> _showHighlightColorSheet(
    String selectedText,
    DocumentLocator locator,
  ) async {
    final choice = await showHighlightEditor(
      context,
      quote: selectedText,
      darkPage: _display.readerTheme.isDarkPage,
    );
    if (choice != null) {
      await _saveHighlight(
        selectedText: selectedText,
        locator: locator,
        color: choice.color,
        note: choice.note,
      );
    }
  }

  Future<void> _showLookupSheet(
    String selectedText,
    DocumentLocator locator,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DictionaryLookupSheet(
        selectedText: selectedText,
        onHighlight: () => _showHighlightColorSheet(selectedText, locator),
      ),
    );
  }

  Future<void> _saveHighlight({
    required String selectedText,
    required DocumentLocator locator,
    required HighlightColor color,
    String? note,
  }) async {
    final highlight = HighlightEntity(
      id: 'highlight-${DateTime.now().microsecondsSinceEpoch}',
      bookId: widget.book.id,
      selectedText: selectedText,
      locator: locator,
      color: color,
      note: note,
      createdAt: DateTime.now(),
    );
    try {
      await _highlightRepository.create(highlight);
      if (!mounted) return;
      setState(() => _highlights = [..._highlights, highlight]);
      _drawReadiumHighlights();
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

  Future<void> _loadHighlights() async {
    try {
      final highlights = await _highlightRepository.getByBookId(widget.book.id);
      if (!mounted) return;
      setState(() => _highlights = highlights);
      _drawReadiumHighlights();
    } catch (_) {
      // The book stays readable; highlights reappear on the next open.
    }
  }

  void _drawReadiumHighlights() {
    if (!_usesReadium || !_readiumReady) return;
    unawaited(
      _readiumSession
          .applyHighlights(_highlights, theme: _display.readerTheme)
          .catchError((Object _) {}),
    );
  }

  /// Highlights on fallback text page [pageIndex], relative to that page.
  List<PageMark> _textPageMarks(int pageIndex) => [
    for (final highlight in _highlights)
      if (highlight.locator case TextLocator(
        :final offset,
      ) when _engine?.pageIndexForOffset(offset) == pageIndex)
        PageMark(
          start: offset - _engine!.pageStartOffset(pageIndex),
          text: highlight.selectedText,
          color: highlight.color,
        ),
  ];

  List<PageMark> _pdfTextPageMarks(int pageIndex) => [
    for (final highlight in _highlights)
      if (highlight.locator case PdfLocator(
        :final page,
        :final textOffset?,
      ) when page == pageIndex + 1)
        PageMark(
          start: textOffset,
          text: highlight.selectedText,
          color: highlight.color,
        ),
  ];

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
      _applyScreenSettings(settings);
      if (_usesReadium && _publication != null) {
        await _readiumSession.applySettings(
          settings: _display,
          format: widget.book.format,
        );
      }
    } catch (_) {
      // Default settings keep the reader usable when preferences cannot load.
    }
  }

  void _handleReaderSettingsChanged(SettingsEntity settings) {
    final previous = _display;
    // A previewed premium item shows on the page but is not saved.
    final saved = AppearanceCatalog.persistable(
      settings,
      saved: _settings,
      premium: _premium.state.unlocked,
    );
    setState(() {
      _settings = saved;
      _sheetSettings = settings;
    });
    _applyWakeLock(settings.keepScreenAwake);
    unawaited(_persistReaderSettings(saved));
    _applyDisplay(previous);
  }

  /// Pushes [_display] to the active renderer after it changed from
  /// [previous].
  void _applyDisplay(SettingsEntity previous) {
    final display = _display;
    if (_usesReadium && _publication != null) {
      unawaited(
        _readiumSession.applySettings(
          settings: display,
          format: widget.book.format,
        ),
      );
      if (previous.readerTheme.isDarkPage != display.readerTheme.isDarkPage) {
        _drawReadiumHighlights();
      }
    }
    if (!_usesReadium && previous.readerMode != display.readerMode) {
      unawaited(_openDocument());
    } else if (!_usesReadium &&
        previous.readerPdfMode != display.readerPdfMode) {
      unawaited(_renderPage(_pageIndex));
    }
  }

  /// Volume keys, full screen and orientation, set once when the reader
  /// opens; only what differs from the app's normal state is touched.
  void _applyScreenSettings(SettingsEntity settings) {
    unawaited(_volumeKeys.setEnabled(enabled: settings.volumeKeyPaging));
    if (settings.fullScreenReading) {
      _changedSystemUi = true;
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    }
    final orientations = switch (settings.readerOrientation) {
      ReaderOrientation.auto => null,
      ReaderOrientation.portrait => [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      ReaderOrientation.landscape => [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    };
    if (orientations != null) {
      _changedOrientation = true;
      unawaited(SystemChrome.setPreferredOrientations(orientations));
    }
  }

  /// One page forward or back, for the volume keys.
  void _turnPage(PageTurn turn) {
    final forward = turn == PageTurn.next;
    if (_usesReadium) {
      if (_publication == null) return;
      unawaited(
        forward ? _readiumSession.goForward() : _readiumSession.goBackward(),
      );
      return;
    }
    final info = _info;
    if (info == null || _isRendering) return;
    final pageCount = info.pageCount ?? 1;
    if (info.layout == DocumentLayout.reflowable &&
        _settings.readerMode == ReaderMode.continuous) {
      final current = (_continuousProgress * (pageCount - 1)).round();
      _continuousPageKey.currentState?.jumpToPage(
        (current + (forward ? 1 : -1)).clamp(0, pageCount - 1),
        pageCount: pageCount,
      );
      return;
    }
    final target = _pageIndex + (forward ? 1 : -1);
    if (target < 0 || target >= pageCount) return;
    _hideChrome();
    unawaited(_renderPage(target));
  }

  /// Switches the page between the light and dark reading themes.
  void _toggleDarkPage() {
    final previous = _display;
    final next = _settings.copyWith(
      readerTheme: previous.readerTheme.isDarkPage
          ? ReaderTheme.light
          : ReaderTheme.dark,
    );
    setState(() => _settings = next);
    unawaited(_persistReaderSettings(next));
    _applyDisplay(previous);
  }

  Future<void> _startBrightnessDrag() async {
    setState(() => _adjustingBrightness = true);
    try {
      _readerBrightness ??= await _brightness.current();
    } catch (_) {
      _readerBrightness ??= .5;
    }
  }

  void _updateBrightness(DragUpdateDetails details, double height) {
    final current = _readerBrightness;
    if (current == null || height <= 0) return;
    // A full-height swipe covers the whole range; up is brighter.
    final next = (current - details.delta.dy / height).clamp(.02, 1.0);
    setState(() => _readerBrightness = next);
    unawaited(_brightness.set(next).catchError((Object _) {}));
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
        settings: _display,
        isPdf: widget.book.format == DocumentFormat.pdf,
        isFallbackPdf:
            !_usesReadium && widget.book.format == DocumentFormat.pdf,
        usesReadium: _usesReadium,
        onChanged: _handleReaderSettingsChanged,
      ),
    );
    if (!mounted) return;
    // Closing the sheet ends any premium preview.
    final previous = _display;
    setState(() => _sheetSettings = null);
    _applyDisplay(previous);
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
                    style: _sheetTitleStyle(context),
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
                      final current =
                          isReadium &&
                          _isCurrentChapter(_readiumTableOfContents[index]);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        selected: current,
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

  /// Whether [link] is the chapter the reader is in. Only decided when
  /// exactly one entry points at the current file: books that keep every
  /// chapter in one file cannot be told apart by path.
  bool _isCurrentChapter(Link link) {
    final current = (_currentReadiumLocator ?? _savedLocator)?.href;
    if (current == null) return false;
    String path(String href) => href.split('#').first;
    final currentPath = path(current);
    if (path(link.href) != currentPath) return false;
    return _readiumTableOfContents
            .where((entry) => path(entry.href) == currentPath)
            .length ==
        1;
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
    this.colorFilter,
  });

  final Uint8List bytes;
  final bool isRendering;
  final Color backgroundColor;
  final ReaderPdfFit fit;

  /// Dims or inverts the rendered page on dark reading themes.
  final ColorFilter? colorFilter;

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

  Widget _filtered(Widget page) {
    final filter = widget.colorFilter;
    return filter == null
        ? page
        : ColorFiltered(colorFilter: filter, child: page);
  }

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
                child: _filtered(
                  widget.fit == ReaderPdfFit.width
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
                style: _sheetTitleStyle(context),
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
    required this.fontFamily,
    required this.textTweaks,
    required this.darkPage,
    required this.marksForPage,
    required this.onSelectionAction,
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
  final String? fontFamily;

  /// Letter/word spacing and weight from the reader settings.
  final TextStyle textTweaks;
  final bool darkPage;
  final List<PageMark> Function(int pageIndex) marksForPage;
  final void Function(
    int pageIndex,
    String pageText,
    TextSelection selection,
    _SelectionAction action,
  )
  onSelectionAction;
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
    final textStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(
          color: widget.textColor,
          fontFamily: widget.fontFamily,
          fontSize: widget.fontSize,
          height: widget.lineSpacing,
        )
        .merge(widget.textTweaks);
    return ColoredBox(
      color: widget.backgroundColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          widget.margin,
          widget.margin + 12 + readerTopBarHeight,
          widget.margin,
          widget.margin * 2.5 + readerBottomBarHeight,
        ),
        itemCount: widget.pages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final pageText = utf8.decode(
            widget.pages[index],
            allowMalformed: true,
          );
          return SelectableText.rich(
            markedText(
              pageText,
              widget.marksForPage(index),
              darkPage: widget.darkPage,
            ),
            contextMenuBuilder: _readerContextMenu(
              (selection, action) =>
                  widget.onSelectionAction(index, pageText, selection, action),
            ),
            textAlign: _readerTextAlign(widget.textAlignment),
            style: textStyle,
          );
        },
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
    required this.fontFamily,
    required this.textTweaks,
    required this.darkPage,
    required this.marks,
    required this.onSelectionAction,
  });

  final String text;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;
  final String? fontFamily;

  /// Letter/word spacing and weight from the reader settings.
  final TextStyle textTweaks;
  final bool darkPage;
  final List<PageMark> marks;
  final void Function(TextSelection, _SelectionAction) onSelectionAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        // The bars overlay the page, so the text starts below the top bar and
        // can scroll clear of the bottom bar.
        padding: EdgeInsets.fromLTRB(
          margin,
          margin + 12 + readerTopBarHeight,
          margin,
          margin * 2.5 + readerBottomBarHeight,
        ),
        child: SelectableText.rich(
          markedText(
            text.isEmpty ? 'No extractable text on this page.' : text,
            marks,
            darkPage: darkPage,
          ),
          contextMenuBuilder: _readerContextMenu(onSelectionAction),
          textAlign: _readerTextAlign(textAlignment),
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(
                color: textColor,
                fontFamily: fontFamily,
                fontSize: fontSize,
                height: lineSpacing,
              )
              .merge(textTweaks),
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
    required this.fontFamily,
    required this.textTweaks,
    required this.darkPage,
    required this.marks,
    required this.onSelectionAction,
  });

  final Uint8List bytes;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment textAlignment;
  final Color backgroundColor;
  final Color textColor;
  final String? fontFamily;

  /// Letter/word spacing and weight from the reader settings.
  final TextStyle textTweaks;
  final bool darkPage;
  final List<PageMark> marks;
  final void Function(TextSelection, _SelectionAction) onSelectionAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        // The bars overlay the page, so the text starts below the top bar and
        // can scroll clear of the bottom bar.
        padding: EdgeInsets.fromLTRB(
          margin,
          margin + 12 + readerTopBarHeight,
          margin,
          margin * 2.5 + readerBottomBarHeight,
        ),
        child: SelectableText.rich(
          markedText(
            utf8.decode(bytes, allowMalformed: true),
            marks,
            darkPage: darkPage,
          ),
          contextMenuBuilder: _readerContextMenu(onSelectionAction),
          textAlign: _readerTextAlign(textAlignment),
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(
                color: textColor,
                fontFamily: fontFamily,
                fontSize: fontSize,
                height: lineSpacing,
              )
              .merge(textTweaks),
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Shown on the chrome's ink, not the page theme, so it reads the same on
    // every reading theme.
    return ColoredBox(
      color: context.colors.background,
      child: Center(
        child: SingleChildScrollView(
          child: StateView(
            icon: Icons.error_outline_rounded,
            iconColor: context.colors.error,
            title: context.l10n.readerOpenError,
            body: context.l10n.readerOpenErrorBody,
            action: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ),
        ),
      ),
    );
  }
}

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
    required this.usesReadium,
    required this.onChanged,
  });

  final SettingsEntity settings;
  final bool isPdf;
  final bool isFallbackPdf;

  /// The native Readium reader is showing the book; some layout settings
  /// only exist there.
  final bool usesReadium;
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
        ReaderTheme.twilight => context.l10n.readerThemeTwilight,
        ReaderTheme.nightContrast => context.l10n.readerThemeNightContrast,
        ReaderTheme.sepiaContrast => context.l10n.readerThemeSepiaContrast,
        ReaderTheme.sage => context.l10n.readerThemeSage,
      };

  String _fontLabel(BuildContext context, ReaderFont font) => switch (font) {
    ReaderFont.original => context.l10n.readerFontOriginal,
    ReaderFont.serif => context.l10n.readerFontSerif,
    ReaderFont.sans => context.l10n.readerFontSans,
    // Font names are proper nouns and stay untranslated.
    _ => font.family!,
  };

  String _presetLabel(BuildContext context, ReaderStylePresetId id) =>
      switch (id) {
        ReaderStylePresetId.standard => context.l10n.readerStyleStandard,
        ReaderStylePresetId.classic => context.l10n.readerStyleClassic,
        ReaderStylePresetId.airy => context.l10n.readerStyleAiry,
        ReaderStylePresetId.compact => context.l10n.readerStyleCompact,
      };

  /// A choice chip that shows a lock on premium items the user can still
  /// pick: picking one previews it until the sheet closes.
  Widget _chip({
    required String label,
    required bool selected,
    required bool locked,
    required VoidCallback onSelected,
    String? fontFamily,
  }) => ChoiceChip(
    avatar: locked ? const Icon(Icons.lock_outline_rounded, size: 16) : null,
    label: Text(label, style: TextStyle(fontFamily: fontFamily)),
    tooltip: locked ? context.l10n.readerPremiumLocked : null,
    selected: selected,
    onSelected: (_) => onSelected(),
  );

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

  Widget _choices<T>({
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T value) label,
    required SettingsEntity Function(T value) apply,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(title, style: _sheetSectionStyle(context)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(label(value)),
              selected: selected == value,
              onSelected: (_) => _update(apply(value)),
            ),
        ],
      ),
    ],
  );

  /// A slider whose lowest value means "keep the book's own setting".
  Widget _bookSlider({
    required String label,
    required double value,
    required double max,
    required int divisions,
    required String Function(double value) format,
    required SettingsEntity Function(double value) apply,
  }) {
    final clamped = value.clamp(0.0, max).toDouble();
    return _ReaderSlider(
      label: label,
      valueLabel: clamped == 0
          ? context.l10n.readerBookDefault
          : format(clamped),
      value: clamped,
      min: 0,
      max: max,
      divisions: divisions,
      onChanged: (value) => _update(apply(value)),
    );
  }

  /// Typography and layout settings, shown only where the active engine
  /// applies them.
  List<Widget> _comfortControls(BuildContext context) {
    final l10n = context.l10n;
    final nativeEpub = widget.usesReadium && !widget.isPdf;
    final weight = _settings.fontWeight.clamp(.5, 2.0).toDouble();
    return [
      if (!widget.isPdf) ...[
        const SizedBox(height: 20),
        Text(l10n.readerTextSection, style: _sheetSectionStyle(context)),
        const SizedBox(height: 8),
        _ReaderSlider(
          label: l10n.readerFontWeight,
          valueLabel: weight == 1
              ? l10n.readerBookDefault
              : '${(weight * 400).round()}',
          value: weight,
          min: .5,
          max: 2,
          divisions: 6,
          onChanged: (value) => _update(_settings.copyWith(fontWeight: value)),
        ),
        _bookSlider(
          label: l10n.readerLetterSpacing,
          value: _settings.letterSpacing,
          max: .5,
          divisions: 10,
          format: (value) => '${value.toStringAsFixed(2)} em',
          apply: (value) => _settings.copyWith(letterSpacing: value),
        ),
        _bookSlider(
          label: l10n.readerWordSpacing,
          value: _settings.wordSpacing,
          max: 1,
          divisions: 10,
          format: (value) => value.toStringAsFixed(1),
          apply: (value) => _settings.copyWith(wordSpacing: value),
        ),
      ],
      if (nativeEpub) ...[
        _bookSlider(
          label: l10n.readerParagraphSpacing,
          value: _settings.paragraphSpacing,
          max: 2,
          divisions: 8,
          format: (value) => value.toStringAsFixed(2),
          apply: (value) => _settings.copyWith(paragraphSpacing: value),
        ),
        _bookSlider(
          label: l10n.readerParagraphIndent,
          value: _settings.paragraphIndent,
          max: 3,
          divisions: 6,
          format: (value) => value.toStringAsFixed(1),
          apply: (value) => _settings.copyWith(paragraphIndent: value),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _settings.hyphenation,
          onChanged: (value) => _update(_settings.copyWith(hyphenation: value)),
          title: Text(l10n.readerHyphenation),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _settings.publisherStyles,
          onChanged: (value) =>
              _update(_settings.copyWith(publisherStyles: value)),
          title: Text(l10n.readerPublisherStyles),
          subtitle: Text(l10n.readerPublisherStylesHint),
        ),
      ],
      if (widget.usesReadium) ...[
        const SizedBox(height: 4),
        Text(l10n.readerLayoutSection, style: _sheetTitleStyle(context)),
        _choices(
          title: l10n.readerColumns,
          values: ReaderColumns.values,
          selected: _settings.readerColumns,
          label: (value) => switch (value) {
            ReaderColumns.auto => l10n.readerColumnsAuto,
            ReaderColumns.one => l10n.readerColumnsOne,
            ReaderColumns.two => l10n.readerColumnsTwo,
          },
          apply: (value) => _settings.copyWith(readerColumns: value),
        ),
        _choices(
          title: l10n.readerDirection,
          // Vertical writing only exists for reflowable text.
          values: [
            for (final value in ReaderDirection.values)
              if (!widget.isPdf || value != ReaderDirection.vertical) value,
          ],
          selected: _settings.readerDirection,
          label: (value) => switch (value) {
            ReaderDirection.book => l10n.readerDirectionBook,
            ReaderDirection.leftToRight => l10n.readerDirectionLtr,
            ReaderDirection.rightToLeft => l10n.readerDirectionRtl,
            ReaderDirection.vertical => l10n.readerDirectionVertical,
          },
          apply: (value) => _settings.copyWith(readerDirection: value),
        ),
      ],
      if (nativeEpub || widget.isFallbackPdf)
        _choices(
          title: l10n.readerImageFilter,
          values: ReaderImageFilter.values,
          selected: _settings.readerImageFilter,
          label: (value) => switch (value) {
            ReaderImageFilter.none => l10n.readerImageFilterNone,
            ReaderImageFilter.dim => l10n.readerImageFilterDim,
            ReaderImageFilter.invert => l10n.readerImageFilterInvert,
          },
          apply: (value) => _settings.copyWith(readerImageFilter: value),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Unlocking from the preview banner keeps what is being previewed.
    return BlocConsumer<PremiumCubit, PremiumState>(
      listenWhen: (previous, current) => !previous.unlocked && current.unlocked,
      listener: (_, _) => widget.onChanged(_settings),
      buildWhen: (previous, current) => previous.unlocked != current.unlocked,
      builder: (context, premium) => _buildSheet(context, premium.unlocked),
    );
  }

  Widget _buildSheet(BuildContext context, bool unlocked) {
    final previewing = !unlocked && AppearanceCatalog.usesPremium(_settings);
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
                context.l10n.readerToolAppearance,
                style: _sheetTitleStyle(context),
              ),
              if (previewing) ...[
                const SizedBox(height: 12),
                _PremiumPreviewBanner(
                  onUnlock: () => showPremiumPaywall(context),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                context.l10n.readerTheme,
                style: _sheetSectionStyle(context),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  for (final theme in ReaderTheme.values)
                    _ThemeSwatch(
                      theme: theme,
                      label: _themeLabel(context, theme),
                      selected: _settings.readerTheme == theme,
                      locked: theme.isPremium && !unlocked,
                      onSelected: () =>
                          _update(_settings.copyWith(readerTheme: theme)),
                    ),
                ],
              ),
              if (!widget.isPdf) ...[
                const SizedBox(height: 20),
                Text(
                  context.l10n.readerFont,
                  style: _sheetSectionStyle(context),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final font in ReaderFont.values)
                      _chip(
                        label: _fontLabel(context, font),
                        fontFamily: font.family,
                        selected: _settings.readerFont == font,
                        locked: font.isPremium && !unlocked,
                        onSelected: () =>
                            _update(_settings.copyWith(readerFont: font)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.readerStyle,
                  style: _sheetSectionStyle(context),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in AppearanceCatalog.presets)
                      _chip(
                        label: _presetLabel(context, preset.id),
                        fontFamily: preset.font.family,
                        selected: preset.matches(_settings),
                        locked: preset.isPremium && !unlocked,
                        onSelected: () => _update(preset.applyTo(_settings)),
                      ),
                  ],
                ),
              ],
              if (widget.isPdf) ...[
                const SizedBox(height: 20),
                Text(
                  context.l10n.readerPdfFit,
                  style: _sheetSectionStyle(context),
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
                  style: _sheetSectionStyle(context),
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
              Text(context.l10n.readerMode, style: _sheetSectionStyle(context)),
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
                style: _sheetSectionStyle(context),
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
              ..._comfortControls(context),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rendered page under [filter]: dimmed to 70 % or colour-inverted.
ColorFilter? _pageColorFilter(ReaderImageFilter filter) => switch (filter) {
  ReaderImageFilter.none => null,
  ReaderImageFilter.dim => const ColorFilter.matrix([
    .7, 0, 0, 0, 0, //
    0, .7, 0, 0, 0, //
    0, 0, .7, 0, 0, //
    0, 0, 0, 1, 0, //
  ]),
  ReaderImageFilter.invert => const ColorFilter.matrix([
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ]),
};

/// Sheet titles use the Title style (15/800), as in DESIGN.md.
TextStyle? _sheetTitleStyle(BuildContext context) => Theme.of(
  context,
).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);

/// Group labels inside a sheet, styled like the Settings section labels.
TextStyle? _sheetSectionStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleSmall?.copyWith(
      color: context.colors.onSurfaceMuted,
      fontWeight: FontWeight.w700,
    );

/// A reading theme shown as itself: its page colour with "Aa" in its text
/// colour, so the choice is visible before it is made.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.label,
    required this.selected,
    required this.locked,
    required this.onSelected,
  });

  final ReaderTheme theme;
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final page = Color(theme.backgroundArgb);
    final ink = Color(theme.textArgb);
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: locked ? '$label, ${context.l10n.readerPremiumLocked}' : label,
      onTap: onSelected,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: page,
                  borderRadius: BorderRadius.circular(12),
                  // Selection is the one orange mark; others get a rule so
                  // a black or white page still has an edge on the card.
                  border: Border.all(
                    color: selected ? colors.primary : colors.border,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Aa',
                      style: text.titleLarge?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (locked)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: ink,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: text.labelMedium?.copyWith(
                  color: selected ? colors.onSurface : colors.onSurfaceMuted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPreviewBanner extends StatelessWidget {
  const _PremiumPreviewBanner({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.readerPremiumPreview)),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onUnlock,
            child: Text(context.l10n.premiumUnlock),
          ),
        ],
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

enum _SelectionAction { highlight, lookup }

/// [snippet] with every case-insensitive occurrence of [query] in bold.
TextSpan _emphasize(String snippet, String query) {
  final lower = snippet.toLowerCase();
  final needle = query.toLowerCase();
  final spans = <TextSpan>[];
  var start = 0;
  while (needle.isNotEmpty) {
    final index = lower.indexOf(needle, start);
    if (index < 0) break;
    if (index > start) {
      spans.add(TextSpan(text: snippet.substring(start, index)));
    }
    spans.add(
      TextSpan(
        text: snippet.substring(index, index + needle.length),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
    start = index + needle.length;
  }
  spans.add(TextSpan(text: snippet.substring(start)));
  return TextSpan(children: spans);
}

/// The fallback pages' selection toolbar: Highlight and Look up first, as in
/// the EPUB reader, then the platform's own items (Copy, Select all, ...).
EditableTextContextMenuBuilder _readerContextMenu(
  void Function(TextSelection selection, _SelectionAction action) onAction,
) => (context, state) {
  final selection = state.textEditingValue.selection;
  void run(_SelectionAction action) {
    state.hideToolbar();
    onAction(selection, action);
  }

  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: state.contextMenuAnchors,
    buttonItems: [
      ContextMenuButtonItem(
        label: context.l10n.readerHighlight,
        onPressed: () => run(_SelectionAction.highlight),
      ),
      ContextMenuButtonItem(
        label: context.l10n.readerLookup,
        onPressed: () => run(_SelectionAction.lookup),
      ),
      ...state.contextMenuButtonItems,
    ],
  );
};

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

  /// The query the results belong to; null until the first search, so the
  /// sheet does not claim "no results" before anything was searched.
  String? _searched;
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
        _searched = null;
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
      setState(() {
        _results = results;
        _searched = query;
      });
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
                style: _sheetTitleStyle(context),
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
                  // One tonal step above the sheet so the field has an edge.
                  fillColor: context.colors.surfaceElevated,
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
                  : _searched == null
                  ? const SizedBox.shrink()
                  : _results.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.readerSearchNoResults,
                        style: _sheetSectionStyle(context),
                      ),
                    )
                  : ListView.separated(
                      // One extra row for the count above the results.
                      itemCount: _results.length + 1,
                      separatorBuilder: (_, index) => index == 0
                          ? const SizedBox.shrink()
                          : const Divider(indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                context.l10n.readerSearchResultCount(
                                  _results.length,
                                ),
                                style: _sheetSectionStyle(context),
                              ),
                            ),
                          );
                        }
                        final result = _results[index - 1];
                        final text = Theme.of(context).textTheme;
                        return InkWell(
                          onTap: () async {
                            await result.onSelected();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (result.snippet != null)
                                  Text.rich(
                                    _emphasize(result.snippet!, _searched!),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyLarge?.copyWith(
                                      height: 1.45,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  result.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceMuted,
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

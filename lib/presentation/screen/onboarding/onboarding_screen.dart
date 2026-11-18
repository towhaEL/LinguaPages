import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/widgets.dart';

/// 4-page horizontal PageView carousel for OpenPages first-run onboarding.
///
/// Features:
/// 1. Top App Bar with brand icon, "OpenPages" in Newsreader serif, and "Skip" action.
/// 2. Page 1 (ce71ef53): "Your books, all in one place" + hero illustration + 5 format pills.
/// 3. Page 2 (ebb14c4c): "Read the way you like" + styles illustration + feature pills.
/// 4. Page 3 (20ed4f15): "Listen when your eyes rest" + audio illustration + feature pills.
/// 5. Page 4 (8a586c73): "Private by design" + privacy illustration + feature pills + dual CTAs.
/// 6. Animated page indicator dots (active 24x8, inactive 8x8).
@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onImportFirstBook,
    this.onExploreFirst,
  });

  final VoidCallback? onImportFirstBook;
  final VoidCallback? onExploreFirst;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await injector<OnboardingPreferences>().complete();
      if (!mounted) return;
      await context.router.replaceAll([const DashboardRoute()]);
      if (mounted) {
        setState(() => _busy = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.onboardingFailed;
      });
    }
  }

  void _handleSkip() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleExploreFirst();
    }
  }

  Future<void> _handleImportFirstBook() async {
    if (widget.onImportFirstBook != null) {
      widget.onImportFirstBook!();
    } else {
      await _completeOnboarding();
      try {
        if (injector.isRegistered<ImportDocumentUseCase>()) {
          await injector<ImportDocumentUseCase>().execute();
        }
      } catch (_) {}
    }
  }

  void _handleExploreFirst() {
    if (widget.onExploreFirst != null) {
      widget.onExploreFirst!();
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveOnboarding(builder: _buildScaffold);
  }

  Widget _buildScaffold(BuildContext context, _OnboardingLayout layout) {
    final pages = _pages();
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        // Every row counts on a ~400dp tall landscape phone.
        toolbarHeight: layout == _OnboardingLayout.split ? 48 : null,
        titleSpacing: layout.isLarge ? 32 : 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_library_outlined, color: context.accent, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'OpenPages',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.22,
                  color: AppColors.primaryInkColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: layout.isLarge ? 24 : 12),
            child: TextButton(
              onPressed: _handleSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondarySlateColor,
                textStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxWidth),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      for (final page in pages)
                        layout.isSplit
                            ? _buildSplitPage(page, layout)
                            : _buildStackedPage(page, layout),
                    ],
                  ),
                ),
                if (layout.isSplit)
                  _buildFooterBar(layout)
                else ...[
                  _buildPageIndicators(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_PageSpec> _pages() => [
    _PageSpec(
      visual: const Image(
        image: AssetImage('assets/images/onboarding_hero_illustration.png'),
        key: Key('onboarding_hero_image'),
        fit: BoxFit.contain,
      ),
      title: 'Your books, all in one place',
      titleStyle: _displayTitle,
      body:
          'EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone.',
      pills: (alignment) => _buildFormatChips(alignment),
    ),
    _PageSpec(
      visual: _framedVisual(
        color: AppColors.surfaceContainerLowColor,
        radius: 16,
        padding: 8,
        image: const Image(
          image: AssetImage(
            'assets/images/onboarding_page_2_reading_styles.png',
          ),
          key: Key('onboarding_page2_image'),
          fit: BoxFit.contain,
        ),
      ),
      title: 'Read the way you like',
      titleStyle: _sectionTitle,
      body:
          'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.',
      pills: (alignment) => _buildPills(alignment, [
        (Icons.format_size, 'Custom Fonts'),
        (Icons.format_align_justify, 'Margins & Spacing'),
        (Icons.edit_note, 'Highlights & Notes'),
      ]),
    ),
    _PageSpec(
      visual: _framedVisual(
        color: AppColors.cardSurface,
        radius: 24,
        padding: 12,
        image: const Image(
          image: AssetImage('assets/images/onboarding_page_3_read_aloud.png'),
          key: Key('onboarding_page3_image'),
          fit: BoxFit.contain,
        ),
      ),
      title: 'Listen when your eyes rest',
      titleStyle: _displayTitle,
      body:
          'Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked.',
      pills: (alignment) => _buildPills(alignment, [
        (Icons.record_voice_over_outlined, 'Natural Voices'),
        (Icons.format_underlined, 'Sentence Tracking'),
        (Icons.bedtime_outlined, 'Sleep Timer'),
      ]),
    ),
    _PageSpec(
      visual: _framedVisual(
        color: AppColors.cardSurface,
        radius: 24,
        padding: 10,
        image: const Image(
          image: AssetImage('assets/images/onboarding_page_4_privacy.png'),
          key: Key('onboarding_page4_image'),
          fit: BoxFit.contain,
        ),
      ),
      title: 'Private by design',
      titleStyle: _sectionTitle,
      body:
          'No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup.',
      pills: (alignment) => _buildPills(alignment, [
        (Icons.lock_outline, '100% Offline Vault'),
        (Icons.shield_outlined, 'Zero Telemetry'),
        (Icons.translate, 'Offline Dictionary'),
      ]),
    ),
  ];

  /// Pages 1 and 3 use the lighter display headline; 2 and 4 the heavier one.
  static TextStyle _displayTitle(double scale) => GoogleFonts.newsreader(
    fontSize: 30 * scale,
    fontWeight: FontWeight.w400,
    height: 38 / 30,
    letterSpacing: -0.45 * scale,
    color: AppColors.primaryInkColor,
  );

  static TextStyle _sectionTitle(double scale) => GoogleFonts.newsreader(
    fontSize: 26 * scale,
    fontWeight: FontWeight.w500,
    height: 34 / 26,
    letterSpacing: -0.26 * scale,
    color: AppColors.primaryInkColor,
  );

  Widget _framedVisual({
    required Color color,
    required double radius,
    required double padding,
    required Widget image,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.hairlineDivider, width: 1),
      ),
      padding: EdgeInsets.all(padding),
      child: image,
    );
  }

  TextStyle _bodyStyle(double scale) => GoogleFonts.inter(
    fontSize: 15 * scale,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.secondarySlateColor,
  );

  /// Phone and tablet portrait: visual above, copy centred below.
  Widget _buildStackedPage(_PageSpec page, _OnboardingLayout layout) {
    final scale = layout.typeScale;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: layout.isLarge ? 24 : 8),
          SizedBox(
            height: layout.isLarge ? 380 : 240,
            child: Center(child: page.visual),
          ),
          SizedBox(height: layout.isLarge ? 36 : 24),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: page.titleStyle(scale),
          ),
          const SizedBox(height: 12),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: _bodyStyle(scale),
          ),
          const SizedBox(height: 20),
          page.pills(WrapAlignment.center),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Landscape: the visual takes the start column at full height, the copy
  /// sits beside it, so a short screen never has to scroll to read a page.
  Widget _buildSplitPage(_PageSpec page, _OnboardingLayout layout) {
    final large = layout.isLarge;
    final scale = layout.typeScale;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 48 : 24,
        vertical: large ? 24 : 4,
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: Center(child: page.visual)),
          SizedBox(width: large ? 56 : 32),
          Expanded(
            flex: 6,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(page.title, style: page.titleStyle(scale)),
                    SizedBox(height: large ? 16 : 8),
                    Text(page.body, style: _bodyStyle(scale)),
                    SizedBox(height: large ? 24 : 14),
                    page.pills(WrapAlignment.start),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChips(WrapAlignment alignment) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: alignment,
      children: [
        for (final format in const ['EPUB', 'PDF', 'TXT', 'MD', 'FB2'])
          Chip(
            label: Text(format),
            backgroundColor: AppColors.cardSurface,
            shape: const StadiumBorder(
              side: BorderSide(color: AppColors.hairlineDivider, width: 1),
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondarySlateColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildPills(WrapAlignment alignment, List<(IconData, String)> pills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: alignment,
      children: [
        for (final (icon, label) in pills) _buildFeaturePill(icon, label),
      ],
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.hairlineDivider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondarySlateColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators({
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: List.generate(4, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? context.accent : const Color(0xFFC4C6D0),
                borderRadius: BorderRadius.circular(4),
              ),
              key: Key('dot_indicator_$index'),
            ),
          ),
        );
      }),
    );
  }

  String get _footerNote => switch (_currentPage) {
    0 => 'Offline-first & zero telemetry',
    1 => '100% Offline • Zero telemetry & personal storage',
    2 => 'Offline-first & zero telemetry · Background audio session',
    _ => 'Archived locally • Zero cloud sync required',
  };

  /// [expand] fills the column width (portrait); otherwise the button sizes
  /// to its label so it can sit in a row (landscape).
  Widget _buildImportButton({required bool expand}) {
    return FilledButton.icon(
      key: const Key('import_first_book_button'),
      style: FilledButton.styleFrom(
        minimumSize: expand ? const Size.fromHeight(52) : const Size(0, 52),
        padding: expand ? null : const EdgeInsets.symmetric(horizontal: 28),
        shape: const StadiumBorder(),
        backgroundColor: context.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      onPressed: _busy ? null : _handleImportFirstBook,
      icon: _busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.folder_open, size: 20),
      label: Text(
        'Import your first book',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExploreButton() {
    return TextButton(
      key: const Key('explore_first_button'),
      onPressed: _busy ? null : _handleExploreFirst,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondarySlateColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        'Explore first',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondarySlateColor,
        ),
      ),
    );
  }

  Widget _buildNextButton({required bool expand}) {
    return FilledButton.icon(
      key: const Key('next_page_button'),
      style: FilledButton.styleFrom(
        minimumSize: expand ? const Size.fromHeight(52) : const Size(160, 52),
        shape: const StadiumBorder(),
        backgroundColor: context.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      onPressed: () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: Text(
        'Next',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Text(
      _error!,
      style: GoogleFonts.inter(fontSize: 12, color: AppColors.destructiveColor),
    );
  }

  Widget _buildNote({required MainAxisAlignment alignment}) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        const Icon(
          Icons.lock_outline,
          size: 14,
          color: AppColors.secondarySlateColor,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _footerNote,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.secondarySlateColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentPage == 3) ...[
            _buildImportButton(expand: true),
            const SizedBox(height: 8),
            _buildExploreButton(),
          ] else
            _buildNextButton(expand: true),
          if (_error != null) ...[const SizedBox(height: 8), _buildError()],
          const SizedBox(height: 12),
          _buildNote(alignment: MainAxisAlignment.center),
        ],
      ),
    );
  }

  /// Landscape: one bar under the pages — progress and the privacy note on
  /// the start side, the actions on the end side.
  Widget _buildFooterBar(_OnboardingLayout layout) {
    final large = layout.isLarge;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        large ? 48 : 24,
        large ? 12 : 4,
        large ? 48 : 24,
        large ? 32 : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_error != null) ...[_buildError(), const SizedBox(height: 8)],
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageIndicators(alignment: MainAxisAlignment.start),
                    const SizedBox(height: 10),
                    _buildNote(alignment: MainAxisAlignment.start),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (_currentPage == 3) ...[
                _buildExploreButton(),
                const SizedBox(width: 8),
                _buildImportButton(expand: false),
              ] else
                _buildNextButton(expand: false),
            ],
          ),
        ],
      ),
    );
  }
}

/// How the onboarding pages are arranged for the current screen.
enum _OnboardingLayout {
  /// Phone portrait (and split screen): the original stacked column.
  compact(maxWidth: 480, typeScale: 1),

  /// Tablet portrait: the stacked column, larger and roomier.
  large(maxWidth: 600, typeScale: 1.2),

  /// Phone landscape: visual and copy side by side, actions in a bar.
  split(maxWidth: 960, typeScale: 0.9),

  /// Tablet landscape: the split layout at tablet scale.
  splitLarge(maxWidth: 1120, typeScale: 1.2);

  const _OnboardingLayout({required this.maxWidth, required this.typeScale});

  final double maxWidth;
  final double typeScale;

  bool get isSplit => this == split || this == splitLarge;
  bool get isLarge => this == large || this == splitLarge;
}

/// Picks an [_OnboardingLayout] with the same rules as every other screen;
/// the page state itself stays in [_OnboardingScreenState].
class _ResponsiveOnboarding extends Screen {
  const _ResponsiveOnboarding({required this.builder});

  final Widget Function(BuildContext, _OnboardingLayout) builder;

  @override
  Widget buildMobilePortraitView(BuildContext context) =>
      builder(context, _OnboardingLayout.compact);

  @override
  Widget buildMobileLandscapeView(BuildContext context) =>
      builder(context, _OnboardingLayout.split);

  @override
  Widget buildTabletView(BuildContext context) => builder(
    context,
    Screen.isTabletLandscape(context)
        ? _OnboardingLayout.splitLarge
        : _OnboardingLayout.large,
  );
}

class _PageSpec {
  const _PageSpec({
    required this.visual,
    required this.title,
    required this.titleStyle,
    required this.body,
    required this.pills,
  });

  final Widget visual;
  final String title;
  final TextStyle Function(double scale) titleStyle;
  final String body;
  final Widget Function(WrapAlignment alignment) pills;
}

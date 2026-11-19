import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
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

/// 3-page first-run onboarding for OpenPages.
///
/// 1. Library: every format on one shelf.
/// 2. Reading: styling, annotations and read aloud.
/// 3. Privacy: what stays on the device, with the Terms of Use and Privacy
///    Policy agreement above the import / explore actions.
///
/// Each page is a tinted illustration "stage" with an eyebrow, an editorial
/// headline, a short paragraph and a list of features. Portrait stacks them;
/// landscape puts the stage beside the copy and the actions in one bar.
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
  static const _pageCount = 3;
  static const _lastPage = _pageCount - 1;

  final _pageController = PageController();
  late final _termsLink = TapGestureRecognizer()
    ..onTap = () => context.router.root.push(const TermsRoute());
  late final _privacyLink = TapGestureRecognizer()
    ..onTap = () => context.router.root.push(const PrivacyRoute());
  int _currentPage = 0;
  var _busy = false;
  String? _error;

  bool get _onLastPage => _currentPage == _lastPage;

  @override
  void dispose() {
    _pageController.dispose();
    _termsLink.dispose();
    _privacyLink.dispose();
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

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleSkip() {
    if (_onLastPage) {
      _handleExploreFirst();
    } else {
      _goTo(_lastPage);
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
    final pages = _pages(context);
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
            child: _Hideable(
              hidden: _onLastPage,
              child: TextButton(
                key: const Key('onboarding_skip_button'),
                onPressed: _handleSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondarySlateColor,
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(context.l10n.onboardingSkip),
              ),
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
                      for (final (index, page) in pages.indexed)
                        layout.isSplit
                            ? _buildSplitPage(index, page, layout)
                            : _buildStackedPage(index, page, layout),
                    ],
                  ),
                ),
                if (layout.isSplit)
                  _buildFooterBar(layout)
                else
                  _buildFooter(layout),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_PageSpec> _pages(BuildContext context) {
    final l10n = context.l10n;
    return [
      _PageSpec(
        visual: const Image(
          image: AssetImage('assets/images/onboarding1.png'),
          key: Key('onboarding_hero_image'),
          fit: BoxFit.contain,
        ),
        eyebrow: l10n.onboardingLibraryEyebrow,
        title: l10n.onboardingLibraryTitle,
        body: l10n.onboardingLibraryBody,
        showFormats: true,
        features: [
          (
            Icons.folder_open_outlined,
            l10n.onboardingLibraryImport,
            l10n.onboardingLibraryImportCaption,
          ),
          (
            Icons.bookmark_border,
            l10n.onboardingLibraryProgress,
            l10n.onboardingLibraryProgressCaption,
          ),
        ],
      ),
      _PageSpec(
        visual: const Image(
          image: AssetImage('assets/images/onboarding2.png'),
          key: Key('onboarding_hero_image'),
          fit: BoxFit.contain,
        ),
        eyebrow: l10n.onboardingReadingEyebrow,
        title: l10n.onboardingReadingTitle,
        body: l10n.onboardingReadingBody,
        features: [
          (
            Icons.text_fields,
            l10n.onboardingReadingStyle,
            l10n.onboardingReadingStyleCaption,
          ),
          (
            Icons.edit_note,
            l10n.onboardingReadingNotes,
            l10n.onboardingReadingNotesCaption,
          ),
          (
            Icons.headphones_outlined,
            l10n.onboardingReadingListen,
            l10n.onboardingReadingListenCaption,
          ),
        ],
      ),
      _PageSpec(
        visual: const Image(
          image: AssetImage('assets/images/onboarding3.png'),
          key: Key('onboarding_page3_image'),
          fit: BoxFit.contain,
        ),
        eyebrow: l10n.onboardingPrivacyEyebrow,
        title: l10n.onboardingPrivacyTitle,
        body: l10n.onboardingPrivacyBody,
        features: [
          (
            Icons.phone_android_outlined,
            l10n.onboardingPrivacyLocal,
            l10n.onboardingPrivacyLocalCaption,
          ),
          (
            Icons.visibility_off_outlined,
            l10n.onboardingPrivacyTracking,
            l10n.onboardingPrivacyTrackingCaption,
          ),
          (
            Icons.translate,
            l10n.onboardingPrivacyLookup,
            l10n.onboardingPrivacyLookupCaption,
          ),
        ],
      ),
    ];
  }

  /// A soft accent-tinted panel the illustration sits on.
  Widget _buildStage(Widget visual, {required double radius}) {
    final accent = context.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.10),
            AppColors.surfaceContainerLowColor,
          ],
        ),
        border: Border.all(color: AppColors.hairlineDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: visual),
      ),
    );
  }

  Widget _buildEyebrow(int index, String label, double scale) {
    final style = GoogleFonts.inter(
      fontSize: 11 * scale,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: context.accent,
    );
    return Text(
      '${context.l10n.onboardingStep(index + 1, _pageCount)}  ·  '
      '${label.toUpperCase()}',
      key: Key('onboarding_eyebrow_$index'),
      style: style,
    );
  }

  TextStyle _titleStyle(double scale) => GoogleFonts.newsreader(
    fontSize: 30 * scale,
    fontWeight: FontWeight.w500,
    height: 36 / 30,
    letterSpacing: -0.45 * scale,
    color: AppColors.primaryInkColor,
  );

  TextStyle _bodyStyle(double scale) => GoogleFonts.inter(
    fontSize: 15 * scale,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.secondarySlateColor,
  );

  List<Widget> _buildCopy(int index, _PageSpec page, _OnboardingLayout layout) {
    final scale = layout.typeScale;
    final compactSplit = layout == _OnboardingLayout.split;
    return [
      _buildEyebrow(index, page.eyebrow, scale),
      SizedBox(height: compactSplit ? 6 : 10),
      Semantics(
        header: true,
        child: Text(page.title, style: _titleStyle(scale)),
      ),
      SizedBox(height: compactSplit ? 6 : 10),
      Text(page.body, style: _bodyStyle(scale)),
      if (page.showFormats) ...[
        SizedBox(height: compactSplit ? 10 : 16),
        _buildFormatChips(),
      ],
      SizedBox(height: compactSplit ? 12 : 20),
      for (final (featureIndex, (icon, title, caption))
          in page.features.indexed) ...[
        if (featureIndex > 0) SizedBox(height: compactSplit ? 8 : 12),
        _buildFeatureRow(icon, title, caption, scale),
      ],
    ];
  }

  /// Phone and tablet portrait: the stage above, the copy left-aligned below.
  Widget _buildStackedPage(
    int index,
    _PageSpec page,
    _OnboardingLayout layout,
  ) {
    final large = layout.isLarge;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: large ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: large ? 16 : 4),
          SizedBox(
            height: large ? 360 : 220,
            width: double.infinity,
            child: _buildStage(page.visual, radius: large ? 32 : 24),
          ),
          SizedBox(height: large ? 32 : 24),
          ..._buildCopy(index, page, layout),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Landscape: the stage takes the start column at full height, the copy
  /// sits beside it and scrolls on its own if a short screen needs it.
  Widget _buildSplitPage(int index, _PageSpec page, _OnboardingLayout layout) {
    final large = layout.isLarge;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 48 : 24,
        vertical: large ? 24 : 4,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _buildStage(page.visual, radius: large ? 32 : 20),
          ),
          SizedBox(width: large ? 56 : 32),
          Expanded(
            flex: 6,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildCopy(index, page, layout),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final format in const ['EPUB', 'PDF', 'TXT', 'MD', 'HTML', 'FB2'])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.hairlineDivider),
            ),
            child: Text(
              format,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.secondarySlateColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String caption,
    double scale,
  ) {
    final accent = context.accent;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: AppColors.primaryInkColor,
                ),
              ),
              Text(
                caption,
                style: GoogleFonts.inter(
                  fontSize: 12.5 * scale,
                  height: 18 / 12.5,
                  color: AppColors.secondarySlateColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pageCount, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () => _goTo(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? context.accent
                    : AppColors.outlineVariantColor,
                borderRadius: BorderRadius.circular(4),
              ),
              key: Key('dot_indicator_$index'),
            ),
          ),
        );
      }),
    );
  }

  TextStyle get _buttonLabelStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.14,
    color: Colors.white,
  );

  ButtonStyle _filledStyle({required Size minimumSize, EdgeInsets? padding}) {
    return FilledButton.styleFrom(
      minimumSize: minimumSize,
      padding: padding,
      shape: const StadiumBorder(),
      backgroundColor: context.accent,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  /// [expand] fills the column width (portrait); otherwise the button sizes
  /// to its label so it can sit in a row (landscape).
  Widget _buildImportButton({required bool expand}) {
    return FilledButton.icon(
      key: const Key('import_first_book_button'),
      style: _filledStyle(
        minimumSize: expand ? const Size.fromHeight(52) : const Size(0, 48),
        padding: expand ? null : const EdgeInsets.symmetric(horizontal: 24),
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
      label: Text(context.l10n.onboardingImport, style: _buttonLabelStyle),
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
        context.l10n.onboardingExplore,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondarySlateColor,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return FilledButton(
      key: const Key('next_page_button'),
      style: _filledStyle(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      onPressed: () => _goTo(_currentPage + 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.onboardingNext, style: _buttonLabelStyle),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }

  /// Hidden on the first page, so the handler needs no guard.
  Widget _buildBackButton() {
    return _Hideable(
      hidden: _currentPage == 0,
      child: TextButton(
        key: const Key('previous_page_button'),
        onPressed: () => _goTo(_currentPage - 1),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondarySlateColor,
          minimumSize: const Size(0, 48),
        ),
        child: Text(
          context.l10n.onboardingBack,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
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

  /// "By continuing, you agree to the Terms of Use and acknowledge the
  /// Privacy Policy." Each document opens in-app.
  Widget _buildAgreement({required TextAlign align}) {
    final l10n = context.l10n;
    final base = GoogleFonts.inter(
      fontSize: 12,
      height: 18 / 12,
      color: AppColors.secondarySlateColor,
    );
    final linkStyle = base.copyWith(
      color: context.accent,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: context.accent.withValues(alpha: 0.4),
    );

    return Text.rich(
      key: const Key('onboarding_agreement'),
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l10n.onboardingAgreementPrefix),
          TextSpan(
            text: l10n.termsTitle,
            style: linkStyle,
            recognizer: _termsLink,
          ),
          TextSpan(text: l10n.onboardingAgreementMiddle),
          TextSpan(
            text: l10n.privacyTitle,
            style: linkStyle,
            recognizer: _privacyLink,
          ),
          TextSpan(text: l10n.onboardingAgreementSuffix),
        ],
      ),
      textAlign: align,
    );
  }

  /// Portrait: progress and Back / Next in one row; on the last page the
  /// agreement and the full-width actions take its place.
  Widget _buildFooter(_OnboardingLayout layout) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.isLarge ? 32 : 20,
        8,
        layout.isLarge ? 32 : 20,
        16,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_onLastPage) ...[
              _buildPageIndicators(),
              const SizedBox(height: 12),
              _buildAgreement(align: TextAlign.center),
              const SizedBox(height: 16),
              _buildImportButton(expand: true),
              const SizedBox(height: 4),
              _buildExploreButton(),
            ] else
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _buildBackButton(),
                    ),
                  ),
                  _buildPageIndicators(),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _buildNextButton(),
                    ),
                  ),
                ],
              ),
            if (_error != null) ...[const SizedBox(height: 8), _buildError()],
          ],
        ),
      ),
    );
  }

  /// Landscape: one bar under the pages — progress (and the agreement on the
  /// last page) on the start side, the actions on the end side.
  Widget _buildFooterBar(_OnboardingLayout layout) {
    final large = layout.isLarge;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        large ? 48 : 24,
        large ? 12 : 4,
        large ? 48 : 24,
        large ? 32 : 8,
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
                    _buildPageIndicators(),
                    if (_onLastPage) _buildAgreement(align: TextAlign.start),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (_onLastPage) ...[
                _buildExploreButton(),
                const SizedBox(width: 8),
                _buildImportButton(expand: false),
              ] else ...[
                if (_currentPage > 0) _buildBackButton(),
                const SizedBox(width: 8),
                _buildNextButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Keeps [child]'s space but hides it and ignores taps while [hidden].
///
/// The buttons it wraps stay enabled throughout: toggling a [TextButton]
/// between enabled and disabled while it is not painted trips a text
/// layout assertion when it reappears.
class _Hideable extends StatelessWidget {
  const _Hideable({required this.hidden, required this.child});

  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: hidden,
      child: Visibility.maintain(visible: !hidden, child: child),
    );
  }
}

/// Two illustrations as one: [base] fills the stage and [inset] sits on its
/// bottom-end corner as a raised card.
class _LayeredVisual extends StatelessWidget {
  const _LayeredVisual({required this.base, required this.inset});

  final Widget base;
  final Widget inset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide * 0.42;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: side * 0.35),
                child: base,
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              width: side,
              height: side,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.hairlineDivider),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: inset,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// How the onboarding pages are arranged for the current screen.
enum _OnboardingLayout {
  /// Phone portrait (and split screen): the stacked column.
  compact(maxWidth: 480, typeScale: 1),

  /// Tablet portrait: the stacked column, larger and roomier.
  large(maxWidth: 600, typeScale: 1.2),

  /// Phone landscape: stage and copy side by side, actions in a bar.
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
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.features,
    this.showFormats = false,
  });

  final Widget visual;
  final String eyebrow;
  final String title;
  final String body;
  final List<(IconData, String, String)> features;
  final bool showFormats;
}

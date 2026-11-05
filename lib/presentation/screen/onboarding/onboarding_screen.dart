import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';

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

  void _handleImportFirstBook() {
    if (widget.onImportFirstBook != null) {
      widget.onImportFirstBook!();
    } else {
      _completeOnboarding();
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
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_library_outlined,
              color: AppColors.accentInkBlueColor,
              size: 24,
            ),
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
            padding: const EdgeInsets.only(right: 12),
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildPage1(),
                      _buildPage2(),
                      _buildPage3(),
                      _buildPage4(),
                    ],
                  ),
                ),
                _buildPageIndicators(),
                const SizedBox(height: 20),
                _buildFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const SizedBox(
            height: 240,
            child: Center(
              child: Image(
                image: AssetImage('assets/images/onboarding_hero_illustration.png'),
                key: Key('onboarding_hero_image'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your books, all in one place',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 38 / 30,
              letterSpacing: -0.45,
              color: AppColors.primaryInkColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 22 / 15,
              color: AppColors.secondarySlateColor,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: const [
              Chip(
                label: Text('EPUB'),
                backgroundColor: AppColors.cardSurface,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.hairlineDivider, width: 1),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySlateColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text('PDF'),
                backgroundColor: AppColors.cardSurface,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.hairlineDivider, width: 1),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySlateColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text('TXT'),
                backgroundColor: AppColors.cardSurface,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.hairlineDivider, width: 1),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySlateColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text('MD'),
                backgroundColor: AppColors.cardSurface,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.hairlineDivider, width: 1),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySlateColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text('FB2'),
                backgroundColor: AppColors.cardSurface,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.hairlineDivider, width: 1),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondarySlateColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.hairlineDivider,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: const Image(
                  image: AssetImage('assets/images/onboarding_page_2_reading_styles.png'),
                  key: Key('onboarding_page2_image'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Read the way you like',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 34 / 26,
              letterSpacing: -0.26,
              color: AppColors.primaryInkColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 22 / 15,
              color: AppColors.secondarySlateColor,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeaturePill(Icons.format_size, 'Custom Fonts'),
              _buildFeaturePill(Icons.format_align_justify, 'Margins & Spacing'),
              _buildFeaturePill(Icons.edit_note, 'Highlights & Notes'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.hairlineDivider,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: const Image(
                  image: AssetImage('assets/images/onboarding_page_3_read_aloud.png'),
                  key: Key('onboarding_page3_image'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Listen when your eyes rest',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 38 / 30,
              letterSpacing: -0.45,
              color: AppColors.primaryInkColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 22 / 15,
              color: AppColors.secondarySlateColor,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeaturePill(Icons.record_voice_over_outlined, 'Natural Voices'),
              _buildFeaturePill(Icons.format_underlined, 'Sentence Tracking'),
              _buildFeaturePill(Icons.bedtime_outlined, 'Sleep Timer'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.hairlineDivider,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: const Image(
                  image: AssetImage('assets/images/onboarding_page_4_privacy.png'),
                  key: Key('onboarding_page4_image'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Private by design',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 34 / 26,
              letterSpacing: -0.26,
              color: AppColors.primaryInkColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 22 / 15,
              color: AppColors.secondarySlateColor,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFeaturePill(Icons.lock_outline, '100% Offline Vault'),
              _buildFeaturePill(Icons.shield_outlined, 'Zero Telemetry'),
              _buildFeaturePill(Icons.translate, 'Offline Dictionary'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.hairlineDivider,
          width: 1,
        ),
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
          Icon(icon, size: 14, color: AppColors.accentInkBlueColor),
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

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                color: isActive
                    ? AppColors.accentInkBlueColor
                    : const Color(0xFFC4C6D0),
                borderRadius: BorderRadius.circular(4),
              ),
              key: Key('dot_indicator_$index'),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    final note = switch (_currentPage) {
      0 => 'Offline-first & zero telemetry',
      1 => '100% Offline • Zero telemetry & personal storage',
      2 => 'Offline-first & zero telemetry · Background audio session',
      _ => 'Archived locally • Zero cloud sync required',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentPage == 3) ...[
            FilledButton.icon(
              key: const Key('import_first_book_button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                backgroundColor: AppColors.accentInkBlueColor,
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
            ),
            const SizedBox(height: 8),
            TextButton(
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
            ),
          ] else ...[
            FilledButton.icon(
              key: const Key('next_page_button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                backgroundColor: AppColors.accentInkBlueColor,
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
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.destructiveColor,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 14,
                color: AppColors.secondarySlateColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  note,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondarySlateColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

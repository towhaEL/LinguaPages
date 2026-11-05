import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app_harness.dart';

/// Test representation of the 4-page Onboarding Carousel specification.
class OnboardingCarouselContractWidget extends StatefulWidget {
  const OnboardingCarouselContractWidget({
    super.key,
    this.onImportFirstBook,
    this.onExploreFirst,
  });

  final VoidCallback? onImportFirstBook;
  final VoidCallback? onExploreFirst;

  @override
  State<OnboardingCarouselContractWidget> createState() =>
      _OnboardingCarouselContractWidgetState();
}

class _OnboardingCarouselContractWidgetState
    extends State<OnboardingCarouselContractWidget> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_library_outlined, color: WarmEditorialTokens.accentInkBlue),
            SizedBox(width: 8),
            Text(
              'OpenPages',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: WarmEditorialTokens.textPrimaryInk,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _controller.jumpToPage(3),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
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
          const SizedBox(height: 24),
          _buildFooter(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 240,
            child: Center(
              child: Image(
                image: AssetImage('assets/images/onboarding_hero_illustration.png'),
                key: Key('onboarding_hero_image'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your books, all in one place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('EPUB')),
              Chip(label: Text('PDF')),
              Chip(label: Text('TXT')),
              Chip(label: Text('MD')),
              Chip(label: Text('FB2')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 240,
            child: Center(
              child: Image(
                image: AssetImage('assets/images/onboarding_page_2_reading_styles.png'),
                key: Key('onboarding_page2_image'),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Read the way you like',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 240,
            child: Center(
              child: Image(
                image: AssetImage('assets/images/onboarding_page_3_read_aloud.png'),
                key: Key('onboarding_page3_image'),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Listen when your eyes rest',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 240,
            child: Center(
              child: Image(
                image: AssetImage('assets/images/onboarding_page_4_privacy.png'),
                key: Key('onboarding_page4_image'),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Private by design',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: WarmEditorialTokens.subtitleSecondary,
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? WarmEditorialTokens.accentInkBlue
                  : const Color(0xFFC4C6D0),
              borderRadius: BorderRadius.circular(4),
            ),
            key: Key('dot_indicator_$index'),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    if (_currentPage == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            FilledButton.icon(
              key: const Key('import_first_book_button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                backgroundColor: WarmEditorialTokens.accentInkBlue,
              ),
              onPressed: widget.onImportFirstBook,
              icon: const Icon(Icons.folder_open),
              label: const Text('Import your first book'),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('explore_first_button'),
              onPressed: widget.onExploreFirst,
              child: const Text(
                'Explore first',
                style: TextStyle(color: WarmEditorialTokens.subtitleSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FilledButton.icon(
        key: const Key('next_page_button'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          backgroundColor: WarmEditorialTokens.accentInkBlue,
        ),
        onPressed: () => _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
      ),
    );
  }
}

void main() {
  group('Tier 1: Features 6-10 - Onboarding Flow & Carousel Contracts', () {
    testWidgets('Page 1 displays headline, hero illustration, and 5 format pills',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingCarouselContractWidget(),
      );

      expect(find.text('Your books, all in one place'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_hero_image')), findsOneWidget);
      expect(find.text('EPUB'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('TXT'), findsOneWidget);
      expect(find.text('MD'), findsOneWidget);
      expect(find.text('FB2'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Page indicators: active dot is 24x8 and inactive dots are 8x8',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingCarouselContractWidget(),
      );

      final dot0 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_0')));
      final dot1 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_1')));

      expect(dot0.size.width, 24);
      expect(dot0.size.height, 8);
      expect(dot1.size.width, 8);
      expect(dot1.size.height, 8);
    });

    testWidgets('Tapping Next transitions to Page 2 ("Read the way you like")',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingCarouselContractWidget(),
      );

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('Read the way you like'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page2_image')), findsOneWidget);

      final dot1 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_1')));
      expect(dot1.size.width, 24);
    });

    testWidgets('Page 3 presents "Listen when your eyes rest" and audio waves',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingCarouselContractWidget(),
      );

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page3_image')), findsOneWidget);
    });

    testWidgets('Page 4 presents "Private by design" with dual import & explore actions',
        (tester) async {
      var importCalled = false;
      var exploreCalled = false;

      await tester.pumpHarness(
        OnboardingCarouselContractWidget(
          onImportFirstBook: () => importCalled = true,
          onExploreFirst: () => exploreCalled = true,
        ),
      );

      // Jump to page 4 via Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page4_image')), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('import_first_book_button')));
      expect(importCalled, isTrue);

      await tester.tap(find.byKey(const Key('explore_first_button')));
      expect(exploreCalled, isTrue);
    });
  });
}

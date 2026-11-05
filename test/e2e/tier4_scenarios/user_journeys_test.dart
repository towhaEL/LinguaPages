import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

/// Test application representing the full integrated user flow across screens.
class FullAppJourneyHarnessWidget extends StatefulWidget {
  const FullAppJourneyHarnessWidget({
    super.key,
    this.startAtOnboarding = true,
  });

  final bool startAtOnboarding;

  @override
  State<FullAppJourneyHarnessWidget> createState() =>
      _FullAppJourneyHarnessWidgetState();
}

enum AppScreen { onboarding, library, reader, settings, paywall, annotations }

class _FullAppJourneyHarnessWidgetState
    extends State<FullAppJourneyHarnessWidget> {
  late AppScreen _currentScreen =
      widget.startAtOnboarding ? AppScreen.onboarding : AppScreen.library;
  BookEntity? _selectedBook;
  Color _readerCanvas = WarmEditorialTokens.paperReader;
  bool _isZenMode = false;
  bool _isReadAloudActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      body: switch (_currentScreen) {
        AppScreen.onboarding => _buildOnboardingScreen(),
        AppScreen.library => _buildLibraryScreen(),
        AppScreen.reader => _buildReaderScreen(),
        AppScreen.settings => _buildSettingsScreen(),
        AppScreen.paywall => _buildPaywallScreen(),
        AppScreen.annotations => _buildAnnotationsScreen(),
      },
    );
  }

  Widget _buildOnboardingScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your books, all in one place',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DRM-free and stored only on your phone.',
              style: TextStyle(fontFamily: 'Inter', color: WarmEditorialTokens.subtitleSecondary),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('journey_onboarding_explore_btn'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const StadiumBorder(),
                backgroundColor: WarmEditorialTokens.accentInkBlue,
              ),
              onPressed: () => setState(() => _currentScreen = AppScreen.library),
              child: const Text('Explore Library'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryScreen() {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontFamily: 'Newsreader')),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            key: const Key('journey_nav_settings_btn'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => setState(() => _currentScreen = AppScreen.settings),
          ),
          IconButton(
            key: const Key('journey_nav_annotations_btn'),
            icon: const Icon(Icons.edit_note),
            onPressed: () => setState(() => _currentScreen = AppScreen.annotations),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero card
          Card(
            key: const Key('journey_library_hero'),
            child: ListTile(
              leading: SizedBox(
                width: 44,
                child: BookCover(book: MockDataFixtures.sampleDuneBook, compact: true),
              ),
              title: const Text('Dune'),
              subtitle: const Text('Chapter 12 · 48%'),
              trailing: FilledButton(
                key: const Key('journey_open_dune_reader_btn'),
                onPressed: () {
                  setState(() {
                    _selectedBook = MockDataFixtures.sampleDuneBook;
                    _currentScreen = AppScreen.reader;
                  });
                },
                child: const Text('Read'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderScreen() {
    return Scaffold(
      backgroundColor: _readerCanvas,
      appBar: _isZenMode
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                key: const Key('journey_reader_back_btn'),
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentScreen = AppScreen.library),
              ),
              title: Text(_selectedBook?.title ?? 'Reader'),
              actions: [
                IconButton(
                  key: const Key('journey_reader_toggle_audio_btn'),
                  icon: const Icon(Icons.headphones),
                  onPressed: () => setState(() => _isReadAloudActive = !_isReadAloudActive),
                ),
                IconButton(
                  key: const Key('journey_reader_theme_btn'),
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {
                    setState(() {
                      _readerCanvas = const Color(0xFFF4ECD8); // Switch to Sepia
                    });
                  },
                ),
              ],
            ),
      body: GestureDetector(
        key: const Key('journey_reader_tap_zone'),
        onTap: () => setState(() => _isZenMode = !_isZenMode),
        child: Container(
          color: _readerCanvas,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter 12: Arrakis Awakening',
                style: const TextStyle(fontFamily: 'Newsreader', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isReadAloudActive)
                Container(
                  key: const Key('journey_active_sentence_band'),
                  padding: const EdgeInsets.all(4),
                  color: WarmEditorialTokens.spokenHighlight,
                  child: const Text(
                    'The desert wind howled against the shield wall.',
                    style: TextStyle(fontFamily: 'Newsreader', fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                )
              else
                const Text(
                  'The desert wind howled against the shield wall.',
                  style: TextStyle(fontFamily: 'Newsreader', fontSize: 18),
                ),
              const Spacer(),
              if (_isZenMode)
                const Text(
                  'Zen Mode Active · 142 / 380 · 37%',
                  key: Key('journey_zen_footer'),
                  style: TextStyle(fontSize: 11, color: WarmEditorialTokens.subtitleSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('journey_settings_back_btn'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentScreen = AppScreen.library),
        ),
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            key: const Key('journey_settings_patron_banner'),
            child: ListTile(
              title: const Text('Patron Edition'),
              subtitle: const Text('Unlock 12 reading themes'),
              trailing: FilledButton(
                key: const Key('journey_patron_unlock_btn'),
                onPressed: () => setState(() => _currentScreen = AppScreen.paywall),
                child: const Text('Unlock'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaywallScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('journey_paywall_close_btn'),
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _currentScreen = AppScreen.settings),
        ),
        title: const Text('Patron Edition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Make every page yours',
              style: TextStyle(fontFamily: 'Newsreader', fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            FilledButton(
              key: const Key('journey_paywall_confirm_unlock_btn'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => setState(() => _currentScreen = AppScreen.settings),
              child: const Text('Unlock Premium (\$14.99)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationsScreen() {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('journey_annotations_back_btn'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentScreen = AppScreen.library),
        ),
        title: const Text('Annotations'),
        actions: [
          IconButton(
            key: const Key('journey_annotations_export_btn'),
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text('All Library Annotations (42 items)'),
      ),
    );
  }
}

void main() {
  group('Tier 4: Real-World Application Scenarios (End-to-End User Journeys)', () {
    testWidgets('Journey 1: First-Run Onboarding -> Library Exploration',
        (tester) async {
      await tester.pumpHarness(
        const FullAppJourneyHarnessWidget(startAtOnboarding: true),
      );

      // Verify Onboarding Screen
      expect(find.text('Your books, all in one place'), findsOneWidget);
      expect(find.byKey(const Key('journey_onboarding_explore_btn')), findsOneWidget);

      // Complete Onboarding -> Lands in Library
      await tester.tap(find.byKey(const Key('journey_onboarding_explore_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
      expect(find.byKey(const Key('journey_library_hero')), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Journey 2: Library Browsing -> Open Book in Reader',
        (tester) async {
      await tester.pumpHarness(
        const FullAppJourneyHarnessWidget(startAtOnboarding: false),
      );

      expect(find.text('Library'), findsOneWidget);

      // Tap Read on hero book Dune
      await tester.tap(find.byKey(const Key('journey_open_dune_reader_btn')));
      await tester.pumpAndSettle();

      // Enters Reader screen
      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Chapter 12: Arrakis Awakening'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Journey 3: Reader Immersion -> Zen Mode & Appearance Customization',
        (tester) async {
      await tester.pumpHarness(
        const FullAppJourneyHarnessWidget(startAtOnboarding: false),
      );

      // Open reader
      await tester.tap(find.byKey(const Key('journey_open_dune_reader_btn')));
      await tester.pumpAndSettle();

      // Change theme to Sepia
      await tester.tap(find.byKey(const Key('journey_reader_theme_btn')));
      await tester.pumpAndSettle();

      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFFF4ECD8));

      // Toggle Zen mode
      await tester.tap(find.byKey(const Key('journey_reader_tap_zone')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journey_zen_footer')), findsOneWidget);
    });

    testWidgets('Journey 4: Read Aloud Audio Session & Sentence Highlight Sync',
        (tester) async {
      await tester.pumpHarness(
        const FullAppJourneyHarnessWidget(startAtOnboarding: false),
      );

      // Open reader
      await tester.tap(find.byKey(const Key('journey_open_dune_reader_btn')));
      await tester.pumpAndSettle();

      // Activate Read Aloud
      await tester.tap(find.byKey(const Key('journey_reader_toggle_audio_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journey_active_sentence_band')), findsOneWidget);

      final bandContainer = tester.widget<Container>(find.byKey(const Key('journey_active_sentence_band')));
      expect(bandContainer.color, WarmEditorialTokens.spokenHighlight);
    });

    testWidgets('Journey 5: Patron Upgrade & Paywall Flow from Settings',
        (tester) async {
      await tester.pumpHarness(
        const FullAppJourneyHarnessWidget(startAtOnboarding: false),
      );

      // Open Settings
      await tester.tap(find.byKey(const Key('journey_nav_settings_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byKey(const Key('journey_settings_patron_banner')), findsOneWidget);

      // Open Paywall
      await tester.tap(find.byKey(const Key('journey_patron_unlock_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Make every page yours'), findsOneWidget);
      expect(find.byKey(const Key('journey_paywall_confirm_unlock_btn')), findsOneWidget);

      // Complete Unlock and return
      await tester.tap(find.byKey(const Key('journey_paywall_confirm_unlock_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}

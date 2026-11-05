import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

/// Test representation of Read Aloud player bottom sheet & sentence highlight (Features 27 & 28).
class ReadAloudContractWidget extends StatefulWidget {
  const ReadAloudContractWidget({
    super.key,
    required this.book,
    required this.spokenSentence,
    this.isPlaying = true,
    this.onPlayPause,
    this.onSkipForward,
    this.onSkipBack,
  });

  final BookEntity book;
  final String spokenSentence;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSkipForward;
  final VoidCallback? onSkipBack;

  @override
  State<ReadAloudContractWidget> createState() => _ReadAloudContractWidgetState();
}

class _ReadAloudContractWidgetState extends State<ReadAloudContractWidget> {
  double _progress = 0.35;
  final _speed = '1.25x';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.paperReader,
      body: Stack(
        children: [
          // Background reader canvas with sentence tracking highlight
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chapter Four: The Silent Harbour',
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The morning fog clung to the damp stones of the alleyways.',
                    style: TextStyle(fontFamily: 'Newsreader', fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  // Spoken sentence tracking band in #D6E2F5
                  Container(
                    key: const Key('spoken_sentence_highlight_band'),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    color: WarmEditorialTokens.spokenHighlight,
                    child: Text(
                      widget.spokenSentence,
                      style: const TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'He listened to the distant foghorn echoing across the port.',
                    style: TextStyle(fontFamily: 'Newsreader', fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Read Aloud Player Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              key: const Key('read_aloud_player_sheet'),
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Grab handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDAD5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Header row with cover thumbnail & title
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 64,
                          child: BookCover(book: widget.book, compact: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Newsreader',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.book.author != null)
                                Text(
                                  widget.book.author!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Spoken sentence quote card with vertical left bar in #2F4A7A
                    Container(
                      key: const Key('player_sentence_quote_card'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.canvasBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(
                            color: WarmEditorialTokens.accentInkBlue,
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '“${widget.spokenSentence}”',
                        style: const TextStyle(
                          fontFamily: 'Newsreader',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Timeline Scrubber
                    Slider(
                      value: _progress,
                      onChanged: (val) => setState(() => _progress = val),
                      activeColor: WarmEditorialTokens.accentInkBlue,
                    ),
                    // Playback Controls Row with 64px hero play/pause
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          key: const Key('read_aloud_skip_back'),
                          icon: const Icon(Icons.replay_10, size: 28),
                          onPressed: widget.onSkipBack,
                        ),
                        GestureDetector(
                          key: const Key('read_aloud_play_pause_hero'),
                          onTap: widget.onPlayPause,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: WarmEditorialTokens.accentInkBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('read_aloud_skip_forward'),
                          icon: const Icon(Icons.forward_10, size: 28),
                          onPressed: widget.onSkipForward,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Adjustment chips: Speed, Voice, Sleep timer
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(label: Text(_speed)),
                          const SizedBox(width: 8),
                          const Chip(label: Text('Natural Voice 2')),
                          const SizedBox(width: 8),
                          const Chip(label: Text('30 min timer')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Test representation of Settings Grouped Inset Cards (Feature 30).
class SettingsContractWidget extends StatelessWidget {
  const SettingsContractWidget({
    super.key,
    this.onPatronBannerPressed,
  });

  final VoidCallback? onPatronBannerPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Newsreader', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Patron Promotion Banner
          Card(
            key: const Key('settings_patron_banner'),
            child: ListTile(
              leading: const Icon(Icons.verified, color: WarmEditorialTokens.accentInkBlue),
              title: const Text('PATRON EDITION', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Unlock 12 themes and 8 editorial fonts'),
              trailing: FilledButton(
                key: const Key('settings_patron_unlock_cta'),
                onPressed: onPatronBannerPressed,
                child: const Text('Unlock'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 2. Appearance Grouped Card
          Card(
            key: const Key('settings_card_appearance'),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined),
                  title: Text('Appearance'),
                  subtitle: Text('Light, Dark, or System mode'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 3. Reading Defaults Card
          Card(
            key: const Key('settings_card_reading_defaults'),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.menu_book),
                  title: Text('Reading defaults'),
                  subtitle: Text('Default typeface, paper tone, line height'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 4. Read Aloud Card
          Card(
            key: const Key('settings_card_read_aloud'),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.headphones_outlined),
                  title: Text('Read aloud (TTS)'),
                  subtitle: Text('Natural voice synthesis, speed presets'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 5. Library & Backup Card
          Card(
            key: const Key('settings_card_backup'),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('Library & Backup'),
                  subtitle: Text('Local vault snapshot & restore'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 6. About Card
          Card(
            key: const Key('settings_card_about'),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About OpenPages'),
                  subtitle: Text('v1.0.0 · 100% Offline & Private'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Test representation of Premium Paywall Sheet (Feature 31).
class PremiumPaywallContractWidget extends StatelessWidget {
  const PremiumPaywallContractWidget({
    super.key,
    this.onUnlockPressed,
    this.onRestorePressed,
  });

  final VoidCallback? onUnlockPressed;
  final VoidCallback? onRestorePressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Make every page yours',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock premium reading themes, handcrafted fonts, and visual presets.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // 3-Theme Hero Preview
              Row(
                key: const Key('paywall_3theme_preview'),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeCard('Warm Linen', const Color(0xFFF5EFEB)),
                  _buildThemeCard('Midnight', const Color(0xFF161E2E)),
                  _buildThemeCard('Forest', const Color(0xFF1B2921)),
                ],
              ),
              const SizedBox(height: 24),
              // Plan cards
              Card(
                key: const Key('paywall_lifetime_plan_card'),
                child: const ListTile(
                  leading: Icon(Icons.radio_button_checked, color: WarmEditorialTokens.accentInkBlue),
                  title: Text('Lifetime — \$14.99 one-time', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Pay once. Own it forever.'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('paywall_unlock_button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                  backgroundColor: WarmEditorialTokens.accentInkBlue,
                ),
                onPressed: onUnlockPressed,
                child: const Text('Unlock Premium'),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('paywall_restore_button'),
                onPressed: onRestorePressed,
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(String name, Color bg) {
    return Container(
      width: 90,
      height: 110,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Test representation of All Annotations Screen (Feature 32).
class AnnotationsFeedContractWidget extends StatelessWidget {
  const AnnotationsFeedContractWidget({
    super.key,
    required this.bookTitle,
    this.onExportMarkdown,
  });

  final String bookTitle;
  final VoidCallback? onExportMarkdown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        title: const Text(
          'Annotations',
          style: TextStyle(fontFamily: 'Newsreader', fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            key: const Key('export_markdown_button'),
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export as Markdown',
            onPressed: onExportMarkdown,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            bookTitle,
            style: const TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Grouped Annotation card with vertical color strip
          Card(
            key: const Key('annotation_item_card_1'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 54,
                    decoration: BoxDecoration(
                      color: WarmEditorialTokens.highlightBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“A secret is only as good as the keeper who guards it.”',
                          style: TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Echoes the prologue theme of stewardship',
                          style: TextStyle(fontSize: 13, color: WarmEditorialTokens.textPrimaryInk),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chapter 4 · Page 142 · Oct 28, 2026',
                          style: TextStyle(
                            fontSize: 11,
                            color: WarmEditorialTokens.subtitleSecondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
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

void main() {
  group('Tier 1: Features 27 & 28 - Spoken Sentence Highlight & Read Aloud Player', () {
    testWidgets('Reader canvas highlights active spoken sentence in #D6E2F5',
        (tester) async {
      await tester.pumpHarness(
        ReadAloudContractWidget(
          book: MockDataFixtures.sampleEpubBook,
          spokenSentence: 'He remembered the scent of rain on the damp flagstones.',
        ),
      );

      final highlightContainer = tester.widget<Container>(
        find.byKey(const Key('spoken_sentence_highlight_band')),
      );
      expect(highlightContainer.color, WarmEditorialTokens.spokenHighlight);
      expect(
        find.text('He remembered the scent of rain on the damp flagstones.'),
        findsOneWidget,
      );
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Read aloud bottom sheet renders 64px hero play/pause, quote card, scrubber',
        (tester) async {
      var playPauseTapped = false;
      await tester.pumpHarness(
        ReadAloudContractWidget(
          book: MockDataFixtures.sampleEpubBook,
          spokenSentence: 'He remembered the scent of rain on the damp flagstones.',
          isPlaying: true,
          onPlayPause: () => playPauseTapped = true,
        ),
      );

      expect(find.byKey(const Key('read_aloud_player_sheet')), findsOneWidget);
      expect(find.byKey(const Key('player_sentence_quote_card')), findsOneWidget);

      final playPauseBox = tester.renderObject<RenderBox>(
        find.byKey(const Key('read_aloud_play_pause_hero')),
      );
      expect(playPauseBox.size.width, 64);
      expect(playPauseBox.size.height, 64);

      await tester.tap(find.byKey(const Key('read_aloud_play_pause_hero')));
      expect(playPauseTapped, isTrue);
    });
  });

  group('Tier 1: Feature 30 - Settings Inset Grouped Cards (03)', () {
    testWidgets('Settings renders 6 grouped cards: Patron, Appearance, Defaults, TTS, Backup, About',
        (tester) async {
      var patronTapped = false;
      await tester.pumpHarness(
        SettingsContractWidget(
          onPatronBannerPressed: () => patronTapped = true,
        ),
      );

      expect(find.byKey(const Key('settings_patron_banner')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_appearance')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_reading_defaults')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_read_aloud')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_backup')), findsOneWidget);
      expect(find.byKey(const Key('settings_card_about')), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings_patron_unlock_cta')));
      expect(patronTapped, isTrue);
      tester.expectNoBottomNavigationBar();
    });
  });

  group('Tier 1: Feature 31 - Premium Paywall Sheet (07)', () {
    testWidgets('Paywall presents 3-theme hero carousel, Lifetime card, and Unlock CTA',
        (tester) async {
      var unlockTapped = false;
      var restoreTapped = false;

      await tester.pumpHarness(
        PremiumPaywallContractWidget(
          onUnlockPressed: () => unlockTapped = true,
          onRestorePressed: () => restoreTapped = true,
        ),
      );

      expect(find.text('Make every page yours'), findsOneWidget);
      expect(find.byKey(const Key('paywall_3theme_preview')), findsOneWidget);
      expect(find.byKey(const Key('paywall_lifetime_plan_card')), findsOneWidget);
      expect(find.byKey(const Key('paywall_unlock_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('paywall_unlock_button')));
      expect(unlockTapped, isTrue);

      await tester.tap(find.byKey(const Key('paywall_restore_button')));
      expect(restoreTapped, isTrue);
    });
  });

  group('Tier 1: Feature 32 - All Annotations Screen (08)', () {
    testWidgets('Annotations renders grouped card with vertical color strip and Markdown export',
        (tester) async {
      var exportTapped = false;
      await tester.pumpHarness(
        AnnotationsFeedContractWidget(
          bookTitle: 'The Shadow of the Wind',
          onExportMarkdown: () => exportTapped = true,
        ),
      );

      expect(find.text('The Shadow of the Wind'), findsOneWidget);
      expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
      expect(find.text('Echoes the prologue theme of stewardship'), findsOneWidget);

      await tester.tap(find.byKey(const Key('export_markdown_button')));
      expect(exportTapped, isTrue);
      tester.expectNoBottomNavigationBar();
    });
  });
}

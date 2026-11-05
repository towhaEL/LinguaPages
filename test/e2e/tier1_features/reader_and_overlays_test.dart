import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_chrome.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

/// Test representation of Reader Screen with Chrome toggling (Features 21 & 22).
class ReaderScreenContractWidget extends StatefulWidget {
  const ReaderScreenContractWidget({
    super.key,
    required this.title,
    required this.chapterTitle,
    required this.pageText,
    this.initialChromeVisible = true,
    this.onContentsPressed,
    this.onAppearancePressed,
    this.onListenPressed,
    this.onNotesPressed,
  });

  final String title;
  final String chapterTitle;
  final String pageText;
  final bool initialChromeVisible;
  final VoidCallback? onContentsPressed;
  final VoidCallback? onAppearancePressed;
  final VoidCallback? onListenPressed;
  final VoidCallback? onNotesPressed;

  @override
  State<ReaderScreenContractWidget> createState() =>
      _ReaderScreenContractWidgetState();
}

class _ReaderScreenContractWidgetState extends State<ReaderScreenContractWidget> {
  late bool _chromeVisible = widget.initialChromeVisible;
  double _brightness = 0.65;
  final _progress = 0.37;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.paperReader,
      body: Stack(
        children: [
          // Underlying 100% Reading Viewport (Zen mode substrate)
          GestureDetector(
            key: const Key('reader_viewport_tap_target'),
            onTap: () => setState(() => _chromeVisible = !_chromeVisible),
            child: Container(
              color: WarmEditorialTokens.paperReader,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapterTitle,
                    style: const TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: WarmEditorialTokens.textPrimaryInk,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Text(
                      widget.pageText,
                      style: const TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 18,
                        height: 1.6,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                  ),
                  // Zen mode footer counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          '12 min left in chapter',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '142 / 380 · 37%',
                        key: const Key('zen_mode_page_counter'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: WarmEditorialTokens.textPrimaryInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bookmark ribbon
          Positioned(
            top: 0,
            right: 28,
            child: Container(
              key: const Key('reader_bookmark_ribbon'),
              width: 14,
              height: 38,
              color: WarmEditorialTokens.accentInkBlue,
            ),
          ),

          // Left edge brightness rail
          if (_chromeVisible)
            Positioned(
              left: 10,
              top: 250,
              bottom: 250,
              child: Container(
                key: const Key('brightness_rail_capsule'),
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _brightness,
                      onChanged: (val) => setState(() => _brightness = val),
                    ),
                  ),
                ),
              ),
            ),

          // Top Chrome Bar
          ReaderChromeSlot(
            visible: _chromeVisible,
            edge: VerticalDirection.up,
            child: ReaderTopBar(
              title: widget.title,
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('reader_search_button'),
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                  IconButton(
                    key: const Key('reader_bookmark_button'),
                    icon: const Icon(Icons.bookmark_outline),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Bottom Chrome Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ReaderChromeSlot(
              visible: _chromeVisible,
              edge: VerticalDirection.down,
              child: ReaderBottomBar(
                progress: _progress,
                bandColor: WarmEditorialTokens.accentInkBlue,
                positionLabel: '37%',
                tools: [
                  ReaderTool(
                    icon: Icons.format_list_bulleted,
                    label: 'Contents',
                    onPressed: widget.onContentsPressed,
                  ),
                  ReaderTool(
                    icon: Icons.text_fields,
                    label: 'Appearance',
                    onPressed: widget.onAppearancePressed,
                  ),
                  ReaderTool(
                    icon: Icons.headphones,
                    label: 'Listen',
                    onPressed: widget.onListenPressed,
                  ),
                  ReaderTool(
                    icon: Icons.edit_note,
                    label: 'Notes',
                    onPressed: widget.onNotesPressed,
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

/// Test representation of Standalone Appearance Bottom Sheet (Feature 23).
class AppearanceSheetContractWidget extends StatelessWidget {
  const AppearanceSheetContractWidget({
    super.key,
    required this.selectedTheme,
    required this.onThemeSelected,
    required this.fontSize,
    required this.onFontSizeChanged,
  });

  final String selectedTheme;
  final ValueChanged<String> onThemeSelected;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final swatches = [
      ('Paper', const Color(0xFFF6F1E7), false),
      ('White', const Color(0xFFFFFFFF), false),
      ('Sepia', const Color(0xFFF4ECD8), false),
      ('Grey', const Color(0xFFEAE6DF), false),
      ('Night', const Color(0xFF23272A), true),
      ('OLED', const Color(0xFF121212), true),
    ];

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Theme',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (name, color, isLocked) in swatches)
                  GestureDetector(
                    key: Key('swatch_$name'),
                    onTap: () => onThemeSelected(name),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedTheme == name
                              ? WarmEditorialTokens.accentInkBlue
                              : WarmEditorialTokens.hairlineDivider,
                          width: selectedTheme == name ? 2.5 : 1.0,
                        ),
                      ),
                      child: isLocked
                          ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                          : (selectedTheme == name
                              ? const Icon(Icons.check, size: 18, color: WarmEditorialTokens.accentInkBlue)
                              : null),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('A−', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Slider(
                    key: const Key('appearance_font_slider'),
                    value: fontSize,
                    min: 12,
                    max: 28,
                    onChanged: onFontSizeChanged,
                  ),
                ),
                const Text('A+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Test representation of Text Selection Toolbar & Wiktionary Sheet (Feature 24).
class SelectionDictionaryContractWidget extends StatelessWidget {
  const SelectionDictionaryContractWidget({
    super.key,
    required this.selectedWord,
    required this.entry,
    this.onDefinePressed,
    this.onHighlightPressed,
    this.onCopyPressed,
  });

  final String selectedWord;
  final DictionaryEntry entry;
  final VoidCallback? onDefinePressed;
  final VoidCallback? onHighlightPressed;
  final VoidCallback? onCopyPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating contextual toolbar
        Container(
          key: const Key('floating_selection_toolbar'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: WarmEditorialTokens.textPrimaryInk,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 5 color dots
              for (final color in [
                WarmEditorialTokens.highlightYellow,
                WarmEditorialTokens.highlightGreen,
                WarmEditorialTokens.highlightBlue,
                WarmEditorialTokens.highlightPink,
                WarmEditorialTokens.highlightOrange,
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton(
                key: const Key('toolbar_define_button'),
                onPressed: onDefinePressed,
                child: const Text('Define', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              IconButton(
                key: const Key('toolbar_copy_button'),
                icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                onPressed: onCopyPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Modal Wiktionary Definition Card
        Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    Text(
                      entry.word,
                      style: const TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.phonetic != null)
                      Text(
                        entry.phonetic!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Chip(
                  label: Text('adjective · Local Lexicon'),
                ),
                const SizedBox(height: 12),
                Text(
                  entry.meanings.first.definitions.first.definition,
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
                const SizedBox(height: 16),
                const Text(
                  'From Wiktionary · CC BY-SA 3.0 · Offline Lexicon',
                  style: TextStyle(
                    fontSize: 11,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Test representation of In-Book Search Overlay (Feature 26).
class InBookSearchContractWidget extends StatelessWidget {
  const InBookSearchContractWidget({
    super.key,
    required this.query,
    required this.matchCount,
    required this.currentMatchIndex,
    this.onNextMatch,
    this.onPrevMatch,
  });

  final String query;
  final int matchCount;
  final int currentMatchIndex;
  final VoidCallback? onNextMatch;
  final VoidCallback? onPrevMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WarmEditorialTokens.canvasBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.search, color: WarmEditorialTokens.accentInkBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    query,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  key: const Key('search_match_counter_badge'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.spokenHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$matchCount results',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: WarmEditorialTokens.accentInkBlue,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('search_prev_match'),
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: onPrevMatch,
                ),
                IconButton(
                  key: const Key('search_next_match'),
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: onNextMatch,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Match $currentMatchIndex of $matchCount in current chapter',
                  style: const TextStyle(fontSize: 12, color: WarmEditorialTokens.subtitleSecondary),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: WarmEditorialTokens.textPrimaryInk, fontSize: 15),
                        children: [
                          TextSpan(text: 'The ship dropped anchor in the silent '),
                          TextSpan(
                            text: 'harbour',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              backgroundColor: WarmEditorialTokens.spokenHighlight,
                            ),
                          ),
                          TextSpan(text: ' under the morning fog.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('Tier 1: Feature 21 - Reader Chrome Visible (04)', () {
    testWidgets('Paper canvas, top bar, left brightness rail, and bottom panel with 4 tools',
        (tester) async {
      await tester.pumpHarness(
        const ReaderScreenContractWidget(
          title: 'The Shadow of the Wind',
          chapterTitle: 'Chapter Four: The Silent Harbour',
          pageText: 'The mist rose slowly over the silent cobblestones...',
          initialChromeVisible: true,
        ),
      );

      expect(find.text('The Shadow of the Wind'), findsOneWidget);
      expect(find.byKey(const Key('brightness_rail_capsule')), findsOneWidget);
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });
  });

  group('Tier 1: Feature 22 - Reader Zen Mode (04-var)', () {
    testWidgets('Tapping viewport toggles chrome off into Zen Mode with page counter',
        (tester) async {
      await tester.pumpHarness(
        const ReaderScreenContractWidget(
          title: 'The Shadow of the Wind',
          chapterTitle: 'Chapter Four: The Silent Harbour',
          pageText: 'The mist rose slowly over the silent cobblestones...',
          initialChromeVisible: true,
        ),
      );

      // Tap viewport to toggle chrome off
      await tester.tap(find.byKey(const Key('reader_viewport_tap_target')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('brightness_rail_capsule')), findsNothing);
      expect(find.byKey(const Key('zen_mode_page_counter')), findsOneWidget);
      expect(find.byKey(const Key('reader_bookmark_ribbon')), findsOneWidget);
    });
  });

  group('Tier 1: Feature 23 - Standalone Appearance Sheet (04b)', () {
    testWidgets('6 theme swatches (with Night and OLED locked) and typography slider',
        (tester) async {
      String? chosenTheme;
      double? chosenSize;

      await tester.pumpHarness(
        AppearanceSheetContractWidget(
          selectedTheme: 'Paper',
          onThemeSelected: (th) => chosenTheme = th,
          fontSize: 18,
          onFontSizeChanged: (sz) => chosenSize = sz,
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byKey(const Key('swatch_Paper')), findsOneWidget);
      expect(find.byKey(const Key('swatch_Night')), findsOneWidget);
      expect(find.byKey(const Key('swatch_OLED')), findsOneWidget);

      await tester.tap(find.byKey(const Key('swatch_Sepia')));
      expect(chosenTheme, 'Sepia');

      await tester.drag(find.byKey(const Key('appearance_font_slider')), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(chosenSize, isNotNull);
    });
  });

  group('Tier 1: Feature 24 - Selection & Dictionary Sheet (04c)', () {
    testWidgets('Floating toolbar (5 dots, Define, Copy) and Wiktionary definition card',
        (tester) async {
      var defineTapped = false;
      await tester.pumpHarness(
        SelectionDictionaryContractWidget(
          selectedWord: 'littoral',
          entry: MockDataFixtures.sampleDictionaryEntryLittoral,
          onDefinePressed: () => defineTapped = true,
        ),
      );

      expect(find.byKey(const Key('floating_selection_toolbar')), findsOneWidget);
      expect(find.text('littoral'), findsOneWidget);
      expect(find.text('/ˈlɪt(ə)rəl/'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toolbar_define_button')));
      expect(defineTapped, isTrue);
    });
  });

  group('Tier 1: Feature 26 - In-Book Search Overlay (04e)', () {
    testWidgets('Search displays query, match counter badge, stepper arrows, and keyword highlight',
        (tester) async {
      var nextTapped = false;
      await tester.pumpHarness(
        InBookSearchContractWidget(
          query: 'harbour',
          matchCount: 23,
          currentMatchIndex: 4,
          onNextMatch: () => nextTapped = true,
        ),
      );

      expect(find.byKey(const Key('search_match_counter_badge')), findsOneWidget);
      expect(find.text('23 results'), findsOneWidget);
      expect(find.text('Match 4 of 23 in current chapter'), findsOneWidget);

      await tester.tap(find.byKey(const Key('search_next_match')));
      expect(nextTapped, isTrue);
    });
  });
}

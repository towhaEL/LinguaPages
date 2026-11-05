import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_player.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_search.dart';

import '../../../e2e/helpers/test_app_harness.dart';

/// Fake ReadAloudCubit for driving interactive UI tests on ReadAloudPlayer.
class FakeReadAloudCubit extends Cubit<ReadAloudState> implements ReadAloudCubit {
  FakeReadAloudCubit({ReadAloudState? initialState})
      : super(
          initialState ??
              const ReadAloudState(
                active: true,
                status: ReadAloudStatus.playing,
                speed: 1.0,
                sleep: SleepTimerChoice.off,
                voice: ReadAloudVoice(id: 'voice-1', name: 'Natural Voice 1', language: 'en-US'),
                voices: [
                  ReadAloudVoice(id: 'voice-1', name: 'Natural Voice 1', language: 'en-US'),
                  ReadAloudVoice(id: 'voice-2', name: 'Editorial Voice 2', language: 'en-GB'),
                ],
              ),
        );

  int playCount = 0;
  int pauseCount = 0;
  int nextCount = 0;
  int previousCount = 0;
  int stopCount = 0;

  @override
  String? get language => 'en-US';

  @override
  Future<void> open() async {
    emit(state.copyWith(active: true, status: ReadAloudStatus.playing));
  }

  @override
  Future<void> play() async {
    playCount++;
    emit(state.copyWith(status: ReadAloudStatus.playing));
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    emit(state.copyWith(status: ReadAloudStatus.paused));
  }

  @override
  Future<void> next() async {
    nextCount++;
  }

  @override
  Future<void> previous() async {
    previousCount++;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    emit(state.copyWith(active: false, status: ReadAloudStatus.idle));
  }

  @override
  Future<void> setSpeed(double speed) async {
    emit(state.copyWith(speed: speed));
  }

  @override
  void setSleep(SleepTimerChoice sleep) {
    emit(state.copyWith(sleep: sleep));
  }

  @override
  Future<void> setVoice(ReadAloudVoice voice) async {
    emit(state.copyWith(voice: () => voice));
  }
}

void main() {
  group('Empirical Challenger: In-Book Search Adversarial Stress Tests', () {
    testWidgets('Search 1: Empty and whitespace query strings handle gracefully', (tester) async {
      var searchCalled = false;
      await tester.pumpHarness(
        ReaderSearchSheet(
          search: (q) async {
            searchCalled = true;
            return [];
          },
        ),
      );

      tester.expectNoBottomNavigationBar();
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Submit empty query
      await tester.enterText(searchField, '');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(searchCalled, isFalse);

      // Submit whitespace query
      await tester.enterText(searchField, '     ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(searchCalled, isFalse);

      // Badge displays 0 results
      expect(find.text('0 results'), findsOneWidget);
    });

    testWidgets('Search 2: Zero results displays empty state, disables steppers, prevents divide-by-zero',
        (tester) async {
      await tester.pumpHarness(
        ReaderSearchSheet(
          search: (q) async => [],
        ),
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'nonexistentqueryxyz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Badge displays 0 results
      expect(find.text('0 results'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('No matches found for "nonexistentqueryxyz"'), findsOneWidget);

      // Steppers must be disabled
      final prevBtn = tester.widget<IconButton>(find.byKey(const Key('search_prev_match')));
      final nextBtn = tester.widget<IconButton>(find.byKey(const Key('search_next_match')));
      expect(prevBtn.onPressed, isNull, reason: 'Prev stepper must be disabled when 0 results');
      expect(nextBtn.onPressed, isNull, reason: 'Next stepper must be disabled when 0 results');

      // Clear button resets query
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('0 results'), findsOneWidget);
    });

    testWidgets(r'Search 3: Regex special characters ([, *, +, ?, \, ^, $) treated literally without regex crash',
        (tester) async {
      const regexAttackQueries = [
        '[',
        '*',
        '+',
        '?',
        '\\',
        '^',
        '\$',
        '[a-z]+',
        '(.*)',
        '{1,3}',
      ];

      for (final query in regexAttackQueries) {
        final hits = [
          ReaderSearchHit(
            title: 'Found literal $query',
            snippet: 'Section containing $query in the text here.',
            onSelected: () async {},
          ),
        ];

        await tester.pumpHarness(
          ReaderSearchSheet(
            query: query,
            matchCount: 1,
            currentMatchIndex: 1,
            search: (q) async => hits,
          ),
        );

        // Verifies no FormatException: Invalid regular expression was thrown
        expect(find.byKey(const Key('search_match_counter_badge')), findsOneWidget);
        expect(find.text('1 result'), findsOneWidget);
        expect(find.text('Match 1 of 1 in current chapter'), findsOneWidget);
        expect(find.byType(ReaderSearchSheet), findsOneWidget);
      }
    });

    testWidgets('Search 4: Rapid stepper clicking and boundary wrapping (1 -> 2 -> 3 -> 1, and 1 -> 3)',
        (tester) async {
      final hits = [
        ReaderSearchHit(title: 'Chapter 1', snippet: 'harbour at dawn', onSelected: () async {}),
        ReaderSearchHit(title: 'Chapter 2', snippet: 'harbour at noon', onSelected: () async {}),
        ReaderSearchHit(title: 'Chapter 3', snippet: 'harbour at night', onSelected: () async {}),
      ];

      await tester.pumpHarness(
        ReaderSearchSheet(
          search: (q) async => hits,
        ),
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'harbour');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('3 results'), findsOneWidget);
      expect(find.text('Match 1 of 3 in current chapter'), findsOneWidget);

      // Next: 1 -> 2
      await tester.tap(find.byKey(const Key('search_next_match')));
      await tester.pumpAndSettle();
      expect(find.text('Match 2 of 3 in current chapter'), findsOneWidget);

      // Next: 2 -> 3
      await tester.tap(find.byKey(const Key('search_next_match')));
      await tester.pumpAndSettle();
      expect(find.text('Match 3 of 3 in current chapter'), findsOneWidget);

      // Next wraps: 3 -> 1
      await tester.tap(find.byKey(const Key('search_next_match')));
      await tester.pumpAndSettle();
      expect(find.text('Match 1 of 3 in current chapter'), findsOneWidget);

      // Prev wraps: 1 -> 3
      await tester.tap(find.byKey(const Key('search_prev_match')));
      await tester.pumpAndSettle();
      expect(find.text('Match 3 of 3 in current chapter'), findsOneWidget);

      // Prev: 3 -> 2
      await tester.tap(find.byKey(const Key('search_prev_match')));
      await tester.pumpAndSettle();
      expect(find.text('Match 2 of 3 in current chapter'), findsOneWidget);

      // Rapid clicking next 9 times -> (2 + 9) % 3 = 11 % 3 = 2
      for (var i = 0; i < 9; i++) {
        await tester.tap(find.byKey(const Key('search_next_match')));
      }
      await tester.pumpAndSettle();
      expect(find.text('Match 2 of 3 in current chapter'), findsOneWidget);
    });

    testWidgets('Search 5: Return to position button and Done button invocation', (tester) async {
      var returnPositionCalled = false;
      var doneCalled = false;

      await tester.pumpHarness(
        ReaderSearchSheet(
          query: 'anchor',
          matchCount: 4,
          currentPositionLabel: 'Page 204 (75%)',
          onReturnToPosition: () => returnPositionCalled = true,
          onDone: () => doneCalled = true,
        ),
      );

      // Verify position label rendered
      expect(find.text('Return to position'), findsOneWidget);
      expect(find.text('Page 204 (75%)'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Return to position
      await tester.tap(find.text('Return to position'));
      await tester.pumpAndSettle();
      expect(returnPositionCalled, isTrue);

      // Pump new sheet to test Done
      await tester.pumpHarness(
        ReaderSearchSheet(
          query: 'anchor',
          onDone: () => doneCalled = true,
        ),
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(doneCalled, isTrue);

      // Verify zero bottom nav
      tester.expectNoBottomNavigationBar();
    });
  });

  group('Empirical Challenger: Text Selection & Wiktionary Lookup Stress Tests', () {
    testWidgets('Selection 1: Long words (100+ chars) render without crashing', (tester) async {
      const extremeWord =
          'Pneumonoultramicroscopicsilicovolcanoconiosispneumonoultramicroscopicsilicovolcanoconiosis'
          'supercalifragilisticexpialidociousantidisestablishmentarianism';

      const entry = DictionaryEntry(
        word: extremeWord,
        phonetic: '/ˌnjuːmənoʊ/',
        meanings: [
          DictionaryMeaning(
            partOfSpeech: 'noun',
            definitions: [
              DictionaryDefinition(
                definition: 'An extremely long fabricated lung disease term.',
                example: 'He pronounced pneumonoultramicroscopicsilicovolcanoconiosis with ease.',
              ),
            ],
          ),
        ],
      );

      await tester.pumpHarness(
        DictionaryLookupSheet(
          selectedText: extremeWord,
          entry: entry,
          onHighlight: () async {},
        ),
      );

      expect(find.text(extremeWord), findsOneWidget);
      expect(find.text('1. '), findsOneWidget);
      expect(find.text('An extremely long fabricated lung disease term.'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Selection 2: Special accented and non-Latin words render cleanly', (tester) async {
      const accentedWords = ['café', 'naïve', 'façade', 'über', '日本語'];

      for (final word in accentedWords) {
        final entry = DictionaryEntry(
          word: word,
          phonetic: '/test/',
          meanings: [
            DictionaryMeaning(
              partOfSpeech: 'noun',
              definitions: [
                DictionaryDefinition(
                  definition: 'Definition of $word in the lexicon.',
                ),
              ],
            ),
          ],
        );

        await tester.pumpHarness(
          DictionaryLookupSheet(
            selectedText: word,
            entry: entry,
            onHighlight: () async {},
          ),
        );

        expect(find.text(word), findsOneWidget);
        expect(find.text('Definition of $word in the lexicon.'), findsOneWidget);
      }
    });

    testWidgets('Selection 3: Words with empty dictionary response render offline fallback sheet', (tester) async {
      // Direct offline sheet rendering via empty entry or offline fallback
      await tester.pumpHarness(
        const DictionaryLookupSheet(
          selectedText: 'unknownlexiconword',
          entry: null,
          onHighlight: _dummyHighlight,
        ),
      );

      // Verify the widget structure or safe loading / error boundary
      expect(find.byType(DictionaryLookupSheet), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Selection 4: FloatingSelectionToolbar 5 color dots and actions', (tester) async {
      final selectedColors = <HighlightColor>[];
      var defineTapped = false;
      var copyTapped = false;

      await tester.pumpHarness(
        FloatingSelectionToolbar(
          onColorSelected: (c) => selectedColors.add(c),
          onDefinePressed: () => defineTapped = true,
          onCopyPressed: () => copyTapped = true,
        ),
      );

      expect(find.byKey(const Key('floating_selection_toolbar')), findsOneWidget);
      expect(find.byKey(const Key('toolbar_define_button')), findsOneWidget);
      expect(find.byKey(const Key('toolbar_copy_button')), findsOneWidget);

      // Tap Define
      await tester.tap(find.byKey(const Key('toolbar_define_button')));
      await tester.pumpAndSettle();
      expect(defineTapped, isTrue);

      // Tap Copy
      await tester.tap(find.byKey(const Key('toolbar_copy_button')));
      await tester.pumpAndSettle();
      expect(copyTapped, isTrue);

      // Tap color dots (Yellow, Green, Blue, Pink, Orange)
      final dotFinders = find.byType(GestureDetector);
      // There are 5 color dot GestureDetector widgets
      expect(dotFinders, findsWidgets);

      await tester.tap(dotFinders.at(0));
      await tester.tap(dotFinders.at(1));
      await tester.tap(dotFinders.at(2));
      await tester.tap(dotFinders.at(3));
      await tester.tap(dotFinders.at(4));
      await tester.pumpAndSettle();

      expect(selectedColors, containsAll([
        HighlightColor.yellow,
        HighlightColor.green,
        HighlightColor.blue,
        HighlightColor.pink,
      ]));
      expect(selectedColors.length, 5);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Selection 5: Fast action row Flashcard and Copy buttons in DictionaryLookupSheet',
        (tester) async {
      var copyPressed = false;
      const entry = DictionaryEntry(
        word: 'solitude',
        phonetic: '/ˈsɒl.ɪ.tjuːd/',
        meanings: [
          DictionaryMeaning(
            partOfSpeech: 'noun',
            definitions: [
              DictionaryDefinition(
                definition: 'The state of being alone.',
              ),
            ],
          ),
        ],
      );

      await tester.pumpHarness(
        DictionaryLookupSheet(
          selectedText: 'solitude',
          entry: entry,
          onHighlight: () async {},
          onCopyPressed: () => copyPressed = true,
        ),
      );

      expect(find.text('Add to Flashcards'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('From Wiktionary · CC BY-SA 3.0 · Offline Lexicon'), findsOneWidget);
      expect(find.text('0 B used'), findsOneWidget);

      // Tap Add to Flashcards (safe invocation)
      await tester.tap(find.text('Add to Flashcards'));
      await tester.pumpAndSettle();

      // Tap Copy
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(copyPressed, isTrue);
    });
  });

  group('Empirical Challenger: Read Aloud Player Adversarial Stress Tests', () {
    testWidgets('Audio 1: Scrubber dragging to boundaries (0.00 and 1.00) clamps safely', (tester) async {
      await tester.pumpHarness(
        const ReadAloudPlayer(),
      );

      tester.expectNoBottomNavigationBar();
      expect(find.byKey(const Key('read_aloud_player_sheet')), findsOneWidget);

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      var slider = tester.widget<Slider>(sliderFinder);
      expect(slider.value, 0.35);

      // Drag all the way to the left (0.00 / 0:00)
      await tester.drag(sliderFinder, const Offset(-300, 0));
      await tester.pumpAndSettle();

      slider = tester.widget<Slider>(sliderFinder);
      expect(slider.value, 0.0);

      // Drag all the way to the right (1.00 / end of chapter)
      await tester.drag(sliderFinder, const Offset(600, 0));
      await tester.pumpAndSettle();

      slider = tester.widget<Slider>(sliderFinder);
      expect(slider.value, 1.0);

      // Drag back to center
      await tester.drag(sliderFinder, const Offset(-150, 0));
      await tester.pumpAndSettle();

      slider = tester.widget<Slider>(sliderFinder);
      expect(slider.value, greaterThan(0.0));
      expect(slider.value, lessThan(1.0));
    });

    testWidgets('Audio 2: Playback controls toggle play/pause, skip back, and skip forward', (tester) async {
      var playPauseTapped = false;
      var skipBackTapped = false;
      var skipForwardTapped = false;

      await tester.pumpHarness(
        ReadAloudPlayer(
          isPlaying: true,
          onPlayPause: () => playPauseTapped = true,
          onSkipBack: () => skipBackTapped = true,
          onSkipForward: () => skipForwardTapped = true,
        ),
      );

      // Play/pause hero button (64px circle)
      final heroBtn = find.byKey(const Key('read_aloud_play_pause_hero'));
      expect(heroBtn, findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await tester.tap(heroBtn);
      await tester.pumpAndSettle();
      expect(playPauseTapped, isTrue);

      // Skip back (replay_10)
      await tester.tap(find.byKey(const Key('read_aloud_skip_back')));
      await tester.pumpAndSettle();
      expect(skipBackTapped, isTrue);

      // Skip forward (forward_10)
      await tester.tap(find.byKey(const Key('read_aloud_skip_forward')));
      await tester.pumpAndSettle();
      expect(skipForwardTapped, isTrue);
    });

    testWidgets('Audio 3: Speed, Voice, and Sleep timer chips interactive dialog flow with ReadAloudCubit',
        (tester) async {
      final fakeCubit = FakeReadAloudCubit();

      await tester.pumpHarness(
        BlocProvider<ReadAloudCubit>.value(
          value: fakeCubit,
          child: const ReadAloudPlayer(),
        ),
      );

      // 1. Speed chip interaction: 1.0x -> pick 1.5x
      expect(find.text('1.0x'), findsOneWidget);
      await tester.tap(find.text('1.0x'));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Speech Rate'), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);

      await tester.tap(find.text('1.5x'));
      await tester.pumpAndSettle();

      expect(fakeCubit.state.speed, 1.5);
      expect(find.text('1.5x'), findsOneWidget);

      // 2. Voice chip interaction: pick Editorial Voice 2
      expect(find.text('Natural Voice 1'), findsOneWidget);
      await tester.tap(find.text('Natural Voice 1'));
      await tester.pumpAndSettle();

      expect(find.text('Read Aloud Voice'), findsOneWidget);
      expect(find.text('Editorial Voice 2 · en-GB'), findsOneWidget);

      await tester.tap(find.text('Editorial Voice 2 · en-GB'));
      await tester.pumpAndSettle();

      expect(fakeCubit.state.voice?.name, 'Editorial Voice 2');
      expect(find.text('Editorial Voice 2'), findsOneWidget);

      // 3. Sleep timer chip interaction: pick 30 minutes
      final sleepFinder = find.text('30 min timer');
      expect(sleepFinder, findsOneWidget);
      await tester.ensureVisible(sleepFinder);
      await tester.tap(sleepFinder);
      await tester.pumpAndSettle();

      expect(find.text('Sleep Timer'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);

      await tester.tap(find.text('30 minutes'));
      await tester.pumpAndSettle();

      expect(fakeCubit.state.sleep, SleepTimerChoice.minutes30);
      expect(find.text('30 min'), findsOneWidget);

      // 4. Hero button triggers cubit pause/play
      await tester.tap(find.byKey(const Key('read_aloud_play_pause_hero')));
      await tester.pumpAndSettle();
      expect(fakeCubit.pauseCount, 1);

      await fakeCubit.close();
    });

    testWidgets('Audio 4: Custom book metadata, sentence quote card and zero-bottom-nav check',
        (tester) async {
      final customBook = BookEntity(
        id: 'adversarial-book-1',
        title: 'Adversarial Edge Test Edition',
        author: 'Professor Q. Stress-Tester',
        format: DocumentFormat.markdown,
        sourceUri: '',
        sourceFileName: 'stress.md',
        contentFingerprint: 'adv-fp-1',
        addedAt: DateTime(2026, 11, 5),
      );

      const sentence = 'The ink flowed across the parchment in perfect silent defiance.';

      await tester.pumpHarness(
        ReadAloudPlayer(
          book: customBook,
          spokenSentence: sentence,
        ),
      );

      expect(find.text('Adversarial Edge Test Edition'), findsOneWidget);
      expect(find.text('Professor Q. Stress-Tester'), findsOneWidget);
      expect(find.text('MARKDOWN'), findsOneWidget);
      expect(find.text('“$sentence”'), findsOneWidget);
      expect(find.byKey(const Key('player_sentence_quote_card')), findsOneWidget);

      // Strict architectural check
      tester.expectNoBottomNavigationBar();
    });
  });
}

Future<void> _dummyHighlight() async {}

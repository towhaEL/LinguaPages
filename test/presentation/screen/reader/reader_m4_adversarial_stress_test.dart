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

  group('Read aloud player', () {
    final book = BookEntity(
      id: 'player-book-1',
      title: 'Adversarial Edge Test Edition',
      author: 'Professor Q. Stress-Tester',
      format: DocumentFormat.markdown,
      sourceUri: '',
      sourceFileName: 'stress.md',
      contentFingerprint: 'adv-fp-1',
      addedAt: DateTime(2026, 11, 5),
    );

    Future<FakeReadAloudCubit> pumpPlayer(
      WidgetTester tester, {
      double progress = .42,
      VoidCallback? onTap,
      ReadAloudState? state,
    }) async {
      final cubit = FakeReadAloudCubit(initialState: state);
      await tester.pumpHarness(
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocProvider<ReadAloudCubit>.value(
            value: cubit,
            child: ReadAloudPlayer(book: book, progress: progress, onTap: onTap),
          ),
        ),
      );
      return cubit;
    }

    testWidgets('shows the book, live status and real progress', (tester) async {
      final cubit = await pumpPlayer(tester);

      expect(find.text('Adversarial Edge Test Edition'), findsOneWidget);
      expect(find.text('Reading aloud · 42%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('read_aloud_progress')),
      );
      expect(bar.value, closeTo(.42, 1e-9));
      expect(find.byType(Slider), findsNothing);

      await cubit.pause();
      await tester.pump();
      expect(find.text('Paused · 42%'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
      await cubit.close();
    });

    testWidgets('transport buttons drive the cubit', (tester) async {
      final cubit = await pumpPlayer(tester);

      await tester.tap(find.byKey(const Key('read_aloud_play_pause_hero')));
      await tester.pump();
      expect(cubit.pauseCount, 1);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('read_aloud_play_pause_hero')));
      await tester.pump();
      expect(cubit.playCount, 1);

      await tester.tap(find.byKey(const Key('read_aloud_skip_back')));
      await tester.tap(find.byKey(const Key('read_aloud_skip_forward')));
      await tester.pump();
      expect(cubit.previousCount, 1);
      expect(cubit.nextCount, 1);

      await tester.tap(find.byKey(const Key('read_aloud_close')));
      await tester.pump();
      expect(cubit.stopCount, 1);
      await cubit.close();
    });

    testWidgets('tapping the book runs onTap', (tester) async {
      var tapped = false;
      final cubit = await pumpPlayer(tester, onTap: () => tapped = true);

      await tester.tap(find.byKey(const Key('read_aloud_player_open')));
      expect(tapped, isTrue);
      await cubit.close();
    });

    testWidgets('controls sheet sets speed, voice from every voice, and sleep',
        (tester) async {
      final voices = [
        for (var i = 1; i <= 7; i++)
          ReadAloudVoice(id: 'v$i', name: 'Voice $i', language: 'en-US'),
        const ReadAloudVoice(id: 'fr', name: 'Voix', language: 'fr-FR'),
      ];
      final cubit = FakeReadAloudCubit(
        initialState: ReadAloudState(
          active: true,
          status: ReadAloudStatus.playing,
          voices: voices,
          voice: voices.first,
        ),
      );
      final progress = ValueNotifier<double>(.25);
      await tester.pumpHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showReadAloudControls(
              context,
              cubit: cubit,
              book: book,
              progress: progress,
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('read_aloud_controls_sheet')), findsOneWidget);
      expect(find.text('Reading aloud · 25%'), findsOneWidget);

      progress.value = .5;
      await tester.pump();
      expect(find.text('Reading aloud · 50%'), findsOneWidget);

      await tester.tap(find.text('1.5×'));
      await tester.pump();
      expect(cubit.state.speed, 1.5);

      await tester.ensureVisible(find.text('30 minutes'));
      await tester.tap(find.text('30 minutes'));
      await tester.pump();
      expect(cubit.state.sleep, SleepTimerChoice.minutes30);

      await tester.ensureVisible(find.byKey(const Key('read_aloud_voice_tile')));
      await tester.tap(find.byKey(const Key('read_aloud_voice_tile')));
      await tester.pumpAndSettle();
      // All of them, not just the first five; other languages listed apart.
      await tester.scrollUntilVisible(find.text('Voix'), 200,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('Other languages'), findsOneWidget);
      await tester.tap(find.text('Voix'));
      await tester.pumpAndSettle();
      expect(cubit.state.voice?.id, 'fr');

      await tester.ensureVisible(find.byKey(const Key('read_aloud_stop_button')));
      await tester.tap(find.byKey(const Key('read_aloud_stop_button')));
      await tester.pumpAndSettle();
      expect(cubit.stopCount, 1);
      expect(find.byKey(const Key('read_aloud_controls_sheet')), findsNothing);
      await cubit.close();
    });
  });
}

Future<void> _dummyHighlight() async {}

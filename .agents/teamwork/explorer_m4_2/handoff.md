# Handoff Report: Milestone 4 Test Infrastructure & Integration Contracts

**Author**: explorer_m4_2  
**Target Milestone**: Milestone 4 — Reader Experience & Overlays (Requirement R2)  
**Date**: 2026-11-04  
**Integrity Mode**: Development (Read-Only Investigation)  

---

## 1. Observation

### 1.1 Test Infrastructure Layout and Execution
We inspected the test suites and harnesses across `test/e2e/` and `test/presentation/screen/reader/`:
- **E2E Test Suite Master**: `test/e2e/all_e2e_tests.dart` aggregates Tier 1 (Features 1–32), Tier 2 (Boundary & Corner Cases), Tier 3 (Cross-Feature Combinations & State Synchronization), and Tier 4 (Real-World Application Scenarios).
  - Executed: `fvm flutter test test/e2e/all_e2e_tests.dart`
  - Output: `00:04 +48: All tests passed!` (48 tests passing synchronously in hermetic execution).
- **Reader Presentation Test Suite**:
  - `test/presentation/screen/reader/reader_tap_zones_test.dart` (3 tests)
  - `test/presentation/screen/reader/marked_text_test.dart` (4 tests)
  - `test/presentation/screen/reader/read_aloud/read_aloud_test.dart` (10 tests)
  - `test/presentation/screen/reader/dictionary_lookup_cubit_test.dart` (4 tests)
  - Executed: `fvm flutter test test/presentation/screen/reader/`
  - Output: `00:05 +21: All tests passed!` (21 unit and cubit tests passing).

### 1.2 Architectural Invariant: Bottom Navigation Bar Prohibition
`test/e2e/helpers/test_app_harness.dart` (lines 177–191) explicitly enforces:
```dart
void expectNoBottomNavigationBar() {
  expect(
    find.byType(NavigationBar),
    findsNothing,
    reason: 'Architecture violation: NavigationBar must NOT be present!',
  );
  expect(
    find.byType(BottomNavigationBar),
    findsNothing,
    reason: 'Architecture violation: BottomNavigationBar must NOT be present!',
  );
}
```
This check is asserted across all screens and sheets, including `reader_and_overlays_test.dart` line 567, `audio_settings_paywall_test.dart` lines 570, 618, 665, `tokens_and_theme_test.dart` line 121, and `user_journeys_test.dart` lines 317, 335.

### 1.3 Design Token and Visual Specifications
In `test/e2e/helpers/test_app_harness.dart` (lines 8–41):
- **Canvas Ivory**: `Color(0xFFFAF7F2)`
- **Card Surface / Sheet Background**: `Color(0xFFFFFFFF)`
- **Hairline Divider**: `Color(0xFFE8E2D9)` (1px width)
- **Primary Ink Text**: `Color(0xFF1C1B1A)`
- **Subtitle Secondary Text**: `Color(0xFF6B655D)`
- **Accent Ink Blue**: `Color(0xFF2F4A7A)`
- **Spoken Sentence Highlight**: `Color(0xFFD6E2F5)`
- **Paper Canvas**: `Color(0xFFF6F1E7)`
- **Destructive**: `Color(0xFFBA1A1A)`
- **Highlight Palette**: Yellow `0xFFFDE047`, Green `0xFF86EFAC`, Blue `0xFF93C5FD`, Pink `0xFFF472B6`, Orange `0xFFFDBA74`, Amber `0xFFE5A93C`
- **Radii System**: Cards `16.0px`, Bottom Sheets `24.0px`–`28.0px`, Chips/Pills `StadiumBorder()`, Book Covers `4.0px`
- **Typography**: Headings/Quotes in `Newsreader` (serif), Controls/Metadata in `Inter` (sans), Numbers/Counters in `FontFeature.tabularFigures()`.

### 1.4 E2E Overlay Contracts Observed

#### A. Reader Chrome & Zen Mode (Features 21 & 22)
Observed in `test/e2e/tier1_features/reader_and_overlays_test.dart` (lines 9–219, 549–591):
- **Chrome Visible State**:
  - Paper canvas `#F6F1E7`.
  - Top bar with back button, book title (`The Shadow of the Wind`), search icon button `Key('reader_search_button')`, bookmark button `Key('reader_bookmark_button')`.
  - Left edge brightness rail capsule: `Key('brightness_rail_capsule')` (32px width, vertical slider, `white 0.9 opacity`, hairline border).
  - Bottom panel (`ReaderBottomBar`): progress slider, position label (`'37%'`), and 4 tools:
    1. Contents: `ReaderTool(icon: Icons.format_list_bulleted, label: 'Contents')`
    2. Appearance: `ReaderTool(icon: Icons.text_fields, label: 'Appearance')`
    3. Listen: `ReaderTool(icon: Icons.headphones, label: 'Listen')`
    4. Notes: `ReaderTool(icon: Icons.edit_note, label: 'Notes')`
- **Zen Mode (Chrome Hidden)**:
  - Tapping viewport `Key('reader_viewport_tap_target')` hides chrome slots.
  - Page footer displays unobtrusive page counter `Key('zen_mode_page_counter')` (`'142 / 380 · 37%'`) with tabular figures.
  - Brightness rail is hidden (`findsNothing`).
  - Top bookmark ribbon `Key('reader_bookmark_ribbon')` remains visible (14×38px `#2F4A7A`).

#### B. Standalone Appearance Sheet (Feature 23 / Screen `04b_appearance_sheet`)
Observed in `test/e2e/tier1_features/reader_and_overlays_test.dart` (lines 221–320, 593–620):
- **Theme Swatches**: 6 circular swatches (44×44px, 1px border default, 2.5px `#2F4A7A` when selected):
  1. `Key('swatch_Paper')` (`#F6F1E7`, unlocked)
  2. `Key('swatch_White')` (`#FFFFFF`, unlocked)
  3. `Key('swatch_Sepia')` (`#F4ECD8`, unlocked)
  4. `Key('swatch_Grey')` (`#EAE6DF`, unlocked)
  5. `Key('swatch_Night')` (`#23272A`, locked with `Icon(Icons.lock)`)
  6. `Key('swatch_OLED')` (`#121212`, locked with `Icon(Icons.lock)`)
- **Typography Sliders**: `Key('appearance_font_slider')` with `A−` (14px, w700) and `A+` (18px, w700), bounds `min: 12`, `max: 28`.
- In Stitch HTML `04b_appearance_sheet_screen.html` (lines 284–449):
  - Font picker: `Newsreader`, `Inter`, `Literata`, `EB Garamond`, `Source Serif 4`.
  - Sliders: Font Size (12–28 pt), Line Spacing (1.1–2.2×), Side Margins (12–44 px).
  - Segmented controls: Reading mode (`Scroll`, `Pages`, `Two columns`).
  - Toggles: `Justify text`, `Hyphenation`, `Publisher styles`.
  - Brightness: 10–100% horizontal slider + `Follow system brightness` toggle.
- In `tier3_cross_feature/cross_feature_sync_test.dart` (lines 160–181): Tapping Sepia/Night dynamically changes reader scaffold background to `0xFFF4ECD8` and `0xFF23272A`.

#### C. Floating Selection Toolbar & Wiktionary Sheet (Feature 24 / Screen `04c_text_selection_dictionary`)
Observed in `test/e2e/tier1_features/reader_and_overlays_test.dart` (lines 322–442, 622–641):
- **Floating Selection Toolbar**:
  - Key: `Key('floating_selection_toolbar')`, dark pill `#1C1B1A`, radius 24px.
  - 5 highlight color dots (16×16px circular): Yellow `#FDE047`, Green `#86EFAC`, Blue `#93C5FD`, Pink `#F472B6`, Orange `#FDBA74`.
  - Define button: `Key('toolbar_define_button')`, `Text('Define')`.
  - Copy button: `Key('toolbar_copy_button')`, `Icon(Icons.copy)`.
- **Bottom Wiktionary Definition Card**:
  - 28px top radius, white background.
  - Word title: Newsreader 26px w600 (`entry.word`).
  - Phonetic text: `entry.phonetic` in `#6B655D`.
  - Part of speech chip: `Chip(label: Text('adjective · Local Lexicon'))`.
  - Definition text with line height 1.45.
  - Attribution footer: `'From Wiktionary · CC BY-SA 3.0 · Offline Lexicon'`.
- In `tier3_cross_feature/cross_feature_sync_test.dart` (lines 208–242): Tapping Define opens Wiktionary sheet populated with word and definition.

#### D. In-Book Search Overlay (Feature 26 / Screen `04e_search_in_book`)
Observed in `test/e2e/tier1_features/reader_and_overlays_test.dart` (lines 444–546, 643–663):
- **Search Header**:
  - Search input displaying query string.
  - Match counter badge: `Key('search_match_counter_badge')` with background `WarmEditorialTokens.spokenHighlight` (`#D6E2F5`), text `'$matchCount results'` in `#2F4A7A`.
  - Stepper navigation buttons: `Key('search_prev_match')` (`Icons.arrow_upward`), `Key('search_next_match')` (`Icons.arrow_downward`).
- **Occurrence Context & Snippet Card**:
  - Subheader: `'Match $currentMatchIndex of $matchCount in current chapter'`.
  - Snippet card with highlighted keyword in `spokenHighlight` `#D6E2F5` and bold font weight.
- In `tier2_boundary/boundary_and_corners_test.dart` (lines 71–106):
  - Zero results state: `Icons.search_off_rounded`, text `'No matches found for "$query"'` (`Newsreader 18px w600`), and hint `'Check your spelling or search across all chapters.'`.

#### E. Spoken Sentence Tracking & Read Aloud Player Sheet (Features 27 & 28 / Screen `05_read_aloud`)
Observed in `test/e2e/tier1_features/audio_settings_paywall_test.dart` (lines 9–236, 551–597):
- **Reader Canvas Sentence Highlight**:
  - `Key('spoken_sentence_highlight_band')`, background `WarmEditorialTokens.spokenHighlight` (`#D6E2F5`), Newsreader 18px w600 ink text.
- **Expanded Player Bottom Sheet**:
  - `Key('read_aloud_player_sheet')`, white card, 28px top radius, drag handle 40×4px `#DCDAD5`.
  - Header: 44×64px cover thumbnail (`BookCover(compact: true)`), title in Newsreader 16px w600, author in Inter 12px `#6B655D`.
  - Sentence quote card: `Key('player_sentence_quote_card')`, `#FAF7F2` background, 12px radius, left border 3.5px `#2F4A7A`, Newsreader 15px italic text.
  - Progress timeline scrubber slider (`activeColor: #2F4A7A`).
  - Hero Play/Pause button: `Key('read_aloud_play_pause_hero')`, 64×64px circle in `#2F4A7A`, white 32px icon (`Icons.play_arrow` / `Icons.pause`).
  - Steppers: `Key('read_aloud_skip_back')` (`Icons.replay_10`), `Key('read_aloud_skip_forward')` (`Icons.forward_10`).
  - Fine-tuning pills: Speed (`1.25x`), Voice (`Natural Voice 2`), Sleep timer (`30 min timer`).
- In `tier3_cross_feature/cross_feature_sync_test.dart` (lines 244–287): Tapping play/pause syncs sentence highlight band between `#D6E2F5` and transparent.

### 1.5 Current State of Source Code Implementation
In `lib/presentation/screen/reader/`:
- `reader_screen.dart` is currently a monolithic file (3,558 lines).
- `_ReaderSettingsSheet` (lines 2625–2850) and `_ReaderSearchSheet` (lines 3384–3550) are implemented as private classes within `reader_screen.dart`.
- Standalone modular files specified in `PROJECT.md` interface contracts:
  - `lib/presentation/screen/reader/widgets/appearance_sheet.dart` does NOT yet exist as a separate file.
  - `lib/presentation/screen/reader/widgets/reader_search.dart` does NOT yet exist as a separate file.
  - `lib/presentation/screen/reader/widgets/contents_annotations_sheet.dart` does NOT yet exist as a separate file (partially handled in `notes_sheet.dart`).
- Existing public components:
  - `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` (408 lines) exists and works with `DictionaryLookupCubit`.
  - `lib/presentation/screen/reader/widgets/notes_sheet.dart` (456 lines) exists for notes and bookmarks.
  - `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart` (217 lines) exists.
  - `lib/presentation/screen/reader/widgets/reader_chrome.dart` (318 lines) exists.
  - `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` (234 lines) exists but is a compact bottom docked bar rather than the expanded sheet specified in `05_read_aloud` (which requires the 64px hero play button, quote card, scrubber, and chips).

---

## 2. Logic Chain

1. **Premise**: Milestone 4 requires production implementation and integration of Reader Experience & Overlays (Requirement R2, Features 1–6 in `PROJECT.md`).
2. **Observation**: E2E test files (`reader_and_overlays_test.dart`, `audio_settings_paywall_test.dart`, `boundary_and_corners_test.dart`, `cross_feature_sync_test.dart`, and `user_journeys_test.dart`) test these features using contract widgets that specify exact widget keys, token colors, element hierarchies, and dimensions.
3. **Observation**: All 48 E2E tests and 21 unit/cubit tests in `test/presentation/screen/reader/` currently pass against existing test contracts.
4. **Deduction on Modular Extraction**: `PROJECT.md` specifies interface contracts at explicit paths:
   - `lib/presentation/screen/reader/widgets/appearance_sheet.dart`
   - `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`
   - `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart`
   - `lib/presentation/screen/reader/widgets/contents_annotations_sheet.dart` (or `notes_sheet.dart`)
   - `lib/presentation/screen/reader/widgets/reader_search.dart`
   - `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`
5. **Deduction on UI Upgrades**: To achieve full pixel-perfection matching the Stitch canvas designs:
   - `appearance_sheet.dart` must export `AppearanceSheet` matching `04b_appearance_sheet` with 6 swatches (`Key('swatch_$name')`), font picker, sliders with `Key('appearance_font_slider')`, layout controls, and brightness.
   - `dictionary_lookup_sheet.dart` and the floating text selection toolbar must provide the 5 color dots, Define (`Key('toolbar_define_button')`), Copy (`Key('toolbar_copy_button')`), and the Wiktionary definition card with phonetics and chips.
   - `contents_annotations_sheet.dart` must unify TOC chapter tree with reading progress banner, bookmarks, highlights, and Markdown export (`Key('export_markdown_button')`).
   - `reader_search.dart` must export `ReaderSearch` matching `04e_search_in_book` with query input, `Key('search_match_counter_badge')`, steppers (`Key('search_prev_match')`, `Key('search_next_match')`), and chapter snippet cards.
   - `read_aloud_player.dart` must be enhanced or provide `ReadAloudPlayerSheet` with `Key('read_aloud_player_sheet')`, `Key('spoken_sentence_highlight_band')`, `Key('player_sentence_quote_card')`, and `Key('read_aloud_play_pause_hero')` (64×64px).
6. **Deduction on Zero Nav Bar Rule**: Any new sheet, modal, or overlay must strictly NOT introduce persistent bottom navigation bars. The `tester.expectNoBottomNavigationBar()` assertion must continue to hold.

---

## 3. Caveats

1. **Readium vs Fallback Modes**: The reader operates in two modes: native Readium for reflowable EPUBs and fallback engines for PDF/TXT. Test harnesses run hermetically without native Readium libraries, relying on `MockDataFixtures` and fallback widgets. Any new overlay widgets must operate seamlessly in both live Readium and hermetic fallback widget testing.
2. **Audio TTS Platform Engine**: Read Aloud in production interacts with platform TTS (`FlutterTts`), whereas tests use `_FakeService` or `MockDataFixtures`. Test contracts verify the presentation state machine (`ReadAloudCubit`) and UI layout.
3. **No Direct Source Editing in this Role**: As an explorer subagent, this investigation is strictly read-only. Concrete implementation will be carried out by implementer agents.

---

## 4. Conclusion

The integration contracts and test infrastructure for Milestone 4 are clear, rigorous, and fully specified:
1. **Contracts & Keys Required**:
   - `AppearanceSheet`: `swatch_Paper`, `swatch_White`, `swatch_Sepia`, `swatch_Grey`, `swatch_Night` (locked), `swatch_OLED` (locked), `appearance_font_slider`.
   - `SelectionDictionary`: `floating_selection_toolbar`, `toolbar_define_button`, `toolbar_copy_button`, 5 color dot indicators.
   - `InBookSearch`: `search_match_counter_badge`, `search_prev_match`, `search_next_match`, snippet cards.
   - `ReadAloud`: `spoken_sentence_highlight_band` (`#D6E2F5`), `read_aloud_player_sheet`, `player_sentence_quote_card`, `read_aloud_play_pause_hero` (64×64px), `read_aloud_skip_back`, `read_aloud_skip_forward`.
   - `ContentsAnnotations`: `export_markdown_button`, TOC chapter tree, bookmarks and highlights tabs.
2. **Boundary & Edge Cases Required**:
   - Zero search results empty state (`Icons.search_off_rounded`, `"No matches found for..."`).
   - Wiktionary lookup missing word graceful fallback (`Icons.search_off`, `"No definition found in offline lexicon"`).
   - Extreme string length handling (`maxLines` with `TextOverflow.ellipsis`).
   - Long definition scroll bounds (constrained within max 75% screen height).
   - Premium lock previews (preview live without persisting until unlocked).
3. **Strict Invariant**: Zero `NavigationBar` or `BottomNavigationBar` widgets anywhere in the tree.

---

## 5. Verification Method

To independently verify the test infrastructure and overlay contracts:
1. Run all E2E test suites:
   ```bash
   fvm flutter test test/e2e/all_e2e_tests.dart
   ```
   *Expected Result*: All 48 tests pass with 0 failures.
2. Run reader-specific E2E tests:
   ```bash
   fvm flutter test test/e2e/tier1_features/reader_and_overlays_test.dart
   fvm flutter test test/e2e/tier1_features/audio_settings_paywall_test.dart
   ```
   *Expected Result*: Both suites pass completely.
3. Run reader unit and presentation tests:
   ```bash
   fvm flutter test test/presentation/screen/reader/
   ```
   *Expected Result*: All 21 tests pass.
4. Run static analysis:
   ```bash
   fvm flutter analyze
   ```
   *Expected Result*: Zero issues/warnings.
5. Invalidation conditions: Any test failure in E2E suites, any appearance of `NavigationBar` or `BottomNavigationBar`, or any violation of the Warm Editorial token palette (`#FAF7F2`, `#FFFFFF`, `#E8E2D9`, `#1C1B1A`, `#6B655D`, `#2F4A7A`, `#D6E2F5`, `#F6F1E7`).

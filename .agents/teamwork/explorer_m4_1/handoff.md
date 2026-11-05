# Milestone 4 Investigation & Implementation Plan: Reader Experience & Overlays (Requirement R2)

## 1. Observation

### 1.1 Existing Files and Directory Layout
A comprehensive scan of `lib/presentation/screen/reader/` and related directories was conducted:
- `lib/presentation/screen/reader/reader_screen.dart` (3,558 lines): Main stateful reader orchestrator.
- `lib/presentation/screen/reader/widgets/reader_chrome.dart` (318 lines): Reader chrome slots, top bar, and bottom bar.
- `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` (408 lines): Dictionary lookup modal, currently using `DictionaryLookupCubit`.
- `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart` (217 lines): Highlight color and note editor.
- `lib/presentation/screen/reader/widgets/notes_sheet.dart` (456 lines): Annotations sheet currently only listing Bookmarks and Highlights (lacks Contents TOC).
- `lib/presentation/screen/reader/widgets/marked_text.dart` (59 lines): Utility creating `TextSpan` highlights for fallback reader pages.
- `lib/presentation/screen/reader/widgets/reader_tap_zones.dart` (73 lines): Reader gesture zones.
- `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` (234 lines): Compact read aloud player docked at bottom.
- `lib/presentation/screen/reader/read_aloud/read_aloud_cubit.dart` (229 lines): Drives read-aloud state, speed, sleep timer, voices.
- `lib/presentation/screen/reader/cubit/dictionary_lookup_cubit.dart` & `dictionary_lookup_state.dart`: BLoC state for dictionary lookups.

### 1.2 Missing Files Required by Architecture and Interface Contracts
Inspecting `PROJECT.md` and `STITCH_UI_IMPLEMENTATION_GUIDE.md`:
- `lib/presentation/screen/reader/widgets/appearance_sheet.dart`: **Does NOT exist**. Currently implemented as private inner class `_ReaderSettingsSheet` in `reader_screen.dart` lines 2625–3308.
- `lib/presentation/screen/reader/widgets/reader_search.dart`: **Does NOT exist**. Currently implemented as private inner class `_ReaderSearchSheet` in `reader_screen.dart` lines 3384–3558.
- `lib/presentation/screen/reader/widgets/reader_selection_toolbar.dart`: **Does NOT exist**. Text selection context menu is built via `AdaptiveTextSelectionToolbar.buttonItems` in `_readerContextMenu` in `reader_screen.dart` lines 3351–3382.

### 1.3 Trigger Mechanisms in `reader_screen.dart`
Direct observations of trigger methods in `lib/presentation/screen/reader/reader_screen.dart`:
- **Appearance**: Triggered at line 582 via `onPressed: _showReaderSettings` from bottom bar tools. Implemented at lines 1826–1845 using `_ReaderSettingsSheet`.
- **In-Book Search**: Triggered at line 572 via `onPressed: _showSearch` from bottom bar tools. Implemented at lines 1098–1105 using `_ReaderSearchSheet(search: _searchReader)`.
- **Annotations**: Triggered at line 577 via `onPressed: _showAnnotations`. Implemented at lines 1136–1170 using `NotesSheet`.
- **Table of Contents**: Triggered at line 567 via `onPressed: _tableOfContents.isEmpty ? null : _showTableOfContents`. Implemented at lines 1868–1963 using an inline bottom sheet.
- **Dictionary Lookup & Selection**:
  - Readium selection: Handled at line 633 via `onSelectionAction: _handleReadiumSelectionAction` (lines 1312–1322), dispatching to `_showLookupSheet` (lines 1440–1453) and `_showHighlightColorSheet` (lines 1421–1438).
  - Fallback selection: Handled at lines 667, 692, 727 via `onSelectionAction: _handleFallbackSelectionAction` (lines 1397–1419) using `_readerContextMenu` (line 3351).
- **Read Aloud**: Triggered at line 590 via `onPressed: _startReadAloud` (lines 1747–1761). Renders docked player at lines 362–382 via `ReadAloudPlayer`. Spoken sentence tracking is handled via `_spokenSubscription` calling `_followSpoken` (lines 1729–1745) and marked in `_textPageMarks` (lines 1511–1526).

### 1.4 Test Suite & Analyzer Baseline
Executed `fvm flutter test` and `fvm flutter analyze`:
- `fvm flutter test`: **All 341 tests passed** (including `reader_and_overlays_test.dart` and `audio_settings_paywall_test.dart`).
- `fvm flutter analyze`: **0 issues found** (0 warnings, 0 errors).
- Existing contract tests in `test/e2e/tier1_features/reader_and_overlays_test.dart` define precise contract widgets with required widget keys:
  - `reader_viewport_tap_target`, `zen_mode_page_counter`, `reader_bookmark_ribbon`
  - `brightness_rail_capsule`
  - `reader_search_button`, `reader_bookmark_button`
  - 4 Tool labels: `Contents`, `Appearance`, `Listen`, `Notes`
  - `swatch_Paper`, `swatch_White`, `swatch_Sepia`, `swatch_Grey`, `swatch_Night`, `swatch_OLED`, `appearance_font_slider`
  - `floating_selection_toolbar`, `toolbar_define_button`, `toolbar_copy_button`
  - `search_match_counter_badge`, `search_prev_match`, `search_next_match`
- Contract tests in `test/e2e/tier1_features/audio_settings_paywall_test.dart` define:
  - `spoken_sentence_highlight_band` (color: `WarmEditorialTokens.spokenHighlight` `#D6E2F5`)
  - `read_aloud_player_sheet`
  - `player_sentence_quote_card`
  - `read_aloud_skip_back`, `read_aloud_play_pause_hero`, `read_aloud_skip_forward`

---

## 2. Logic Chain

### 2.1 Decoupling Private Sheets into Dedicated Widgets
- **Step 1**: In `reader_screen.dart`, `_ReaderSettingsSheet` (lines 2625–3308) and `_ReaderSearchSheet` (lines 3384–3558) are private inner classes within a 3,558-line file.
- **Step 2**: Requirement R2 and PROJECT.md explicitly demand `lib/presentation/screen/reader/widgets/appearance_sheet.dart` and `lib/presentation/screen/reader/widgets/reader_search.dart`.
- **Step 3**: Extracting these sheets into public standalone widgets conforming to Stitch canvas designs (`04b_appearance_sheet` and `04e_search_in_book`) satisfies interface contracts, improves testability, and adheres to clean architecture without regressing existing `ReaderScreen` behaviour.

### 2.2 Reader Chrome & Top/Bottom Bar Alignment (04 & 04-var)
- **Step 1**: In Stitch screen `04_reader_chrome_visible` (`80a5b425`), search is located in the Top Bar alongside bookmark and overflow actions, freeing the Bottom Bar to feature 4 balanced tools: `Contents`, `Appearance`, `Listen`, `Notes`.
- **Step 2**: In `reader_chrome.dart`, `ReaderTopBar` currently only accepts an optional single `action` widget, and `ReaderBottomBar` packs search as a bottom tool button.
- **Step 3**: `ReaderTopBar` should be enhanced to natively support search (`key: const Key('reader_search_button')`), bookmark (`key: const Key('reader_bookmark_button')`), and overflow menu actions, and display the book title and author in Newsreader serif.
- **Step 4**: `ReaderBottomBar` should be updated to display the chapter status row ("Chapter Four", "Page 142 of 380 · 12 min left in chapter", and progress badge pill "37%"), a scrubber with chapter ticks, and the 4 canonical tools.
- **Step 5**: The left-edge brightness rail (`key: const Key('brightness_rail_capsule')`) is currently invisible in `reader_screen.dart` until swiped. It must render as a floating capsule with `Icons.brightness_5`, vertical track, and level label when chrome is visible.
- **Step 6**: In Zen Mode (`04_reader_chrome_hidden`), chrome slides out, leaving a clean reading page with `key: const Key('zen_mode_page_counter')` at the bottom and `key: const Key('reader_bookmark_ribbon')` if bookmarked.

### 2.3 Appearance Sheet Refactoring (`04b_appearance_sheet`)
- **Step 1**: Create `lib/presentation/screen/reader/widgets/appearance_sheet.dart`.
- **Step 2**: Layout must implement:
  - Drag handle `40×4px` (`#CEC5BB`).
  - Header with "Appearance", subtitle "Offline reading aesthetics", Reset button, Close button.
  - Section 1: Page Tone swatches (diameter 44px) for Paper, White, Sepia, Grey, Night, OLED with keys `swatch_Paper`, `swatch_Night`, `swatch_OLED`, etc. Locked patron badges for Night & OLED if premium is inactive.
  - Section 2: Typeface cards for Newsreader, Inter, Literata, EB Garamond, Source Serif 4.
  - Section 3: Typography sliders (Font size with `appearance_font_slider` key, A−/A+; Line spacing 1.1–2.2×; Margins 12–44px).
  - Section 4: Layout mode segmented control (Scroll / Pages / Two Columns) and switches (Justify, Hyphenation, Publisher styles).
  - Section 5: Brightness slider with "Follow system brightness" toggle.
- **Step 3**: Wire `AppearanceSheet` to `SettingsEntity` and `onChanged` callback in `reader_screen.dart`.

### 2.4 Floating Text Selection Toolbar & Wiktionary Card (`04c_text_selection_dictionary`)
- **Step 1**: In `marked_text.dart` / `reader_screen.dart`, selection currently uses `AdaptiveTextSelectionToolbar.buttonItems`.
- **Step 2**: Design `04c` requires a floating capsule toolbar (`key: const Key('floating_selection_toolbar')`) featuring:
  - Highlight action with 5 color dots (`#FDE047`, `#86EFAC`, `#93C5FD`, `#F472B6`, `#FDBA74`).
  - Note icon button (`Icons.edit_note`).
  - Define button (`key: const Key('toolbar_define_button')`).
  - Copy button (`key: const Key('toolbar_copy_button')`).
  - Share button (`Icons.share`).
- **Step 3**: `DictionaryLookupSheet` in `widgets/dictionary_lookup_sheet.dart` should be upgraded:
  - Header: Word in `Newsreader 28px w600`, phonetic spelling `/ˈlɪt(ə)rəl/`, audio pronunciation button (`Icons.volume_up` using TTS), etymology note.
  - Action buttons: Bookmark word (`Icons.bookmark_add`), close (`Icons.close`).
  - Part-of-speech chips (`adjective`, `noun`) + `Local Lexicon` green dot badge.
  - Numbered definitions with italic usage blockquote and left accent border (`#2F4A7A4D`).
  - Quick action row: "Add to Flashcards", "Copy", "open_in_new".
  - Footer: "From Wiktionary · CC BY-SA 3.0 · Offline Lexicon" + "0 B used" offline pill.
- **Step 4**: Binds directly to `DictionaryLookupCubit`. If definition lookups fail or are offline, show offline lexicon fallback data.

### 2.5 Unified Contents TOC & Annotations Side Sheet (`04d_contents_annotations`)
- **Step 1**: Currently, TOC is displayed in an inline bottom sheet in `reader_screen.dart` (lines 1868–1963), while Bookmarks and Highlights are in `NotesSheet` (`notes_sheet.dart`).
- **Step 2**: Stitch `04d` specifies a side modal sheet / drawer with 3 tabs:
  1. `Contents`: TOC chapter hierarchy tree, reading progress banner (`Chapter 4 · Page 142 of 380 · 37%`), current chapter highlighted with left ink-blue bar (`3.5px #2F4A7A`), and recent notes preview in this chapter.
  2. `Bookmarks`: List of bookmark cards with locators and dates.
  3. `Highlights`: List of highlight cards with colored left strip, quote, user note, page reference, and date.
- **Step 3**: Top bar contains Back button, Search in contents icon, and "Export as Markdown" icon.
- **Step 4**: Footer contains "Export as Markdown (.md)" pill button and local offline vault status badge.
- **Step 5**: Update `notes_sheet.dart` (or create `contents_annotations_sheet.dart` and re-export) to accept TOC entries and provide the unified 3-tab drawer.

### 2.6 Search In-Book Overlay (`04e_search_in_book`)
- **Step 1**: Create `lib/presentation/screen/reader/widgets/reader_search.dart`.
- **Step 2**: Implement `ReaderSearchSheet`:
  - Header: Back button, book title italic, author, format pill (`EPUB`/`PDF`).
  - Search Header Card:
    - Search icon in `#2F4A7A`.
    - Text field with clear button.
    - Results badge (`key: const Key('search_match_counter_badge')`): e.g. `23 results`.
    - Stepper row: "Match 4 of 23 in current chapter", prev button (`key: const Key('search_prev_match')`), next button (`key: const Key('search_next_match')`).
  - Quick filter chips: "This book (23)", "All chapters", "Notes & Highlights", "Case sensitive".
  - Grouped chapter results: Chapter title header with count, result cards with match term bolded in deep ink blue (`#2F4A7A`) with `#D6E2F5` tint and page indicator (`p. 42`).
- **Step 3**: Connects to `_searchReader` in `reader_screen.dart` with fallback snippets if query results are empty or offline.

### 2.7 Read Aloud Player & Canvas Sentence Tracking (`05_read_aloud`)
- **Step 1**: In `reader_screen.dart` line 1525, `_textPageMarks` currently hardcodes `HighlightColor.yellow`. Update `PageMark` in `marked_text.dart` to support `customColor` and use `WarmEditorialTokens.spokenHighlight` (`Color(0xFFD6E2F5)`), with `key: const Key('spoken_sentence_highlight_band')`.
- **Step 2**: Upgrade `ReadAloudPlayer` in `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` to render the expanded player bottom sheet (`key: const Key('read_aloud_player_sheet')`):
  - Grab handle pill (`#DCDAD5`).
  - Miniature book cover thumbnail (`BookCover(book: book, compact: true)`).
  - Title, author, chapter subtitle, and minimize button.
  - Spoken sentence card (`key: const Key('player_sentence_quote_card')`) with left vertical border in `WarmEditorialTokens.accentInkBlue` (width 3.5px) and serif italic quote.
  - Timeline scrubber with elapsed and remaining timestamps, and "Sentence X of Y" badge.
  - Playback controls:
    - `key: const Key('read_aloud_skip_back')` (`Icons.replay_10`, size 28)
    - `key: const Key('read_aloud_play_pause_hero')` (64×64 circle in `accentInkBlue` with white play/pause icon)
    - `key: const Key('read_aloud_skip_forward')` (`Icons.forward_10`, size 28)
  - Quick adjustment chips: Speed (`1.25x`), Voice (`Natural 2`), Sleep timer (`30 min`).
  - Trust footer: "Local On-Device TTS · 0 KB network used" with lock icon.

---

## 3. Caveats

1. **Native Readium vs. Fallback Document Engine**:
   - For EPUBs, Readium handles reflow, selection, and rendering internally via platform channels (`ReadiumReaderWidget`). Readium selection actions are passed via `onSelectionAction`.
   - For PDF/TXT/MD/FB2, Flutter's `SelectableText.rich` and `marked_text.dart` are used.
   - The UI sheets (`AppearanceSheet`, `DictionaryLookupSheet`, `ContentsAnnotationsSheet`, `ReaderSearchSheet`, `ReadAloudPlayer`) are completely universal and work identically across both engines.
2. **Read Aloud TTS Availability on Emulators / CI**:
   - In automated test and CI environments where system TTS engines may be absent, `ReadAloudCubit` correctly handles `ReadAloudProblem.noEngine`.
   - The expanded player sheet must handle both active TTS streaming and mock/fallback text presentation so unit/widget tests never crash.
3. **No Bottom Navigation Bar**:
   - The strict invariant must be maintained: **ZERO bottom navigation bars anywhere in the app**. All sheets must use modal bottom sheets (`showModalBottomSheet`) or left drawers.

---

## 4. Conclusion & Recommended Worker Implementation Plan

The codebase has a robust foundation with functional repositories and cubits (`ReadAloudCubit`, `DictionaryLookupCubit`, `PremiumCubit`), but requires extracting private inner classes into dedicated widget files and styling them with pixel-perfect Warm Editorial tokens matching Stitch screens 04, 04-var, 04b, 04c, 04d, 04e, and 05.

### Surgical Step-by-Step Plan for Worker:

#### Step 1: Create `lib/presentation/screen/reader/widgets/appearance_sheet.dart`
- Implement `AppearanceSheet` matching `04b_appearance_sheet` (`d8bb2a41`).
- Include all 6 swatches (Paper, White, Sepia, Grey, Night, OLED) with keys `swatch_Paper`, `swatch_Night`, `swatch_OLED`, etc., font picker, typography sliders (`Key('appearance_font_slider')`), layout toggles, brightness slider.
- In `reader_screen.dart`, update `_showReaderSettings` to invoke `AppearanceSheet`.

#### Step 2: Create `lib/presentation/screen/reader/widgets/reader_search.dart`
- Implement `ReaderSearchSheet` matching `04e_search_in_book` (`c63b6121`).
- Include search field, results counter badge (`Key('search_match_counter_badge')`), stepper buttons (`Key('search_prev_match')`, `Key('search_next_match')`), filter chips, and grouped chapter snippets with bolded keywords.
- In `reader_screen.dart`, update `_showSearch` to invoke `ReaderSearchSheet`.

#### Step 3: Upgrade `ReaderChrome` in `reader_chrome.dart` & `reader_screen.dart`
- Update `ReaderTopBar` to add `Key('reader_search_button')`, `Key('reader_bookmark_button')`, book author subtitle, and overflow menu.
- Update `ReaderBottomBar` to include chapter status row, scrubber with chapter ticks, and the 4 tools (`Contents`, `Appearance`, `Listen`, `Notes`).
- In `reader_screen.dart`, add the visible left-edge brightness rail (`Key('brightness_rail_capsule')`).
- In Zen mode, verify `Key('zen_mode_page_counter')` and `Key('reader_bookmark_ribbon')`.

#### Step 4: Upgrade `dictionary_lookup_sheet.dart` & Selection Toolbar
- Implement floating selection toolbar widget (`Key('floating_selection_toolbar')`) with 5 color dots, `Key('toolbar_define_button')`, `Key('toolbar_copy_button')`, note, and share.
- Upgrade `DictionaryLookupSheet` to match `04c_text_selection_dictionary` (Newsreader word title, phonetics, audio icon, etymology note, chips, definitions with left accent, flashcard/copy actions, Wiktionary offline footer).

#### Step 5: Upgrade `notes_sheet.dart` into Unified Contents & Annotations Sheet (`04d`)
- Add `Contents` tab alongside `Bookmarks` and `Highlights`.
- Implement chapter tree with current chapter highlighted with left ink-blue bar (`3.5px #2F4A7A`), reading progress banner, recent notes preview, Markdown export button, and local vault status badge.

#### Step 6: Upgrade `read_aloud_player.dart` & Spoken Sentence Highlight (`05`)
- In `marked_text.dart` and `reader_screen.dart`, highlight spoken sentences with `WarmEditorialTokens.spokenHighlight` (`#D6E2F5`) and key `Key('spoken_sentence_highlight_band')`.
- In `read_aloud_player.dart`, implement expanded player sheet (`Key('read_aloud_player_sheet')`) with book cover thumbnail, chapter info, quote card with left border (`Key('player_sentence_quote_card')`), timeline scrubber, hero 64px play/pause button (`Key('read_aloud_play_pause_hero')`), skip back (`Key('read_aloud_skip_back')`), skip forward (`Key('read_aloud_skip_forward')`), adjustment chips, and offline note.

#### Step 7: Verification & Regression Check
- Run `fvm flutter test test/e2e/tier1_features/reader_and_overlays_test.dart`.
- Run `fvm flutter test test/e2e/tier1_features/audio_settings_paywall_test.dart`.
- Run full suite: `fvm flutter test`.
- Run static analysis: `fvm flutter analyze` (confirm 0 errors, 0 warnings).

---

## 5. Verification Method

To independently verify the implementation:
1. **Unit and Contract Tests**:
   ```bash
   fvm flutter test test/e2e/tier1_features/reader_and_overlays_test.dart
   fvm flutter test test/e2e/tier1_features/audio_settings_paywall_test.dart
   fvm flutter test test/presentation/screen/reader/
   ```
2. **Full Regression Test Suite**:
   ```bash
   fvm flutter test
   ```
3. **Analyzer Quality Check**:
   ```bash
   fvm flutter analyze
   ```
   *Pass Condition*: 0 errors, 0 warnings, 0 issues.
4. **Visual Inspection**:
   - Compare implemented widgets against reference HTML/PNG files:
     - `design/screens/04_reader_chrome_visible/`
     - `design/screens/04_reader_chrome_hidden/`
     - `design/screens/04b_appearance_sheet/`
     - `design/screens/04c_text_selection_dictionary/`
     - `design/screens/04d_contents_annotations/`
     - `design/screens/04e_search_in_book/`
     - `design/screens/05_read_aloud/`

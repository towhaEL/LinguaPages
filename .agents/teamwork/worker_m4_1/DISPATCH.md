## 2026-11-04T22:23:30Z
You are worker_m4_1, a teamwork_worker subagent.
Your assigned working directory is `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/worker_m4_1/`.
Your parent is orchestrator_gen2 (conversation ID: 888c77aa-2b04-4621-9911-6d983e663338).

MANDATORY FIRST STEP:
Read `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/ORIGINAL_REQUEST.md` completely.
Also read `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2/PROJECT.md`.
Read the exploration reports:
- `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/spec_miner_m4_1/handoff.md`
- `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/explorer_m4_1/handoff.md`
- `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/explorer_m4_2/handoff.md`

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE FILE OWNERSHIP:
You have exclusive write access to:
- `lib/presentation/screen/reader/widgets/appearance_sheet.dart` (create new)
- `lib/presentation/screen/reader/widgets/reader_search.dart` (create new)
- `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`
- `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart`
- `lib/presentation/screen/reader/widgets/notes_sheet.dart`
- `lib/presentation/screen/reader/widgets/reader_chrome.dart`
- `lib/presentation/screen/reader/widgets/marked_text.dart`
- `lib/presentation/screen/reader/reader_screen.dart`
- `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`

YOUR MISSION:
Implement Milestone 4: Reader Experience & Overlays (Requirement R2) matching Stitch canvas designs and specifications:
1. `AppearanceSheet` (`lib/presentation/screen/reader/widgets/appearance_sheet.dart`):
   - Match Stitch screen `04b_appearance_sheet` (`d8bb2a41`).
   - 6 theme swatches (Paper, White, Sepia, Grey, Night [patron lock], OLED [patron lock]) with keys `Key('swatch_Paper')`, `Key('swatch_White')`, etc.
   - Typeface cards (Newsreader, Inter, Literata, EB Garamond, Source Serif 4).
   - Typography sliders (`Key('appearance_font_slider')` for font size with A−/A+; line spacing; margins).
   - Layout mode segmented control (Scroll/Pages/Two Columns) + toggles (Justify, Hyphenation, Publisher styles).
   - Brightness slider + "Follow system brightness" switch.
   - Wire to `reader_screen.dart` `_showReaderSettings`.
2. `ReaderSearchSheet` (`lib/presentation/screen/reader/widgets/reader_search.dart`):
   - Match Stitch screen `04e_search_in_book` (`c63b6121`).
   - Search input, match counter badge (`Key('search_match_counter_badge')`), stepper buttons (`Key('search_prev_match')`, `Key('search_next_match')`), scope chips, grouped chapter snippets with bolded keywords (`#2F4A7A` text on `#D6E2F5` tint).
   - Wire to `reader_screen.dart` `_showSearch`.
3. `ReaderChrome` (`lib/presentation/screen/reader/widgets/reader_chrome.dart` & `reader_screen.dart`):
   - Top Bar: book title & author in Newsreader, `Key('reader_search_button')`, `Key('reader_bookmark_button')`.
   - Bottom Bar: chapter status row, scrubber with chapter ticks, 4 tools: `Contents`, `Appearance`, `Listen`, `Notes`.
   - Left edge brightness rail: `Key('brightness_rail_capsule')` visible when chrome is visible.
   - Zen mode: clean reading canvas, `Key('zen_mode_page_counter')` footer, `Key('reader_bookmark_ribbon')` if bookmarked.
4. `DictionaryLookupSheet` & Floating Text Selection Toolbar (`lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`, `highlight_editor_sheet.dart`):
   - Match Stitch screen `04c_text_selection_dictionary` (`3377a7d8`).
   - Floating selection toolbar (`Key('floating_selection_toolbar')`) with 5 color dots (#FDE047, #86EFAC, #93C5FD, #F472B6, #FDBA74), `Key('toolbar_define_button')`, `Key('toolbar_copy_button')`, note, share.
   - Wiktionary definition card: Newsreader headword, phonetics, audio icon, etymology, chips, definition items with left accent line, flashcard/copy actions, offline footer.
5. `NotesSheet` (`lib/presentation/screen/reader/widgets/notes_sheet.dart`):
   - Match Stitch screen `04d_contents_annotations` (`60c9068e`).
   - Side sheet drawer with 3 tabs: Contents (TOC tree with active chapter ink-blue bar, progress banner), Bookmarks, Highlights.
   - Sticky "Export as Markdown (.md)" stadium button (`Key('export_markdown_button')`) and vault size badge.
6. `ReadAloudPlayer` & Sentence Tracking (`lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`, `marked_text.dart`, `reader_screen.dart`):
   - Match Stitch screen `05_read_aloud` (`b44bfe85`).
   - Spoken sentence highlight band in `#D6E2F5` (`Key('spoken_sentence_highlight_band')`).
   - Expanded bottom player sheet (`Key('read_aloud_player_sheet')`): book cover thumbnail, chapter info, quote card with left border (`Key('player_sentence_quote_card')`), timeline scrubber, hero 64px play button (`Key('read_aloud_play_pause_hero')`), skip back (`Key('read_aloud_skip_back')`), skip forward (`Key('read_aloud_skip_forward')`), adjustment chips (speed, voice, timer), and offline note.

ARCHITECTURAL MANDATES:
- Warm Editorial Minimalism (ivory `#FAF7F2`, white cards `#FFFFFF`, 1px `#E8E2D9` hairline borders, Newsreader serif, Inter sans).
- STRICTLY ZERO bottom navigation bars anywhere in the app (`expectNoBottomNavigationBar`).
- All Flutter commands MUST be run with `fvm flutter <cmd>`.

VERIFICATION:
You must run:
1. `fvm flutter test test/e2e/tier1_features/reader_and_overlays_test.dart`
2. `fvm flutter test test/e2e/tier1_features/audio_settings_paywall_test.dart`
3. `fvm flutter test` (entire test suite must pass 100%)
4. `fvm flutter analyze` (0 errors, 0 warnings)
Document commands and outputs in `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/worker_m4_1/handoff.md`.
Update `progress.md` periodically with "Last visited: [timestamp]".
When complete, notify parent (888c77aa-2b04-4621-9911-6d983e663338).

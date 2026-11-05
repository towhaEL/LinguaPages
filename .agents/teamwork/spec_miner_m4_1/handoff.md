# Milestone 4: Reader Experience & Overlays — Specification Mining Report

**Subagent ID:** `spec_miner_m4_1`  
**Working Directory:** `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/spec_miner_m4_1/`  
**Parent:** `orchestrator_gen2` (Conversation ID: `888c77aa-2b04-4621-9911-6d983e663338`)  
**Target Viewport:** Android Mobile (412 × 915 dp) Material 3 Warm Editorial Minimalism  
**Authoritative Sources:**
- `design/STITCH_UI_IMPLEMENTATION_GUIDE.md`
- `design/screens/04b_appearance_sheet/04b_appearance_sheet_screen.html` & `.png`
- `design/screens/04c_text_selection_dictionary/04c_text_selection_dictionary_screen.html` & `.png`
- `design/screens/04d_contents_annotations/04d_contents_annotations_screen.html` & `.png`
- `design/screens/04e_search_in_book/04e_search_in_book_screen.html` & `.png`
- `design/screens/05_read_aloud/05_read_aloud_screen.html` & `.png`
- `lib/presentation/theme/app_tokens.dart`, `lib/presentation/theme/app_text_styles.dart`

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Appearance Sheet | Theme Palette Swatches | 6 circular swatches (diameter 44px): Paper (`#F6F1E7`), White (`#FFFFFF`), Sepia (`#F4ECD8`), Grey (`#EAE6DF`), Night (`#23272A`), OLED (`#121212`). Active has double ring (`ring-2 #2F4A7A ring-offset-2`). Night and OLED display lock badge (`#6B401E`). | User tap on theme swatch | Immediate reader page background & text tint update; if premium & locked, preview or trigger paywall | Graceful fallback to Paper if invalid theme index | `04b_appearance_sheet_screen.html` lines 230-282 |
| 2 | Appearance Sheet | Typeface Carousel | Horizontal card selector with 5 families: Newsreader (Default serif), Inter (Modern sans), Literata (Book serif), EB Garamond (Classic), Source Serif 4 (Warm). Active card has `#2F4A7A` background, white text, check icon. | Tap typeface card | Reader text re-renders with selected `GoogleFonts` or system fallback | Missing font falls back to system serif/sans | `04b_appearance_sheet_screen.html` lines 284-333 |
| 3 | Appearance Sheet | Typography Sliders | 3 slider cards with `surface-container-low` background and `1px #E8E2D9` border: Font Size (12–28 pt, A−/A+ icons), Line Spacing (1.1–2.2×, format icons), Side Margins (12–44 px, width icons). | User slider drag | Real-time reflow of reader document margins, line heights, and font sizes | Clamped within safe bounds | `04b_appearance_sheet_screen.html` lines 335-374 |
| 4 | Appearance Sheet | Layout & Flow Controls | Capsule segmented control (`Scroll`, `Pages`, `Two Columns`) + Inset grouped card with 3 toggles: Justify text, Hyphenation, Publisher styles. | Mode tap / toggle switch | Reconfigures reader pagination mode, text alignment (`TextAlign.justify` vs left), and CSS hyphenation | Non-reflowable formats (e.g. fixed PDF) disable inapplicable controls | `04b_appearance_sheet_screen.html` lines 376-427 |
| 5 | Appearance Sheet | Display Brightness | Slider (10%–100%) with `light_mode` and `brightness_high` icons + "Follow system brightness" switch. | Slider drag / switch toggle | Modifies system window brightness via `ScreenBrightnessService` | Inverts or clamps if brightness API throws; preserves system value | `04b_appearance_sheet_screen.html` lines 429-450 |
| 6 | Selection & Dictionary | Floating Selection Toolbar | Contextual floating capsule above selected word with pointer caret. Contains: Brush with 5 color dots (Yellow `#FDE047`, Green `#86EFAC`, Blue `#93C5FD`, Pink `#F472B6`, Orange `#FDBA74`), Note, Define (active pill), Copy, Share, More. | Long press / text selection in reader | Floating toolbar anchored to selection bounds | Automatically repositions or hides if selection cleared | `04c_text_selection_dictionary_screen.html` lines 215-256 |
| 7 | Selection & Dictionary | Wiktionary Definition Card | Modal bottom sheet (`rounded-t-[28px]`, max-h 510px). Header with headword (`Newsreader 30px w600`), phonetics (`/ˈlɪt(ə)rəl/`), pronunciation audio button, etymology note, Part-of-Speech filter chips (`adjective`, `noun`), definition items with blockquotes, action buttons (Flashcards, Copy, Full entry), footer with CC BY-SA 3.0 license & "0 B used". | Tap "Define" or lookup word | Opens bottom sheet with definitions, pronunciations, etymologies from local Wiktionary database | If not found, displays "No definition found" message while keeping Highlight and Copy active | `04c_text_selection_dictionary_screen.html` lines 259-365 |
| 8 | Contents & Annotations | Unified Side Sheet Drawer | Left modal drawer (width 350px = ~85% mobile width, shadow `8px 0 32px -4px rgba(28,27,26,0.18)`) with right backdrop scrim and tap-to-close button. Header with Book title, author, and 3 tab pills: Contents (count), Bookmarks (count), Highlights (count). | Tap "Contents" tool or swipe from left | Slides drawer into view over reader | Dismisses on back button or right scrim tap | `04d_contents_annotations_screen.html` lines 156-200 |
| 9 | Contents & Annotations | TOC Hierarchy & Reading Progress | Top reading progress banner ("Chapter 4 · Page 142 of 380 · 37% completed") with `auto_stories` icon + nested chapter tree with expandable/collapsible parts. Active chapter highlighted with deep ink blue vertical strip (`w-1.5 #2F4A7A`), dot indicator, and "Current" badge. | Tap chapter title | Reader navigates to chapter locator; updates reading progress | Disables navigation if chapter locator unresolvable | `04d_contents_annotations_screen.html` lines 201-319 |
| 10 | Contents & Annotations | Active Highlights & Markdown Export | Chapter notes preview cards with vertical color strips, italic quotes, user notes, and page/date metadata. Bottom sticky button "Export as Markdown (.md)" + vault size info ("Local Offline Vault · 24.8 KB"). | Tap note card / tap Export button | Navigates to note or invokes system share sheet with exported Markdown document | Handles file system write errors gracefully | `04d_contents_annotations_screen.html` lines 320-378 |
| 11 | Search In Book | Context Header & Search Bar | Editorial sub-header (`The Shadow of the Wind · Carlos Ruiz Zafón · EPUB`) + search input card with blinking cursor, match counter badge ("23 results"), and clear button. | Text input in search field | Queries book text via search engine | Shows empty state if query blank; error if indexing fails | `04e_search_in_book_screen.html` lines 160-190 |
| 12 | Search In Book | Occurrence Stepper & Scope Chips | Stepper sub-row with "Match 4 of 23 in current chapter" counter + up/down arrows. Horizontal scope chips: "This book (23)", "All chapters", "Notes & Highlights", "Case sensitive". | Tap stepper arrow / tap scope chip | Jumps to next/previous occurrence; filters search scope | Disabled arrows at boundary if loop disabled | `04e_search_in_book_screen.html` lines 191-225 |
| 13 | Search In Book | Grouped Snippets & Focus Match Card | Search results grouped by chapter headers ("Chapter 2", "Chapter 4 Current"). Snippet cards with `<mark class="bg-[#2F4A7A]/10 text-[#2F4A7A]">` bold highlights. Active match card has pulsing blue dot, `MATCH 4 OF 23` label, and deep left accent line. | Tap result snippet card | Reader jumps to matching page and highlights term | Handles text offset mismatches gracefully | `04e_search_in_book_screen.html` lines 226-315 |
| 14 | Search In Book | Floating Return-to-Position Bar | Floating bottom pill (NOT a bottom nav bar!): Left button "Return to position · Page 142 (62%)" with `bookmark_border` icon + Right primary stadium button "Done" with `check` icon. | Tap "Return to position" / tap "Done" | Returns to pre-search location or confirms current selected match | None | `04e_search_in_book_screen.html` lines 316-331 |
| 15 | Read Aloud | Spoken Sentence Canvas Tracker | Reader canvas highlight band (`#D6E2F5` / `accentContainer` with border bottom `border-primary/20`) tracking the currently spoken sentence, with subtle backdrop mask (`#31302D/15`). | Text-to-speech engine sentence event | Highlights current sentence in reader view and auto-scrolls | Clears highlight on pause or stop | `05_read_aloud_screen.html` lines 140-185 |
| 16 | Read Aloud | Expanded Bottom Player Sheet | Level 3 modal sheet (`rounded-t-3xl`, top drag handle). Top header with 2:3 miniature book cover (`w-12 h-16`), book title, chapter title, and minimize arrow `keyboard_arrow_down`. | Audio playback start / tap player pill | Expands audio player sheet over reader view | Minimizes back to compact bar on minimize tap | `05_read_aloud_screen.html` lines 188-215 |
| 17 | Read Aloud | Editorial Spoken Sentence Card | Inset card (`bg-[#F6F3EE]/60`, rounded-2xl): Previous sentence (faded 50% opacity italic), current sentence quoted in large Newsreader serif (`19px w500 text-[#1C1C19]`) with deep blue left bar (`border-l-2 #2F4A7A`), and next sentence preview (faded 60% opacity). | TTS sentence progression | Updates sentence card text in real time with smooth transition | Fallback to current sentence if no previous/next | `05_read_aloud_screen.html` lines 216-232 |
| 18 | Read Aloud | Scrubber & Playback Controls | Chapter timeline scrubber bar (height 20px, filled progress track `#2F4A7A`, circular thumb with shadow), elapsed time ("04:18"), sentence badge ("Sentence 14 of 48"), remaining time ("-08:42"). Controls row: Bookmark audio snippet, Replay 10s, 64px Play/Pause button (`#2F4A7A`), Forward 10s, Overflow menu. | Scrubber drag / button taps | Seeks audio, toggles play/pause, skips 10s, bookmarks sentence | Prevents scrubbing past chapter bounds | `05_read_aloud_screen.html` lines 233-274 |
| 19 | Read Aloud | Speech Fine-Tuning Chips | Bottom chip row: Speed pill ("1.25x" active `#2F4A7A`), Voice picker ("Natural 2"), Sleep timer ("30 min"). Footer note: "Local On-Device TTS · 0 KB network used". | Tap chip | Opens speed picker, voice selector, or sleep timer dialog | Falls back to system default voice if selected voice unavailable | `05_read_aloud_screen.html` lines 275-297 |

---

## Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Appearance Sheet | User selects Night or OLED theme without Premium purchase | Swatch displays brass lock badge (`#6B401E`); tapping opens `PremiumPaywallSheet` or temporarily previews the theme during sheet session without persisting to database. |
| 2 | Appearance Sheet | Fixed-layout PDF loaded in reader | Font family, font size, line spacing, margins, and layout flow toggles (Justify/Hyphenation) are disabled or replaced with PDF Fit controls (`Width`, `Page`) and image filter options (`Dim`, `Invert`). |
| 3 | Appearance Sheet | "Follow system brightness" toggled ON | Brightness slider is locked/disabled; reader listens to system sensor/window events and resets custom app brightness. |
| 4 | Appearance Sheet | Rapid slider dragging on low-end hardware | Sliders use local state for immediate 60fps UI thumb updates; debounces persistence and Readium renderer reflow calls by ~200ms. |
| 5 | Text Selection | Multi-word or multi-line sentence selected | Teardrop selection handles anchor to start and end characters; floating toolbar centers above top line; Define button shows "Define" if single word or "Lookup phrase" if multi-word. |
| 6 | Text Selection | Rapid tap on one of the 5 highlight color dots | Immediately creates a `HighlightEntity` with that exact color hex (`#FDE047`, `#86EFAC`, `#93C5FD`, `#F472B6`, `#FDBA74`) and dismisses toolbar without opening secondary note sheet. |
| 7 | Dictionary Card | Selected word not in local Wiktionary database | Displays friendly message (`"No definition found in local lexicon"`), suggests searching the web, while still offering "Highlight", "Note", and "Copy" actions. |
| 8 | Dictionary Card | Pronunciation audio button tapped when TTS engine offline | TTS falls back to platform phonetics speech synthesizer or shows brief non-blocking toast if audio unavailable. |
| 9 | Dictionary Card | Tapping "Add to Flashcards" | Word, phonetic spelling, part of speech, and primary definition are bundled into local vocabulary card storage; button animates to checked state. |
| 10 | Contents Sheet | Extremely long chapter title in TOC | Truncates with ellipsis while maintaining tabular page number alignment (`tabular-nums`) on the right. |
| 11 | Contents Sheet | User taps "Export as Markdown (.md)" | Formats book title, author, date, reading progress, and all grouped highlights/notes into clean Github-flavored Markdown (`.md`) and invokes `SharePlus.share()`. |
| 12 | Contents Sheet | Book has zero bookmarks and zero highlights | Bookmarks and Highlights tabs render empty state illustrations (`empty_shelf` / `note_stack`) with reassuring offline note. |
| 13 | Search Overlay | Search query yields 0 results | Displays centered clean message (`"No matches found for '...'"`), stepper arrows disabled, and match counter badge displays `"0 results"`. |
| 14 | Search Overlay | Search term contains regex special characters (`?`, `*`, `[`, `(`, `\`) | Input treated as literal string search; escapes regex characters to prevent runtime pattern syntax exceptions. |
| 15 | Search Overlay | User taps "Return to position" after jumping across 10 search results | Immediately animates reader back to original pre-search locator position (`Page 142 · 62%`) and restores reading context. |
| 16 | Read Aloud | Sentence contains non-pronounceable characters or punctuation only | TTS engine automatically advances to the next valid alphanumeric sentence without stalling or throwing audio playback errors. |
| 17 | Read Aloud | Sleep timer reaches 00:00 while reading | Smoothly fades out audio over 2 seconds, pauses playback, releases wake lock, and preserves current sentence locator position. |
| 18 | Read Aloud | Screen rotates to landscape or phone receives phone call | Audio playback pauses automatically on audio focus loss; Android MediaSession notification updates state to paused. |
| 19 | Read Aloud | User drags chapter timeline scrubber rapidly | Audio playback pauses during scrub gesture, updates sentence preview card in real time, and resumes playback at new sentence on thumb release. |

---

## 5-Component Handoff Report

### 1. Observation

Direct examination of authoritative design artifacts revealed exact measurements, CSS rules, color tokens, and font pairings:

1. **`04b_appearance_sheet` (`d8bb2a419ed94bd2912d8dd529e5c482`)**:
   - Container: Level 3 elevation Modal Bottom Sheet with top corner radius `24px` (`rounded-t-3xl`), border top `1px #E8E2D9`, shadow `0 -8px 32px rgba(28,27,26,0.18)`, background `#FFFFFF`. Drag handle is `40×4px` (`w-10 h-1 rounded-full bg-[#CEC5BB]`).
   - Header: Horizontal padding `20px` (`px-5`), vertical padding `12px` (`py-3`), border bottom `1px #EBE8E3/70`. Title `"Appearance"` in `Newsreader 19px w500 #1C1C19`, subtitle `"Offline reading aesthetics"` in `Inter 11px w500 #635D56`. Trailing text button `"Reset"` in `Inter 12px w500` + close button `32×32px` with `close` icon (20px).
   - Theme Swatches (6 swatches in `grid-cols-6 gap-2`):
     - Paper: `#F6F1E7` (border `#CEC5BB`, active ring `ring-2 #2F4A7A ring-offset-2`, check icon `18px #153362`).
     - White: `#FFFFFF` (border `#CEC5BB`).
     - Sepia: `#F4ECD8` (border `#E0D5BC`).
     - Grey: `#EAE6DF` (border `#D5D0C7`).
     - Night: `#23272A` (border `#3A3F43`, brass lock badge `16×16px bg-[#6B401E]` with icon `lock` 10px `#FFDCC5`).
     - OLED: `#121212` (border `#2D2D2D`, lock badge `16×16px bg-[#6B401E]`).
   - Typeface Carousel: 5 horizontal cards (`px-3.5 py-2.5 rounded-xl`): Newsreader (active `#2F4A7A`), Inter, Literata, EB Garamond, Source Serif 4.
   - Typography Sliders: 3 cards in `bg-[#F6F3EE]/70 rounded-2xl p-3 border 1px #E8E2D9/70`:
     - Font Size: min 12, max 28, value 18, leading `"A−"` (12px), trailing `"A+"` (16px), accent `#2F4A7A`.
     - Line Spacing: min 1.1, max 2.2, step 0.1, value 1.6, leading icon `format_line_spacing` (18px), trailing icon `density_medium` (20px).
     - Side Margins: min 12, max 44, step 2, value 24, leading icon `width_normal` (18px), trailing icon `width_wide` (18px).
   - Layout & Flow: Segmented control (`Scroll`, `Pages`, `Two Columns`) in pill container `bg-[#EBE8E3] rounded-full`. Inset grouped card (`rounded-2xl border 1px #E8E2D9 divide-y 1px #E8E2D9/80`) with 3 toggle switches: `"Justify text"`, `"Hyphenation"`, `"Publisher styles"`.
   - Display Brightness: Card with slider (10–100%, value 85%), leading icon `light_mode`, trailing icon `brightness_high` (filled `#2F4A7A`) + sub-row `"Follow system brightness"` switch.

2. **`04c_text_selection_dictionary` (`3377a7d8be9f4c4a806e881edd365939`)**:
   - Selection Highlight: `bg-[#2F4A7A]/15` (`rgba(47,74,122,0.15)`), text `#2F4A7A`, rounded-sm. Left and right handles: `2px #2F4A7A` bar with rotated 45° teardrop pins (`8×8px #2F4A7A`).
   - Floating Selection Toolbar: `bg-white/95 backdrop-blur-md rounded-2xl border 1px #E8E2D9`, shadow `0 10px 25px -5px rgba(28,27,26,0.12), 0 4px 10px rgba(28,27,26,0.06)`, atmospheric pointer caret (`10×10px` rotated 45°). Actions:
     - Highlight: icon `brush` (19px) + 5 color dots (8×8px each): Yellow `#FDE047`, Green `#86EFAC`, Blue `#93C5FD`, Pink `#F472B6`, Orange `#FDBA74`.
     - Divider: `1px × 16px` `#C4C6D0/40`.
     - Note: icon `edit_note` (20px).
     - Define: Active pill `bg-[#153362] text-white rounded-xl px-3 py-1.5 font-label-md` with icon `local_library` (18px).
     - Copy: icon `content_copy` (19px).
     - Share: icon `share` (19px).
     - More: icon `more_horiz` (20px).
   - Bottom Dictionary Card: `rounded-t-[28px]`, max-h 510px, drag handle `40×4px bg-[#DCDAD5]`.
     - Word: `Newsreader 30px w600 #1C1C19`.
     - Phonetics: `/ˈlɪt(ə)rəl/` (`Inter 12px w400 #635D56`).
     - Audio button: `28×28px bg-[#F6F3EE] border 1px #E8E2D9` with icon `volume_up` (16px `#153362`).
     - Actions: Bookmark icon `bookmark_add` (20px) and close `close` (20px).
     - Etymology: icon `history_edu` (15px) + text `"Latin littoralis, from litus (‘shore’)"`.
     - Chips: Active `"adjective"` (`bg-[#2F4A7A] text-white rounded-full px-3.5 py-1`), inactive `"noun"` (`bg-[#F6F3EE] text-[#635D56]`), status `"Local Lexicon"` with green dot (`#059669`).
     - Definitions: Numbered list with blockquoted usage sentences (`pl-3 border-l-2 border-[#2F4A7A]/30 italic Newsreader 14px #635D56`).
     - Action buttons: `"Add to Flashcards"` (`bg-[#F6F3EE] border 1px #E8E2D9`), `"Copy"` (`bg-[#F6F3EE]`), and `"Full entry"`.
     - Footer: `"From Wiktionary · CC BY-SA 3.0 · Offline Lexicon"` + `"0 B used"` with `wifi_off` icon (`#047857`).

3. **`04d_contents_annotations` (`60c9068ec7e6446eb55f8762102cb112`)**:
   - Navigation Side Sheet: Left drawer (width `350px`, height 100%, bg `#FCF9F4`, border right `1px #E5E2DD`, shadow `8px 0 32px -4px rgba(28,27,26,0.18)`). Right remaining ~62px strip is dimmed backdrop with tap-to-close circle button.
   - Header: Action row with back arrow `arrow_back`, search `search`, and export `ios_share`. Book title in `Newsreader 19px w500 italic` + author in `Inter 12px`. 3 tabs: Contents (count badge 18, active `#2F4A7A`), Bookmarks (count 3), Highlights (count 12).
   - Reading Progress Banner: Inset card (`bg-[#F6F3EE] border 1px #E5E2DD rounded-xl p-3`), icon `auto_stories` in 28×28px circle, `"Chapter 4 · Page 142 of 380 · 37% completed"`, badge `"37%"` in `#D7E2FF/50`.
   - TOC Tree: Expandable/collapsible parts. Active chapter (Chapter 4) highlighted with deep blue vertical strip (`w-1.5 bg-[#2F4A7A]`), dot indicator, `"Chapter Four: The Silent Harbour"`, `"Current"` badge, `"Reading now · Page 142"`, and page number `p. 142` in tabular numbers.
   - Highlights in Chapter: Grouped cards with left color strip (blue `#2F4A7A`, amber `#D99B26`), quote in `Newsreader 18px italic`, attached note in `Inter 13px`, date and page reference.
   - Footer: Full-width stadium button `"Export as Markdown (.md)"` (h-11 rounded-full border `1px #E5E2DD bg-white`) + info `"Local Offline Vault · 24.8 KB"`.

4. **`04e_search_in_book` (`c63b6121c3f6481fa466900795a02b89`)**:
   - Fullscreen overlay on `#FAF7F2` canvas.
   - Editorial breadcrumb header: Back arrow, `"The Shadow of the Wind · Carlos Ruiz Zafón"`, format `"EPUB"`.
   - Search card: `bg-white rounded-2xl border 1px #E8E2D9 p-2.5 shadow-[0_4px_16px_rgba(28,27,26,0.04)]`. Input text `"harbour"` in `Newsreader 19px`, blinking cursor `1.5×20px #2F4A7A`, badge `"23 results"` in `#2F4A7A/10`, clear button `close`.
   - Occurrence stepper sub-row: `"Match 4 of 23 in current chapter"`, previous match arrow `keyboard_arrow_up`, next match arrow `keyboard_arrow_down`.
   - Filter chips: `"This book (23)"` (active `#2F4A7A`), `"All chapters"`, `"Notes & Highlights"`, `"Case sensitive"`.
   - Result list grouped by chapters: Chapter headers with result counts and `"Current"` badge. Snippets with highlighted matching keyword `<mark class="bg-[#2F4A7A]/10 text-[#2F4A7A]">`. Focused active match card has pulsing blue dot, label `MATCH 4 OF 23`, left accent line, and `p. 142 (Current)`.
   - Floating Bottom Jump Bar (NOT a BottomNavBar): Floating pill (`absolute bottom-5 inset-x-5 bg-white/95 backdrop-blur-md rounded-full border 1px #E8E2D9 shadow-[0_8px_24px_-4px_rgba(28,27,26,0.12)] p-1.5`). Left: `"Return to position · Page 142 (62%)"` with `bookmark_border`. Right: stadium button `"Done"` with `check` icon in `#2F4A7A`.

5. **`05_read_aloud` (`b44bfe8531334c9fab5c6e95ba2c2ac3`)**:
   - Spoken sentence highlight on reader canvas: `<mark class="bg-[#D6E2F5]/40 text-[#1C1B1A] border-b border-[#2F4A7A]/20">` with dimmed backdrop (`bg-[#31302D]/15`).
   - Expanded Bottom Player Sheet: Level 3 Modal Bottom Sheet (`rounded-t-3xl border-t 1px #E8E2D9 shadow-[0_-8px_32px_rgba(28,27,26,0.12)] bg-white pt-3 pb-6 px-6`). Drag handle `40×4px bg-[#CEC5BB]`.
   - Book header: 2:3 book cover (`48×64px rounded-lg bg-[#F0EDE9] border 1px #E5E2DD/60 shadow-[0_2px_8px_rgba(28,27,26,0.08)]`), title `"The Shadow of the Wind"`, author, chapter title, and minimize button `keyboard_arrow_down`.
   - Spoken sentence card: Inset card (`bg-[#F6F3EE]/60 rounded-2xl p-4 border 1px #F0EDE9`). Previous sentence faded in 50% opacity italic; current sentence quoted with vertical left bar (`2px #2F4A7A`) in `Newsreader 19px w500 #1C1C19`; next sentence faded in 60% opacity.
   - Chapter timeline scrubber: height 20px, filled progress bar `#2F4A7A`, scrubber thumb `16×16px #2F4A7A` with white border, elapsed `"04:18"`, sentence badge `"Sentence 14 of 48"` (`bg-[#EAE1D7]/50`), remaining `"-08:42"`.
   - Controls: Bookmark button `bookmark_add`, Skip back 10s `replay_10`, 64×64px hero play/pause circular button in `#2F4A7A`, Skip forward 10s `forward_10`, overflow menu `more_vert`.
   - Adjustment chips: Speed `"1.25x"` (active `#2F4A7A`), Voice `"Natural 2"`, Sleep timer `"30 min"`.
   - Footer: `"Local On-Device TTS · 0 KB network used"` with `lock` icon.

---

### 2. Logic Chain

1. **Appearance Sheet Implementation (`lib/presentation/screen/reader/widgets/appearance_sheet.dart`)**:
   - Currently, `_ReaderSettingsSheet` is embedded inside `reader_screen.dart` (lines 2700-3112) with simple ChoiceChips and Sliders.
   - By extracting and upgrading this to a standalone `AppearanceSheet` widget matching `04b_appearance_sheet_screen.html`, we provide the 6 theme swatches (with `#6B401E` lock badges and `#2F4A7A` active double rings), 5 typeface cards (`Newsreader`, `Inter`, `Literata`, `EB Garamond`, `Source Serif 4`), 3 slider cards with `A−/A+` and icons, the segmented mode pill (`Scroll`/`Pages`/`Two Columns`), the 3 switch grouped card (`Justify`, `Hyphenation`, `Publisher styles`), and the display brightness slider + system toggle.
   - State connects to `SettingsEntity` and `SettingsRepository`, with preview mode handling for locked themes via `AppearanceCatalog.effective()` and `AppearanceCatalog.persistable()`.

2. **Text Selection & Dictionary Card (`lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` & `highlight_editor_sheet.dart`)**:
   - `highlight_editor_sheet.dart` already supports `HighlightColor` (yellow, green, blue, pink, orange). We can expose the quick 5-color dot toolbar on the floating selection toolbar above selected text.
   - `DictionaryLookupSheet` currently renders a basic list of meanings. Upgrading it to match `04c_text_selection_dictionary_screen.html` gives the headword serif title, `/phonetic/`, speaker audio button invoking `FlutterTts`, etymology, Part-of-Speech filter chips (`adjective`, `noun`), definition blockquotes with left `#2F4A7A/30` vertical borders, "Add to Flashcards" pill, and Wiktionary CC BY-SA 3.0 attribution footer.

3. **Contents & Annotations Side Sheet (`lib/presentation/screen/reader/widgets/contents_annotations_sheet.dart` / updating `notes_sheet.dart`)**:
   - Currently, `reader_screen.dart` opens a standard 55% bottom sheet for TOC and `NotesSheet` for notes.
   - Following `04d_contents_annotations_screen.html`, a unified `ContentsAnnotationsSheet` provides the 350px left drawer layout, the 3 tab pills (`Contents`, `Bookmarks`, `Highlights`), the reading progress banner with `auto_stories` and percentage badge, the TOC tree with deep blue active indicator (`w-1.5 #2F4A7A`) and "Current" badge, and the chapter notes preview cards.
   - The sticky footer button triggers `AnnotationMarkdownExporter.export()` and shares via `SharePlus`.

4. **In-Book Search Overlay (`lib/presentation/screen/reader/widgets/reader_search.dart`)**:
   - Currently, `_ReaderSearchSheet` is an internal private widget in `reader_screen.dart`.
   - Extracting and upgrading to `ReaderSearchOverlay` matching `04e_search_in_book_screen.html` adds the editorial context breadcrumb (`Title · Author · EPUB`), the search bar card with blinking cursor, match counter badge ("23 results"), occurrence stepper sub-row ("Match 4 of 23 in current chapter"), scope filter chips, grouped chapter cards with highlighted `<mark>` keywords, active match card with pulsing dot, and the floating bottom jump bar ("Return to position · Page 142 (62%)" + "Done" pill).

5. **Read Aloud In-App Player (`lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`)**:
   - Currently, `ReadAloudPlayer` is a compact bottom bar (`Row` of 7 icons).
   - Upgrading `ReadAloudPlayer` to match `05_read_aloud_screen.html` provides the expanded Level 3 Modal Bottom Sheet with the 2:3 miniature book cover, book title and chapter metadata, editorial spoken sentence card with faded preceding/succeeding sentences and `#2F4A7A` left accent bar, chapter timeline scrubber with elapsed/remaining times and "Sentence 14 of 48" badge, 64px hero play/pause circular button in `#2F4A7A`, and fine-tuning chips for Speed ("1.25x"), Voice ("Natural 2"), and Sleep timer ("30 min").
   - Reader canvas draws the sentence highlight band in `#D6E2F5` with bottom border `#2F4A7A/20`.

---

### 3. Caveats

1. **Hardware Text-to-Speech Voices**: Available voices depend on device platform engines (Android TTS / iOS AVSpeechSynthesizer). Mock voices and natural labels ("Natural 2", "English (US)") should map to `ReadAloudVoice` entities with fallback to default system voice.
2. **Readium vs Fallback Formats**: EPUB uses Readium where native selection action menu applies on Android/iOS; reflowable fallback formats (TXT, MD, FB2) use Flutter's `SelectableText.rich` and custom floating context menus. Both must share identical design tokens.
3. **No Bottom Navigation Bar Mandate**: Both the Search In-Book bottom bar ("Return to position" + "Done") and Read Aloud controls are floating modal sheets/pills, NOT `BottomNavigationBar` or `NavigationBar`. This strictly complies with Requirement R1 and R4.

---

### 4. Conclusion

All 5 screens in Milestone 4 have unambiguous, pixel-exact design specifications documented in local HTML/CSS files and mockups. The design system follows Material 3 Warm Editorial Minimalism:
- Palette: Canvas Ivory `#FAF7F2`, Card Surface `#FFFFFF`, Hairline `#E8E2D9`, Text Ink `#1C1B1A`, Secondary Slate `#6B655D`, Accent Blue `#2F4A7A`, Spoken Highlight `#D6E2F5`.
- Typography: Headings in `Newsreader` serif, UI metadata and controls in `Inter` sans, tabular figures for all numeric indicators.
- Radii: Cards `16px`, Bottom Sheets `24px` / `28px`, Action pills & chips `StadiumBorder()`.

The plan is actionable and provides all needed dimensions, color codes, widget hierarchies, micro-interactions, inputs, outputs, and edge cases for the implementation engineer.

---

### 5. Verification Method

To independently verify this specification:
1. **HTML Inspection**:
   - Run `grep -n "border" design/screens/04b_appearance_sheet/04b_appearance_sheet_screen.html`
   - Run `grep -n "bg-primary-container" design/screens/04c_text_selection_dictionary/04c_text_selection_dictionary_screen.html`
   - Run `grep -n "w-\[350px\]" design/screens/04d_contents_annotations/04d_contents_annotations_screen.html`
   - Run `grep -n "Return to position" design/screens/04e_search_in_book/04e_search_in_book_screen.html`
   - Run `grep -n "D6E2F5" design/screens/05_read_aloud/05_read_aloud_screen.html`
2. **Visual Image Comparison**:
   - Inspect `.png` renderings in each screen directory:
     - `design/screens/04b_appearance_sheet/04b_appearance_sheet_screen.png`
     - `design/screens/04c_text_selection_dictionary/04c_text_selection_dictionary_screen.png`
     - `design/screens/04d_contents_annotations/04d_contents_annotations_screen.png`
     - `design/screens/04e_search_in_book/04e_search_in_book_screen.png`
     - `design/screens/05_read_aloud/05_read_aloud_screen.png`
3. **Flutter Static Analysis & Tests**:
   - Run `fvm flutter analyze` to verify clean analysis.
   - Run `fvm flutter test` to ensure existing reader unit and cubit tests pass.

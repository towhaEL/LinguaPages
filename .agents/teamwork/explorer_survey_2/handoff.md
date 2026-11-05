# Handoff Report — Explorer Survey 2: Reader & Services (R4 & R5)

**Agent**: `explorer_survey_2`  
**Working Directory**: `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/explorer_survey_2/`  
**Recipient**: `2283687a-5c7c-4e1f-9d03-d89b8d745253`  
**Date**: 2026-11-04  
**Scope**: Codebase Survey & Gap Analysis for R4 (Reader Experience & Overlays) and R5 (Audio, Lock Screen, Settings, Premium, Annotations).

---

## 1. Observation

### 1.1 File Existence & Codebase Map
From inspecting the repository tree and lines of code:

| Screen / Feature | Target Specification Path | Current Code Location | Status & Line Count |
|---|---|---|---|
| **04 Reader Chrome Visible** (`80a5b425`) | `lib/presentation/screen/reader/widgets/reader_chrome.dart` | `lib/presentation/screen/reader/widgets/reader_chrome.dart` & `reader_screen.dart` | 252 lines (`reader_chrome.dart`), 3,558 lines (`reader_screen.dart`) |
| **04-var Reader Zen Mode** (`b868e1ce`) | `lib/presentation/screen/reader/reader_screen.dart` | `reader_screen.dart:425-464` (`_pageOverlays`) | Embedded inside `reader_screen.dart` |
| **04b Appearance Sheet** (`d8bb2a41`) | `lib/presentation/screen/reader/widgets/appearance_sheet.dart` | `reader_screen.dart:2900-3113` (`_ReaderSettingsSheet`) | **Missing standalone file**; embedded as private class |
| **04c Text Selection & Dictionary** (`3377a7d8`) | `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` | `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` | 408 lines; lacks floating selection toolbar |
| **04d Contents & Annotations** (`60c9068e`) | `lib/presentation/screen/reader/widgets/notes_sheet.dart` | `notes_sheet.dart` (456 lines) & `reader_screen.dart:1880-1920` (`_showTableOfContents`) | Split across two separate sheets |
| **04e In-Book Search** (`c63b6121`) | `lib/presentation/screen/reader/widgets/reader_search.dart` | `reader_screen.dart:3384-3558` (`_ReaderSearchSheet`) | **Missing standalone file**; embedded as private class |
| **05 Read Aloud Player** (`b44bfe85`) | `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` | `read_aloud_player.dart` (217 lines), `read_aloud_cubit.dart` (229 lines) | Minimal 1-row bar; lacks 2:3 cover, serif quote, chapter scrubber |
| **06 Lock Screen Controls** (`cb0c0e53`) | Android MediaSession / `audio_service` integration | Handled via `flutter_readium` native TTS; no custom Flutter UI | Android 15 system UI reference; `pubspec.yaml` has `flutter_tts` & `flutter_readium`, not `audio_service` |
| **03 Settings Screen** (`0e2582dd`) | `lib/presentation/screen/settings/settings_portrait_view.dart` | `settings_portrait_view.dart` (730 lines) | Missing "Appearance" card group and "Read aloud" speed scrubber |
| **07 Premium Paywall** (`e4e1f706`) | `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart` | `premium_paywall_sheet.dart` (274 lines), `premium_cubit.dart` (144 lines) | Missing 3-theme hero preview carousel & 2 plan radio cards |
| **08 All Annotations** (`837a423b`) | `lib/presentation/screen/annotations/annotations_screen.dart` | `annotations_screen.dart` (346 lines), `annotations_cubit.dart` (64 lines) | Flat list without book grouping headers, 2:3 covers, or filter counts |

### 1.2 State Management Architecture Observed
- **Reader Screen** (`lib/presentation/screen/reader/reader_screen.dart`):
  - Implemented as a monolithic `StatefulWidget` (`_ReaderScreenState`), NOT a Cubit.
  - Controls lifecycle of `ReadiumDocumentSession` for EPUB/PDF, reflowable document engines for text formats, and integrates `ReadAloudCubit` and `DictionaryLookupCubit`.
  - Directly invokes Drift repositories: `SettingsRepository`, `HighlightRepository`, `BookmarkRepository`, `ReadingSessionRepository`, and device services `ScreenBrightnessService` and `VolumeKeyService`.
- **Read Aloud** (`lib/presentation/screen/reader/read_aloud/read_aloud_cubit.dart`):
  - Uses `ReadAloudCubit` with state `ReadAloudState` (`active`, `status`, `voices`, `voice`, `speed`, `sleep`, `problem`).
  - Coupled with `ReadAloudService` (`ReadiumReadAloudService` for Readium books, `FlutterTtsReadAloudService` for fallback text).
  - Uses `SleepTimer` (`sleep_timer.dart`) for countdown and end-of-chapter timers.
- **Dictionary Lookup** (`lib/presentation/screen/reader/cubit/dictionary_lookup_cubit.dart`):
  - Uses `DictionaryLookupCubit` with state `DictionaryLookupState` (`status`, `word`, `entries`).
  - Backed by `DictionaryRepository` (Drift cache + remote API fallback).
- **Settings** (`lib/presentation/screen/settings/settings_portrait_view.dart`):
  - No `SettingsCubit` exists. Multiple private `StatefulWidget` states (`_ReadingSettingsState`, `_DictionarySettingsState`, `_BackupManagerState`) access `injector<SettingsRepository>()` directly and call `updateSetting()`.
  - Connects to `BlocBuilder<PremiumCubit, PremiumState>` to observe premium unlock status.
- **Premium Monetization** (`lib/presentation/screen/premium/cubit/premium_cubit.dart`):
  - Uses `@lazySingleton class PremiumCubit extends Cubit<PremiumState>`.
  - `PremiumState` contains `bool unlocked`, `PremiumStatus status`, and `BillingProduct? product`.
- **Annotations** (`lib/presentation/screen/annotations/cubit/annotations_cubit.dart`):
  - Uses `@injectable class AnnotationsCubit extends Cubit<AnnotationsState>`.
  - `AnnotationsState` manages `status`, `items` (`List<AnnotationItem>`), `type`, `color`, `bookId`, and `query`. Contains `visible` and `toMarkdown()`.

### 1.3 Verbatim Tool Command Results & Environmental Observations
- Running `flutter analyze`:
  ```
  The current Flutter SDK version is 3.44.2.
  Because flutter_readium 0.6.2 requires Flutter SDK version >=3.44.8 and no
    versions of flutter_readium match >0.6.2 <0.7.0, flutter_readium ^0.6.2 is forbidden.
  So, because lingua_pages depends on flutter_readium ^0.6.2, version solving failed.
  Try using the Flutter SDK version: 3.47.9.
  ```
- Running `fvm list`:
  ```
  stable: 3.44.2 (Dart 3.12.2)
  ```
- `DarkColorTheme` (`lib/presentation/theme/dark/dark_color_theme.dart`):
  Currently uses `fontFamily = 'Figtree'` and orange accent `_orange = Color(0xFFE0742E)`. The R1 core token requirement specifies Newsreader/Inter and `#2F4A7A`.

---

## 2. Logic Chain

### 2.1 Reader Experience & Overlays (R4)
1. **04 Reader Chrome Visible (`80a5b425`)**:
   - *Observation*: In `reader_chrome.dart:55-95`, `ReaderTopBar` only supports a back button, title, and one trailing widget. In `reader_screen.dart:563-600`, `_buildBottomBar` renders 5-6 tools including search and notes.
   - *Design Gap*: The Stitch spec (`04_reader_chrome_visible_screen.html`) places Search, Bookmark, and Overflow menu (`more_vert`) in the translucent top bar (`#F6F1E7/90` with backdrop blur and `#E8E2D9` hairline).
   - *Design Gap*: The left edge indicator must be a floating capsule rail (`left-2.5 top-1/2 -translate-y-1/2`, `width: 3px`, height percentage bar) instead of the dark square popup in `reader_screen.dart:500-532`.
   - *Design Gap*: The bottom panel must feature a rounded-t-28px/24px sheet with a drag handle, chapter title, "Page 142 of 380 · 12 min left in chapter", a 37% percentage badge pill, a progress scrubber with chapter tick marks and previous/next chapter steppers, and exactly 4 tools: `Contents`, `Appearance`, `Listen`, `Notes`.

2. **04-var Zen Mode (`b868e1ce`)**:
   - *Observation*: In `reader_screen.dart:439-464`, `_pageOverlays` renders a single centered text caption at the bottom.
   - *Design Gap*: In `04_reader_chrome_hidden_screen.html`, Zen mode features a 100% reading viewport on paper canvas `#F6F1E7`, drop cap initial letter in Newsreader (`#2F4A7A`), an archival corner bookmark ribbon pinned top-right (`top: 0, right: 28`), and a 3-part footer: "12 min left in chapter", center dot, and page counter `142 / 380 · 37%`.

3. **04b Appearance Sheet (`d8bb2a41`)**:
   - *Observation*: Currently embedded as `_ReaderSettingsSheet` in `reader_screen.dart:2900-3113`.
   - *Design Gap*: The design requires a standalone bottom sheet with 5 distinct sections:
     1. Page Tone: 6 circular 40-44px swatches (`Paper #F6F1E7`, `White #FFFFFF`, `Sepia #F4ECD8`, `Grey #EAE6DF`, `Night #23272A` [locked], `OLED #121212` [locked]) with double-ring selection indicator.
     2. Typeface: Horizontal scroll cards with "Aa" sample, font name, and category badge (`Newsreader`, `Inter`, `Literata`, `EB Garamond`, `Source Serif 4`).
     3. Typography & Spacing: Sliders with `A−` / `A+` end indicators for font size, line spacing, and margins.
     4. Layout & Flow: Segmented control (`Scroll` / `Pages` / `Two Columns`), toggle switches for `Justify text`, `Hyphenation`, and `Publisher styles`.
     5. Display Brightness: Slider with `Follow system brightness` toggle.

4. **04c Text Selection & Dictionary (`3377a7d8`)**:
   - *Observation*: `DictionaryLookupSheet` only renders a definition list and two bottom buttons (`Copy` and `Highlight`).
   - *Design Gap*: The design requires a two-tiered selection UI:
     1. Floating contextual toolbar hovering above the selected text with: Highlight (5 color dots: yellow `#FFD54F`, green `#81C784`, blue `#64B5F6`, pink `#F06292`, orange `#FFB74D`), Add Note button, Define button (active in ink blue `#2F4A7A`), Copy, Share.
     2. Bottom dictionary sheet with phonetic spelling, audio pronunciation button, part of speech chips (`adjective`, `noun`), numbered definition rows, and Wiktionary CC BY-SA 3.0 attribution footer.

5. **04d Contents & Annotations Panel (`60c9068e`)**:
   - *Observation*: TOC is handled separately in `reader_screen.dart:1880-1920`, while notes and bookmarks are in `notes_sheet.dart`.
   - *Design Gap*: Design requires a single unified side/bottom sheet with 3 tabs (`Contents`, `Bookmarks`, `Highlights`), a top-right "Export as Markdown" action, nested chapter tree with active chapter indicator (3px `#2F4A7A` vertical strip), and highlight cards with color strip, quote, page number, and note.

6. **04e In-Book Search (`c63b6121`)**:
   - *Observation*: Currently embedded as `_ReaderSearchSheet` in `reader_screen.dart:3384-3558`.
   - *Design Gap*: Design requires an integrated top search bar with match counter badge ("23 results"), previous/next stepper arrow buttons, and a result snippets list grouped by chapter with search terms bolded in `#2F4A7A` and page number badges.

---

### 2.2 Audio, Monetization, Settings & Annotations (R5)
1. **05 Read Aloud In-App Player (`b44bfe85`)**:
   - *Observation 1 (Spoken highlight)*: In `reader_screen.dart:1525`, fallback text sets `color: HighlightColor.yellow`. It must use `#D6E2F5` (`AppColors.accentContainer`).
   - *Observation 2 (Player UI)*: `read_aloud_player.dart` is currently a single-line 56px row.
   - *Design Gap*: Design specifies an expanded bottom player sheet:
     - Top miniature 2:3 book cover with soft drop shadow + book title in Newsreader serif + chapter subtitle.
     - Spoken sentence card: active sentence displayed large in serif with preceding/following sentences faded in slate (`opacity: 0.5`).
     - Progress scrubber with current timestamp, sentence index badge ("Sentence 14 of 48"), and remaining time.
     - Playback controls: 10s skip backward, 64×64px circular play/pause button in `#2F4A7A`, 10s skip forward, and bookmark moment button.
     - Pill chips row: Speed (`1.25x`), Voice picker, Sleep timer (`30 min`), plus offline privacy badge.

2. **06 Android Lock Screen Controls (`cb0c0e53`)**:
   - *Observation*: As documented in `design/design.md` lines 93-94, the lock screen card is rendered natively by Android 15's SystemUI via `MediaSession`.
   - *Integration Reality*: `flutter_readium` manages the MediaSession for EPUB and PDF via native TTS navigator. For text formats (TXT, MD, HTML, FB2), `flutter_tts` does not produce a system media notification. Metadata passed to MediaSession must include book cover art, chapter title, subtitle, and actions matching the reference mockup.

3. **03 Settings Screen (`0e2582dd`)**:
   - *Observation*: `settings_portrait_view.dart` contains no Appearance section and groups settings into flat sections.
   - *Design Gap*: Must be restructured into 6 inset grouped cards (`16px` radius, `#FFFFFF` surface, 1px `#E8E2D9` border):
     1. Patron Edition Banner ("Unlock 12 themes and 8 fonts" + "Unlock" pill button).
     2. Group 1: Appearance (Theme: Light / Dark / System segmented pill; Interface scale slider 80%-130%).
     3. Group 2: Reading defaults (4 paper tone swatches, font selector chips, tap zones tile, volume keys toggle, keep screen awake toggle).
     4. Group 3: Read aloud (Voice selector tile, 0.5x-2.5x speed slider with tick labels, skip page numbers toggle).
     5. Group 4: Library & Backup (Import folder tile, auto-mark finished toggle, trash auto-empty tile, dual "Back up now" and "Restore backup" buttons).
     6. Group 5: About & Licenses (Dictionary credits, open-source licenses, privacy pledge, version footer).

4. **07 Premium Appearance Paywall (`e4e1f706`)**:
   - *Observation*: `premium_paywall_sheet.dart` displays swatches and text bullets in a single scrollable sheet.
   - *Design Gap*: Needs:
     - Top close '✕' button.
     - 3-theme hero preview carousel (Warm Linen, Midnight Blue, Forest) with quotes in Newsreader serif.
     - Headline "Make every page yours" + feature checkmarks.
     - Reassurance card ("Reading, offline storage, dictionary, and search remain free forever").
     - 2 selectable plan cards with radio buttons: Lifetime ($14.99 one-time, "Best Value" chip) and Yearly ($4.99/year).
     - Full-width stadium CTA "Unlock Premium" in `#2F4A7A` + "Restore purchases" link.

5. **08 All Annotations Screen (`837a423b`)**:
   - *Observation*: `annotations_screen.dart` renders a flat list of `_AnnotationRow` items.
   - *Design Gap*: Must render:
     - Top bar with item counter ("42 items"), search icon, overflow menu ("Export as Markdown (.md)", "Export as Plain Text", "Clear Selected").
     - Search bar ("Search highlights & notes...").
     - Horizontally scrollable filter chips with counts (`All (42)`, `Highlights (30)`, `Notes (12)`, `Bookmarks (8)`) and color dot filters.
     - Grouped cards by book: Book header with 2:3 cover thumbnail, title in Newsreader, author, and annotation count badge.
     - Annotation item cards: vertical color strip indicator, italic serif quote, attached note in secondary container, page reference & date footer.

---

## 3. Caveats

1. **Environment Flutter SDK Mismatch**:
   - The sandbox environment currently runs Flutter `3.44.2` (`/home/tn-99778/fvm/default/bin/flutter`), but `pubspec.yaml` specifies `flutter_readium: ^0.6.2`, which requires Flutter `>=3.44.8`.
   - Running `flutter analyze` without `--no-pub` fails on pub resolution. To resolve this, the environment requires Flutter 3.47+ (or pub resolution with an updated SDK).
2. **Missing `audio_service` Package**:
   - Neither `audio_service` nor `media_session` is present in `pubspec.yaml`. Lock-screen MediaSession for EPUB/PDF is handled by `flutter_readium`. Text fallback formats currently lack native MediaSession background notifications.
3. **Monolithic `reader_screen.dart`**:
   - At 3,558 lines, `reader_screen.dart` contains critical reader state and inline UI components (`_ReaderSettingsSheet`, `_ReaderSearchSheet`). Refactoring these into standalone files (`appearance_sheet.dart`, `reader_search.dart`) must preserve all callbacks and state variables without breaking existing reader logic.
4. **State Management Independence**:
   - `SettingsPortraitView` does not use a `SettingsCubit`, relying on `SettingsRepository` and local state. Do not invent an unnecessary breaking Cubit layer unless orchestrator coordinates it; maintain repository compatibility.

---

## 4. Conclusion

The application possesses solid domain logic and data layers (Drift database, Readium session, text engines, repositories, and cubits for ReadAloud, Premium, Dictionary, and Annotations). However, the presentation layer exhibits significant visual and structural gaps when compared against Stitch UI designs:
1. **R4**: Missing modularization for `appearance_sheet.dart` and `reader_search.dart`; reader chrome needs translucent top bar and 4-tool bottom panel with chapter scrubber; zen mode requires drop cap, ribbon, and cadence footer; text selection requires the floating toolbar; TOC and annotations require unification.
2. **R5**: Read Aloud player must be upgraded from a 1-row widget to the full bottom player sheet with sentence tracking; sentence highlight color must be corrected to `#D6E2F5`; Settings screen needs inset grouped cards and the Appearance section; Premium paywall requires the 3-theme hero carousel and dual plan cards; Annotations screen must group items by book with 2:3 covers and vertical color strips.

### Proposed File Boundaries for Clean Implementation
- `lib/presentation/screen/reader/widgets/reader_chrome.dart` — Translucent top bar, left brightness rail, 4-tool bottom panel.
- `lib/presentation/screen/reader/widgets/appearance_sheet.dart` — Extracted standalone sheet for 6 themes, fonts, typography sliders, layout, brightness.
- `lib/presentation/screen/reader/widgets/reader_search.dart` — Extracted standalone search overlay with counter, steppers, and chapter snippets.
- `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` & `selection_toolbar.dart` — Floating toolbar + dictionary sheet.
- `lib/presentation/screen/reader/widgets/notes_sheet.dart` — Unified TOC, bookmarks, and highlights panel with Markdown export.
- `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` — Expanded player bottom sheet with 2:3 cover, serif quote, and controls.
- `lib/presentation/screen/settings/settings_portrait_view.dart` — Inset grouped cards with Appearance and reading defaults.
- `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart` — Paywall with theme carousel and plan cards.
- `lib/presentation/screen/annotations/annotations_screen.dart` — Book-grouped annotations list with 2:3 cover thumbnails and Markdown export.

---

## 5. Verification Method

To verify these findings and check progress during subsequent implementation:

1. **Inspect Target Files**:
   - `view_file` on `lib/presentation/screen/reader/reader_screen.dart` (lines 2900-3558 for embedded sheets).
   - `view_file` on `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`.
   - `view_file` on `lib/presentation/screen/settings/settings_portrait_view.dart`.
   - `view_file` on `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`.
   - `view_file` on `lib/presentation/screen/annotations/annotations_screen.dart`.
2. **Inspect Stitch Reference Mockups & HTML**:
   - `design/screens/03_settings/03_settings_screen.html`
   - `design/screens/04_reader_chrome_visible/04_reader_chrome_visible_screen.html`
   - `design/screens/04_reader_chrome_hidden/04_reader_chrome_hidden_screen.html`
   - `design/screens/04b_appearance_sheet/04b_appearance_sheet_screen.html`
   - `design/screens/04c_text_selection_dictionary/04c_text_selection_dictionary_screen.html`
   - `design/screens/04d_contents_annotations/04d_contents_annotations_screen.html`
   - `design/screens/04e_search_in_book/04e_search_in_book_screen.html`
   - `design/screens/05_read_aloud/05_read_aloud_screen.html`
   - `design/screens/06_lock_screen/06_lock_screen_screen.html`
   - `design/screens/07_premium_paywall/07_premium_paywall_screen.html`
   - `design/screens/08_all_annotations/08_all_annotations_screen.html`
3. **Test Suite Verification**:
   - Run unit tests: `flutter test test/presentation/screen/reader/` and `flutter test test/presentation/screen/premium/`.
   - Run static analysis: `flutter analyze --no-pub`.

# Project: OpenPages Production UI Implementation

## Architecture
OpenPages is an offline-first, private e-book reader built with Flutter, BLoC/Cubit state management, Drift persistence, and Readium/text rendering engines.
The presentation layer follows Material 3 Warm Editorial Minimalism, targeting mobile viewports (412×915 dp) with:
- Warm ivory canvas (`#FAF7F2`) and pure white elevated cards (`#FFFFFF`)
- Distinctive hairline borders (`1px #E8E2D9`) and 16px/24px corner radii
- Editorial typography pairing `Newsreader` (serif for headings/titles) with `Inter` (sans for controls/labels)
- Dedicated paper reading canvas (`#F6F1E7`) and sentence tracking highlight (`#D6E2F5`)
- Strict architectural mandate: Absolutely **NO persistent bottom navigation bar** anywhere in the application.

## Toolchain & SDK Configuration
- Flutter SDK Requirement: `flutter_readium ^0.6.2` and `pubspec.lock` require Flutter SDK `>=3.47.0` (active stable version `3.47.9` available in FVM).
- All workers, reviewers, and challengers must execute Flutter commands using FVM: `fvm flutter analyze` and `fvm flutter test` (or point PATH to Flutter 3.47.9).

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Warm Editorial Palette | Ivory `#FAF7F2`, White `#FFFFFF`, Hairline `#E8E2D9`, Text `#1C1B1A`, Subtitle `#6B655D`, Accent `#2F4A7A`, Spoken `#D6E2F5`, Paper `#F6F1E7`, Destructive `#BA1A1A` | M1 | ORIGINAL_REQUEST §R1 |
| 2 | Typography Hierarchy | Newsreader serif for titles/headings, Inter sans for UI controls/labels, tabular figures for numbers | M1 | ORIGINAL_REQUEST §R1 |
| 3 | Shape & Radii System | Cards 16px, Bottom sheets 24-28px, Chips & CTAs StadiumBorder(), 1px borders | M1 | ORIGINAL_REQUEST §R1 |
| 4 | Bottom Nav Removal | Complete removal of bottomNavigationBar in dashboard_portrait.dart and anywhere in app | M1 | ORIGINAL_REQUEST §R1 |
| 5 | Theme Wiring | Integrate Warm Editorial theme into MaterialApp.router in app.dart preserving Cubits | M1 | ORIGINAL_REQUEST §R1 |
| 6 | Onboarding Page 1 (ce71ef53) | "Your books, all in one place" + onboarding_hero_illustration.png + 5 format pills | M2 | ORIGINAL_REQUEST §R2 |
| 7 | Onboarding Page 2 (ebb14c4c) | "Read the way you like" + onboarding_page_2_reading_styles.png + feature pills | M2 | ORIGINAL_REQUEST §R2 |
| 8 | Onboarding Page 3 (20ed4f15) | "Listen when your eyes rest" + onboarding_page_3_read_aloud.png + subtitle | M2 | ORIGINAL_REQUEST §R2 |
| 9 | Onboarding Page 4 (8a586c73) | "Private by design" + onboarding_page_4_privacy.png + dual buttons (Import / Explore) | M2 | ORIGINAL_REQUEST §R2 |
| 10 | Onboarding Dots & Flow | 4-page horizontal PageView carousel with animated active pill (24×8) & inactive dots (8×8) | M2 | ORIGINAL_REQUEST §R2 |
| 11 | Library Top Bar & Actions | Leading icon + "Library" title in Newsreader + search and settings icon buttons | M3 | ORIGINAL_REQUEST §R3 |
| 12 | Continue Reading Hero Card | 96×144 2:3 cover shadow, format badge, chapter progress bar, and "Resume" pill button | M3 | ORIGINAL_REQUEST §R3 |
| 13 | Recent Books Carousel | Horizontal scroll row with mini circular SVG progress rings | M3 | ORIGINAL_REQUEST §R3 |
| 14 | Library Filter Chips & Sort | Horizontal chips (All, Reading, To read, Finished, Favorites, Collections) + Sort button | M3 | ORIGINAL_REQUEST §R3 |
| 15 | 3-Column Book Grid | 2:3 cover ratio, format badges, progress indicators, 2-line title in Newsreader, author | M3 | ORIGINAL_REQUEST §R3 |
| 16 | Library Extended FAB | Bottom-right extended pill FAB (+ Import) in #2F4A7A with white label | M3 | ORIGINAL_REQUEST §R3 |
| 17 | Empty Library View (02b) | Centered empty_library_shelf.png, "Your shelf is quiet", dual buttons (Import files / folder) | M3 | ORIGINAL_REQUEST §R3 |
| 18 | Filter & Sort Sheet (02c) | Modal bottom sheet (28px radius), sort radios, format multi-select chips, categories, sticky Apply | M3 | ORIGINAL_REQUEST §R3 |
| 19 | Book Details Sheet (02d) | 130×195 cover, header, action row (Read, Collect, Edit, Share), metadata grid, Move to Trash | M3 | ORIGINAL_REQUEST §R3 |
| 20 | Fallback Book Cover Widget | Render fallback_book_cover_default.png in book_cover.dart when cover is missing | M3 | ORIGINAL_REQUEST §R3 |
| 21 | Reader Chrome Visible (04) | Paper #F6F1E7 canvas, translucent top bar, left brightness rail, bottom panel with scrubber & 4 tools | M4 | ORIGINAL_REQUEST §R4 |
| 22 | Reader Zen Mode (04-var) | 100% reading viewport, drop cap, corner bookmark ribbon, footer counter (142 / 380 · 37%) | M4 | ORIGINAL_REQUEST §R4 |
| 23 | Standalone Appearance Sheet (04b)| 6 theme swatches (with premium locks), font picker, typography sliders (A−/A+), layout controls | M4 | ORIGINAL_REQUEST §R4 |
| 24 | Selection & Dictionary Sheet (04c)| Floating toolbar (5 color dots, Note, Define, Copy, Share) + Wiktionary definition card | M4 | ORIGINAL_REQUEST §R4 |
| 25 | Unified TOC & Annotations (04d) | Left side sheet with Contents tree, Bookmarks tab, Highlights tab, Markdown export | M4 | ORIGINAL_REQUEST §R4 |
| 26 | In-Book Search Overlay (04e) | Search bar with match counter badge, stepper arrows, chapter snippets with bold keywords | M4 | ORIGINAL_REQUEST §R4 |
| 27 | Spoken Sentence Highlight | Sentence tracking highlight in reader canvas using #D6E2F5 (accentContainer) | M5 | ORIGINAL_REQUEST §R5 |
| 28 | Read Aloud Player Bottom Sheet (05)| Expanded sheet with 2:3 cover, serif quote card, timeline scrubber, 64px play/pause, chips | M5 | ORIGINAL_REQUEST §R5 |
| 29 | Lock Screen MediaSession (06) | Android MediaSession metadata and playback actions alignment | M5 | ORIGINAL_REQUEST §R5 |
| 30 | Settings Inset Grouped Cards (03) | 6 inset cards: Patron banner, Appearance, Reading defaults, Read aloud, Library/Backup, About | M5 | ORIGINAL_REQUEST §R5 |
| 31 | Premium Paywall Sheet (07) | 3-theme hero preview carousel, feature bullets, Lifetime & Yearly plan cards, unlock CTA | M5 | ORIGINAL_REQUEST §R5 |
| 32 | All Annotations Screen (08) | Grouped cards by book with 2:3 covers, vertical color strips, quotes, notes, Markdown export | M5 | ORIGINAL_REQUEST §R5 |
| 33 | E2E Testing Suite (Tiers 1-4) | Comprehensive opaque-box test runner and test cases covering all 32 features | E2E | ORIGINAL_REQUEST §R6 |
| 34 | Quality Assurance & 0-Lint (R6) | 100% test pass and 0 errors / 0 warnings in flutter analyze | M6 | ORIGINAL_REQUEST §R6 |

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| E2E | E2E Testing Track | Requirement-driven opaque-box test infra & test suite (Tiers 1-4), publishes TEST_READY.md | none | DONE |
| M1 | Core Design Tokens & Theme Synchronization | R1: Theme tokens in lib/presentation/theme/, remove NavigationBar in dashboard_portrait.dart, wire app.dart | none | DONE |
| M2 | Onboarding Flow | R2: 4-page PageView carousel, animated dots, format pills, dual actions in onboarding_screen.dart | M1 | DONE |
| M3 | Library & Book Management | R3: Home view, Continue Reading card, recent carousel, filter chips/sheet, 3-col grid, FAB, empty state, book details, book_cover.dart | M1 | PLANNED |
| M4 | Reader Experience & Overlays | R4: Reader chrome, zen mode, standalone appearance sheet, selection toolbar, dictionary sheet, TOC side sheet, search overlay | M1 | PLANNED |
| M5 | Audio, Settings, Monetization & Annotations | R5: Read aloud sentence highlight (#D6E2F5) & player sheet, MediaSession alignment, settings grouped cards, premium paywall, all annotations screen | M1 | PLANNED |
| M6 | Final Verification, QA & Hardening | R6: Run full E2E test suite (Tiers 1-4), adversarial hardening (Tier 5), ensure 0 analyze warnings/errors | M1, M2, M3, M4, M5, E2E | PLANNED |

## Interface Contracts

### Theme ↔ All Feature Screens
- `AppColors`: Exposes `background` (`#FAF7F2`), `surface` (`#FFFFFF`), `hairline` (`#E8E2D9`), `primaryInk` (`#1C1B1A`), `secondarySlate` (`#6B655D`), `accentInkBlue` (`#2F4A7A`), `accentContainer` (`#D6E2F5`), `paperReader` (`#F6F1E7`), `destructive` (`#BA1A1A`).
- `AppTheme`: Returns Material 3 `ThemeData` with `ScaffoldMessenger`, `CardTheme(radius: 16)`, `BottomSheetTheme(radius: 24)`, `ChipTheme(StadiumBorder)`.
- Navigation: Contextual routes only. Zero bottom navigation bars.

### Book Cover ↔ Library & Reader Sheets
- `BookCover`: Accepts `Book` entity, `width`, `height`, `elevation`.
- Fallback: When `coverPath == null` or missing, displays `Image.asset('assets/images/fallback_book_cover_default.png', fit: BoxFit.cover)`.

### Reader Screen ↔ Extracted Sheets (M4)
- `AppearanceSheet`: Callback `onThemeChanged(ReaderTheme)`, `onFontChanged(String)`, `onSizeChanged(double)`, `onBrightnessChanged(double)`.
- `ReaderSearchSheet`: Callback `onQueryChanged(String)`, `onResultSelected(SearchResult)`, `onDismiss()`.
- `DictionaryLookupSheet`: Receives `DictionaryLookupState`, callbacks for flashcards/copy.
- `NotesSheet`: Receives TOC entries, bookmarks, highlights, callback `onExportMarkdown()`.

### Read Aloud ↔ Reader Screen (M5)
- Sentence highlight: Uses `AppColors.accentContainer` (`#D6E2F5`) for currently active sentence in `reader_screen.dart`.
- `ReadAloudPlayerSheet`: Interacts with `ReadAloudCubit` (`play`, `pause`, `seek`, `setSpeed`, `setSleepTimer`).

## Code Layout
- `lib/presentation/theme/`: Master color tokens, text styles, app theme (`app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`).
- `lib/presentation/screen/dashboard/`: Root navigation scaffold (`dashboard_portrait.dart` - no bottom nav).
- `lib/presentation/screen/onboarding/`: Onboarding carousel (`onboarding_screen.dart`).
- `lib/presentation/screen/home/`: Library screens and sheets (`home_portrait_view.dart`, `components/library_content.dart`, `components/filter_sort_sheet.dart`, `components/library_book_actions.dart`).
- `lib/presentation/widgets/book/`: Book cover widget (`book_cover.dart`).
- `lib/presentation/screen/reader/`: Reader experience (`reader_screen.dart`, `widgets/reader_chrome.dart`, `widgets/appearance_sheet.dart`, `widgets/dictionary_lookup_sheet.dart`, `widgets/selection_toolbar.dart`, `widgets/notes_sheet.dart`, `widgets/reader_search.dart`).
- `lib/presentation/screen/reader/read_aloud/`: Read aloud player (`read_aloud_player.dart`).
- `lib/presentation/screen/settings/`: Settings screens (`settings_portrait_view.dart`).
- `lib/presentation/screen/premium/`: Premium paywall (`widgets/premium_paywall_sheet.dart`).
- `lib/presentation/screen/annotations/`: Annotations screen (`annotations_screen.dart`).
- `test/e2e/`: Opaque-box E2E test suite (Tiers 1-4).

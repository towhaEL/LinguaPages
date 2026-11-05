# Project: LinguaPages Remaining Screen UI & Components (Generation 2)

## Architecture
LinguaPages is an offline-first e-book reader following Material 3 Warm Editorial Minimalism:
- Palette: Canvas Ivory `#FAF7F2`, Surface White `#FFFFFF`, Hairline `#E8E2D9`, Text `#1C1B1A`, Subtitle `#6B655D`, Accent Ink Blue `#2F4A7A`, Spoken `#D6E2F5`, Paper `#F6F1E7`, Destructive `#BA1A1A`.
- Typography: Newsreader serif for titles/headings, Inter sans for UI controls/labels, tabular figures for numbers.
- Radii: Cards 16px, Bottom sheets 24-28px, Chips & CTAs StadiumBorder().
- Navigation: Strictly ZERO bottom navigation bars. All navigation is contextual.
- State: BLoC / Cubit integration with fallback/mock data for unbuilt backends.
- Toolchain: All Flutter commands must be executed via `fvm flutter <cmd>`.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Appearance Bottom Sheet | 6 theme swatches (with premium locks), font picker, typography sliders (A−/A+), layout controls, brightness | M4 | ORIGINAL_REQUEST §R2 (04b_appearance_sheet d8bb2a41) |
| 2 | Text Selection Toolbar | Floating toolbar (Highlight with 5 color dots, Note, Define, Copy, Share) | M4 | ORIGINAL_REQUEST §R2 (04c_text_selection_dictionary 3377a7d8) |
| 3 | Wiktionary Definition Card | Bottom Wiktionary definition card with phonetics, etymology, definitions, chips | M4 | ORIGINAL_REQUEST §R2 (04c_text_selection_dictionary 3377a7d8) |
| 4 | Contents TOC & Annotations Side Sheet | Left/modal side sheet with Contents TOC tree, Bookmarks tab, Highlights tab, Markdown export | M4 | ORIGINAL_REQUEST §R2 (04d_contents_annotations 60c9068e) |
| 5 | In-Book Search Overlay | Search field with match counter badge, stepper arrows, chapter snippets with bold keywords | M4 | ORIGINAL_REQUEST §R2 (04e_search_in_book c63b6121) |
| 6 | Read Aloud Player Sheet | Full-screen/expanded bottom player sheet: cover art, serif sentence card, timeline scrubber, playback controls, chips | M4 | ORIGINAL_REQUEST §R2 (05_read_aloud b44bfe85) |
| 7 | Settings Screen & Inset Cards | Grouped inset cards: Patron banner, Appearance, Reading defaults, Read aloud, Library/Backup, About | M5 | ORIGINAL_REQUEST §R1 (03_settings 0e2582dd) |
| 8 | Premium Paywall Sheet | 3-theme hero preview carousel, feature bullets, Lifetime & Yearly plan cards, unlock CTA, restore link | M5 | ORIGINAL_REQUEST §R3 (07_premium_paywall e4e1f706) |
| 9 | All Annotations Screen | Grouped cards by book with covers, vertical color strip, quote, note, page reference, date, Markdown export | M5 | ORIGINAL_REQUEST §R3 (08_all_annotations 837a423b) |
| 10 | Architectural & Nav Invariants | Zero bottom nav, warm editorial minimalism, BLoC/Cubit state integration | M4, M5, M6 | ORIGINAL_REQUEST §R4 |
| 11 | Quality Assurance & 0-Lint | `fvm flutter analyze` 0 errors/warnings, `fvm flutter test` 100% pass | M6 | ORIGINAL_REQUEST §Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M4 | Reader Widgets & Overlays | Features 1-6: Appearance sheet, Selection & Dictionary card, TOC & Annotations sheet, In-book search, Read aloud player | M1-M3 | IN_PROGRESS |
| M5 | Settings, Paywall & All Annotations | Features 7-9: Settings screen & inset cards, Premium paywall sheet, All annotations screen | M4 | PLANNED |
| M6 | Final Verification & Quality Assurance | Features 10-11: Full test suite, E2E tests, 0 analyzer issues, zero bottom nav audit | M4, M5 | PLANNED |

## Interface Contracts
- `AppearanceSheet`: `lib/presentation/screen/reader/widgets/appearance_sheet.dart`
- `DictionaryLookupSheet`: `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`
- `HighlightEditorSheet`: `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart`
- `ContentsAnnotationsSheet`: `lib/presentation/screen/reader/widgets/contents_annotations_sheet.dart` or `notes_sheet.dart`
- `ReaderSearch`: `lib/presentation/screen/reader/widgets/reader_search.dart`
- `ReadAloudPlayerSheet`: `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`
- `SettingsScreen`: `lib/presentation/screen/settings/settings_portrait_view.dart`
- `PremiumPaywallSheet`: `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`
- `AnnotationsScreen`: `lib/presentation/screen/annotations/annotations_screen.dart`

## Code Layout
- `lib/presentation/screen/reader/widgets/`: Reader UI overlays and sheets.
- `lib/presentation/screen/reader/read_aloud/`: Read Aloud audio playback sheets and widgets.
- `lib/presentation/screen/settings/`: Settings screens and inset card widgets.
- `lib/presentation/screen/premium/widgets/`: Paywall sheets and subscription cards.
- `lib/presentation/screen/annotations/`: All annotations screen and cards.
- `test/e2e/`: End-to-end tests verifying integration.

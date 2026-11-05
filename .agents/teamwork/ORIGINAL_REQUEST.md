# Original User Request

## Initial Request — 2026-11-04T19:11:09Z

You are a team of senior Flutter engineers and UI perfectionists working together to implement the OpenPages UI pixel-by-pixel across the entire application for production-ready use.

Integrity mode: development

## Reference Material
- Master Implementation Blueprint: `design/STITCH_UI_IMPLEMENTATION_GUIDE.md`
- Screen Catalog & Manifest: `design/screens/screens_manifest.json` and `design/screens/README.md`
- High-res reference mockups (780×1830) and HTML/Tailwind templates in `design/screens/<screen_id>/`
- Standalone illustration assets in `assets/images/`
- Target viewport: Mobile 412×915 dp. Material 3 with Warm Editorial Minimalism.

## Verification Resources
- Visual reference HTML templates and PNG mockups located in `design/screens/`
- Existing Flutter test suites run via `flutter test`
- Static analysis run via `flutter analyze`
- The team may decide whether to create additional widget or golden tests during implementation to verify visual fidelity

## Requirements

### R1. Core Design Tokens and Theme Synchronization
Synchronize and apply core design tokens in `lib/presentation/theme/`:
- Palette: Canvas `#FAF7F2`, Card Surfaces `#FFFFFF`, Hairline dividers `#E8E2D9`, Text `#1C1B1A`, Subtitle `#6B655D`, Accent `#2F4A7A`, Spoken highlight `#D6E2F5`, Paper `#F6F1E7`, Destructive `#BA1A1A`.
- Typography: Headings/Titles in `Newsreader` serif, UI controls/metadata/labels in `Inter` sans.
- Radii: Cards `16px`, Bottom Sheets `24px`, Action pills/chips `StadiumBorder()`.
- Bottom Navigation Bar: Strictly ensure NO bottom navigation bar is added anywhere.
- State preservation: Coordinate feature work and merge without breaking existing BLoC/Cubit state.

### R2. Onboarding Flow
Implement the complete 4-page horizontal `PageView` carousel with animated page dots in `lib/presentation/screen/onboarding/onboarding_screen.dart`:
- Page 1 (`ce71ef53`): "Your books, all in one place" + `onboarding_hero_illustration.png` + 5 format pills (`EPUB`, `PDF`, `TXT`, `MD`, `FB2`).
- Page 2 (`ebb14c4c`): "Read the way you like" + `onboarding_page_2_reading_styles.png`.
- Page 3 (`20ed4f15`): "Listen when your eyes rest" + `onboarding_page_3_read_aloud.png`.
- Page 4 (`8a586c73`): "Private by design" + `onboarding_page_4_privacy.png` + primary "Import your first book" & secondary "Explore first".

### R3. Library & Book Management
Implement library views and book management components in `lib/presentation/screen/home/` (`home_portrait_view.dart`, `library_content.dart`, `library_book_actions.dart`):
- `02_library` (`9d845920`): Top bar (search + settings), "Continue Reading" hero card with 2:3 cover shadow, recent books row with circular progress rings, horizontal filter chips (`All`, `Reading`, `To read`, `Finished`, `Favorites`, `Collections ▾`), 3-column book grid, extended pill FAB (`+ Import`).
- `02b_empty_library` (`e53734ed`): Centered `empty_library_shelf.png`, headline, dual buttons ("Import files" filled pill & "Import a folder" outlined pill).
- `02c_filter_sort_sheet` (`7a5f6480`): Sort radio rows, format multi-select chips, browse categories, grid/list toggle, sticky "Apply".
- `02d_book_details` (`54ac31ae`): Top metadata header, action row (Read, Add to Collection, Edit, Share), metadata grid, "Move to Trash" destructive button.
- Integrate `fallback_book_cover_default.png` for books missing cover art in `lib/presentation/widgets/book/book_cover.dart`.

### R4. Reader Experience & Overlays
Implement reader screens and interactive sheets in `lib/presentation/screen/reader/` (`reader_screen.dart`, `reader_chrome.dart`, `appearance_sheet.dart`, `dictionary_lookup_sheet.dart`, `notes_sheet.dart`, `reader_search.dart`):
- `04_reader_chrome_visible` (`80a5b425`): Paper canvas `#F6F1E7`, translucent top bar (back, title, search, bookmark, menu), left edge brightness rail, bottom panel (slider with chapter ticks, 4 tools: Contents, Appearance, Listen, Notes).
- `04_reader_chrome_hidden` (`b868e1ce`): Zen mode, 100% text, tiny footer page counter (`142 / 380`).
- `04b_appearance_sheet` (`d8bb2a41`): 6 theme swatches (with premium locks), font picker, typography sliders (A−/A+), layout controls, brightness.
- `04c_text_selection_dictionary` (`3377a7d8`): Floating toolbar (Highlight with 5 color dots, Note, Define, Copy, Share) + bottom Wiktionary definition card with phonetics and chips.
- `04d_contents_annotations` (`60c9068e`): Side sheet with Contents TOC tree, Bookmarks tab, Highlights tab, Markdown export.
- `04e_search_in_book` (`c63b6121`): Search field with match counter, stepper arrows, chapter snippets with bold keyword highlights.

### R5. Audio, Monetization, Settings & Annotations
Implement settings, audio player, monetization, and annotation screens in `lib/presentation/screen/settings/`, `lib/presentation/screen/reader/read_aloud/`, `lib/presentation/screen/premium/`, `lib/presentation/screen/annotations/`:
- `03_settings` (`0e2582dd`): Grouped inset cards (Appearance, Reading defaults, Read aloud, Library & Backup, Premium banner, About).
- `05_read_aloud` (`b44bfe85`): Sentence highlight band (`#D6E2F5`) in reader + expanded bottom player sheet (large cover, serif sentence, scrubber, playback controls, speed/voice/sleep timer chips).
- `06_lock_screen` (`cb0c0e53`): Update Android MediaSession notification metadata and actions to match the design card.
- `07_premium_paywall` (`e4e1f706`): 3-theme hero preview, feature bullets, Lifetime & Yearly plan cards, unlock button, restore purchase link.
- `08_all_annotations` (`837a423b`): Grouped annotation cards by book, vertical color strip, quote, note, page reference, date, Markdown export.

### R6. Quality Assurance & Pixel-Fidelity Verification
Inspect and verify every modified screen against its corresponding `.html` and `.png` in `design/screens/<slug>/`:
- Verify exact padding (`20px` side margins), border widths (`1px #E8E2D9`), corner radii (`16px`/`24px`), font sizes, and color codes.
- Ensure zero lint errors via `flutter analyze`.
- Ensure all existing unit, cubit, and use case tests pass via `flutter test`.

## Acceptance Criteria

### Theme & Design Tokens
- [ ] Palette matches exact hex values: Canvas `#FAF7F2`, Surfaces `#FFFFFF`, Dividers `#E8E2D9`, Text `#1C1B1A`, Subtitle `#6B655D`, Accent `#2F4A7A`, Spoken highlight `#D6E2F5`, Paper `#F6F1E7`, Destructive `#BA1A1A`.
- [ ] Typography uses Newsreader for headings/titles and Inter for UI controls/metadata/labels.
- [ ] Corner radii match specifications (Cards `16px`, Bottom Sheets `24px`, Action pills/chips `StadiumBorder()`).
- [ ] No bottom navigation bar exists anywhere in the application.

### Onboarding Flow
- [ ] 4-page horizontal `PageView` carousel functions with page indicator dots.
- [ ] Page 1 displays "Your books, all in one place", `onboarding_hero_illustration.png`, and format pills (`EPUB`, `PDF`, `TXT`, `MD`, `FB2`).
- [ ] Page 2 displays "Read the way you like" and `onboarding_page_2_reading_styles.png`.
- [ ] Page 3 displays "Listen when your eyes rest" and `onboarding_page_3_read_aloud.png`.
- [ ] Page 4 displays "Private by design", `onboarding_page_4_privacy.png`, "Import your first book" primary button, and "Explore first" secondary button.

### Library & Book Management
- [ ] Library screen (`02_library`) displays top bar, Continue Reading hero card with 2:3 cover shadow, recent books row with circular progress rings, horizontal filter chips, 3-column book grid, and extended pill FAB (`+ Import`).
- [ ] Empty library screen (`02b_empty_library`) displays centered `empty_library_shelf.png`, headline, and dual import buttons.
- [ ] Filter and sort sheet (`02c_filter_sort_sheet`) displays sort radio rows, format multi-select chips, categories, grid/list toggle, and sticky "Apply" button.
- [ ] Book details sheet (`02d_book_details`) displays top metadata header, action row, metadata grid, and "Move to Trash" destructive button.
- [ ] Missing book cover art renders `fallback_book_cover_default.png`.

### Reader Experience & Overlays
- [ ] Visible reader chrome (`04_reader_chrome_visible`) features paper canvas `#F6F1E7`, translucent top bar, brightness rail on left edge, and bottom panel with slider chapter ticks and 4 tool buttons.
- [ ] Zen mode (`04_reader_chrome_hidden`) hides chrome, displaying 100% text and page counter (`142 / 380`).
- [ ] Appearance sheet (`04b_appearance_sheet`) displays 6 theme swatches (with premium locks), font picker, typography sliders, layout controls, and brightness.
- [ ] Text selection toolbar and dictionary sheet (`04c_text_selection_dictionary`) render floating toolbar (5 color dots, Note, Define, Copy, Share) and bottom Wiktionary definition card with phonetics and chips.
- [ ] Contents & annotations side sheet (`04d_contents_annotations`) provides TOC tree, Bookmarks tab, Highlights tab, Markdown export.
- [ ] In-book search (`04e_search_in_book`) displays match counter, stepper arrows, and chapter snippets with highlighted keywords.

### Audio, Monetization, Settings & Annotations
- [ ] Settings screen (`03_settings`) renders grouped inset cards for Appearance, Reading defaults, Read aloud, Library & Backup, Premium banner, and About.
- [ ] Read aloud player (`05_read_aloud`) highlights sentences in `#D6E2F5` and expands bottom player sheet with cover art, sentence preview, scrubber, playback controls, and chips.
- [ ] Lock screen (`06_lock_screen`) updates Android MediaSession notification metadata and actions to match design specs.
- [ ] Premium paywall (`07_premium_paywall`) displays 3-theme hero preview, feature bullets, Lifetime & Yearly plan cards, unlock button, and restore purchase link.
- [ ] Annotations screen (`08_all_annotations`) displays cards grouped by book with vertical color strips, quotes, notes, page references, dates, and Markdown export.

### Quality & Regression Verification
- [ ] `flutter analyze` completes with 0 errors and 0 warnings.
- [ ] `flutter test` passes all existing unit, cubit, and use case tests without regression.


## Follow-up — 2026-11-04T22:09:38Z

Complete the remaining screen UI and components for LinguaPages as production code integrated into the Flutter app, matching the Stitch canvas designs and design implementation guides.

Working directory: /home/tn-99778/Towha/LinguaPages
Integrity mode: development

## Verification Resources
- Design documentation: `design/STITCH_UI_IMPLEMENTATION_GUIDE.md`, `design/screens/README.md`
- Stitch Canvas Project ID: `8671147000524611054`
- Existing tokens and themes: `lib/presentation/theme/app_tokens.dart`, `app_colors.dart`, `app_theme.dart`

## Requirements

### R1. Settings Screen
Implement the settings screen (`lib/presentation/screen/settings/`) and its grouped inset cards matching `03_settings` (`0e2582dd`).

### R2. Reader Widgets and Sheets
Implement the remaining reader UI sheets and overlays matching their respective Stitch canvas designs:
- Appearance bottom sheet (`lib/presentation/screen/reader/widgets/appearance_sheet.dart`) matching `04b_appearance_sheet` (`d8bb2a41`).
- Wiktionary definition card & floating text selection toolbar (`lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`, `highlight_editor_sheet.dart`) matching `04c_text_selection_dictionary` (`3377a7d8`).
- Contents TOC & Annotations side sheet matching `04d_contents_annotations` (`60c9068e`).
- In-book search overlay (`lib/presentation/screen/reader/widgets/reader_search.dart`) matching `04e_search_in_book` (`c63b6121`).
- Full-screen Read Aloud player sheet matching `05_read_aloud` (`b44bfe85`).

### R3. Paywall and Annotations Screens
Implement the remaining application screens:
- Premium paywall sheet (`lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`) matching `07_premium_paywall` (`e4e1f706`).
- All annotations screen (`lib/presentation/screen/annotations/`) matching `08_all_annotations` (`837a423b`).

### R4. Architecture, State Integration, and Navigation Constraints
Connect screens with existing app state/blocs/services where available, providing fallback/mock data where backend logic is not yet built. Follow Material 3 Warm Editorial Minimalism throughout all components. Strictly zero bottom navigation bars anywhere in the app. All Flutter CLI commands must be executed with `fvm flutter <cmd>`.

## Acceptance Criteria

### UI Fidelity and Completeness
- [ ] Settings screen and grouped inset cards match Stitch screen `03_settings` (`0e2582dd`).
- [ ] Reader appearance sheet matches Stitch screen `04b_appearance_sheet` (`d8bb2a41`).
- [ ] Wiktionary definition card and floating text selection toolbar match Stitch screen `04c_text_selection_dictionary` (`3377a7d8`).
- [ ] Contents TOC and annotations side sheet match Stitch screen `04d_contents_annotations` (`60c9068e`).
- [ ] In-book search overlay matches Stitch screen `04e_search_in_book` (`c63b6121`).
- [ ] Full-screen Read Aloud player sheet matches Stitch screen `05_read_aloud` (`b44bfe85`).
- [ ] Premium paywall sheet matches Stitch screen `07_premium_paywall` (`e4e1f706`).
- [ ] All annotations screen matches Stitch screen `08_all_annotations` (`837a423b`).
- [ ] Strictly zero bottom navigation bars anywhere in the app.
- [ ] Presentation widgets connect to existing state/blocs/services where available, using mock or fallback data where backend logic is not yet built.

### Code Quality and Verification
- [ ] `fvm flutter analyze` produces zero errors or warnings.
- [ ] `fvm flutter test` runs with 100% of tests passing.

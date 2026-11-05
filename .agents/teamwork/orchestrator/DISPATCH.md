## 2026-11-03T10:11:06Z
Create a comprehensive screen-wise and component-wise UI generation plan for the LinguaPages app based on the design specification in `design/design.md`. The plan decomposes every screen into discrete components for generation rather than generating complete screens at once, specifies screen-wise image naming for all components, and delivers the plan prior to any image generation.

Working directory: /Users/uswer/StudioProjects/linguaPages
Integrity mode: development

Reference material: `/Users/uswer/StudioProjects/linguaPages/design/design.md`

## Requirements

### R1. Screen-Wise and Component-Wise UI Generation Plan
Produce a complete UI generation plan at `design/ui_generation_plan.md` covering all screens and variants defined in `/Users/uswer/StudioProjects/linguaPages/design/design.md`. Decompose each screen into modular, individually generatable UI components instead of full-screen generations. Execution in this run is strictly limited to authoring the plan; do not generate image assets yet.

### R2. Screen-Wise Image Naming & Component Specifications
Define a consistent screen-wise naming schema for all component images to be generated in future steps. In `design/ui_generation_plan.md`, detail each component with:
- Exact screen-wise image filename (e.g., `<screen_number>_<screen_name>_<component_name>.png`)
- Target output file path within `design/components/`
- Component role and layout description
- Visual prompt details and generation parameters aligned with the shared style block in `design/design.md` (colors, typography, shapes, and Material 3 structure)

## Acceptance Criteria

### Scope & Structure
- [ ] `design/ui_generation_plan.md` exists and covers all 8 screens and their variants from `design/design.md` (1. Onboarding, 2. Library, 2b. Empty library, 2c. Filter and sort sheet, 2d. Book details sheet, 3. Settings, 4. Reader with chrome and hidden chrome, 4b. Appearance sheet, 4c. Text selection & dictionary, 4d. Contents & annotations, 4e. Search in book, 5. Read aloud player variants, 6. Lock-screen controls, 7. Premium appearance, 8. All annotations).
- [ ] Every screen is decomposed into discrete visual components rather than single full-screen generations.
- [ ] No image generation is executed; the deliverable is strictly the comprehensive planning document.

### Component Specifications & Naming
- [ ] Every component entry specifies an exact screen-wise image filename adhering to the defined naming scheme.
- [ ] Every component entry specifies a target image path located in `design/components/`.
- [ ] Every component entry includes generation prompts and styling parameters reflecting the shared style block of `design/design.md`.


## 2026-11-04T19:13:04Z
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
- [ ] Empty library screen (`02b_empty_library`) displays centered `empty_library_shelf.png`, headline, dual buttons ("Import files" filled pill & "Import a folder" outlined pill).
- [ ] Filter and sort sheet (`02c_filter_sort_sheet`) displays sort radio rows, format multi-select chips, categories, grid/list toggle, and sticky "Apply" button.
- [ ] Book details sheet (`02d_book_details`) displays top metadata header, action row, metadata grid, and "Move to Trash" destructive button.
- [ ] Missing book cover art renders `fallback_book_cover_default.png`.

### Reader Experience & Overlays
- [ ] Visible reader chrome (`04_reader_chrome_visible`) features paper canvas `#F6F1E7`, translucent top bar, brightness rail on left edge, and bottom panel with slider chapter ticks and 4 tool buttons.
- [ ] Zen mode (`04_reader_chrome_hidden`) hides chrome, displaying 100% text and page counter (`142 / 380`).
- [ ] Appearance sheet (`04b_appearance_sheet`) displays 6 theme swatches (with premium locks), font picker, typography sliders, layout controls, and brightness.
- [ ] Text selection toolbar and dictionary sheet (`04c_text_selection_dictionary`) render floating toolbar (5 color dots, Note, Define, Copy, Share) + bottom Wiktionary definition card with phonetics and chips.
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

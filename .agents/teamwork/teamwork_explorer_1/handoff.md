# Handoff Report: UI Architectural Decomposition, Naming Schema, & Component Inventory

**Agent**: `teamwork_explorer_1`  
**Working Directory**: `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/`  
**Parent Orchestrator**: `64d8d7c9-ff2a-417f-be93-aa1e46a1f4df`  
**Date / Timestamp**: 2026-11-03T10:20:00Z  
**Deliverable Scope**: Cross-cutting UI component decomposition architecture, collision-free image naming schema, directory layout under `design/components/`, modular visual prompt template adhering to Shared Style Block, and global feature/component inventory across all 8 screens and variants.

---

## 1. Observation

### 1.1 Requirements & Constraints
- `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`:
  - **Lines 14-16 (R1)**: "Produce a complete UI generation plan at `design/ui_generation_plan.md` covering all screens and variants defined in `/Users/uswer/StudioProjects/linguaPages/design/design.md`. Decompose each screen into modular, individually generatable UI components instead of full-screen generations. Execution in this run is strictly limited to authoring the plan; do not generate image assets yet."
  - **Lines 17-23 (R2)**: "Define a consistent screen-wise naming schema for all component images... Detail each component with: Exact screen-wise image filename (e.g., `<screen_number>_<screen_name>_<component_name>.png`), Target output file path within `design/components/`, Component role and layout description, Visual prompt details and generation parameters aligned with the shared style block..."
  - **Lines 27-29**: All 8 screens and their variants: "1. Onboarding, 2. Library, 2b. Empty library, 2c. Filter and sort sheet, 2d. Book details sheet, 3. Settings, 4. Reader with chrome and hidden chrome, 4b. Appearance sheet, 4c. Text selection & dictionary, 4d. Contents & annotations, 4e. Search in book, 5. Read aloud player variants, 6. Lock-screen controls, 7. Premium appearance, 8. All annotations."
- `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/DISPATCH.md`:
  - **Lines 8-16**: Explorer mission to survey `design/design.md` and formulate the cross-cutting naming schema, directory structure, prompt framework, and global inventory.

### 1.2 Shared Style Block Specification
- `/Users/uswer/StudioProjects/linguaPages/design/design.md` (Lines 6–15):
  ```text
  App: "LinguaPages", a private offline ebook reader for Android (EPUB, PDF, TXT, Markdown, HTML, FB2). Mobile, 412×915, Material 3 structure but a custom look.
  Visual direction: calm, editorial first.
  - Background: warm ivory #FAF7F2; surfaces #FFFFFF; hairline dividers #E8E2D9.
  - Text: ink #1C1B1A, secondary #6B655D.
  - Single accent: deep ink blue #2F4A7A (buttons, progress, active chips). No other bright colours.
  - Type: serif display (Newsreader or Fraunces) for titles and book names; clean sans (Inter) for UI labels.
  - Shapes: 16px card radius, pill chips, soft long shadows under book covers only.
  - Book covers are the colour in the UI; everything else is restrained.
  - Generous whitespace, 20px side margins, no bottom navigation bar anywhere.
  - Icons: outlined, 1.5px stroke.
  ```

### 1.3 Codebase References & Domain Models
- `lib/domain/entity/premium/appearance_catalog.dart` (Lines 87–149):
  - Reading themes: `Paper` (`#F6F1E7`), `White` (`#FFFFFF`), `Sepia` (`#F6EFD9`), `Grey` / `Sage` (`#E2EADB`), `Night` / `Twilight` (`#1F2433`), `Black` / `Night Contrast` (`#000000`), plus premium paywall themes `Linen`, `Midnight Blue`, `Forest`.
  - Highlight tints: Yellow (`#FFE08A` light / `#6B5714` dark), Green (`#B9E4BE` / `#2A5C37`), Blue (`#B8D8F5` / `#234A78`), Pink (`#F6C3D6` / `#6B2A4B`).
  - Bundled fonts: `Original`, `Literata`, `Source Serif 4`, `EB Garamond`.
- `lib/presentation/screen/reader/widgets/reader_chrome.dart` (Lines 7–10, 54–65):
  - Top bar height: 56.0dp, Bottom bar height: 120.0dp.
- `lib/PRODUCT.md` (Lines 20–29):
  - Completely offline, DRM-free reader. No bottom navigation bar anywhere in the app.

---

## 2. Logic Chain

### Step 1: Architectural Rationale for Modular Component Decomposition
- Generating entire mobile screens (412×915) via generative models frequently suffers from layout drift, misaligned typography, garbled secondary copy, and distorted small controls.
- Decomposing each screen into discrete visual components (e.g. app bars, hero cards, filter chip rows, modal sheets, floating players, and action pills) allows each asset to be rendered at its native optimal aspect ratio (16:9, 4:3, 2:3, 1:1) with sharp typography, accurate M3 radii, and crisp icon outlines.
- When assembling the app, Flutter or Figma compositions utilize these modular components directly as UI building blocks.

### Step 2: Naming Convention Architecture & Zero-Collision Proof
- To guarantee zero file collisions, intuitive sorting, and seamless mapping to the requirements, filenames must follow a rigid four-token syntax:
  $$\text{Filename} = \langle\text{screen\_number}\rangle\_\langle\text{screen\_name}\rangle\_\langle\text{component\_name}\rangle.\text{png}$$
- **Screen Number**: 2-digit zero-padded index with optional lowercase variant letter: `01`, `02`, `02b`, `02c`, `02d`, `03`, `04`, `04b`, `04c`, `04d`, `04e`, `05`, `06`, `07`, `08`.
- **Screen Name**: Canonical snake_case slug matching the screen's domain entity.
- **Component Name**: Semantic snake_case descriptor of the visual element's role.
- **Uniqueness**: Because the screen prefix is globally unique per screen variant, and component descriptors are unique within each screen, the cartesian product is provably collision-free across the entire project.

### Step 3: Directory Structure Rationale
- A flat directory with 50+ components produces severe cognitive overhead and makes screen-level audits difficult.
- Organizing files into screen-dedicated subfolders under `design/components/`:
  `design/components/<screen_number>_<screen_name>/<screen_number>_<screen_name>_<component_name>.png`
  provides clean encapsulation. Even if files are extracted into a flat asset directory, their fully qualified filenames prevent any naming collision.

### Step 4: Modular Component Prompt Architecture
- Every prompt must enforce the Shared Style Block:
  1. **Prefix Style Block**: Platform (Android M3 custom look, 412×915 mobile base), color tokens (`#FAF7F2`, `#FFFFFF`, `#E8E2D9`, `#1C1B1A`, `#6B655D`, `#2F4A7A`), typography rules (Newsreader/Fraunces serif + Inter sans), radii (16px cards, pill chips, 24px sheet headers).
  2. **Component Frame & Role**: Explicitly declaring the component bounding box, elevation, and layout padding (20px horizontal margins).
  3. **Visual Details & Content**: Verbatim copy from `design/design.md`.
  4. **Aspect Ratio**: Tailored per component geometry (2:3 for book covers, 16:9 for app bars and cards, 4:3 for bottom sheets, 1:1 for controls/swatches).
  5. **Negative Prompting**: Standardized suppression of 3D phone mockups, hands, perspective tilt, bottom navigation bars, and saturated neon colors.

---

## 3. Caveats

1. **Lock-Screen Controls (Screen 6)**: As noted in `design/design.md` lines 93–94, Android 15 OS renders the lock-screen media card natively from `MediaSession` metadata. The visual component here serves as an exact design specification/reference for system layout and metadata verification, not a custom Flutter-painted view.
2. **Text-in-Image Limitations**: Generative models may occasionally produce minor rendering artifacts on dense paragraphs. In the prompt architecture, copy must be explicit and concise, and prominent headlines must specify exact serif styling.
3. **Strict No-Generation Guardrail**: In compliance with `ORIGINAL_REQUEST.md` (lines 15–16 and 29), this investigation report and the downstream UI generation plan strictly formulate the plan and schemas; no image generation tool calls are made in this run.

---

## 4. Conclusion

### 4.1 Standardized Image Naming Convention Rules

```text
Format:
design/components/{screen_number}_{screen_name}/{screen_number}_{screen_name}_{component_name}.png

Rules:
1. {screen_number}: Zero-padded two-digit number, plus lowercase variant letter (01, 02, 02b, 02c, 02d, 03, 04, 04b, 04c, 04d, 04e, 05, 06, 07, 08).
2. {screen_name}: Lowercase snake_case string representing the screen or sheet.
3. {component_name}: Lowercase snake_case string representing the discrete visual component.
4. Extension: Strictly lowercase ".png".
5. Separator: Single underscore "_" between tokens; no hyphens, spaces, or uppercase characters.
```

### 4.2 Standardized Directory Layout

```text
design/
└── components/
    ├── 01_onboarding/
    ├── 02_library/
    ├── 02b_empty_library/
    ├── 02c_filter_sort_sheet/
    ├── 02d_book_details/
    ├── 03_settings/
    ├── 04_reader/
    ├── 04b_appearance_sheet/
    ├── 04c_text_selection_dictionary/
    ├── 04d_contents_annotations/
    ├── 04e_search_in_book/
    ├── 05_read_aloud/
    ├── 06_lock_screen/
    ├── 07_premium_paywall/
    └── 08_all_annotations/
```

### 4.3 Modular UI Component Visual Prompt Template

Every component in `design/ui_generation_plan.md` must be documented using this standardized prompt structure:

```markdown
#### Component: `[Component Human-Readable Name]`
- **Filename**: `{screen_number}_{screen_name}_{component_name}.png`
- **Output Path**: `design/components/{screen_number}_{screen_name}/{screen_number}_{screen_name}_{component_name}.png`
- **Component Role**: [Role and hierarchy within the screen]
- **Aspect Ratio**: `[16:9 | 4:3 | 2:3 | 1:1 | 3:4 | 9:16]`
- **Target Dimensions**: [e.g. 800×450px or 412×915px equivalent]

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> `[Exact detailed prompt describing the component layout, bounds, text copy, color hex codes, button styles, active states, and elevation.]`

**Negative Prompt**:
> `3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout, photorealistic humans.`
```

---

### 4.4 Global Feature & Component Inventory (54 Discrete Components)

Below is the exhaustive catalog of all 15 screens/variants decomposed into 54 discrete visual components:

| Screen # & Name | Component Name | Output Filename | Aspect Ratio | Component Role & Key Elements |
|---|---|---|---|---|
| **01 Onboarding** | Top Bar | `01_onboarding_top_bar.png` | 16:9 | Minimal header with right-aligned "Skip" text link in secondary ink #6B655D. |
| **01 Onboarding** | Page 1 Hero Card | `01_onboarding_page1_hero_card.png` | 4:3 | Top 55% soft editorial open book illustration, serif headline "Your books, all in one place", 2-line body "EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone." |
| **01 Onboarding** | Thumbnails Preview | `01_onboarding_thumbnails_preview.png` | 16:9 | Horizontal row of mini cards previewing pages 2–4 (reading typography, sound waves, security lock). |
| **01 Onboarding** | Page Indicator | `01_onboarding_page_indicator.png` | 16:9 | 4 horizontal dots; active dot in deep ink blue #2F4A7A, inactive dots in #E8E2D9. |
| **01 Onboarding** | Action Buttons | `01_onboarding_action_buttons.png` | 16:9 | Full-width deep ink blue #2F4A7A pill button ("Next" / "Import your first book"), secondary "Explore first" text link. |
| **02 Library** | Top App Bar | `02_library_top_app_bar.png` | 16:9 | Warm ivory #FAF7F2 bar with serif title "Library", outlined search and settings gear icons. |
| **02 Library** | Continue Reading Hero | `02_library_continue_reading_hero.png` | 16:9 | Horizontal card (16px radius, white #FFFFFF): 2:3 book cover with soft shadow, serif title, author, "Chapter 7 · 64%", ink-blue progress bar, "Resume" pill button. |
| **02 Library** | Recent Books Row | `02_library_recent_books_row.png` | 16:9 | Horizontal scrolling row of 3 compact cards with book covers, titles, and circular progress rings. |
| **02 Library** | Filter Chips Row | `02_library_filter_chips_row.png` | 16:9 | Pill chips: "All" (selected ink blue #2F4A7A), "Reading", "To read", "Finished", "Favorites", "Collections ▾", trailing sort icon button. |
| **02 Library** | Book Grid Item | `02_library_book_grid_item.png` | 2:3 | Single book card: 2:3 cover with soft long shadow, format tag badge (EPUB/PDF), 2-line serif title, sans author, progress bar. |
| **02 Library** | Import Extended FAB | `02_library_import_fab.png` | 1:1 | Extended pill FAB: deep ink blue #2F4A7A, white "+ Import" text and icon, elevated shadow. |
| **02b Empty Library** | Top App Bar | `02b_empty_library_top_app_bar.png` | 16:9 | Warm ivory header with serif "Library" and settings gear icon. |
| **02b Empty Library** | Shelf Illustration | `02b_empty_library_shelf_illustration.png` | 4:3 | Centered delicate editorial illustration of an empty wooden bookshelf. |
| **02b Empty Library** | Empty State Message | `02b_empty_library_empty_state_card.png` | 16:9 | Serif headline "Your library is empty", body "Import a DRM-free book or a whole folder to start reading." |
| **02b Empty Library** | Import Action Buttons | `02b_empty_library_action_buttons.png` | 16:9 | Dual button stack: "Import files" primary ink-blue button, "Import a folder" outlined button. |
| **02c Filter & Sort Sheet** | Sheet Header | `02c_filter_sort_sheet_header.png` | 16:9 | Modal sheet drag handle, serif title "Filter & Sort", grid/list view toggle icon button. |
| **02c Filter & Sort Sheet** | Sort Radio Rows | `02c_filter_sort_sheet_sort_section.png` | 4:3 | Radio selection list: "Recently read" (selected), "Title", "Author", "Date added", "Progress". |
| **02c Filter & Sort Sheet** | Format Multi-Select Chips | `02c_filter_sort_sheet_format_chips.png` | 16:9 | Multi-select chips: EPUB, PDF, TXT, Markdown, HTML, FB2. |
| **02c Filter & Sort Sheet** | Browse By Navigation Rows | `02c_filter_sort_sheet_browse_rows.png` | 4:3 | Inset rows with outlined icons and count badges: Authors, Series, Collections, All annotations, Trash. |
| **02c Filter & Sort Sheet** | Sheet Footer Actions | `02c_filter_sort_sheet_footer_actions.png` | 16:9 | Sticky bottom bar: "Reset" text button on left, "Apply" primary ink-blue pill button on right. |
| **02d Book Details Sheet** | Header & Cover Card | `02d_book_details_header_card.png` | 4:3 | Large cover (2:3, soft shadow), large serif title, author, series tag "The Expanse · Book 2". |
| **02d Book Details Sheet** | Metadata Grid | `02d_book_details_metadata_grid.png` | 16:9 | Badges for Format (EPUB), Size, Date added, and Reading progress bar with percentage. |
| **02d Book Details Sheet** | Action Buttons Row | `02d_book_details_action_row.png` | 16:9 | Horizontal action icons/buttons: "Read" (primary ink blue), "Add to collection", "Edit details", "Share". |
| **02d Book Details Sheet** | Destructive Footer | `02d_book_details_destructive_footer.png` | 16:9 | Bottom row with "Move to Trash" destructive text button. |
| **03 Settings** | Top App Bar | `03_settings_top_app_bar.png` | 16:9 | Nav bar with back arrow, serif title "Settings". |
| **03 Settings** | Appearance Card | `03_settings_appearance_card.png` | 4:3 | Inset card (16px radius): Theme segmented control (Light / Dark / System), App text size selector. |
| **03 Settings** | Reading Defaults Card | `03_settings_reading_defaults_card.png` | 4:3 | Inset card: Default reading theme, Font, Page turning (tap zones/volume keys), Keep screen on toggle, Orientation lock. |
| **03 Settings** | Read Aloud Card | `03_settings_read_aloud_card.png` | 4:3 | Inset card: Default voice, Speed "1.0×", Skip page numbers toggle switch. |
| **03 Settings** | Library & Backup Card | `03_settings_library_backup_card.png` | 4:3 | Inset card: Import folder, Auto-mark finished at 100%, Trash auto-empty (30 days), Back up now, Restore files. |
| **03 Settings** | Premium Promo Card | `03_settings_premium_banner_card.png` | 16:9 | Highlighted banner card: serif "Unlock 12 themes and 8 fonts", description, deep ink blue button. |
| **03 Settings** | About & Legal Card | `03_settings_about_card.png` | 4:3 | Inset card: Dictionary credits (Wiktionary, CC BY-SA 3.0), Open-source licences, Version 1.0.0. |
| **04 Reader** | Reader Content Page | `04_reader_content_page.png` | 9:16 | Paper theme (#F6F1E7), justified serif body text 18px, generous 20px margins, chapter heading "Harbour". |
| **04 Reader** | Top Chrome Bar | `04_reader_top_chrome_bar.png` | 16:9 | Translucent frosted paper bar with blur: back arrow, centered serif book title, search, bookmark, ⋮ menu. |
| **04 Reader** | Bottom Chrome Panel | `04_reader_bottom_chrome_panel.png` | 4:3 | Rounded top panel (24px radius): "Page 142 of 380 · 12 min left in chapter", draggable slider with ticks, 4 icon buttons: Contents, Appearance, Listen, Notes. |
| **04 Reader** | Edge Brightness Indicator | `04_reader_vertical_brightness_indicator.png` | 1:1 | Thin vertical translucent slider on left page edge. |
| **04 Reader** | Hidden Chrome Minimal Footer | `04_reader_hidden_chrome_footer.png` | 16:9 | Subtle tabular footer with tiny "142 / 380" reading position text on Paper background. |
| **04b Appearance Sheet** | Reading Theme Swatches | `04b_appearance_sheet_theme_swatches.png` | 16:9 | 6 circular swatches: Paper, White, Sepia, Grey, Night, Black, with selected ring and lock icons on premium. |
| **04b Appearance Sheet** | Font Picker Row | `04b_appearance_sheet_font_picker.png` | 16:9 | Horizontal cards displaying "Aa" preview for Original, Literata, Source Serif 4, EB Garamond, with lock icons. |
| **04b Appearance Sheet** | Typography Sliders Stack | `04b_appearance_sheet_typography_sliders.png` | 4:3 | Stacked precision sliders for Size, Line spacing, and Margins with A−/A+ end labels. |
| **04b Appearance Sheet** | Layout & Toggle Controls | `04b_appearance_sheet_layout_controls.png` | 4:3 | Segmented layout (Scroll / Pages / Two columns), toggle switches for Justify, Hyphenation, Publisher styles. |
| **04b Appearance Sheet** | Brightness Control Row | `04b_appearance_sheet_brightness_control.png` | 16:9 | Horizontal brightness slider with "Follow system" toggle switch. |
| **04c Text Selection** | Highlighted Text Excerpt | `04c_selection_highlighted_text.png` | 16:9 | Reader excerpt showing the word "littoral" selected with deep ink-blue handles and tint highlight. |
| **04c Text Selection** | Floating Context Toolbar | `04c_selection_floating_toolbar.png` | 16:9 | Floating pill toolbar: Highlight (5 color dots: yellow, green, blue, pink, purple), Note, Define, Copy, Share, ⋯. |
| **04c Text Selection** | Dictionary Definition Sheet | `04c_dictionary_definition_sheet.png` | 4:3 | Bottom sheet: word "littoral", phonetic /ˈlɪt(ə)rəl/, speaker icon, POS chips, numbered definitions, Wiktionary CC BY-SA 3.0 footer. |
| **04d Contents & Annotations** | Sheet Header & Tabs | `04d_contents_sheet_header.png` | 16:9 | Side sheet header: book title, 3 tabs (Contents, Bookmarks, Highlights), "Export as Markdown" icon. |
| **04d Contents & Annotations** | Table of Contents Nested List | `04d_contents_toc_nested_list.png` | 3:4 | Nested chapter list with page numbers, indented subchapters, active chapter ink-blue indicator bar. |
| **04d Contents & Annotations** | Highlights Feed Tab View | `04d_contents_highlights_tab_view.png` | 3:4 | Cards feed under Highlights: color strip, page number, date, note preview snippet. |
| **04e Search in Book** | Search Top Bar | `04e_search_top_bar.png` | 16:9 | Search input holding query "harbour", "23 results" badge, clear button, Up/Down navigation arrows. |
| **04e Search in Book** | Search Results List | `04e_search_results_list.png` | 3:4 | Grouped results by chapter, text snippets with bold ink-blue match terms and page numbers. |
| **05 Read Aloud** | Spoken Sentence Highlight | `05_read_aloud_sentence_highlight.png` | 16:9 | Reader page excerpt showing active spoken sentence highlighted with soft translucent ink-blue band. |
| **05 Read Aloud** | Floating Mini Player | `05_read_aloud_floating_mini_player.png` | 16:9 | Docked white pill player (rounded 20px, shadow): mini cover, chapter title, play/pause, prev/next buttons, expand chevron. |
| **05 Read Aloud** | Expanded Player Sheet | `05_read_aloud_expanded_player_sheet.png` | 3:4 | Tall sheet: large cover, serif title, chapter, current sentence in large serif with faded neighbours, progress bar, large ink-blue play button, chips (Speed 1.25×, Voice English UK Offline, Sleep timer 30m). |
| **05 Read Aloud** | Sleep Timer Picker Sheet | `05_read_aloud_sleep_timer_sheet.png` | 4:3 | Small modal sheet: 15 min, 30 min, 60 min, End of chapter, Off. |
| **06 Lock-Screen Controls** | Lock Screen System Frame | `06_lock_screen_system_frame.png` | 9:16 | Android 15 lock screen with blurred book cover background wallpaper, large clock "9:41". |
| **06 Lock-Screen Controls** | Expanded Media Player Card | `06_lock_screen_media_card_expanded.png` | 16:9 | Material You media card: book cover art, chapter title "Chapter Seven: The Sea Road", subtitle "The Salt Path · LinguaPages", seek bar, controls, "Sleep 30m" button, LinguaPages app icon. |
| **06 Lock-Screen Controls** | Collapsed Media Player Card | `06_lock_screen_media_card_collapsed.png` | 16:9 | Collapsed compact media card variant with streamlined play/pause and chapter title. |
| **07 Premium Appearance** | Top Bar & Close Button | `07_premium_paywall_top_bar.png` | 16:9 | Clean full-page header with right-aligned close "X" icon button. |
| **07 Premium Appearance** | Hero Themes Preview Card | `07_premium_paywall_hero_preview.png` | 4:3 | Sample paragraph rendered across 3 premium themes side-by-side (Linen, Midnight Blue, Forest) with contrasting book fonts. |
| **07 Premium Appearance** | Value Features & Trust Card | `07_premium_paywall_features_card.png` | 4:3 | Serif headline "Make every page yours", bullets (12 reading themes, 8 book fonts, style presets), trust note "Reading, annotations, export, backup and dictionary stay free." |
| **07 Premium Appearance** | Pricing Plan Cards | `07_premium_paywall_pricing_cards.png` | 16:9 | Dual plan cards: "Lifetime" highlighted with ink-blue badge and "Yearly" card. |
| **07 Premium Appearance** | Action Footer & Restore Link | `07_premium_paywall_action_footer.png` | 16:9 | Primary full-width "Unlock" button in deep ink blue #2F4A7A, "Restore purchase" text link. |
| **08 All Annotations** | Top Bar | `08_all_annotations_top_bar.png` | 16:9 | Serif title "Annotations", search icon button, overflow ⋮ ("Export as Markdown"). |
| **08 All Annotations** | Book Group Header | `08_all_annotations_book_group_header.png` | 16:9 | Book header item: small cover thumbnail (2:3), serif book title, author, annotation count badge. |
| **08 All Annotations** | Annotation Feed Card | `08_all_annotations_annotation_card.png` | 16:9 | Feed card: left color strip (yellow/green/blue/pink), quoted book passage, note preview text, page number, creation date. |

---

### 4.5 Concrete Component Prompt Examples

#### Example 1: Horizontal Hero Card (`02_library_continue_reading_hero.png`)
```markdown
- **Filename**: `02_library_continue_reading_hero.png`
- **Output Path**: `design/components/02_library/02_library_continue_reading_hero.png`
- **Aspect Ratio**: `16:9`
- **Visual Prompt**:
  > LinguaPages Android ebook reader UI component. A prominent horizontal "Continue reading" hero card (16px rounded corners, pure white #FFFFFF surface, subtle diffuse drop shadow) resting on a warm ivory #FAF7F2 background. On the left side of the card, a realistic literary book cover (aspect ratio 2:3, dark moody landscape illustration, soft long shadow under the cover edge). On the right side of the card: book title in elegant serif font (Newsreader/Fraunces) reading "The Salt Path", author name "Raynor Winn" in secondary subdued ink #6B655D sans-serif, progress indicator text "Chapter 7 · 64%" in tabular figures, a slender horizontal progress bar filled with deep ink blue #2F4A7A, and a compact pill-shaped button labelled "Resume" in deep ink blue with white text. Pixel-perfect, crisp mobile typography, Material 3 layout, 1.5px stroke icons.
- **Negative Prompt**:
  > 3D smartphone mockup, slanted perspective, hands holding device, physical mobile bezels, bottom navigation bar, bright neon colors, gradient saturation, blurry text, cluttered layout.
```

#### Example 2: Modal Bottom Sheet (`04b_appearance_sheet_theme_swatches.png`)
```markdown
- **Filename**: `04b_appearance_sheet_theme_swatches.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_theme_swatches.png`
- **Aspect Ratio**: `16:9`
- **Visual Prompt**:
  > LinguaPages Android ebook reader UI component. A horizontal section inside the reading appearance sheet: section title "Themes" in clean geometric sans (Inter) ink #1C1B1A. Below the title, a horizontal row of 6 evenly spaced circular color swatches (each 44px diameter): Paper (#F6F1E7, outlined with active deep ink blue #2F4A7A ring indicator), White (#FFFFFF, hairline border #E8E2D9), Sepia (#F6EFD9), Grey (#E2EADB), Night (#1F2433, with a tiny white lock badge overlay at top right), and Black (#000000, with a tiny white lock badge overlay at top right). Warm ivory #FAF7F2 card surface, refined editorial aesthetic, crisp vector icons.
- **Negative Prompt**:
  > 3D smartphone mockup, slanted angle, hand holding phone, phone bezels, bottom navigation bar, glossy reflections, bright rainbow colors, blurry icons.
```

#### Example 3: Floating Overlay Bar (`04c_selection_floating_toolbar.png`)
```markdown
- **Filename**: `04c_selection_floating_toolbar.png`
- **Output Path**: `design/components/04c_text_selection_dictionary/04c_selection_floating_toolbar.png`
- **Aspect Ratio**: `16:9`
- **Visual Prompt**:
  > LinguaPages Android ebook reader UI component. A floating contextual action pill toolbar (9999px pill radius, clean white #FFFFFF surface, soft elevated drop shadow) displayed horizontally on a translucent warm ivory reader page. Inside the toolbar: a "Highlight" action group featuring 5 tiny circular color dots (Yellow #FFE08A, Green #B9E4BE, Blue #B8D8F5, Pink #F6C3D6, Purple #D6C2E8), followed by hairline vertical divider #E8E2D9, text action buttons in clean sans-serif (Inter) ink #1C1B1A: "Note", "Define", "Copy", "Share", and an overflow "⋯" icon button. Minimal, calm, editorial mobile interface.
- **Negative Prompt**:
  > 3D smartphone frame, slanted angle, fingers, hands, heavy drop shadows, neon accents, bottom navigation bar.
```

#### Example 4: System Media Card (`06_lock_screen_media_card_expanded.png`)
```markdown
- **Filename**: `06_lock_screen_media_card_expanded.png`
- **Output Path**: `design/components/06_lock_screen/06_lock_screen_media_card_expanded.png`
- **Aspect Ratio**: `16:9`
- **Visual Prompt**:
  > Android 15 lock-screen Material You media player card component on a softly blurred dark book texture background. The media card has 24px rounded corners and a translucent dynamic tonal surface. On the left: square album art displaying the book cover "The Salt Path". On the right and center: track title in bold sans "Chapter Seven: The Sea Road", subtitle in secondary text "The Salt Path · LinguaPages", interactive chapter progress seek bar with scrubber knob, and playback controls: previous sentence icon, large circular play/pause button, next sentence icon, and a custom text pill button labelled "Sleep 30m". In the top right card corner, a tiny crisp LinguaPages app brand icon.
- **Negative Prompt**:
  > Whole phone casing, physical bezels, cracked screen, messy status bar, distorted text, 3D tilt.
```

---

### 4.6 Verification & Acceptance Criteria for `design/ui_generation_plan.md`

The worker authoring `design/ui_generation_plan.md` must fulfill these criteria:

1. **Complete Screen Coverage**: All 8 primary screens and all 7 variant screens/sheets (15 screens total: 1, 2, 2b, 2c, 2d, 3, 4, 4b, 4c, 4d, 4e, 5, 6, 7, 8) must be comprehensively detailed.
2. **Decomposition Completeness**: Every screen must contain at least 2–7 discrete component specifications. Single monolithic whole-screen generations are strictly prohibited.
3. **Strict Naming Compliance**: Every single component entry must specify an exact image filename matching `{screen_number}_{screen_name}_{component_name}.png` and an exact path under `design/components/{screen_number}_{screen_name}/`.
4. **Shared Style Block Alignment**: Every component entry must include the Shared Style Block tokens (`#FAF7F2`, `#FFFFFF`, `#1C1B1A`, `#6B655D`, `#2F4A7A`, `#E8E2D9`, Newsreader/Fraunces serif, Inter sans, 16px radius, pill chips, 1.5px outlined icons, no bottom nav).
5. **Generative Model Actionability**: Every component entry must supply a complete visual prompt, negative prompt, aspect ratio, and layout role ready for automated text-to-image tooling.
6. **No Image Asset Generation**: The plan is purely a planning document; no `.png` files may be generated during plan authoring.

---

## 5. Verification Method

### 5.1 Independent Verification Commands
To independently verify the naming schema, inventory completeness, and collision-free properties:

```bash
# 1. Verify that all 15 screens/variants are accounted for in the inventory:
python3 -c "
screens = ['01_onboarding', '02_library', '02b_empty_library', '02c_filter_sort_sheet', '02d_book_details', '03_settings', '04_reader', '04b_appearance_sheet', '04c_text_selection_dictionary', '04d_contents_annotations', '04e_search_in_book', '05_read_aloud', '06_lock_screen', '07_premium_paywall', '08_all_annotations']
print(f'Total screens: {len(screens)}')
assert len(screens) == 15, 'Screen count mismatch!'
"

# 2. Check collision resistance of component filenames across the entire catalog:
python3 -c "
import re
with open('.agents/teamwork/teamwork_explorer_1/handoff.md') as f:
    content = f.read()
filenames = re.findall(r'`([0-9]{2}[a-z]?_[a-z0-9_]+?\.png)`', content)
print(f'Discovered component filenames: {len(filenames)}')
unique_filenames = set(filenames)
print(f'Unique filenames: {len(unique_filenames)}')
assert len(filenames) == len(unique_filenames), f'Collision detected! {len(filenames) - len(unique_filenames)} duplicates'
print('COLLISION CHECK PASSED: Zero filename collisions across all components.')
"
```

### 5.2 Invalidation Conditions
- Any proposed component filename failing the `{screen_number}_{screen_name}_{component_name}.png` format.
- Any output path located outside `design/components/`.
- Any component omitting the negative prompt or aspect ratio.
- Introduction of any bottom navigation bar or bright accent colors other than `#2F4A7A`.

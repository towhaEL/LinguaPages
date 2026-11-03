# LinguaPages UI Component Generation Plan

**Project**: LinguaPages (Private offline ebook reader for Android)  
**Target Viewport**: 412×915 (Material 3 structure with custom editorial design)  
**Deliverable Type**: Modular UI Component Generation Specification & Execution Plan  
**Target Directory**: `design/components/`  
**Execution Scope**: Pure planning specification; NO image generation executed during this phase.

---

## 1. Executive Summary & Architectural Overview

LinguaPages is a private, DRM-free, offline ebook reader for Android supporting EPUB, PDF, TXT, Markdown, HTML, and FB2 formats. Rather than generating monolithic, full-screen mobile mockups—which frequently suffer from layout drift, garbled secondary copy, and distorted micro-controls—this document establishes a component-driven UI generation architecture.

Every screen and modal sheet across the application is decomposed into discrete, modular visual components. Each component is specified with its native aspect ratio (16:9, 4:3, 2:3, 1:1, 3:4, or 9:16), exact target dimensions, semantic role, full visual generation prompt incorporating the Shared Style Block, and standardized negative prompt.

### Key Architectural Tenets
1. **Calm, Editorial-First Aesthetic**: Warm ivory canvas (`#FAF7F2`), pure white elevated surfaces (`#FFFFFF`), hairline dividers (`#E8E2D9`), deep ink typography (`#1C1B1A`), and a single restrained deep ink blue accent (`#2F4A7A`). Book covers provide the primary color in the UI.
2. **Strict Navigation Guardrail**: Generous whitespace with 20px side margins. Strictly no persistent bottom navigation bar anywhere in the app.
3. **Collision-Free Naming Convention**: Every generated asset follows a strict schema:
   `<screen_number>_<screen_name>_<component_name>.png`
   organized within screen-specific subdirectories under `design/components/`.
4. **Zero Generation Execution Guardrail**: In accordance with project instructions, this deliverable is strictly the comprehensive planning and specification document. No image generation calls (`.png` assets) are made during this run.

---

## 2. Design System & Shared Style Block Specification

All component prompts inherit the foundational tokens defined in `design/design.md`.

### 2.1 Color Palette Tokens
| Token Name | Hex Code | Role & Application |
|---|---|---|
| Canvas Background | `#FAF7F2` | Warm ivory background for app scaffolds, screen canvas, and empty spaces |
| Surface / Cards | `#FFFFFF` | Pure white elevated surfaces, cards, sheets, dialogs, and floating controls |
| Hairline Divider | `#E8E2D9` | 1px border lines, subtle dividers, inactive slider tracks, and sheet handles |
| Primary Ink | `#1C1B1A` | Dark neutral ink for headings, titles, active labels, body text, and icons |
| Secondary Slate | `#6B655D` | Subdued slate for authors, subtitles, metadata, page counts, and inactive icons |
| Accent Ink Blue | `#2F4A7A` | Single accent: primary CTA buttons, progress bars, active chips, and selection |
| Reading Paper Theme | `#F6F1E7` | Warm digital paper canvas specifically for the reader page background |
| Spoken Text Tint | `#D6E2F5` | Soft translucent blue highlight band for the currently spoken read-aloud sentence |
| Destructive Error | `#BA1A1A` | Coral red for destructive text actions ("Move to Trash") |

### 2.2 Typography System
- **Display & Headings**: Serif display font (**Newsreader** or **Fraunces**) with optical sizing, applied to screen titles, book titles, chapter headers, and modal sheet headlines.
- **UI Labels & Metadata**: Clean geometric sans-serif (**Inter**), applied to navigation labels, action buttons, chip text, tabular page counters, and settings toggles.
- **Reading Body**: Elegant serif (**Newsreader**, **Literata**, or **EB Garamond**) set at 18px with 1.5 line-height and justified alignment with hyphenation.

### 2.3 Shapes, Radii & Shadows
- **Card Containers**: `16px` rounded corners.
- **Bottom Sheets & Modal Panels**: `24px` top rounded corners with `32×4px` centered pill drag handle (`#E8E2D9`).
- **Interactive Controls & Chips**: `9999px` stadium pill shape for action buttons, filter chips, and floating players.
- **Book Covers**: Aspect ratio `2:3` with `4px` corner radius.
- **Elevation & Shadows**: Flat 0-elevation for UI panels with 1px hairline borders (`#E8E2D9`). Soft, diffuse, long drop shadow under 2:3 book covers only (`offset(0, 8px), blur 16px, opacity ~12%`).

### 2.4 Iconography
- **Stroke & Style**: Outlined icons with consistent `1.5px` stroke weight, drawn in Primary Ink (`#1C1B1A`) or Secondary Slate (`#6B655D`).

---

## 3. Component Image Naming Convention & Directory Architecture

To guarantee zero filename collisions and intuitive asset mapping across Flutter development, filenames follow a rigid syntax:

$$\text{Path} = \text{design/components/}\langle\text{screen\_number}\rangle\_\langle\text{screen\_name}\rangle/\langle\text{screen\_number}\rangle\_\langle\text{screen\_name}\rangle\_\langle\text{component\_name}\rangle.\text{png}$$

### Naming Syntax Rules
1. `<screen_number>`: Zero-padded two-digit index with optional variant letter: `00`, `01`, `02`, `02b`, `02c`, `02d`, `03`, `04`, `04b`, `04c`, `04d`, `04e`, `05`, `06`, `07`, `08`.
2. `<screen_name>`: Lowercase snake_case identifier matching the screen domain (`onboarding`, `library`, `empty_library`, `filter_sort_sheet`, `book_details`, `settings`, `reader`, `appearance_sheet`, `text_selection_dictionary`, `contents_annotations`, `search_in_book`, `read_aloud`, `lock_screen`, `premium_paywall`, `all_annotations`).
3. `<component_name>`: Semantic snake_case descriptor of the visual element's role (`top_bar`, `hero_card`, `chips_row`, `results_list`, etc.).
4. File Extension: Strictly lowercase `.png`.

### Standardized Directory Hierarchy
```text
design/
└── components/
    ├── 00_shared/
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

---

## 4. Global Screen & Component Inventory (71 Discrete Components)

| Screen # & Name | Component Name | Output Filename | Aspect Ratio | Dimensions | Role Summary |
|---|---|---|---|---|---|
| **00 Shared** | Tokens & Palette | `00_shared_design_tokens_palette.png` | 16:9 | 1280×720 | Global color swatches, typography specimen, corner radii, and drop shadows |
| **00 Shared** | Book Cover Spec | `00_shared_book_cover_spec.png` | 2:3 | 600×900 | 2:3 book cover specification with soft shadow and corner format badge |
| **01 Onboarding** | Top Bar | `01_onboarding_top_bar.png` | 16:9 | 824×200 | Minimal header with right-aligned "Skip" text link (#6B655D) |
| **01 Onboarding** | Page 1 Hero Card | `01_onboarding_hero_page1.png` | 4:3 | 800×600 | Open book illustration, "Your books, all in one place" headline, formats body |
| **01 Onboarding** | Page 2 Hero Card | `01_onboarding_hero_page2.png` | 4:3 | 800×600 | Typography illustration, "Read the way you like" headline, customization body |
| **01 Onboarding** | Page 3 Hero Card | `01_onboarding_hero_page3.png` | 4:3 | 800×600 | Sound waves illustration, "Listen when your eyes rest" headline, TTS body |
| **01 Onboarding** | Page 4 Hero Card | `01_onboarding_hero_page4.png` | 4:3 | 800×600 | Lock & dictionary illustration, "Private by design" headline, privacy body |
| **01 Onboarding** | Thumbnails Preview | `01_onboarding_thumbnails_preview.png` | 16:9 | 824×300 | Horizontal strip previewing miniature cards for pages 2, 3, and 4 |
| **01 Onboarding** | Page Indicator | `01_onboarding_page_indicator.png` | 16:9 | 600×120 | 4 horizontal dots; active dot in deep ink blue #2F4A7A, inactive in #E8E2D9 |
| **01 Onboarding** | Action Buttons | `01_onboarding_action_buttons.png` | 16:9 | 824×240 | Full-width deep ink blue pill button ("Next"/"Import") + "Explore first" link |
| **02 Library** | Top App Bar | `02_library_top_app_bar.png` | 16:9 | 824×200 | Warm ivory bar with serif title "Library", search icon, settings gear icon |
| **02 Library** | Continue Reading Hero | `02_library_continue_reading_hero.png` | 16:9 | 824×360 | White card (16px radius): 2:3 cover, serif title, author, progress bar, Resume pill |
| **02 Library** | Recent Books Row | `02_library_recent_books_row.png` | 16:9 | 824×360 | Horizontal scrolling strip of 3 compact cards with circular progress rings |
| **02 Library** | Filter Chips Row | `02_library_filter_chips_row.png` | 16:9 | 824×160 | Pill chips: All (selected), Reading, To read, Finished, Collections ▾, Sort icon |
| **02 Library** | Book Grid Item | `02_library_book_grid_item.png` | 2:3 | 600×900 | 3-column grid item: 2:3 cover with soft shadow, format tag, 2-line title, author |
| **02 Library** | Import Extended FAB | `02_library_import_fab.png` | 1:1 | 400×400 | Extended stadium pill FAB: deep ink blue #2F4A7A, white "+ Import" icon and text |
| **02b Empty Library** | Top App Bar | `02b_empty_library_top_app_bar.png` | 16:9 | 824×200 | Warm ivory header with serif "Library" and settings gear icon |
| **02b Empty Library** | Shelf Illustration | `02b_empty_library_shelf_illustration.png` | 4:3 | 800×600 | Centered delicate editorial illustration of an empty wooden bookshelf |
| **02b Empty Library** | Empty State Card | `02b_empty_library_empty_state_card.png` | 16:9 | 824×240 | Headline "Your library is empty" (serif), DRM-free folder import body (sans) |
| **02b Empty Library** | Import Action Buttons | `02b_empty_library_action_buttons.png` | 16:9 | 824×240 | Dual button stack: "Import files" primary pill, "Import a folder" outlined pill |
| **02c Filter & Sort Sheet** | Sheet Header | `02c_filter_sort_sheet_header.png` | 16:9 | 824×240 | Modal sheet drag handle, serif title "Filter & Sort", grid/list toggle |
| **02c Filter & Sort Sheet** | Sort Radio Rows | `02c_filter_sort_sheet_sort_section.png` | 4:3 | 800×600 | Radio selection list: Recently read (selected), Title, Author, Date added, Progress |
| **02c Filter & Sort Sheet** | Format Multi-Select Chips | `02c_filter_sort_sheet_format_chips.png` | 16:9 | 824×240 | Multi-select pill chips: EPUB, PDF, TXT, Markdown, HTML, FB2 |
| **02c Filter & Sort Sheet** | Browse By Navigation Rows | `02c_filter_sort_sheet_browse_rows.png` | 4:3 | 800×600 | Navigation list rows with counts & chevrons: Authors, Series, Collections, Trash |
| **02c Filter & Sort Sheet** | Sheet Footer Actions | `02c_filter_sort_sheet_footer_actions.png` | 16:9 | 824×200 | Sticky bottom bar: "Reset" secondary text button, "Apply" ink-blue pill button |
| **02d Book Details Sheet** | Header & Cover Card | `02d_book_details_header_card.png` | 4:3 | 800×600 | Large 2:3 cover with soft shadow, serif title, author, series metadata tag |
| **02d Book Details Sheet** | Metadata Grid | `02d_book_details_metadata_grid.png` | 16:9 | 824×280 | Technical specs: Format (EPUB), Size, Date added, and 6px progress bar card |
| **02d Book Details Sheet** | Action Buttons Row | `02d_book_details_action_row.png` | 16:9 | 824×200 | Row: Read (primary ink blue), Add to collection, Edit details, Share |
| **02d Book Details Sheet** | Destructive Footer | `02d_book_details_destructive_footer.png` | 16:9 | 824×160 | Bottom destructive text button "Move to Trash" in coral red with trash icon |
| **03 Settings** | Top App Bar | `03_settings_top_app_bar.png` | 16:9 | 824×200 | Nav bar with back arrow and serif title "Settings" |
| **03 Settings** | Appearance Card | `03_settings_appearance_card.png` | 4:3 | 800×600 | Inset card (16px radius): Theme segmented pill [Light/Dark/System], Text size |
| **03 Settings** | Reading Defaults Card | `03_settings_reading_defaults_card.png` | 4:3 | 800×600 | Inset card: Default reading theme, Font, Page turning switches, Orientation lock |
| **03 Settings** | Read Aloud Card | `03_settings_read_aloud_card.png` | 4:3 | 800×600 | Inset card: Default voice ("English UK Offline"), Speed "1.0×", Skip page numbers |
| **03 Settings** | Library & Backup Card | `03_settings_library_backup_card.png` | 4:3 | 800×600 | Inset card: Import folder, Auto-mark finished, Trash auto-empty, Backup & Restore |
| **03 Settings** | Premium Banner Card | `03_settings_premium_banner_card.png` | 16:9 | 824×320 | Highlighted card "Unlock 12 themes and 8 fonts" with ink-blue CTA button |
| **03 Settings** | About & Legal Card | `03_settings_about_card.png` | 4:3 | 800×600 | Inset card: Wiktionary credits (CC BY-SA 3.0), Open-source licences, Version 1.0.0 |
| **04 Reader** | Reader Content Page | `04_reader_content_page.png` | 9:16 | 720×1280 | Paper theme (#F6F1E7), justified 18px serif text, chapter header "The Harbour" |
| **04 Reader** | Top Chrome Bar | `04_reader_top_chrome_bar.png` | 16:9 | 824×200 | Translucent paper bar with blur: back arrow, book title, search, bookmark, ⋮ |
| **04 Reader** | Bottom Chrome Panel | `04_reader_bottom_chrome_panel.png` | 4:3 | 800×600 | Rounded panel: Page metadata, slider with ticks, 4 tools: Contents, Appearance, Listen, Notes |
| **04 Reader** | Edge Brightness Indicator | `04_reader_vertical_brightness_indicator.png` | 1:1 | 400×400 | Thin vertical translucent slider on left page edge with ink-blue fill |
| **04 Reader** | Hidden Chrome Footer | `04_reader_hidden_chrome_footer.png` | 16:9 | 824×160 | Distraction-free reading view with tiny "142 / 380" position indicator |
| **04b Appearance Sheet** | Reading Theme Swatches | `04b_appearance_sheet_theme_swatches.png` | 16:9 | 824×280 | 6 circular swatches (Paper, White, Sepia, Grey, Night, Black) with lock badges |
| **04b Appearance Sheet** | Font Picker Row | `04b_appearance_sheet_font_picker.png` | 16:9 | 824×200 | Horizontal row showing 'Aa' in fonts (Publisher, Newsreader, Fraunces, etc.) |
| **04b Appearance Sheet** | Typography Sliders | `04b_appearance_sheet_typography_sliders.png` | 4:3 | 800×600 | Sliders for Size (18px), Line spacing (1.5), Margins (20px) with A−/A+ labels |
| **04b Appearance Sheet** | Layout & Toggle Controls | `04b_appearance_sheet_layout_controls.png` | 4:3 | 800×600 | Segmented layout [Scroll/Pages/Two columns], Justify, Hyphenation toggles |
| **04b Appearance Sheet** | Brightness Control Row | `04b_appearance_sheet_brightness_control.png` | 16:9 | 824×180 | Horizontal brightness slider flanked by sun icons and "Follow system" toggle |
| **04c Text Selection** | Highlighted Text Excerpt | `04c_selection_highlighted_text.png` | 16:9 | 824×320 | Reader paragraph with word 'littoral' selected with ink-blue handles and tint |
| **04c Text Selection** | Floating Context Toolbar | `04c_selection_floating_toolbar.png` | 16:9 | 824×200 | Floating pill toolbar: Highlight (5 color dots), Note, Define, Copy, Share, ⋯ |
| **04c Text Selection** | Dictionary Definition Sheet | `04c_dictionary_definition_sheet.png` | 4:3 | 800×600 | Bottom sheet: 'littoral', phonetics, audio icon, POS chips, numbered definitions, Wiktionary footer |
| **04d Contents & Annotations** | Sheet Header & Tabs | `04d_contents_sheet_header.png` | 16:9 | 824×240 | Side sheet header: book title, "Export as Markdown" icon, 3 tabs (Contents, Bookmarks, Highlights) |
| **04d Contents & Annotations** | TOC Nested List | `04d_contents_toc_nested_list.png` | 3:4 | 600×800 | Nested chapter hierarchy with page numbers and ink-blue active chapter bar |
| **04d Contents & Annotations** | Highlights Feed Tab View | `04d_contents_highlights_tab_view.png` | 3:4 | 600×800 | Highlights cards list: color strip, quote snippet, page, date, note preview |
| **04d Contents & Annotations** | Bookmarks Tab View | `04d_contents_bookmarks_tab_view.png` | 3:4 | 600×800 | Bookmarks list: bookmark icon in #2F4A7A, chapter name, page number, delete trash icon |
| **04e Search in Book** | Search Top Bar | `04e_search_top_bar.png` | 16:9 | 824×200 | Input holding 'harbour', '23 results' badge, clear button, up/down arrows |
| **04e Search in Book** | Search Results List | `04e_search_results_list.png` | 3:4 | 600×800 | Grouped chapter results with bold ink-blue match terms and page numbers |
| **05 Read Aloud** | Spoken Sentence Highlight | `05_read_aloud_sentence_highlight.png` | 16:9 | 824×360 | Reader text auto-scrolling with active spoken sentence highlighted in ink-blue band |
| **05 Read Aloud** | Floating Mini Player | `05_read_aloud_floating_mini_player.png` | 16:9 | 824×220 | Docked white pill player: cover thumbnail, chapter title, play/pause, prev/next, expand chevron |
| **05 Read Aloud** | Expanded Player Sheet | `05_read_aloud_expanded_player_sheet.png` | 3:4 | 600×800 | Tall sheet: cover hero, title, large serif sentence with faded neighbours, controls, chips row |
| **05 Read Aloud** | Sleep Timer Picker Sheet | `05_read_aloud_sleep_timer_sheet.png` | 4:3 | 800×600 | Modal sheet: 15 min, 30 min (selected), 60 min, End of chapter, Off |
| **06 Lock Screen** | Lock Screen System Frame | `06_lock_screen_system_frame.png` | 9:16 | 720×1280 | Android 15 lock screen with blurred book cover wallpaper and large "9:41" clock |
| **06 Lock Screen** | Expanded Media Player Card | `06_lock_screen_media_card_expanded.png` | 16:9 | 824×360 | Material You media card: cover art, chapter title, seek bar, controls, "Sleep 30m" button, app icon |
| **06 Lock Screen** | Collapsed Media Player Card | `06_lock_screen_media_card_collapsed.png` | 16:9 | 824×200 | Collapsed single-row card variant with square thumbnail, compact text, inline controls |
| **07 Premium Appearance** | Top Bar & Close Button | `07_premium_paywall_top_bar.png` | 16:9 | 824×180 | Full-page header with right-aligned outlined close "X" icon button |
| **07 Premium Appearance** | Hero Themes Preview Card | `07_premium_paywall_hero_preview.png` | 4:3 | 800×600 | 3-way side-by-side theme comparison: Linen, Midnight Blue, Forest in contrasting fonts |
| **07 Premium Appearance** | Value Features & Trust Card | `07_premium_paywall_features_card.png` | 4:3 | 800×600 | Headline "Make every page yours", bullets (12 themes, 8 fonts, presets), free features note |
| **07 Premium Appearance** | Pricing Plan Cards | `07_premium_paywall_pricing_cards.png` | 16:9 | 824×320 | Dual plan cards: Lifetime (highlighted with ink-blue border & badge) vs Yearly |
| **07 Premium Appearance** | Action Footer & Restore Link | `07_premium_paywall_action_footer.png` | 16:9 | 824×220 | Primary "Unlock LinguaPages Premium" ink-blue pill button + "Restore purchase" text link |
| **08 All Annotations** | Top Bar | `08_all_annotations_top_bar.png` | 16:9 | 824×200 | Serif title "Annotations", search icon button, overflow menu (⋮) with Markdown export |
| **08 All Annotations** | Book Group Header | `08_all_annotations_book_group_header.png` | 16:9 | 824×200 | Book section header: cover thumbnail (2:3), serif title, author, count badge |
| **08 All Annotations** | Annotation Feed Card | `08_all_annotations_annotation_card.png` | 16:9 | 824×320 | Feed card: 4px color strip, quoted passage, reader note with pencil icon, page & date |
| **08 All Annotations** | Export Dialog Sheet | `08_all_annotations_export_dialog_sheet.png` | 4:3 | 800×600 | Modal sheet: Markdown (.md), clipboard copy, share options, primary ink-blue pill CTA |

---

## 5. Screen-by-Screen Component Generation Specifications

### 5.0 Shared Design Tokens & Style Spec Sheet (`00_shared`)

#### Component: `Shared Design Tokens Palette`
- **Filename**: `00_shared_design_tokens_palette.png`
- **Output Path**: `design/components/00_shared/00_shared_design_tokens_palette.png`
- **Component Role**: Master design system style guide exhibiting the complete color palette, typography hierarchy, button pill shapes, 16px card corners, hairline dividers, and icon stroke weights.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `1280×720px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI design token specification sheet for LinguaPages Android ebook reader on a warm ivory #FAF7F2 background. The layout displays six labeled color swatch cards with 16px rounded corners and pure white #FFFFFF surfaces: 1. Canvas Ivory (#FAF7F2), 2. Card Surface (#FFFFFF), 3. Hairline Divider (#E8E2D9), 4. Primary Ink (#1C1B1A), 5. Secondary Slate (#6B655D), 6. Accent Deep Ink Blue (#2F4A7A). Alongside the swatches: a typography specimen contrasting Newsreader serif display headlines against Inter sans-serif labels; stadium pill buttons (9999px radius) filled in deep ink blue #2F4A7A with crisp white text; and a row of 1.5px outlined minimalist vector icons (search, bookmark, settings gear, volume wave, book cover). Clean, high-contrast, editorial design system reference.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout, photorealistic humans.

---

#### Component: `Shared Book Cover Spec`
- **Filename**: `00_shared_book_cover_spec.png`
- **Output Path**: `design/components/00_shared/00_shared_book_cover_spec.png`
- **Component Role**: Component specification for literary 2:3 book covers displaying realistic illustration, title, author, corner format badge, and diffuse drop shadow.
- **Aspect Ratio**: `2:3`
- **Target Dimensions**: `600×900px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Standalone 2:3 aspect ratio literary book cover UI asset resting on a warm ivory #FAF7F2 background. The book cover features an atmospheric editorial woodcut illustration of a misty coastal cliff. Elegant Newsreader serif typography reads 'The Salt Path' in large cream lettering, with author 'Raynor Winn' beneath in clean sans-serif. In the top-right corner of the cover, a tiny translucent dark pill badge displays 'EPUB' in crisp white Inter typography. The book cover has a 4px corner radius and casts a soft, diffuse, long drop shadow downward. Book covers provide the primary color in the UI; everything else is calm and restrained.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout, photorealistic humans.

---

### 5.1 Screen 01: Onboarding Carousel (`01_onboarding`)

#### Component: `Onboarding Top Bar`
- **Filename**: `01_onboarding_top_bar.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_top_bar.png`
- **Component Role**: Top utility header for the onboarding carousel containing 20px horizontal margin padding and a right-aligned secondary text link.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Mobile app UI top header for the onboarding screen of LinguaPages. Background is solid warm ivory #FAF7F2. On the top-right, aligned with 20px side margin, is a subtle text link 'Skip' in 15px clean geometric sans-serif (Inter) in secondary slate #6B655D. Generous whitespace, clean status bar safe area clearance, calm editorial atmosphere.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Page 1 Hero Card`
- **Filename**: `01_onboarding_hero_page1.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_hero_page1.png`
- **Component Role**: Primary hero card occupying the top 55% of Page 1 in the onboarding carousel, showcasing multi-format offline book reading.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Onboarding carousel page 1 hero component for LinguaPages. Warm ivory #FAF7F2 background. The upper section features a delicate, soft editorial watercolor and linework illustration of an open hardcover book with layered paper leaves floating quietly upward. Below the illustration: a prominent headline in elegant Newsreader serif display font (ink #1C1B1A, 28px) reading 'Your books, all in one place'. Directly beneath is a 2-line body description in clean Inter sans-serif (slate #6B655D, 15px, 1.4 line height) reading: 'EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone.' Refined, literary, quiet editorial beauty.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout, photorealistic humans.

---

#### Component: `Onboarding Page 2 Hero Card`
- **Filename**: `01_onboarding_hero_page2.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_hero_page2.png`
- **Component Role**: Hero card for Page 2 of the carousel, illustrating deep reader customization, typography controls, and persistent annotations.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Onboarding carousel page 2 hero component for LinguaPages. Warm ivory #FAF7F2 canvas. Upper area depicts a calm editorial illustration of typography tools: sample color swatches (Paper, Sepia, Night), ribbon bookmarks, and an elegant 'Aa' typeface emblem. Below the art, an ink #1C1B1A serif display headline (Newsreader 28px) reading 'Read the way you like', followed by a 2-line Inter sans body (slate #6B655D, 15px): 'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.' Clean whitespace, balanced margins.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Page 3 Hero Card`
- **Filename**: `01_onboarding_hero_page3.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_hero_page3.png`
- **Component Role**: Hero card for Page 3 of the carousel, illustrating offline natural text-to-speech read aloud with background lock-screen playback.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Onboarding carousel page 3 hero component for LinguaPages on warm ivory #FAF7F2. Soft editorial illustration of gentle acoustic sound waves in deep ink blue #2F4A7A and warm slate emanating from the spine of an open book. Below the illustration, Newsreader serif headline (28px, ink #1C1B1A) reading 'Listen when your eyes rest'. Beneath is a 2-line Inter sans-serif body (15px, slate #6B655D): 'Natural text-to-speech reads aloud, even with the screen locked.' Restrained, serene, literary aesthetic.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Page 4 Hero Card`
- **Filename**: `01_onboarding_hero_page4.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_hero_page4.png`
- **Component Role**: Hero card for Page 4 of the carousel, emphasizing private offline architecture, zero tracking, and built-in dictionary lookup.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Onboarding carousel page 4 hero component for LinguaPages on warm ivory #FAF7F2. Visual illustration showcases a minimalist brass and ink padlock motif resting beside an open dictionary with delicate phonetics linework. Bold Newsreader serif headline (28px, ink #1C1B1A) reading 'Private by design'. Below: 2-line Inter sans body (15px, slate #6B655D) reading 'No account, no tracking. Look up words with the free dictionary.' Editorial, trustworthy, elegant negative space.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Thumbnails Preview`
- **Filename**: `01_onboarding_thumbnails_preview.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_thumbnails_preview.png`
- **Component Role**: Horizontal preview component displaying miniature thumbnail cards for pages 2, 3, and 4 sitting beside the large active page.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×300px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component for LinguaPages onboarding showing a preview strip of three miniature cards (12px rounded corners, pure white #FFFFFF surfaces, 1px border #E8E2D9). Card 1 shows a thumbnail of typography swatches ('Read the way you like'), Card 2 shows sound waves ('Listen when your eyes rest'), and Card 3 shows a lock emblem ('Private by design'). Cards sit horizontally with 12px gaps on a warm ivory #FAF7F2 ground, demonstrating carousel depth.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Page Indicator`
- **Filename**: `01_onboarding_page_indicator.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_page_indicator.png`
- **Component Role**: Centered 4-dot pagination indicator representing carousel progress.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `600×120px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component showing a centered horizontal row of four pagination indicator dots on warm ivory #FAF7F2. The first dot is active: an elongated rounded pill (24px width, 8px height) in solid deep ink blue #2F4A7A. The remaining three dots are inactive: circular dots (8px diameter) in hairline grey #E8E2D9 with 8px spacing. Minimalist, pixel-perfect Material 3 pagination indicator.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Onboarding Action Buttons`
- **Filename**: `01_onboarding_action_buttons.png`
- **Output Path**: `design/components/01_onboarding/01_onboarding_action_buttons.png`
- **Component Role**: Bottom action area of the onboarding flow providing the primary progression pill button and secondary exploration link.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component for the bottom action container of LinguaPages onboarding. Warm ivory #FAF7F2 background with 20px side margins. Contains a full-width primary stadium pill button (52px height, 9999px radius) filled with deep ink blue #2F4A7A, displaying bold white Inter sans-serif text 'Next' (or 'Import your first book'). Positioned 16px beneath the button is a centered secondary text link 'Explore first' in 14px Inter sans-serif in secondary slate #6B655D. Clean, spacious, touch-friendly mobile layout.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.2 Screen 02: Library (Main Screen) (`02_library`)

#### Component: `Library Top App Bar`
- **Filename**: `02_library_top_app_bar.png`
- **Output Path**: `design/components/02_library/02_library_top_app_bar.png`
- **Component Role**: Primary application header for the Library screen, establishing brand typography and providing access to search and settings.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Mobile app top app bar for LinguaPages Library on warm ivory #FAF7F2 background. Height 56px, 20px horizontal padding. On the left: prominent screen title 'Library' in 28px Newsreader serif display font (ink #1C1B1A, bold). On the right: a row of two outlined 1.5px stroke icons in ink #1C1B1A—first an outlined search magnifying glass icon, followed by an outlined settings gear icon with 20px spacing. No bottom border line, completely open and spacious editorial header.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Library Continue Reading Hero`
- **Filename**: `02_library_continue_reading_hero.png`
- **Output Path**: `design/components/02_library/02_library_continue_reading_hero.png`
- **Component Role**: Prominent hero card at the top of the library displaying the active reading session with direct resume capability.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×360px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Prominent horizontal 'Continue reading' hero card for LinguaPages library. Card has 16px rounded corners, pure white #FFFFFF surface, and rests on warm ivory #FAF7F2 with 20px side margins. On the left: a realistic 2:3 literary book cover with dark moody coastal art (rounded 4px, soft long drop shadow). On the right: book title in Newsreader serif (20px, ink #1C1B1A) reading 'The Salt Path', author 'Raynor Winn' in 14px Inter sans (slate #6B655D), reading position 'Chapter 7 · 64%' in tabular figures, a slender 4px horizontal progress bar filled with deep ink blue #2F4A7A (grey track #E8E2D9), and a compact stadium pill button labelled 'Resume' in solid deep ink blue #2F4A7A with white Inter text.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Library Recent Books Row`
- **Filename**: `02_library_recent_books_row.png`
- **Output Path**: `design/components/02_library/02_library_recent_books_row.png`
- **Component Role**: Horizontally scrolling strip directly beneath the hero card displaying secondary recent books with circular progress rings.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×360px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Horizontal scrolling row of 3 recent book cards for LinguaPages library on warm ivory #FAF7F2. Each card (120px width, 16px rounded corners, pure white #FFFFFF surface, 16px padding) contains: a compact 2:3 book cover with soft shadow, a 1-line title in 14px Newsreader serif ('Caliban\'s War', 'Piranesi', 'Klara and the Sun'), author in 12px Inter sans (slate #6B655D), and an elegant circular progress ring (32px diameter, deep ink blue #2F4A7A arc with percentage '42%' inside). Editorial, clean, orderly bookshelf layout.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Library Filter Chips Row`
- **Filename**: `02_library_filter_chips_row.png`
- **Output Path**: `design/components/02_library/02_library_filter_chips_row.png`
- **Component Role**: Horizontally scrolling pill chips bar enabling rapid shelf filtering and modal sort sheet invocation.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×160px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component of a horizontal scrolling filter chip bar for LinguaPages library on warm ivory #FAF7F2. Left-to-right chips: 1. 'All' (selected, filled in solid deep ink blue #2F4A7A with white 14px Inter text), 2. 'Reading' (unselected, white surface #FFFFFF, 1px border #E8E2D9, ink text #1C1B1A), 3. 'To read', 4. 'Finished', 5. 'Favorites', 6. 'Collections ▾' (with trailing small dropdown chevron). At the far right end: an outlined 1.5px stroke sort/filter icon button (hairline circular button). Stadium pill shapes (9999px radius), generous touch padding.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Library Book Grid Item`
- **Filename**: `02_library_book_grid_item.png`
- **Output Path**: `design/components/02_library/02_library_book_grid_item.png`
- **Component Role**: Individual book card unit representing an item inside the 3-column bookshelf grid.
- **Aspect Ratio**: `2:3`
- **Target Dimensions**: `600×900px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Single book item for the 3-column library grid in LinguaPages on warm ivory #FAF7F2. Displays a realistic 2:3 ratio book cover with soft, diffuse, long drop shadow. Top-right corner of the cover has a small semi-transparent format badge 'EPUB' in crisp white Inter typography. Underneath the cover edge is a slender 3px progress bar in deep ink blue #2F4A7A indicating 75% read. Beneath the cover: book title in 14px Newsreader serif display font (max 2 lines, ink #1C1B1A) reading 'The Left Hand of Darkness', followed by author name 'Ursula K. Le Guin' in 12px Inter sans (secondary slate #6B655D). Book covers provide the primary color in the UI; everything else is restrained.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Library Import Extended FAB`
- **Filename**: `02_library_import_fab.png`
- **Output Path**: `design/components/02_library/02_library_import_fab.png`
- **Component Role**: Extended Floating Action Button anchored at the bottom-right of the library for file and folder imports.
- **Aspect Ratio**: `1:1`
- **Target Dimensions**: `400×400px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Floating Action Button component for LinguaPages library displayed on a warm ivory #FAF7F2 canvas. An extended stadium pill button (52px height, 9999px radius, soft elevated shadow) filled with solid deep ink blue #2F4A7A. Inside the pill is a clean white plus icon ('+') with 1.5px stroke weight, followed by bold white Inter sans-serif text '+ Import'. Crisp, elegant Material 3 extended FAB with calm editorial styling.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.3 Screen 02b: Empty Library (`02b_empty_library`)

#### Component: `Empty Library Top App Bar`
- **Filename**: `02b_empty_library_top_app_bar.png`
- **Output Path**: `design/components/02b_empty_library/02b_empty_library_top_app_bar.png`
- **Component Role**: Clean top app bar for the empty library state with settings access.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top app bar for LinguaPages empty library screen on warm ivory #FAF7F2. Left-aligned title 'Library' in 28px Newsreader serif display font (ink #1C1B1A). On the far right: single outlined 1.5px stroke settings gear icon in ink #1C1B1A. Search icon is omitted because the library has no books. Clean, quiet whitespace.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Empty Library Shelf Illustration`
- **Filename**: `02b_empty_library_shelf_illustration.png`
- **Output Path**: `design/components/02b_empty_library/02b_empty_library_shelf_illustration.png`
- **Component Role**: Centered delicate editorial illustration of an empty wooden bookshelf communicating serene potential.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Centered editorial empty state illustration for LinguaPages on warm ivory #FAF7F2. A delicate line art and soft watercolor wash depicting an empty three-tier wooden bookshelf. Sunlight casts soft diagonal shadows across the shelves, and a small sprig of olive leaves rests quietly on the top corner. Muted warm wood and slate tones, refined literary serenity, calm negative space.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout, photorealistic humans.

---

#### Component: `Empty Library Empty State Card`
- **Filename**: `02b_empty_library_empty_state_card.png`
- **Output Path**: `design/components/02b_empty_library/02b_empty_library_empty_state_card.png`
- **Component Role**: Typographic message block guiding first-time readers on how to populate their local offline library.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Centered typographic card for LinguaPages empty library on warm ivory #FAF7F2. Features a prominent headline in Newsreader serif display font (24px, ink #1C1B1A) reading 'Your library is empty'. Below is a 2-line body in clean Inter sans-serif (15px, secondary slate #6B655D, 1.4 line-height) reading: 'Import a DRM-free book or a whole folder to start reading.' Generous whitespace, centered text alignment, calm and reassuring tone.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Empty Library Import Action Buttons`
- **Filename**: `02b_empty_library_action_buttons.png`
- **Output Path**: `design/components/02b_empty_library/02b_empty_library_action_buttons.png`
- **Component Role**: Dual button stack providing immediate pathways for importing individual files or batch directory scanning.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Dual button action component for LinguaPages empty library on warm ivory #FAF7F2. Centered vertical stack of two stadium pill buttons (48px height, 9999px radius, width 280px): Top button is primary 'Import files' in solid deep ink blue #2F4A7A with bold white Inter text and leading document icon. Bottom button is secondary outlined 'Import a folder' with 1.5px hairline border #E8E2D9, white surface #FFFFFF, ink #1C1B1A Inter text and leading folder icon. 12px vertical spacing between buttons.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.4 Screen 02c: Filter and Sort Sheet (`02c_filter_sort_sheet`)

#### Component: `Filter & Sort Sheet Header`
- **Filename**: `02c_filter_sort_sheet_header.png`
- **Output Path**: `design/components/02c_filter_sort_sheet/02c_filter_sort_sheet_header.png`
- **Component Role**: Modal sheet header with drag handle, title, and view mode toggle.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top header section of a modal bottom sheet for LinguaPages. The container has a pure white #FFFFFF surface with 24px top rounded corners. Centered at top: a 32×4px rounded pill drag handle in hairline grey #E8E2D9. Below the handle: the title 'Filter & Sort' in 20px Newsreader serif display font (ink #1C1B1A). On the right side: a segmented pill toggle for shelf view mode with two outlined 1.5px stroke icons: [ 3-column Grid (selected in deep ink blue #2F4A7A) | 1-column List ]. Hairline divider #E8E2D9 below.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Filter & Sort Sheet Sort Section`
- **Filename**: `02c_filter_sort_sheet_sort_section.png`
- **Output Path**: `design/components/02c_filter_sort_sheet/02c_filter_sort_sheet_sort_section.png`
- **Component Role**: Sort criteria section featuring single-select radio option rows.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component for the 'Sort by' section inside LinguaPages filter bottom sheet on white #FFFFFF surface. Section label 'Sort by' in 13px Inter sans bold (secondary slate #6B655D, uppercase tracking). Below are five selectable radio rows with 48px height and hairline dividers #E8E2D9: 1. 'Recently read' (selected, with active solid deep ink blue #2F4A7A radio indicator), 2. 'Title', 3. 'Author', 4. 'Date added', 5. 'Progress'. Clean typography, 15px Inter sans labels, spacious touch targets.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Filter & Sort Sheet Format Chips`
- **Filename**: `02c_filter_sort_sheet_format_chips.png`
- **Output Path**: `design/components/02c_filter_sort_sheet/02c_filter_sort_sheet_format_chips.png`
- **Component Role**: Multi-select format filter section displaying pill chips for supported offline ebook formats.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component showing the 'Format' multi-select filter section in LinguaPages bottom sheet on white #FFFFFF surface. Section label 'Format' in 13px Inter sans (slate #6B655D). A wrapping row of six stadium pill chips (36px height, 9999px radius): 1. 'EPUB' (selected, solid deep ink blue #2F4A7A with white text), 2. 'PDF' (selected, solid deep ink blue #2F4A7A with white text), 3. 'TXT' (unselected, warm ivory #FAF7F2 background, 1px border #E8E2D9, ink text #1C1B1A), 4. 'Markdown', 5. 'HTML', 6. 'FB2'. Clean, tactile pill chips.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Filter & Sort Sheet Browse Rows`
- **Filename**: `02c_filter_sort_sheet_browse_rows.png`
- **Output Path**: `design/components/02c_filter_sort_sheet/02c_filter_sort_sheet_browse_rows.png`
- **Component Role**: Secondary navigation rows for browsing library books by metadata collections, annotations, or trash.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component showing 'Browse by' navigation list in LinguaPages filter sheet on white #FFFFFF surface. Section label 'Browse by' in 13px Inter sans bold (slate #6B655D). Five list tiles with 1.5px stroke outlined icons, 15px Inter sans labels, tabular count badges, and trailing chevrons: 1. Authors ('142'), 2. Series ('18'), 3. Collections ('7'), 4. All annotations ('64'), 5. Trash ('3'). Hairline dividers #E8E2D9 between rows, elegant editorial hierarchy.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Filter & Sort Sheet Footer Actions`
- **Filename**: `02c_filter_sort_sheet_footer_actions.png`
- **Output Path**: `design/components/02c_filter_sort_sheet/02c_filter_sort_sheet_footer_actions.png`
- **Component Role**: Pinned bottom action bar inside the filter sheet committing or resetting parameters.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Bottom pinned footer actions bar for LinguaPages filter sheet on pure white #FFFFFF surface. 1px hairline top divider #E8E2D9. On the left: a subtle 'Reset' text button in 14px Inter sans (secondary slate #6B655D). On the right: a primary 'Apply' stadium pill button (48px height, 9999px radius, 140px width) in solid deep ink blue #2F4A7A with bold white Inter text. Clean whitespace, 20px side padding.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.5 Screen 02d: Book Details Sheet (`02d_book_details`)

#### Component: `Book Details Header Card`
- **Filename**: `02d_book_details_header_card.png`
- **Output Path**: `design/components/02d_book_details/02d_book_details_header_card.png`
- **Component Role**: Top section of tall bottom sheet (invoked via long-press) displaying prominent book cover art and literary metadata.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Header section of tall bottom sheet for LinguaPages book details. Pure white #FFFFFF surface with 24px top rounded corners and 32×4px grey drag handle #E8E2D9. Below the handle: centered prominent 2:3 book cover with soft long drop shadow (140px width). Below cover: book title in 24px Newsreader serif display font (ink #1C1B1A) reading 'Caliban\'s War', author 'James S.A. Corey' in 15px Inter sans (secondary slate #6B655D), and series tag 'The Expanse · Book 2' in a subtle warm ivory #FAF7F2 pill badge with 1px border #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Book Details Metadata Grid`
- **Filename**: `02d_book_details_metadata_grid.png`
- **Output Path**: `design/components/02d_book_details/02d_book_details_metadata_grid.png`
- **Component Role**: Technical metadata strip and reading progress card.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×280px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component for technical metadata and progress in LinguaPages book details sheet on white #FFFFFF surface. Top row features three compact spec badges: 'Format: EPUB', 'Size: 2.8 MB', 'Added: 12 Oct 2026' (13px Inter sans, warm ivory #FAF7F2 pills). Below is a reading progress card (16px rounded corners, 1px border #E8E2D9, 16px padding): reading status 'Chapter 14 of 53 · 28% read · 6h 15m left' in tabular figures, and a 6px deep ink blue #2F4A7A horizontal progress bar. Clean, restrained, informative.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Book Details Action Row`
- **Filename**: `02d_book_details_action_row.png`
- **Output Path**: `design/components/02d_book_details/02d_book_details_action_row.png`
- **Component Role**: Horizontal action row offering direct reader launch, collection assignment, metadata editing, and document sharing.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Horizontal action buttons row for LinguaPages book details sheet on white #FFFFFF surface. From left to right: 1. Primary 'Read' button: prominent stadium pill (48px height, solid deep ink blue #2F4A7A, white Inter text with leading open book icon); 2. Outlined 'Add to collection' pill button (1.5px border #E8E2D9, ink text #1C1B1A); 3. Outlined 'Edit details' pill button; 4. Outlined 'Share' icon button. Clean 1.5px outlined iconography, 12px horizontal gaps.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Book Details Destructive Footer`
- **Filename**: `02d_book_details_destructive_footer.png`
- **Output Path**: `design/components/02d_book_details/02d_book_details_destructive_footer.png`
- **Component Role**: Destructive soft-delete action button located at the bottom of the book details sheet.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×160px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Destructive action footer component for LinguaPages book details sheet on white #FFFFFF surface. Top hairline divider #E8E2D9. Centered in the row is a text action button 'Move to Trash' in 14px Inter sans in error coral red #BA1A1A, paired with a leading 1.5px outlined trash can icon. Generous vertical padding, clear separation from primary reading actions.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.6 Screen 03: Settings (`03_settings`)

#### Component: `Settings Top App Bar`
- **Filename**: `03_settings_top_app_bar.png`
- **Output Path**: `design/components/03_settings/03_settings_top_app_bar.png`
- **Component Role**: Top app bar for the Settings screen with back navigation and screen title.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top app bar for LinguaPages Settings screen on warm ivory #FAF7F2 background. Height 56px, 20px side margins. On the left: a 1.5px outlined back arrow icon in ink #1C1B1A. Adjacent: screen title 'Settings' in 28px Newsreader serif display font (ink #1C1B1A, bold). Clean, open layout, no clutter.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings Appearance Card`
- **Filename**: `03_settings_appearance_card.png`
- **Output Path**: `design/components/03_settings/03_settings_appearance_card.png`
- **Component Role**: Inset card containing global app theme and text size configuration.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Inset settings card for LinguaPages on warm ivory #FAF7F2. Card has 16px rounded corners, pure white #FFFFFF surface, and 16px padding. Section label 'Appearance' in 13px Inter sans bold (secondary slate #6B655D). Row 1: 'Theme' with a 3-way segmented stadium pill control [ Light (selected in deep ink blue #2F4A7A with white text) | Dark | System ]. Row 2: 'App text size' with value 'Normal' in slate #6B655D and trailing chevron. Leading 1.5px outlined icons, hairline row dividers #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings Reading Defaults Card`
- **Filename**: `03_settings_reading_defaults_card.png`
- **Output Path**: `design/components/03_settings/03_settings_reading_defaults_card.png`
- **Component Role**: Inset card configuring global reader defaults for themes, fonts, gestures, and hardware keys.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Inset settings card for LinguaPages 'Reading defaults' on warm ivory #FAF7F2. White #FFFFFF card, 16px radius. Section label 'Reading defaults'. List rows with leading 1.5px outlined icons: 1. 'Default reading theme' with circular Paper (#F6F1E7) swatch preview and chevron; 2. 'Default font' with value 'Newsreader' in slate #6B655D; 3. 'Page turning with volume keys' with active Material 3 toggle switch in deep ink blue #2F4A7A; 4. 'Keep screen on' toggle switch (ON); 5. 'Orientation lock' with value 'Follow sensor'. Hairline dividers #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings Read Aloud Card`
- **Filename**: `03_settings_read_aloud_card.png`
- **Output Path**: `design/components/03_settings/03_settings_read_aloud_card.png`
- **Component Role**: Inset card for text-to-speech synthesis parameters, voice models, speed, and parsing rules.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Inset settings card for LinguaPages 'Read aloud' on warm ivory #FAF7F2. Pure white #FFFFFF surface, 16px rounded corners. Section label 'Read aloud'. Rows: 1. 'Default voice' with value 'English (UK) · Offline' in slate #6B655D and trailing chevron; 2. 'Reading speed' with value '1.0×'; 3. 'Skip page numbers and footnotes' with active Material 3 toggle switch in deep ink blue #2F4A7A. 1.5px outlined speech icons, hairline dividers #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings Library & Backup Card`
- **Filename**: `03_settings_library_backup_card.png`
- **Output Path**: `design/components/03_settings/03_settings_library_backup_card.png`
- **Component Role**: Inset card managing folder automation, trash retention, and encrypted local backup/restore.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Inset settings card for LinguaPages 'Library & Backup' on warm ivory #FAF7F2. White #FFFFFF card, 16px radius. Section label 'Library & Backup'. Rows: 1. 'Import folder' with value '~/Documents/Books' in slate #6B655D; 2. 'Auto-mark finished at 100%' with toggle switch (ON, deep ink blue #2F4A7A); 3. 'Auto-empty Trash' with value 'After 30 days'; 4. 'Back up now' with action button 'Export ZIP'; 5. 'Restore files' with file picker chevron. Clean, reliable, offline-first.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings Premium Banner Card`
- **Filename**: `03_settings_premium_banner_card.png`
- **Output Path**: `design/components/03_settings/03_settings_premium_banner_card.png`
- **Component Role**: Promotional banner card in Settings highlighting the paywall offering.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×320px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Highlighted promotional banner card for LinguaPages Settings on warm ivory #FAF7F2. The card has a pure white #FFFFFF surface, 16px rounded corners, and a subtle 1px border in deep ink blue #2F4A7A. Inside: headline in 18px Newsreader serif display font reading 'Unlock 12 themes and 8 fonts'. Below is a 1-line description in 14px Inter sans (slate #6B655D): 'Elevate your reading experience with handcrafted editorial palettes.' On the right: a compact stadium pill button labelled 'Explore' in solid deep ink blue #2F4A7A with white text.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Settings About & Legal Card`
- **Filename**: `03_settings_about_card.png`
- **Output Path**: `design/components/03_settings/03_settings_about_card.png`
- **Component Role**: Inset card providing open-source licensing, Wiktionary dictionary attribution, and app versioning.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Inset settings card for LinguaPages 'About' on warm ivory #FAF7F2. Pure white #FFFFFF surface, 16px radius. Section label 'About'. Rows: 1. 'Dictionary credits' with subtitle 'From Wiktionary · CC BY-SA 3.0' in secondary slate #6B655D and external link icon; 2. 'Open-source licences' with chevron; 3. 'Version' with value '1.0.0' in tabular Inter sans; 4. 'Private and offline' reassurance badge. Hairline dividers #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.7 Screen 04: Reader (Chrome Visible & Hidden Chrome) (`04_reader`)

#### Component: `Reader Content Page`
- **Filename**: `04_reader_content_page.png`
- **Output Path**: `design/components/04_reader/04_reader_content_page.png`
- **Component Role**: Fullscreen digital reading page canvas in "Paper" theme with editorial typography, chapter header, and justified body copy.
- **Aspect Ratio**: `9:16`
- **Target Dimensions**: `720×1280px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Mobile ebook reader content page component for LinguaPages. Fullscreen canvas filled with warm digital paper background #F6F1E7 (Paper theme). Generous 20px side margins and balanced top/bottom margins. At the top of the text block: chapter header 'Chapter 3: The Harbour' in elegant 22px Newsreader serif display font (ink #1C1B1A). Below is rich, publication-grade justified body text (18px Newsreader serif, 1.5 line height, clean hyphenation) filling the page with beautiful literary prose. Calm, glare-free, distraction-free digital paper experience.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Reader Top Chrome Bar`
- **Filename**: `04_reader_top_chrome_bar.png`
- **Output Path**: `design/components/04_reader/04_reader_top_chrome_bar.png`
- **Component Role**: Translucent frosted paper top app bar displayed when reader chrome is active.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Translucent top chrome bar for LinguaPages reader (height 56px). Background is warm paper #F6F1E7 with frosted blur and a subtle 1px bottom border #E8E2D9. On the left: outlined 1.5px stroke back arrow icon in ink #1C1B1A. In the center: book title 'The Salt Path' in 15px Newsreader serif display font. On the right: a row of three outlined 1.5px stroke icons: search magnifying glass, outlined bookmark ribbon, and vertical three dots menu (⋮). Clean, light, non-distracting reading overlay.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Reader Bottom Chrome Panel`
- **Filename**: `04_reader_bottom_chrome_panel.png`
- **Output Path**: `design/components/04_reader/04_reader_bottom_chrome_panel.png`
- **Component Role**: Rounded top bottom control panel featuring chapter reading metadata, progress slider, and 4 primary tool buttons.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Bottom control panel for LinguaPages reader with 16px rounded top corners. Background is translucent warm paper #F6F1E7 with frosted glass blur and 1px top border #E8E2D9. Upper row displays reading metadata: 'Page 142 of 380 · 12 min left in chapter' in 13px Inter sans (secondary slate #6B655D, tabular figures). Below is a draggable chapter seek slider filled with deep ink blue #2F4A7A, featuring discrete subtle chapter tick marks. Bottom row contains four evenly spaced labeled icon buttons (1.5px stroke outlined icons, 12px Inter sans labels): 1. 'Contents' (list icon), 2. 'Appearance' (Aa palette icon), 3. 'Listen' (headphones icon), 4. 'Notes' (pencil document icon).

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Reader Edge Brightness Indicator`
- **Filename**: `04_reader_vertical_brightness_indicator.png`
- **Output Path**: `design/components/04_reader/04_reader_vertical_brightness_indicator.png`
- **Component Role**: Thin vertical brightness gauge appearing on the left edge during vertical swipe gestures.
- **Aspect Ratio**: `1:1`
- **Target Dimensions**: `400×400px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Vertical edge brightness indicator component for LinguaPages reader on paper #F6F1E7 background. Positioned on the left screen edge: a slender 4px wide vertical pill track (height 200px) with 9999px rounded caps. The track is semi-transparent grey #E8E2D9, with the lower 70% filled in solid deep ink blue #2F4A7A. Adjacent to the slider is a tiny 12px outlined sun icon in deep ink blue. Subtle, minimalist gesture feedback.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Reader Hidden Chrome Footer`
- **Filename**: `04_reader_hidden_chrome_footer.png`
- **Output Path**: `design/components/04_reader/04_reader_hidden_chrome_footer.png`
- **Component Role**: Minimal reading position indicator displayed in distraction-free mode when all chrome is hidden.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×160px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Minimalist bottom reading footer for LinguaPages reader in hidden chrome mode on warm paper #F6F1E7. The entire screen area is quiet and unadorned. At the bottom center, a tiny, subtle reading position indicator '142 / 380' in 11px clean Inter sans-serif (secondary slate #6B655D, 50% opacity). Zero toolbars, zero buttons, peaceful digital paper reading.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.8 Screen 04b: Appearance Sheet (`04b_appearance_sheet`)

#### Component: `Appearance Sheet Reading Theme Swatches`
- **Filename**: `04b_appearance_sheet_theme_swatches.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_theme_swatches.png`
- **Component Role**: Reading theme selector inside the appearance sheet showing 6 circular swatches with lock badges.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×280px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Horizontal theme selector component inside LinguaPages appearance bottom sheet on pure white #FFFFFF surface. Section title 'Reading themes' in 14px Inter sans (ink #1C1B1A). Below is a horizontal row of six circular color swatches (44px diameter), each displaying sample 'Aa' serif letters: 1. Paper (warm ivory #F6F1E7, active 2px outline ring in deep ink blue #2F4A7A); 2. White (#FFFFFF, 1px border #E8E2D9); 3. Sepia (#F6EFD9); 4. Grey (#E0DFDB); 5. Night (#1F2433, with a tiny white lock badge at top-right); 6. Black (#000000, with a tiny white lock badge). Subdued labels beneath each swatch.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Appearance Sheet Font Picker Row`
- **Filename**: `04b_appearance_sheet_font_picker.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_font_picker.png`
- **Component Role**: Horizontal font selection carousel showing 'Aa' previews for bundled and premium typefaces.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Font selector row component for LinguaPages appearance sheet on white #FFFFFF surface. Section title 'Font' in 14px Inter sans. A horizontally scrolling row of stadium pill chips (38px height, 9999px radius): 1. 'Publisher' (unselected, white #FFFFFF, 1px border #E8E2D9); 2. 'Aa Newsreader' (selected, solid deep ink blue #2F4A7A, white text); 3. 'Aa Fraunces' (white, 1px border #E8E2D9); 4. 'Aa Literata'; 5. 'Aa Source Serif'; 6. 'Aa EB Garamond' (with tiny lock icon); 7. 'Aa Inter'. Refined typographic specimen row.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Appearance Sheet Typography Sliders`
- **Filename**: `04b_appearance_sheet_typography_sliders.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_typography_sliders.png`
- **Component Role**: Stack of precision sliders controlling text size, line spacing, and margins with A− and A+ end labels.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Precision typography sliders stack for LinguaPages appearance sheet on white #FFFFFF surface. Stack of three slider controls with 14px Inter sans labels: 1. 'Size (18 px)' flanked by small 'A−' on left and large 'A+' on right; 2. 'Line spacing (1.5)' flanked by compact and tall line icons; 3. 'Margins (20 px)' flanked by narrow and wide margin icons. Sliders have smooth deep ink blue #2F4A7A active tracks and circular thumbs, with neutral hairline tracks #E8E2D9. Pixel-perfect, high-readability controls.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Appearance Sheet Layout & Toggle Controls`
- **Filename**: `04b_appearance_sheet_layout_controls.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_layout_controls.png`
- **Component Role**: Reading layout segmented control and typographic switches for justification, hyphenation, and publisher styles.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> UI component for layout and switches inside LinguaPages appearance sheet on white #FFFFFF surface. Top: a 3-segment stadium pill control (40px height, 9999px radius, background #FAF7F2, 1px border #E8E2D9) with options: 'Scroll', 'Pages' (selected, solid deep ink blue #2F4A7A, white text), and 'Two columns'. Below are three switch rows with 14px Inter sans labels: 1. 'Justify text' (toggle ON, deep ink blue #2F4A7A); 2. 'Hyphenation' (toggle ON); 3. 'Publisher styles' (toggle OFF, grey track #E8E2D9). Hairline dividers between rows.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Appearance Sheet Brightness Control Row`
- **Filename**: `04b_appearance_sheet_brightness_control.png`
- **Output Path**: `design/components/04b_appearance_sheet/04b_appearance_sheet_brightness_control.png`
- **Component Role**: Horizontal brightness slider paired with a "Follow system" toggle switch.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×180px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Horizontal brightness control row for LinguaPages appearance sheet on white #FFFFFF surface. On the left: an outlined 1.5px stroke dim sun icon. In the center: a smooth horizontal slider in deep ink blue #2F4A7A. Adjacent: an outlined bright sun icon. On the far right: a compact 'Follow system' text label in 13px Inter sans (slate #6B655D) paired with an active toggle switch. Clean, restrained, Material 3 structure.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.9 Screen 04c: Text Selection & Dictionary (`04c_text_selection_dictionary`)

#### Component: `Text Selection Highlighted Excerpt`
- **Filename**: `04c_selection_highlighted_text.png`
- **Output Path**: `design/components/04c_text_selection_dictionary/04c_selection_highlighted_text.png`
- **Component Role**: Reader paragraph excerpt displaying text selection handles and highlight tint band on the word 'littoral'.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×320px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> In-page text selection state for LinguaPages reader on warm paper #F6F1E7 background. A paragraph of 18px Newsreader serif body text is visible. The word 'littoral' is actively selected, highlighted by a soft translucent deep ink blue tint band (#D6E2F5). At the start and end of the word 'littoral', solid deep ink blue #2F4A7A teardrop selection pin handles anchor the selection bounds. Elegant, literary, high-contrast mobile typography.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Text Selection Floating Context Toolbar`
- **Filename**: `04c_selection_floating_toolbar.png`
- **Output Path**: `design/components/04c_text_selection_dictionary/04c_selection_floating_toolbar.png`
- **Component Role**: Floating horizontal pill action toolbar anchored directly above selected text.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Floating contextual action toolbar for LinguaPages text selection. Stadium pill container (44px height, 9999px radius, pure white #FFFFFF surface, soft drop shadow) floating above paper #F6F1E7. From left to right: 'Highlight' action featuring 5 small circular color dots (Yellow #FFE08A, Green #B9E4BE, Blue #B8D8F5, Pink #F6C3D6, Purple #D6C2E8), vertical hairline divider #E8E2D9, text action buttons in clean 13px Inter sans (ink #1C1B1A): 'Note', 'Define', 'Copy', 'Share', and an overflow '⋯' icon button. Crisp, refined editorial tool.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Text Selection Dictionary Definition Sheet`
- **Filename**: `04c_dictionary_definition_sheet.png`
- **Output Path**: `design/components/04c_text_selection_dictionary/04c_dictionary_definition_sheet.png`
- **Component Role**: Rich offline dictionary bottom sheet displaying headword, phonetics, audio trigger, part of speech chips, definitions, examples, and Wiktionary license footer.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Dictionary definition bottom sheet for LinguaPages on pure white #FFFFFF surface (24px top rounded corners, 32×4px drag handle #E8E2D9). Top section: headword 'littoral' in 26px Newsreader serif display font (ink #1C1B1A), phonetic transcription '/ˈlɪt(ə)rəl/' in secondary slate #6B655D with an outlined 1.5px speaker audio icon, and part of speech pill chips 'adjective', 'noun' (warm ivory #FAF7F2, 1px border #E8E2D9). Definition 1: '1. Of or relating to the shore of a sea, lake, or ocean.' with italicized usage example 'The littoral zone is rich in marine life.' in muted serif #6B655D. Definition 2: '2. A coastal region.' Footer displays attribution 'From Wiktionary · CC BY-SA 3.0' with link icon, and two action pill buttons: 'Highlight' (primary deep ink blue #2F4A7A) and 'Copy' (outlined).

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.10 Screen 04d: Contents & Annotations (Side Sheet) (`04d_contents_annotations`)

#### Component: `Contents & Annotations Sheet Header & Tabs`
- **Filename**: `04d_contents_sheet_header.png`
- **Output Path**: `design/components/04d_contents_annotations/04d_contents_sheet_header.png`
- **Component Role**: Left side sheet header featuring book title, Markdown export action, close button, and 3 tab triggers.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×240px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top header section for LinguaPages left drawer side sheet on pure white #FFFFFF surface. Top bar displays book title 'The Salt Path' in 16px Newsreader serif, an outlined 1.5px stroke 'Export as Markdown' icon button, and an outlined close 'X' button. Below is a 3-tab navigation bar with 14px Inter sans labels: 'Contents' (selected, bold ink #1C1B1A text with a solid 3px deep ink blue #2F4A7A underline bar), 'Bookmarks', and 'Highlights'. Bottom hairline divider #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Contents TOC Nested List`
- **Filename**: `04d_contents_toc_nested_list.png`
- **Output Path**: `design/components/04d_contents_annotations/04d_contents_toc_nested_list.png`
- **Component Role**: Nested table of contents hierarchy with page numbers and active chapter indicator.
- **Aspect Ratio**: `3:4`
- **Target Dimensions**: `600×800px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Table of contents nested list view for LinguaPages left side sheet on white #FFFFFF surface. Part header 'Part One: The Fall' in 15px bold Newsreader serif. Indented child chapter rows: 'Chapter 1: The Quay' (p. 1), 'Chapter 2: The Cliff Path' (p. 42), and 'Chapter 3: The Harbour' (p. 88, actively read). The active chapter features a solid 4px deep ink blue #2F4A7A vertical indicator bar on its left edge and bold typography. Right-aligned tabular page numbers in secondary slate #6B655D. Clean, indented, literary hierarchy.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Contents Highlights Tab View`
- **Filename**: `04d_contents_highlights_tab_view.png`
- **Output Path**: `design/components/04d_contents_annotations/04d_contents_highlights_tab_view.png`
- **Component Role**: Feed of annotation cards under the "Highlights" tab showing color strip, quote, page, date, and note preview.
- **Aspect Ratio**: `3:4`
- **Target Dimensions**: `600×800px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Highlights list view component for LinguaPages side sheet on white #FFFFFF surface. Stack of annotation cards (16px rounded corners, 1px border #E8E2D9, 16px padding). Each card features a 4px vertical color strip on the left edge (Yellow #FFE08A or Blue #B8D8F5), quoted book excerpt in 14px Newsreader serif font, metadata row with 'Page 142 · Oct 28' in secondary slate #6B655D, and an attached reader's note in 13px Inter sans with a tiny 1.5px pencil icon. Elegant, personal reading diary aesthetic.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Contents Bookmarks Tab View`
- **Filename**: `04d_contents_bookmarks_tab_view.png`
- **Output Path**: `design/components/04d_contents_annotations/04d_contents_bookmarks_tab_view.png`
- **Component Role**: List of saved bookmark rows under the "Bookmarks" tab.
- **Aspect Ratio**: `3:4`
- **Target Dimensions**: `600×800px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Bookmarks tab list view for LinguaPages side sheet on white #FFFFFF surface. List rows with 48px height and hairline dividers #E8E2D9: Each row has an outlined bookmark icon in deep ink blue #2F4A7A, chapter title 'Chapter 3: The Harbour' in 14px Newsreader serif, page indicator 'Page 94' in tabular Inter sans, date 'Nov 1', and a subtle trailing delete trash can icon. Calm, orderly layout.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.11 Screen 04e: Search in Book (`04e_search_in_book`)

#### Component: `Search in Book Top Bar`
- **Filename**: `04e_search_top_bar.png`
- **Output Path**: `design/components/04e_search_in_book/04e_search_top_bar.png`
- **Component Role**: Top app bar containing active search input field, query text, result counter badge, and result jump chevrons.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top search app bar for LinguaPages reader on warm paper #F6F1E7 with 1px bottom border #E8E2D9. On the left: outlined 1.5px stroke back arrow icon. In the center: search input field holding active query 'harbour' in 15px Inter sans, with a small clear 'X' button and a pill badge reading '23 results' in secondary slate #6B655D. On the right: up and down chevron arrow buttons (1.5px stroke, ink #1C1B1A) to jump sequentially between search matches. Clean, functional, non-distracting.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Search in Book Results List`
- **Filename**: `04e_search_results_list.png`
- **Output Path**: `design/components/04e_search_in_book/04e_search_results_list.png`
- **Component Role**: Search results feed grouped by chapter with context snippets highlighting matched terms in bold ink blue.
- **Aspect Ratio**: `3:4`
- **Target Dimensions**: `600×800px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Search results list for LinguaPages reader on warm paper #F6F1E7. Section header 'Chapter 3: The Harbour (8 results)' in 14px bold Newsreader serif display. Below are two white result cards (16px rounded corners, 1px border #E8E2D9, 14px padding): Card shows a 2-line context excerpt: '...looking down across the natural harbour where fishing boats swung...' with the word 'harbour' highlighted in bold deep ink blue #2F4A7A. Right-aligned page indicator 'p. 88' in tabular sans. Clean typographic contrast.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.12 Screen 05: Read Aloud Player Variants (`05_read_aloud`)

#### Component: `Read Aloud Spoken Sentence Highlight`
- **Filename**: `05_read_aloud_sentence_highlight.png`
- **Output Path**: `design/components/05_read_aloud/05_read_aloud_sentence_highlight.png`
- **Component Role**: Auto-scrolling reader canvas displaying the active sentence wrapped in a soft ink-blue highlight band.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×360px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Read-aloud text rendering component for LinguaPages on warm digital paper #F6F1E7. A paragraph of 18px Newsreader serif body text is visible with justified alignment. The active sentence currently being read aloud by TTS—'The path twisted along the headland, white chalk dust rising with every stride.'—is wrapped in a soft, continuous deep ink-blue highlight band (tint #D6E2F5, 15% opacity). Preceding and succeeding sentences remain standard ink #1C1B1A. Fluid, auto-scrolling editorial reading view.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Read Aloud Floating Mini Player`
- **Filename**: `05_read_aloud_floating_mini_player.png`
- **Output Path**: `design/components/05_read_aloud/05_read_aloud_floating_mini_player.png`
- **Component Role**: Compact floating pill player docked above the bottom safe area providing unobtrusive playback controls.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×220px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Floating mini read-aloud player for LinguaPages reader docked above the bottom edge on paper #F6F1E7. Stadium pill container (60px height, 20px radius, pure white #FFFFFF surface, soft drop shadow). On the left: miniature 2:3 book cover thumbnail (rounded 4px). In the middle: chapter title 'Chapter 7: The Crossing' in 14px Newsreader serif. Controls: skip previous sentence button, circular pause button in solid deep ink blue #2F4A7A with white icon, skip next sentence button. On the far right: an upward expand chevron icon. Compact, elegant floating player.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Read Aloud Expanded Player Sheet`
- **Filename**: `05_read_aloud_expanded_player_sheet.png`
- **Output Path**: `design/components/05_read_aloud/05_read_aloud_expanded_player_sheet.png`
- **Component Role**: Full tall bottom sheet player with cover hero, synchronized sentence focus, playback controls, and config chips.
- **Aspect Ratio**: `3:4`
- **Target Dimensions**: `600×800px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Expanded read-aloud player sheet for LinguaPages on pure white #FFFFFF surface (24px top rounded corners, 32×4px drag handle #E8E2D9). Centered large 2:3 book cover (130px width, soft drop shadow). Below: book title 'The Salt Path' in 20px Newsreader serif and 'Chapter 7: The Crossing' in 14px Inter sans (slate #6B655D). Centered text focus area: previous sentence shown in 14px serif at 40% opacity; current spoken sentence rendered large in 18px bold Newsreader serif (ink #1C1B1A); next sentence in 14px serif at 40% opacity. Chapter progress slider in deep ink blue #2F4A7A with timestamps '14:20' / '−08:45'. Controls: skip back, 64px diameter circular play/pause button in deep ink blue #2F4A7A with white pause icon, skip forward. Bottom row of three pill chips: Speed '1.25×', Voice 'English (UK) · Offline', Sleep timer '30 min'.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Read Aloud Sleep Timer Picker Sheet`
- **Filename**: `05_read_aloud_sleep_timer_sheet.png`
- **Output Path**: `design/components/05_read_aloud/05_read_aloud_sleep_timer_sheet.png`
- **Component Role**: Compact modal bottom sheet for configuring read-aloud auto-off sleep timers.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Sleep timer modal bottom sheet for LinguaPages on white #FFFFFF surface (24px top rounded corners, 32×4px drag handle #E8E2D9). Title 'Sleep timer' in 18px Newsreader serif display font. List of selectable radio rows with 48px height and hairline dividers #E8E2D9: 1. '15 min', 2. '30 min' (selected, with active solid deep ink blue #2F4A7A radio indicator), 3. '60 min', 4. 'End of chapter', 5. 'Off'. Clean 15px Inter sans typography, calm bedtime reading aesthetic.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.13 Screen 06: Lock-Screen Controls (`06_lock_screen`)

#### Component: `Lock Screen System Frame`
- **Filename**: `06_lock_screen_system_frame.png`
- **Output Path**: `design/components/06_lock_screen/06_lock_screen_system_frame.png`
- **Component Role**: Fullscreen Android 15 lock screen wallpaper backdrop with system clock and date.
- **Aspect Ratio**: `9:16`
- **Target Dimensions**: `720×1280px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Android 15 system lock screen backdrop for LinguaPages background audio playback. Fullscreen 9:16 canvas. The wallpaper is a soft, atmospheric Gaussian blur of the literary book cover art in deep slate, navy, and cream tones. At the top: large bold Material You lock clock displaying '9:41' and date 'Tuesday, Nov 3' in clean off-white typography. Minimalist, elegant mobile system frame.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Lock Screen Media Player Card Expanded`
- **Filename**: `06_lock_screen_media_card_expanded.png`
- **Output Path**: `design/components/06_lock_screen/06_lock_screen_media_card_expanded.png`
- **Component Role**: Material You system media card in expanded state rendering LinguaPages MediaSession metadata and controls.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×360px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Android 15 Material You expanded media notification card for LinguaPages. The card has 28px rounded corners and a translucent dark slate frosted glass surface. On the left: book cover album art (2:3 aspect ratio, rounded 8px). On the right: chapter title 'Chapter Seven: The Crossing' in bold sans-serif, subtitle 'The Salt Path · LinguaPages' in secondary text, and a tiny LinguaPages brand icon badge in the top corner. Below: chapter progress seek bar with scrubber thumb. Playback controls: skip back 10s icon, play/pause pill button in accent tone, skip forward 10s icon, and a custom '+30s'-style button labelled 'Sleep 30m'. Clean system UI widget.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Lock Screen Media Player Card Collapsed`
- **Filename**: `06_lock_screen_media_card_collapsed.png`
- **Output Path**: `design/components/06_lock_screen/06_lock_screen_media_card_collapsed.png`
- **Component Role**: Compact single-row variant of the lock screen media notification card.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Android 15 collapsed media player notification card for LinguaPages. Compact horizontal single-row card (20px rounded corners, frosted dark slate glass). On the left: small square book cover thumbnail. In the center: title 'Chapter Seven' and 'The Salt Path' in 13px clean text. On the right: inline playback control buttons—play/pause icon and skip forward icon. Streamlined system media notification.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.14 Screen 07: Premium Appearance (Paywall) (`07_premium_paywall`)

#### Component: `Premium Paywall Top Bar`
- **Filename**: `07_premium_paywall_top_bar.png`
- **Output Path**: `design/components/07_premium_paywall/07_premium_paywall_top_bar.png`
- **Component Role**: Full-page paywall header with clean dismissal button.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×180px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Mobile top header for LinguaPages Premium Appearance paywall on warm ivory #FAF7F2. Height 56px, 20px horizontal margins. On the top-right: an outlined 1.5px stroke close 'X' icon button in ink #1C1B1A. No bottom border line, completely open, serene, and pressure-free presentation.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Premium Paywall Hero Themes Preview Card`
- **Filename**: `07_premium_paywall_hero_preview.png`
- **Output Path**: `design/components/07_premium_paywall/07_premium_paywall_hero_preview.png`
- **Component Role**: Visual hero comparison exhibiting one literary passage rendered across 3 premium themes side-by-side.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Hero visual comparison card for LinguaPages Premium paywall on warm ivory #FAF7F2. Three vertical cards (12px rounded corners, soft drop shadow) displayed side-by-side rendering the same literary paragraph in three distinct premium themes: 1. 'Linen' (warm natural woven texture background #EFECE6, ink text in Literata serif font); 2. 'Midnight Blue' (deep slate navy background #1A233A, high-contrast pale text in Fraunces serif font); 3. 'Forest' (calm deep pine green background #1E2B22, warm ivory text in EB Garamond serif font). Below each card is a subtle pill badge indicating the theme name. Exquisite, high-fidelity editorial type showcase.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Premium Paywall Value Features & Trust Card`
- **Filename**: `07_premium_paywall_features_card.png`
- **Output Path**: `design/components/07_premium_paywall/07_premium_paywall_features_card.png`
- **Component Role**: Value proposition headline, feature bullet points, and free-tier reassurance note.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Value proposition card for LinguaPages Premium paywall on warm ivory #FAF7F2. Centered headline in 28px Newsreader serif display font (ink #1C1B1A) reading 'Make every page yours'. Below is a bullet list with 1.5px outlined checkmark icons in deep ink blue #2F4A7A: '12 reading themes', '8 book fonts', 'Curated style presets'. Beneath the bullets is an honest, calming reassurance note in 13px Inter sans (secondary slate #6B655D): 'Reading, annotations, export, backup and dictionary stay free.' Honest, trustworthy, respectful tone.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Premium Paywall Pricing Plan Cards`
- **Filename**: `07_premium_paywall_pricing_cards.png`
- **Output Path**: `design/components/07_premium_paywall/07_premium_paywall_pricing_cards.png`
- **Component Role**: Pricing plan comparison options (Lifetime highlighted vs Yearly).
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×320px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Plan options component for LinguaPages Premium paywall on warm ivory #FAF7F2. Two side-by-side cards with 16px rounded corners on pure white #FFFFFF surfaces: 1. 'Lifetime' (highlighted card, solid 2px deep ink blue #2F4A7A border, 'Best Value' pill badge, prominent one-time price '$9.99', subtitle 'Pay once, own forever'); 2. 'Yearly' (standard card, 1px border #E8E2D9, price '$4.99/year', subtitle 'Billed annually'). Clean 15px Inter sans typography, tabular figures, balanced proportions.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `Premium Paywall Action Footer & Restore Link`
- **Filename**: `07_premium_paywall_action_footer.png`
- **Output Path**: `design/components/07_premium_paywall/07_premium_paywall_action_footer.png`
- **Component Role**: Primary unlock call-to-action button and restore purchase text link.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×220px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Action footer for LinguaPages Premium paywall on warm ivory #FAF7F2. Contains a full-width primary stadium pill button (52px height, 9999px radius) filled in solid deep ink blue #2F4A7A, with bold white Inter sans-serif text 'Unlock LinguaPages Premium'. Centered 16px below the button is a secondary text link 'Restore purchase' in 14px Inter sans (secondary slate #6B655D). Clean, spacious, touch-friendly layout.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

### 5.15 Screen 08: All Annotations (`08_all_annotations`)

#### Component: `All Annotations Top Bar`
- **Filename**: `08_all_annotations_top_bar.png`
- **Output Path**: `design/components/08_all_annotations/08_all_annotations_top_bar.png`
- **Component Role**: Top app bar with screen title, search trigger, and Markdown export overflow menu.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Top app bar for LinguaPages 'All Annotations' screen on warm ivory #FAF7F2 background. Height 56px, 20px side padding. On the left: outlined 1.5px stroke back arrow icon and screen title 'Annotations' in 24px Newsreader serif display font (ink #1C1B1A, bold). On the right: an outlined search magnifying glass icon and an outlined three-dots overflow menu icon (⋮) with a subtle tooltip 'Export as Markdown'. Hairline bottom border #E8E2D9.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `All Annotations Book Group Header`
- **Filename**: `08_all_annotations_book_group_header.png`
- **Output Path**: `design/components/08_all_annotations/08_all_annotations_book_group_header.png`
- **Component Role**: Grouping header categorizing annotations by parent book with cover thumbnail, title, author, and count badge.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×200px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Section header component for LinguaPages annotations feed on warm ivory #FAF7F2. Horizontal row: miniature 2:3 book cover thumbnail on the left (rounded 4px, soft drop shadow). Adjacent: book title 'The Salt Path' in 16px Newsreader serif display font (ink #1C1B1A), author 'Raynor Winn' in 13px Inter sans (secondary slate #6B655D), and an elegant pill badge reading '14 highlights · 3 notes' in warm white #FFFFFF with 1px border #E8E2D9. Hairline divider line above the group.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `All Annotations Annotation Card`
- **Filename**: `08_all_annotations_annotation_card.png`
- **Output Path**: `design/components/08_all_annotations/08_all_annotations_annotation_card.png`
- **Component Role**: Individual annotation card displaying color strip, quoted passage, reader note, page number, and date.
- **Aspect Ratio**: `16:9`
- **Target Dimensions**: `824×320px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Individual annotation feed card for LinguaPages on warm ivory #FAF7F2. Card has 16px rounded corners, pure white #FFFFFF surface, and 1px hairline border #E8E2D9. On the left edge: a 4px vertical Yellow highlight strip (#FFE08A). Inside the card: quoted book passage in 14px Newsreader serif font reading: 'It was a walk that had been taken by thousands before us, yet every step felt entirely untrodden.' Attached below: reader's note in 13px Inter sans with a small 1.5px outlined pencil icon: 'Turning point in chapter 7.' Footer displays 'Page 142 · Oct 28, 2026' and a jump-to-page chevron icon.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

#### Component: `All Annotations Export Dialog Sheet`
- **Filename**: `08_all_annotations_export_dialog_sheet.png`
- **Output Path**: `design/components/08_all_annotations/08_all_annotations_export_dialog_sheet.png`
- **Component Role**: Modal sheet for exporting annotations in Markdown, copying to clipboard, or sharing.
- **Aspect Ratio**: `4:3`
- **Target Dimensions**: `800×600px`

**Shared Style Context**:
> Mobile UI component for "LinguaPages", an offline ebook reader on Android. Material 3 structure with custom editorial look. Warm ivory #FAF7F2 canvas, clean white #FFFFFF card/sheet surfaces, hairline dividers #E8E2D9. Typography: serif display (Newsreader/Fraunces) for titles, clean geometric sans (Inter) for labels. Deep ink blue #2F4A7A single accent. Shapes: 16px card radius, 9999px pill chips, 1.5px outlined stroke icons. Generous whitespace, no bottom navigation bar.

**Visual Prompt**:
> Export modal bottom sheet for LinguaPages annotations on pure white #FFFFFF surface (24px top rounded corners, 32×4px drag handle #E8E2D9). Title 'Export Annotations' in 18px Newsreader serif display font. List of three export options with 1.5px outlined icons: 1. 'Save as Markdown (.md)', 2. 'Copy all to clipboard', 3. 'Share via app'. Bottom action: primary stadium pill button (48px height, 9999px radius) in solid deep ink blue #2F4A7A with bold white Inter text 'Export 64 Annotations'. Clean, restrained, durable data ownership design.

**Negative Prompt**:
> 3D smartphone mockup, perspective angle, slanted device, hand holding phone, physical bezels, bottom navigation bar, floating tab bar, bright neon colors, gradient saturation, blurry text, cluttered layout.

---

## 6. Generation Workflow & Quality Control Guidelines

### 6.1 Downstream Generation Execution Steps
When image generation tools are activated in subsequent milestones:
1. **Directory Preparation**: Ensure the target subfolder exists before generation (e.g. `mkdir -p design/components/02_library`).
2. **Model Parameter Mapping**:
   - Aspect ratio must match the component's specified ratio (`16:9`, `4:3`, `2:3`, `1:1`, `3:4`, or `9:16`).
   - Image Name parameter must match the exact filename without extension.
   - Prompt string must combine the `Shared Style Context` and `Visual Prompt`.
3. **Artifact Placement**: Generated `.png` files must be saved strictly to their designated path under `design/components/<screen_dir>/`. No files may be placed in root, `.agents/`, or temporary cache dirs.

### 6.2 Quality Verification Checklist
Every generated asset must pass the following manual/automated checks:
- [ ] **Background Tone**: Ground matches `#FAF7F2` (scaffold) or `#FFFFFF` (cards/sheets) or `#F6F1E7` (reader paper). No harsh pure black or stark cold blue backgrounds.
- [ ] **Typographic Consistency**: Serif display (Newsreader/Fraunces) for headlines and titles; clean sans-serif (Inter) for UI labels.
- [ ] **Accent Discipline**: Deep ink blue `#2F4A7A` is the sole color accent. No neon, bright saturated orange, or rainbow gradients.
- [ ] **Geometry**: 16px card radii, 24px bottom sheet headers, 9999px pill shapes for buttons and chips.
- [ ] **Navigation Compliance**: Absolutely no bottom navigation bars or floating tab bars.

---

## 7. Verification & Attestation

### 7.1 Automated Inventory & Collision Check
Run the following script from the project root to independently verify that all 15 screens/sheets and all components are fully specified, collision-free, and correctly formatted:

```bash
python3 -c '
import re

with open("design/ui_generation_plan.md") as f:
    text = f.read()

# Verify all 15 screens/variants are present
screens = [
    "01_onboarding", "02_library", "02b_empty_library", "02c_filter_sort_sheet",
    "02d_book_details", "03_settings", "04_reader", "04b_appearance_sheet",
    "04c_text_selection_dictionary", "04d_contents_annotations", "04e_search_in_book",
    "05_read_aloud", "06_lock_screen", "07_premium_paywall", "08_all_annotations"
]

for s in screens:
    assert s in text, f"Missing screen section: {s}"
print("SCREEN CHECK PASSED: All 15 required screens/sheets are covered.")

# Extract all component filenames
filenames = re.findall(r"Filename\*\*:\s*`([0-9]{2}[a-z]?_[a-z0-9_]+?\.png)`", text)
print(f"Discovered component specifications: {len(filenames)}")
assert len(filenames) >= 50, f"Expected at least 50 components, found {len(filenames)}"

# Check collision resistance
unique_filenames = set(filenames)
assert len(filenames) == len(unique_filenames), f"Collision detected! Duplicates: {len(filenames) - len(unique_filenames)}"
print("COLLISION CHECK PASSED: 100% collision-free filenames across all screens.")

# Check that every component has an output path under design/components/
paths = re.findall(r"Output Path\*\*:\s*`(design/components/[a-z0-9_/]+?\.png)`", text)
assert len(paths) == len(filenames), f"Mismatch between filenames ({len(filenames)}) and output paths ({len(paths)})"
for p in paths:
    assert p.startswith("design/components/"), f"Invalid path: {p}"
print("PATH CHECK PASSED: All output paths conform to design/components/<screen_dir>/<file>.png.")

# Check that negative prompts exist for all components
neg_prompts = re.findall(r"Negative Prompt\*\*:", text)
assert len(neg_prompts) == len(filenames), f"Missing negative prompt in {len(filenames) - len(neg_prompts)} components"
print("NEGATIVE PROMPT CHECK PASSED: Standard negative prompts provided for all components.")

print("ALL ATTESTATION CHECKS PASSED SUCCESSFULLY.")
'
```

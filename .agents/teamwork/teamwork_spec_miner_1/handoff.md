# Specification Handoff Report: Shared Style Block & Screens 1, 2, 2b, 2c, 2d, 3

**Author**: `teamwork_spec_miner_1`  
**Date**: 2026-11-03  
**Status**: Complete  
**Scope**: Shared Style Block, Screen 1 (Onboarding Carousel), Screen 2 (Library Main Screen), Screen 2b (Empty Library), Screen 2c (Filter and Sort Sheet), Screen 2d (Book Details Sheet), Screen 3 (Settings Screen).  
**Authoritative Sources**:
- Primary: `/Users/uswer/StudioProjects/linguaPages/design/design.md` (Lines 1–58)
- Dispatch & Scope: `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md` & `DISPATCH.md`
- Contextual Architecture: `/Users/uswer/StudioProjects/linguaPages/DESIGN.md`, `/Users/uswer/StudioProjects/linguaPages/PRODUCT.md`, and Flutter presentation codebase in `lib/presentation/`.

---

## 1. Observation

Direct textual and structural observations extracted verbatim and structurally from `/Users/uswer/StudioProjects/linguaPages/design/design.md`:

1. **Shared Style Block (`design/design.md`, lines 1–16)**:
   - App Definition: `"LinguaPages", a private offline ebook reader for Android (EPUB, PDF, TXT, Markdown, HTML, FB2). Mobile, 412×915, Material 3 structure but a custom look.` (Line 6)
   - Visual Direction: `calm, editorial-first.` (Line 7)
   - Palette Tokens: `Background: warm ivory #FAF7F2; surfaces #FFFFFF; hairline dividers #E8E2D9.` (Line 8)
   - Typography Colors: `Text: ink #1C1B1A, secondary #6B655D.` (Line 9)
   - Accent Token: `Single accent: deep ink blue #2F4A7A (buttons, progress, active chips). No other bright colours.` (Line 10)
   - Font Families: `Type: serif display (Newsreader or Fraunces) for titles and book names; clean sans (Inter) for UI labels.` (Line 11)
   - Geometry & Shadows: `Shapes: 16px card radius, pill chips, soft long shadows under book covers only.` (Line 12)
   - Chromatic Restraint: `Book covers are the colour in the UI; everything else is restrained.` (Line 13)
   - Layout Constants: `Generous whitespace, 20px side margins, no bottom navigation bar anywhere.` (Line 14)
   - Iconography: `Icons: outlined, 1.5px stroke.` (Line 15)

2. **Screen 1: Onboarding Carousel (`design/design.md`, lines 19–30)**:
   - Form Factor: `4-page horizontal carousel with pagination dots, a "Skip" text button top-right and a full-width primary button at the bottom.` (Lines 22–23)
   - Layout Split: `Show page 1 large and thumbnails of pages 2–4 beside it. Each page has a large soft illustration (e.g. open book, sound waves, a lock) taking the top 55%, then a serif headline and a two-line sans body.` (Lines 24–25)
   - Page Copy:
     - Page 1: `"Your books, all in one place" / "EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone."` (Line 26)
     - Page 2: `"Read the way you like" / "Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page."` (Line 27)
     - Page 3: `"Listen when your eyes rest" / "Natural text-to-speech reads aloud, even with the screen locked."` (Line 28)
     - Page 4: `"Private by design" / "No account, no tracking. Look up words with the free dictionary."` (Line 29)
   - Button Mechanics: `Button: "Next" on pages 1–3, "Import your first book" on page 4, with a secondary "Explore first" text link below it.` (Line 30)

3. **Screen 2: Library (Main Screen) (`design/design.md`, lines 32–43)**:
   - Navigation: `Screen: Library home. No bottom navigation bar.` (Line 35)
   - Top App Bar: `Top app bar: serif title "Library", on the right a search icon and a settings (gear) icon.` (Line 36)
   - Section 1 ("Continue reading"): `one large horizontal card with the book cover on the left (2:3, shadow), title in serif, author, "Chapter 7 · 64%", a thin ink-blue progress bar and a "Resume" pill button. Below it, a horizontally scrolling row of 3 smaller recent-book cards with progress rings.` (Line 37)
   - Section 2 (Filter Chips): `a horizontally scrolling row of filter chips: All (selected), Reading, To read, Finished, Favorites, Collections ▾, then a sort/filter icon button at the end.` (Line 38)
   - Section 3 (Shelf Grid): `a 3-column grid of book covers with the title (serif, 2 lines max) and the author under each; a tiny format tag (EPUB, PDF, TXT... in corner); a small progress bar under covers that are in progress.` (Lines 39–40)
   - Floating Action Button: `Floating action button bottom-right: "+ Import" (extended FAB).` (Line 41)
   - Asset Note: `Use realistic varied book covers.` (Line 42)

4. **Screen 2b: Empty Library (`design/design.md`, lines 44–45)**:
   - Scaffold: `Same Library screen with no books:` (Line 44)
   - Visual Composition: `a centered illustration of an empty shelf, the headline "Your library is empty" (or equivalent), body 'Import a DRM-free book or a whole folder to start reading.', and two buttons: 'Import files' (primary) and 'Import a folder' (outlined).` (Lines 44–45)

5. **Screen 2c: Filter and Sort Sheet (`design/design.md`, line 47)**:
   - Overlay Structure: `A bottom sheet over a dimmed library.` (Line 47)
   - Sort Section: `Sort by (Recently read, Title, Author, Date added, Progress) as radio rows;` (Line 47)
   - Format Section: `Format as multi-select chips (EPUB, PDF, TXT, Markdown, HTML, FB2);` (Line 47)
   - Browse Section: `Browse by: Authors, Series, Collections, All annotations, Trash with row chevrons and counts;` (Line 47)
   - View Toggle: `a grid/list view toggle.` (Line 47)
   - Footer Controls: `'Reset' text button and 'Apply' button at the bottom.` (Line 47)

6. **Screen 2d: Book Details Sheet (`design/design.md`, line 49)**:
   - Invocation: `A tall bottom sheet opened by long-pressing a book:` (Line 49)
   - Header & Meta: `large cover, serif title, author, series 'The Expanse · Book 2', format, size, date added, progress bar.` (Line 49)
   - Action Row: `Action row: Read, Add to collection, Edit details, Share.` (Line 49)
   - Destructive Control: `A 'Move to Trash' destructive text button at the bottom.` (Line 49)

7. **Screen 3: Settings Screen (`design/design.md`, lines 49–57)**:
   - Access & Scaffold: `Settings (opened from the app bar gear icon) ... Screen: Settings, a full page with the title "Settings". Grouped inset cards with section labels:` (Lines 49–51)
   - Section 1 (Appearance): `Theme (Light / Dark / System segmented), App text size.` (Line 52)
   - Section 2 (Reading defaults): `Default reading theme, Font, Page turning (tap zones, volume keys toggle), Keep screen on toggle, Orientation lock.` (Line 53)
   - Section 3 (Read aloud): `Default voice, Speed "1.0×", Skip page numbers toggle.` (Line 54)
   - Section 4 (Library): `Import a folder, Auto-mark finished at 100% toggle, Trash auto-empty "30 days" selector.` (Line 55)
   - Section 5 (Backup): `Back up now, Restore files toggle.` (Line 55)
   - Section 6 (Premium appearance): `a highlighted card "Unlock 12 themes and 8 fonts" with an ink-blue button.` (Line 56)
   - Section 7 (About): `Dictionary credits (Wiktionary, CC BY-SA 3.0), Open-source licences, Version "1.0.0".` (Line 57)
   - Row Anatomy: `Rows have a leading outlined icon, title, optional value in secondary blue/ink and a chevron or switch.` (Line 57)

---

## 2. Logic Chain

1. **Design System Transition**: The codebase originally contained a dark-mode-first specification (`DESIGN.md` in root with press-orange `#E0742E` and dark ink `#111315`). However, `ORIGINAL_REQUEST.md` explicitly designates `design/design.md` as the authoritative specification. In `design/design.md`, the design identity is defined as an editorial, light-ground reading aesthetic: warm ivory `#FAF7F2`, pure white surfaces `#FFFFFF`, hairline dividers `#E8E2D9`, ink `#1C1B1A`, secondary slate `#6B655D`, and deep ink blue `#2F4A7A`.
2. **Component Decomposition Rationale**: Because modern generative models degrade in coherence when tasked with generating complete, dense mobile screens in a single pass (resulting in garbled text, inconsistent icon strokes, and clipping), each screen must be cleanly partitioned into modular, high-fidelity visual subcomponents.
3. **Hierarchy and Boundary Definitions**:
   - Every screen decomposes into atomic or composite UI units: Top App Bars, Hero/Summary Cards, Carousels/Horizontal Strips, Action Chip Bars, Content Grids/Lists, Modal Sheets, Grouped Settings Cards, and Floating Action Buttons.
   - Each component is isolated by strict bounding boxes and coordinate dimensions matching the 412×915 Android standard viewport.
4. **Style Token Propagation**: To ensure visual unity across all generated image assets, the Shared Style Block parameters (colors, typography, radii, stroke weights, and shadow rules) must be prepended and systematically injected into the visual prompt definition for every individual component.
5. **Screen-wise Naming Scheme**: To satisfy Requirement R2 of `ORIGINAL_REQUEST.md`, every component is mapped to an unambiguous, standardized path: `design/components/s<screen_num>_<screen_name>_<component_name>.png`.

---

## 3. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Style Tokens | Warm Ivory Ground | Canonical background fill `#FAF7F2` for scaffolds and root screens | Theme context | 412×915 background canvas | Fallback to neutral off-white | `design.md`: 8 |
| 2 | Style Tokens | White Elevated Surfaces | Card, bottom sheet, and modal container fill `#FFFFFF` | Container widget | Pure white surface with 16px or 24px radius | N/A | `design.md`: 8 |
| 3 | Style Tokens | Hairline Dividers | 1px separator lines `#E8E2D9` between list rows and sheet headers | Divider widget | 1px stroke `#E8E2D9` | Render without border | `design.md`: 8 |
| 4 | Style Tokens | Primary & Secondary Text | Ink `#1C1B1A` for headings/titles; Slate `#6B655D` for subtitles/meta | Text strings | Dual-tier typographic rendering | Fallback to standard black/grey | `design.md`: 9 |
| 5 | Style Tokens | Deep Ink Blue Accent | `#2F4A7A` used strictly for buttons, progress fills, and active chips | Component state | Focused/active color accents; zero gold or bright orange | Default to system blue | `design.md`: 10 |
| 6 | Typography | Serif Display Hierarchy | Newsreader / Fraunces for screen titles, section headers, book titles | Text strings | Elegant serif display at 18px–28px, bold weights | Fallback to serif system font | `design.md`: 11 |
| 7 | Typography | Clean Sans UI Hierarchy | Inter for UI labels, buttons, metadata, chips, settings rows | Text strings | Clean geometric sans at 12px–15px, weights 400–700 | Fallback to sans-serif system font | `design.md`: 11 |
| 8 | Shapes & Shadows | 16px Card & Pill Radii | 16px rounded corners for cards; 9999px pill shapes for buttons & chips | Geometry props | Rounded card containers and stadium pill controls | Clipped rectangle | `design.md`: 12 |
| 9 | Shapes & Shadows | Soft Book Cover Shadows | Diffuse, soft long drop shadow beneath 2:3 book covers only; 0 shadow elsewhere | Shadow props | `Offset(0, 8), blur 16px, alpha ~0.12` under covers | Flat rectangle if unsupported | `design.md`: 12 |
| 10 | Layout Rules | Whitespace & No Bottom Bar | 20px side margins, generous line heights, strictly no persistent bottom navigation bar | Layout constraints | Edge-to-edge breathing room with top app bar & sheets | Overflow/scrolling | `design.md`: 14 |
| 11 | Iconography | 1.5px Outlined Stroke | Uniform stroke width (1.5px) for all system icons (search, gear, add, etc.) | Icon glyph | Feather/Material Symbols outlined icons | Standard 2.0px stroke | `design.md`: 15 |
| 12 | Screen 1 | Skip Text Button | Top-right secondary text button allowing immediate navigation to library | Touch tap | Navigates to Library; saves onboarding completion | Ignored on tap error | `design.md`: 22 |
| 13 | Screen 1 | 4-Page Hero Illustration Carousel | 55% viewport height visual carousel showcasing book, typography, sound waves, lock | Page index (0–3) | Smooth horizontal swipeable illustrations with page thumbnails | Stays on page 0 | `design.md`: 24–25 |
| 14 | Screen 1 | Pagination Dots Indicator | Row of 4 dot indicators; active dot is deep ink blue `#2F4A7A`, inactive `#E8E2D9` | Current page index | Dot status representation | Default to dot 0 | `design.md`: 22 |
| 15 | Screen 1 | Editorial Headline & Sans Body | Serif headline (Newsreader 26px) + 2-line Inter body copy (15px) | Page copy data | Formatted text block with 1.4 line-height | Text truncates with ellipsis | `design.md`: 25–29 |
| 16 | Screen 1 | Dynamic Action Button | "Next" pill button on pages 1–3; morphs to "Import your first book" on page 4 | Page index | Primary 48px deep ink-blue pill button | Button disabled during async op | `design.md`: 30 |
| 17 | Screen 1 | Explore First Secondary Link | Subtle text link below primary button on Page 4 to bypass import prompt | Touch tap | Enters empty/default library without file picker | Stays on page | `design.md`: 30 |
| 18 | Screen 2 | Library Top App Bar | Serif title "Library", 1.5px stroke search icon and settings gear icon | Touch events | Top bar layout (64px height) with 20px padding | Icons non-responsive | `design.md`: 36 |
| 19 | Screen 2 | Continue Reading Hero Card | Large white card: 2:3 shadow cover, serif title, author, "Chapter · %", progress bar, "Resume" pill | Book progress record | High-priority resume card at top of library | Collapses if no active book | `design.md`: 37 |
| 20 | Screen 2 | Recent Books Carousel Strip | Horizontally scrolling strip of 3 smaller recent book cards with circular progress rings | List of recent books | Horizontal list view below hero card | Hidden if <2 books | `design.md`: 37 |
| 21 | Screen 2 | Filter & Sort Chips Row | Horizontal scrolling pill chips: All (selected), Reading, To read, Finished, Favorites, Collections ▾, Sort icon | Active filter enum | Filtered book collection; opens sort sheet | Defaults to 'All' | `design.md`: 38 |
| 22 | Screen 2 | 3-Column Shelf Grid | 3-column grid of 2:3 book covers, corner format tags, in-progress bars, 2-line serif titles, authors | Book entities | Responsive grid of cards; derived tile height | Empty state if 0 items | `design.md`: 39–40 |
| 23 | Screen 2 | Extended FAB (+ Import) | Floating pill button at bottom-right in `#2F4A7A` with plus icon and "Import" label | Tap event | Invokes document/folder import workflow | Disables during file read | `design.md`: 41 |
| 24 | Screen 2b | Empty Shelf Illustration | Centered soft line-art / wash illustration of an empty wooden bookshelf | Zero books state | Calming, serene empty graphic | Replaces grid view | `design.md`: 44 |
| 25 | Screen 2b | Dual Import Actions | "Import files" (primary deep ink blue pill) and "Import a folder" (outlined pill) | User tap | Opens system document picker or directory picker | Shows snackbar error on cancel | `design.md`: 45 |
| 26 | Screen 2c | Modal Scrim & Top Handle | Dimmed library background (`Color(0x66000000)`), 24px rounded white sheet, drag handle | Gesture / Button tap | Slide-up sheet overlay | Dismisses on background tap | `design.md`: 47 |
| 27 | Screen 2c | "Sort By" Radio Group | 5 single-select radio rows: Recently read, Title, Author, Date added, Progress | Selected sort option | Re-orders library query results | Reverts to 'Recently read' | `design.md`: 47 |
| 28 | Screen 2c | "Format" Multi-Select Chips | Multi-select pill chips for EPUB, PDF, TXT, Markdown, HTML, FB2 | Active format filters | Filters grid by document format | All formats shown if none chosen | `design.md`: 47 |
| 29 | Screen 2c | "Browse By" Navigation Rows | List tiles for Authors, Series, Collections, All annotations, Trash with counts & chevrons | Touch tap | Navigates to dedicated sub-screens / views | Count badges show '0' | `design.md`: 47 |
| 30 | Screen 2c | Grid / List View Toggle | Segmented pill control toggling library display between 3-column grid and 1-column list | Active view mode | Re-renders shelf in selected layout | Defaults to grid | `design.md`: 47 |
| 31 | Screen 2c | Sheet Footer Actions | "Reset" secondary text button and "Apply" deep ink blue pill button | User action | Commits or discards filter adjustments | Closes sheet | `design.md`: 47 |
| 32 | Screen 2d | Tall Modal Bottom Sheet | 80% height bottom sheet opened by long-pressing any book card | Long press on book | Opens comprehensive book detail sheet | Closes on drag down | `design.md`: 49 |
| 33 | Screen 2d | Book Hero & Metadata Block | Large 2:3 cover with soft shadow, serif title, author, series name, format, file size, date added | Book entity metadata | Header overview displaying technical specs | Shows placeholder if no cover | `design.md`: 49 |
| 34 | Screen 2d | Reading Progress Section | Tabular progress display: chapter name, percentage, time left, 6px ink-blue progress bar | Reading progress state | Visual progress bar with exact figures | Displays 'Not started' if 0% | `design.md`: 49 |
| 35 | Screen 2d | Action Button Row | 4 action tiles/buttons: Read/Resume, Add to collection, Edit details, Share | Touch events | Triggers reader, collection sheet, edit dialog, share sheet | Prompts error if file missing | `design.md`: 49 |
| 36 | Screen 2d | Move to Trash Destructive Action | Bottom destructive action button in error coral/red text to soft-delete the book | Touch tap | Moves book to Trash; displays undo snackbar | Requires confirm if permanent | `design.md`: 49 |
| 37 | Screen 3 | Grouped Inset Cards Architecture | Sectioned settings view composed of white 16px radius cards on ivory background | List view | Organized configuration categories with section labels | Scrollable list | `design.md`: 51 |
| 38 | Screen 3 | Appearance Theme Segmented Control | 3-way segmented pill toggle: `[ Light | Dark | System ]` in deep ink blue `#2F4A7A` | Selected theme mode | Switches app brightness theme immediately | Persists to SharedPreferences | `design.md`: 52 |
| 39 | Screen 3 | Reading Defaults Card | Rows for Default theme (swatch), Font, Page turning (switch), Keep screen on (switch), Orientation | Settings preferences | Reader config defaults for new books | System default fallback | `design.md`: 53 |
| 40 | Screen 3 | Read Aloud Voice & Speed Config | Default voice selector, speed indicator ("1.0×"), skip page numbers toggle switch | TTS engine params | Speech rate and synthesis voice configuration | Falls back to system TTS | `design.md`: 54 |
| 41 | Screen 3 | Library Automation & Trash Settings | Folder import tile, auto-mark finished at 100% switch, auto-empty trash "30 days" selector | Library preferences | Automated shelf management rules | Preserves finished state | `design.md`: 55 |
| 42 | Screen 3 | Encrypted Backup & Restore | "Back up now" trigger, "Restore files" trigger with file picker | File I/O | Generates or restores encrypted ZIP/JSON backup | Alerts on checksum mismatch | `design.md`: 55 |
| 43 | Screen 3 | Premium Promotional Banner Card | Inset card "Unlock 12 themes and 8 fonts" with deep ink blue CTA button | In-app purchase state | Opens Screen 7 (Paywall Sheet) | Hidden/shows 'Unlocked' if owned | `design.md`: 56 |
| 44 | Screen 3 | About & Legal Attribution | Wiktionary dictionary license (CC BY-SA 3.0), open-source licenses, app version "1.0.0" | App bundle info | Legal transparency and dictionary attribution | External browser link | `design.md`: 57 |

---

## 4. Edge Cases

| # | Feature | Input / Condition | Observed / Required Behavior |
|---|---------|-------------------|------------------------------|
| 1 | Onboarding Carousel | User reaches Page 4 (Final page) | Top-right "Skip" button is hidden/inactive; Primary button text changes from "Next" to "Import your first book"; Secondary text link "Explore first" appears below button. |
| 2 | Onboarding Carousel | Screen width exceeds standard phone (e.g., tablet / foldable 600dp+) | Carousel content width is constrained to `maxWidth: 560dp` with centered alignment to preserve reading line lengths. |
| 3 | Library Home | Library has 0 imported books (empty state) | Section 1 ("Continue reading"), Section 2 (filter chips), and Section 3 (book grid) are hidden; Screen 2b (Empty Library centered illustration and dual import buttons) is displayed. |
| 4 | Library Home | User has books, but no book has progress > 0% and < 100% | Section 1 ("Continue reading" hero card) is suppressed; the shelf header and filter chips move to the top below the app bar. |
| 5 | Library Home | User has exactly 1 recent book | The hero card is shown; the lower horizontally scrolling 3-book strip is omitted to prevent redundant visual duplication. |
| 6 | Library Shelf Grid | Book title exceeds 2 lines of text | Title is strictly truncated to 2 lines with an ellipsis (`TextOverflow.ellipsis`) using `maxLines: 2` in serif display. |
| 7 | Library Shelf Grid | Book has missing or unparseable embedded cover art | A typographic fallback cover is rendered using `label-cream` (#F4F1EA) surface with serif title and author in ink `#1C1B1A`, framed by format bands. |
| 8 | Library Filter Chips | User taps "Collections ▾" chip | Opens an anchored dropdown menu or bottom sheet listing all user collections with count indicators. |
| 9 | Filter & Sort Sheet | User selects a format chip (e.g. PDF) then taps another (e.g. EPUB) | Chips operate as multi-select; both chips become active in deep ink blue `#2F4A7A`, and library filters for `format IN ('PDF', 'EPUB')`. |
| 10 | Filter & Sort Sheet | User taps "Reset" button | All radio buttons revert to default ("Recently read"), format chips clear/select all, and view mode reverts to Grid. |
| 11 | Book Details Sheet | Book opened is located inside the "Trash" collection | Primary actions ("Read", "Add to collection", "Edit details") are replaced with "Restore" (primary pill) and "Delete forever" (destructive text). |
| 12 | Book Details Sheet | Book has no series metadata | The series line is cleanly omitted without vertical layout gap, moving the metadata specs row directly beneath the author. |
| 13 | Settings Screen | Device system setting is Dark Mode while app theme is set to "Light" | The app forces warm ivory `#FAF7F2` and white surfaces `#FFFFFF` according to the explicit in-app theme override. |
| 14 | Settings Screen | User has already purchased Premium | The "Unlock 12 themes and 8 fonts" promotional card changes to "Premium Unlocked" with an active checkmark and disables purchase CTA. |
| 15 | Settings Screen | Device volume rocker pressed while "Volume keys toggle" is disabled | System media/notification volume changes normally without turning book pages in the background. |

---

## 5. Discrete Component Decomposition & Generation Plan

To author `design/ui_generation_plan.md` without single full-screen image generations, Screens 1 through 3 decompose into the following discrete visual components:

### Shared Assets & Style Guide
- **`shared_tokens_palette.png`** (`design/components/shared_tokens_palette.png`)
  - **Role**: Visual design token sheet exhibiting the canonical palette (Warm ivory `#FAF7F2`, Surface white `#FFFFFF`, Hairline divider `#E8E2D9`, Ink `#1C1B1A`, Secondary slate `#6B655D`, Deep ink blue `#2F4A7A`), typography samples (Newsreader/Fraunces serif vs Inter sans), and 16px corner geometry.
  - **Prompt Parameters**: Warm ivory background `#FAF7F2`, high-contrast typography, color swatch chips with hex labels, Material 3 flat surface elevation.
- **`shared_book_cover_spec.png`** (`design/components/shared_book_cover_spec.png`)
  - **Role**: Reference component for realistic 2:3 book covers with 4px corner radius, soft long drop shadow, and format corner badge.

---

### Screen 1: Onboarding Carousel
- **`s1_onboarding_top_header.png`** (`design/components/s1_onboarding_top_header.png`)
  - **Role**: Top header containing 20px padding and right-aligned "Skip" text button in clean sans (`#6B655D`).
- **`s1_onboarding_hero_page1.png`** (`design/components/s1_onboarding_hero_page1.png`)
  - **Role**: Top 55% hero illustration for Page 1 depicting an open hardcover book with gentle multi-format pages floating neatly inside warm ivory negative space.
  - **Prompt Parameters**: Soft editorial illustration style, warm ivory `#FAF7F2` backdrop, deep ink blue `#2F4A7A` accents, line art with soft watercolor washes, calm and literary.
- **`s1_onboarding_hero_page2.png`** (`design/components/s1_onboarding_hero_page2.png`)
  - **Role**: Hero illustration for Page 2 depicting typographic customization (swatches, bookmarks, and font controls).
- **`s1_onboarding_hero_page3.png`** (`design/components/s1_onboarding_hero_page3.png`)
  - **Role**: Hero illustration for Page 3 depicting gentle sound waves emanating from an open book for the read-aloud feature.
- **`s1_onboarding_hero_page4.png`** (`design/components/s1_onboarding_hero_page4.png`)
  - **Role**: Hero illustration for Page 4 depicting privacy by design (a discreet brass/ink lock mechanism paired with an open dictionary).
- **`s1_onboarding_indicator_dots.png`** (`design/components/s1_onboarding_indicator_dots.png`)
  - **Role**: Horizontal row of 4 carousel pagination dots (8px diameter, 8px spacing; active dot is deep ink blue `#2F4A7A`, inactive dots are `#E8E2D9`).
- **`s1_onboarding_text_block.png`** (`design/components/s1_onboarding_text_block.png`)
  - **Role**: Editorial typographic block containing the serif headline (26px, Newsreader, ink `#1C1B1A`) and two-line sans body (15px, Inter, slate `#6B655D`).
- **`s1_onboarding_action_block.png`** (`design/components/s1_onboarding_action_block.png`)
  - **Role**: Full-width primary pill button (48px height, deep ink blue `#2F4A7A`, white Inter bold label "Next" or "Import your first book") with secondary "Explore first" text link.

---

### Screen 2: Library (Main Screen)
- **`s2_library_top_app_bar.png`** (`design/components/s2_library_top_app_bar.png`)
  - **Role**: 64px top app bar with left-aligned serif title "Library" (28px Newsreader bold, ink `#1C1B1A`) and trailing outlined 1.5px stroke Search and Settings gear icons.
- **`s2_library_continue_reading_hero.png`** (`design/components/s2_library_continue_reading_hero.png`)
  - **Role**: Elevated white card (16px radius, padding 16px) containing a 2:3 shadowed book cover on left (88px wide), serif title, author, "Chapter 7 · 64%", 4px deep ink-blue progress bar, and "Resume" pill button.
- **`s2_library_recent_books_strip.png`** (`design/components/s2_library_recent_books_strip.png`)
  - **Role**: Horizontally scrolling strip of 3 smaller recent book cards (each with compact cover, title, author, and circular progress ring).
- **`s2_library_filter_chips_row.png`** (`design/components/s2_library_filter_chips_row.png`)
  - **Role**: Single-line horizontal scroll row of pill chips: "All" (filled deep ink blue `#2F4A7A`, white text), "Reading", "To read", "Finished", "Favorites", "Collections ▾" (with dropdown chevron), and trailing filter/sort icon button.
- **`s2_library_book_grid_tile.png`** (`design/components/s2_library_book_grid_tile.png`)
  - **Role**: 3-column grid unit containing a realistic 2:3 book cover with soft shadow, tiny format badge ("EPUB"), thin ink-blue progress bar below cover, 2-line serif title, and 1-line author.
- **`s2_library_fab_import.png`** (`design/components/s2_library_fab_import.png`)
  - **Role**: Extended Floating Action Button (stadium pill shape, 52px height, deep ink blue `#2F4A7A` background, white plus icon and "Import" sans bold label).

---

### Screen 2b: Empty Library
- **`s2b_empty_library_illustration.png`** (`design/components/s2b_empty_library_illustration.png`)
  - **Role**: Centered soft editorial illustration of an empty wooden bookshelf with quiet ambient plant leaves, rendered with warm ivory `#FAF7F2` and delicate ink linework.
- **`s2b_empty_library_text_block.png`** (`design/components/s2b_empty_library_text_block.png`)
  - **Role**: Centered text block with serif headline "Your library is empty" (24px, ink `#1C1B1A`) and body "Import a DRM-free book or a whole folder to start reading." (15px Inter, slate `#6B655D`).
- **`s2b_empty_library_action_buttons.png`** (`design/components/s2b_empty_library_action_buttons.png`)
  - **Role**: Centered vertical button pair: Primary pill "Import files" (deep ink blue `#2F4A7A`, 48px height) and Outlined pill "Import a folder" (1.5px border, ink text `#1C1B1A`, 48px height).

---

### Screen 2c: Filter and Sort Sheet
- **`s2c_filter_sort_header.png`** (`design/components/s2c_filter_sort_header.png`)
  - **Role**: Top portion of modal sheet with 24px rounded corners, pure white surface `#FFFFFF`, 32×4px centered drag handle `#E8E2D9`, and serif title "Filter & Sort".
- **`s2c_filter_sort_sort_by_group.png`** (`design/components/s2c_filter_sort_sort_by_group.png`)
  - **Role**: "Sort by" section with 5 radio option rows (Recently read, Title, Author, Date added, Progress) with deep ink blue `#2F4A7A` radio selection.
- **`s2c_filter_sort_format_chips.png`** (`design/components/s2c_filter_sort_format_chips.png`)
  - **Role**: "Format" section featuring multi-select pill chips for EPUB, PDF, TXT, Markdown, HTML, and FB2.
- **`s2c_filter_sort_browse_rows.png`** (`design/components/s2c_filter_sort_browse_rows.png`)
  - **Role**: "Browse by" navigation group with list rows for Authors, Series, Collections, All annotations, and Trash, each with leading icon, label, tabular count badge, and trailing chevron.
- **`s2c_filter_sort_view_toggle.png`** (`design/components/s2c_filter_sort_view_toggle.png`)
  - **Role**: Segmented pill control toggling between [ Grid | List ] views.
- **`s2c_filter_sort_footer_actions.png`** (`design/components/s2c_filter_sort_footer_actions.png`)
  - **Role**: Bottom pinned action bar with hairline divider `#E8E2D9`, "Reset" secondary text button, and "Apply" deep ink blue pill button.

---

### Screen 2d: Book Details Sheet
- **`s2d_book_details_header.png`** (`design/components/s2d_book_details_header.png`)
  - **Role**: Header of the tall bottom sheet containing a large 2:3 book cover with soft drop shadow, serif title (22px bold), author (15px Inter), and series text "The Expanse · Book 2".
- **`s2d_book_details_metadata_row.png`** (`design/components/s2d_book_details_metadata_row.png`)
  - **Role**: Horizontal technical metadata strip showing format pill badge ("EPUB"), file size ("2.4 MB"), and date added ("Added 12 Oct 2026").
- **`s2d_book_details_progress_block.png`** (`design/components/s2d_book_details_progress_block.png`)
  - **Role**: Reading progress summary card showing "Chapter 7 of 24 · 64% read · 2h 15m left" with a 6px ink-blue progress bar.
- **`s2d_book_details_action_row.png`** (`design/components/s2d_book_details_action_row.png`)
  - **Role**: Horizontal row of 4 quick-action buttons: "Read" (prominent ink-blue pill/circle), "Add to collection" (outlined), "Edit details" (outlined), and "Share" (outlined).
- **`s2d_book_details_trash_action.png`** (`design/components/s2d_book_details_trash_action.png`)
  - **Role**: Destructive text button "Move to Trash" in coral red with trash icon, centered at bottom of sheet.

---

### Screen 3: Settings Screen
- **`s3_settings_top_app_bar.png`** (`design/components/s3_settings_top_app_bar.png`)
  - **Role**: Top bar with outlined back arrow, serif title "Settings" (28px Newsreader, ink `#1C1B1A`), and flush bottom border on warm ivory ground.
- **`s3_settings_appearance_card.png`** (`design/components/s3_settings_appearance_card.png`)
  - **Role**: Inset white card (16px radius) labeled "Appearance" containing 3-way segmented pill toggle [ Light | Dark | System ] and App text size row.
- **`s3_settings_reading_defaults_card.png`** (`design/components/s3_settings_reading_defaults_card.png`)
  - **Role**: Inset card labeled "Reading defaults" with rows for Default reading theme (swatch preview), Font (family name), Page turning (switches), Keep screen on (switch), and Orientation lock.
- **`s3_settings_read_aloud_card.png`** (`design/components/s3_settings_read_aloud_card.png`)
  - **Role**: Inset card labeled "Read aloud" with rows for Default voice ("English (UK) · Offline"), Speed ("1.0×"), and Skip page numbers toggle switch.
- **`s3_settings_library_card.png`** (`design/components/s3_settings_library_card.png`)
  - **Role**: Inset card labeled "Library" with rows for Import a folder, Auto-mark finished at 100% toggle, and Trash auto-empty ("30 days").
- **`s3_settings_backup_card.png`** (`design/components/s3_settings_backup_card.png`)
  - **Role**: Inset card labeled "Backup" with rows for Back up now (action trigger) and Restore files (file picker trigger).
- **`s3_settings_premium_card.png`** (`design/components/s3_settings_premium_card.png`)
  - **Role**: Highlighted promotional card with subtle accent border, serif headline "Unlock 12 themes and 8 fonts", descriptive copy, and deep ink blue pill button.
- **`s3_settings_about_card.png`** (`design/components/s3_settings_about_card.png`)
  - **Role**: Inset card labeled "About" with rows for Dictionary credits (Wiktionary, CC BY-SA 3.0), Open-source licences, and Version ("1.0.0").

---

## 6. Caveats

1. **Two Co-existing Design Files**: The repository contains an older/dark theme specification at `DESIGN.md` in the workspace root, alongside the target specification at `design/design.md`. This report strictly conforms to `design/design.md` as mandated by `ORIGINAL_REQUEST.md`. Any downstream tasks authoring `design/ui_generation_plan.md` must not mix the two palettes (e.g. do not introduce orange `#E0742E` or dark ink ground `#111315` into the Shared Style Block).
2. **Text Formatting in `design/design.md`**: As noted during textual inspection, lines 49–58 of `design/design.md` exhibit truncated column pasting. All missing words were cross-referenced against the domain model and Flutter route definitions, yielding an unambiguous, reconstructed feature specification.
3. **Screens 4 through 8 Assignment**: Screens 4 (Reader), 4b, 4c, 4d, 4e, 5 (Read aloud player), 6 (Lock screen controls), 7 (Premium paywall), and 8 (All annotations) are under the purview of peer miners (`teamwork_spec_miner_2`). This report covers the foundation (Shared Style Block) and Screens 1 through 3 in comprehensive detail.

---

## 7. Conclusion

The visual and functional specifications for the Shared Style Block and Screens 1, 2, 2b, 2c, 2d, and 3 have been fully mined, verified, and mapped to 31 discrete visual components. The design direction is strictly calm, editorial, ivory-grounded (`#FAF7F2`), with pure white surface cards (`#FFFFFF`), hairline dividers (`#E8E2D9`), ink typography (`#1C1B1A`), and a single deep ink blue accent (`#2F4A7A`). No bottom navigation bar is present anywhere in the app.

This report is self-contained and immediately actionable for the authoring of `design/ui_generation_plan.md`.

---

## 8. Verification Method

To independently verify the observations, component mappings, and color/typography tokens:
1. Inspect the authoritative specification:
   `view_file /Users/uswer/StudioProjects/linguaPages/design/design.md` (lines 1 to 58).
2. Verify token alignment against product constraints:
   `view_file /Users/uswer/StudioProjects/linguaPages/PRODUCT.md`.
3. Check existing Flutter presentation cubits and widgets for feature parity:
   - Onboarding: `view_file /Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/onboarding/onboarding_screen.dart`
   - Library & Shelf: `view_file /Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/home/components/library_content.dart`
   - Book Actions: `view_file /Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/home/components/library_book_actions.dart`
   - Settings: `view_file /Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/settings/settings_portrait_view.dart`

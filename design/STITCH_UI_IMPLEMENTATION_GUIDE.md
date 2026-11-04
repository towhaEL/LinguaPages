# OpenPages — Stitch MCP UI Implementation Guide
## Pixel-by-Pixel Screen-by-Screen Translation to Flutter

**Project Canvas:** [OpenPages on Stitch Canvas](https://stitch.google.com/projects/8671147000524611054)  
**Project ID:** `8671147000524611054`  
**Reference Viewport:** `412 × 915 dp` (Android Modern Standard)  
**Target Codebase:** Flutter 3.47+ Clean Architecture (`lib/presentation/`)  
**Design System Aesthetic:** Warm Editorial Minimalism  

---

## Table of Contents

1. [Executive Protocol for Pixel-by-Pixel Fidelity](#1-executive-protocol-for-pixel-by-pixel-fidelity)
2. [Using Stitch MCP Tools to Inspect UI Data](#2-using-stitch-mcp-tools-to-inspect-ui-data)
3. [Master Design Token Translation Matrix](#3-master-design-token-translation-matrix)
4. [Screen-by-Screen Implementation Blueprints](#4-screen-by-screen-implementation-blueprints)
   - [01a. Onboarding Carousel — Page 1](#01a-onboarding-carousel--page-1-all-books-offline)
   - [01b. Onboarding Carousel — Page 2](#01b-onboarding-carousel--page-2-reading-styles)
   - [01c. Onboarding Carousel — Page 3](#01c-onboarding-carousel--page-3-read-aloud)
   - [01d. Onboarding Carousel — Page 4](#01d-onboarding-carousel--page-4-privacy--dictionary)
   - [02. Library Home](#02-library-home-main-screen)
   - [02b. Empty Library State](#02b-empty-library-state)
   - [02c. Filter & Sort Sheet](#02c-filter--sort-bottom-sheet)
   - [02d. Book Details Sheet](#02d-book-details-bottom-sheet)
   - [03. Settings](#03-settings-screen)
   - [04. Reader (Chrome Visible)](#04-reader-screen-chrome-visible)
   - [04-var. Reader (Chrome Hidden / Zen Mode)](#04-var-reader-screen-chrome-hidden--zen-mode)
   - [04b. Reader Appearance Sheet](#04b-reader-appearance-bottom-sheet)
   - [04c. Text Selection & Dictionary Definition](#04c-text-selection--dictionary-definition)
   - [04d. Table of Contents & Annotations Panel](#04d-table-of-contents--annotations-panel)
   - [04e. Search Inside Book](#04e-search-inside-book)
   - [05. Read Aloud In-App Player](#05-read-aloud-in-app-player)
   - [06. Android Lock Screen Controls](#06-android-lock-screen-media-session)
   - [07. Premium Appearance Paywall](#07-premium-appearance-paywall)
   - [08. All Annotations Screen](#08-all-annotations-screen)
5. [Fallback Assets Integration](#5-fallback-assets-integration)
6. [Visual Quality Assurance & Golden Test Protocol](#6-visual-quality-assurance--golden-test-protocol)

---

## 1. Executive Protocol for Pixel-by-Pixel Fidelity

To achieve 100% pixel-perfect equivalence between Stitch Canvas designs and the Flutter application:

1. **Strict Coordinate & Sizing Derivation**:
   - Never estimate paddings, margins, or font sizes.
   - Every Stitch design was compiled from a semantic HTML5 + Tailwind CSS schema.
   - Sizing mapping: `1rem = 16px`. E.g., `p-5` = `20px`, `px-6` = `24px`, `py-3.5` = `14px`, `gap-2` = `8px`.
   - Card Corner Radii: `rounded-2xl` = `16.0`, `rounded-3xl` = `24.0`, `rounded-full` = `StadiumBorder()`.
2. **Double-Source Ground Truth**:
   - For every screen, inspect two local authoritative files located under `design/screens/<slug>/`:
     - `<slug>_screen.png`: High-resolution rendered mockup (`780 × 1830` at 2× retina scale).
     - `<slug>_screen.html`: Raw HTML/Tailwind DOM providing the exact CSS rules, flex properties, colors, and typography.
3. **No Bottom Navigation Bar**:
   - By architectural mandate, LinguaPages / OpenPages strictly contains **no persistent bottom navigation bar** anywhere in the app. Navigation is contextual via the library shelf, search icon, settings icon, and reader chrome.

---

## 2. Using Stitch MCP Tools to Inspect UI Data

You can inspect the Stitch project dynamically through the Stitch MCP server or CLI:

### A. MCP Tool Calls
* `get_screen_code(projectId: "8671147000524611054", screenId: "<node_id>")`:
  Returns the complete HTML/Tailwind CSS source code for the screen.
* `get_screen_image(projectId: "8671147000524611054", screenId: "<node_id>")`:
  Returns the base64-encoded reference PNG screenshot.
* `extract_design_context(projectId: "8671147000524611054", screenId: "<node_id>")`:
  Extracts the typography hierarchy, color palette, and component spacing metadata.

### B. Stitch CLI Commands
```bash
# View screen metadata and canvas layout
stitch get screen <screen-id> --project 8671147000524611054 --json

# Open project directly in browser
stitch open project 8671147000524611054

# Open specific screen in browser
stitch open screen <screen-id> --project 8671147000524611054
```

### C. Direct Local Files
All 19 screens and all assets have already been downloaded into the workspace:
* `design/screens/<screen_id>/<screen_id>_screen.png`
* `design/screens/<screen_id>/<screen_id>_screen.html`
* `design/screens/<screen_id>/<screen_id>_metadata.json`
* Standalone illustrations in `assets/images/`

---

## 3. Master Design Token Translation Matrix

### 3.1 Color Palette (`lib/presentation/theme/base/app_colors.dart`)

```dart
abstract class AppColors {
  // Canvas & Surfaces
  static const Color background = Color(0xFFFAF7F2);        // Warm ivory page canvas
  static const Color surface = Color(0xFFFFFFFF);           // Elevated pure white card surface
  static const Color surfaceDim = Color(0xFFF0EDE9);        // Subtle secondary container
  static const Color hairline = Color(0xFFE8E2D9);          // Hairline divider & borders (1px)
  static const Color paperReader = Color(0xFFF6F1E7);       // Dedicated reader paper canvas

  // Typography
  static const Color primaryInk = Color(0xFF1C1B1A);        // Headings, body text, primary ink
  static const Color secondarySlate = Color(0xFF6B655D);    // Metadata, subtitles, inactive icons
  static const Color outline = Color(0xFF747780);           // Inactive track, subtle borders

  // Accent & Interaction
  static const Color accentInkBlue = Color(0xFF2F4A7A);     // Primary CTA, active chips, progress
  static const Color accentContainer = Color(0xFFD6E2F5);   // Read aloud spoken sentence highlight
  static const Color destructive = Color(0xFFBA1A1A);       // Trash, delete, error warnings
}
```

### 3.2 Typography System (`lib/presentation/theme/text/`)

| Token | Family | Size | Weight | Line Height | Letter Spacing | Flutter TextStyle |
|---|---|---|---|---|---|---|
| `display-lg` | Newsreader | `32px` | 500 | `40px` | `-0.02em` | `GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w500, height: 1.25, letterSpacing: -0.64)` |
| `headline-lg` | Newsreader | `26px` | 500 | `34px` | `-0.015em` | `GoogleFonts.newsreader(fontSize: 26, fontWeight: FontWeight.w500, height: 1.30, letterSpacing: -0.39)` |
| `headline-md` | Newsreader | `22px` | 600 | `28px` | `-0.01em` | `GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: -0.22)` |
| `headline-sm` | Newsreader | `18px` | 600 | `26px` | `0.0em` | `GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w600, height: 1.44)` |
| `body-lg` | Newsreader | `18px` | 400 | `28px` | `0.01em` | `GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0.18)` |
| `body-md` | Inter | `16px` | 400 | `24px` | `-0.005em` | `GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.50, letterSpacing: -0.08)` |
| `body-sm` | Inter | `13px` | 400 | `18px` | `0.0em` | `GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.38)` |
| `label-lg` | Inter | `14px` | 600 | `20px` | `0.01em` | `GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.42, letterSpacing: 0.14)` |
| `label-md` | Inter | `12px` | 600 | `16px` | `0.02em` | `GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.24)` |
| `label-sm` | Inter | `11px` | 500 | `14px` | `0.03em` | `GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.27, letterSpacing: 0.33)` |

### 3.3 Elevation, Shadows & Borders

```dart
// Standard hairline border for containers, cards, and input fields
final hairlineBorder = Border.all(color: const Color(0xFFE8E2D9), width: 1.0);

// Soft, diffuse drop shadow under book covers (2:3 aspect ratio)
final bookCoverShadow = [
  BoxShadow(
    color: const Color(0x1F000000), // ~12% opacity
    blurRadius: 16.0,
    offset: const Offset(0, 8.0),
  ),
];

// Card border radius
final cardRadius = BorderRadius.circular(16.0);

// Bottom sheet border radius
final bottomSheetRadius = const BorderRadius.vertical(top: Radius.circular(24.0));
```

---

## 4. Screen-by-Screen Implementation Blueprints

---

### 01a. Onboarding Carousel — Page 1: All Books & Offline

* **Target File:** `lib/presentation/screen/onboarding/onboarding_screen.dart`
* **Stitch Node ID:** `ce71ef5341e7435abff9e5eab14d0402`
* **Stitch Canvas:** [Open Screen 01a](https://stitch.google.com/projects/8671147000524611054?node-id=ce71ef5341e7435abff9e5eab14d0402)
* **Local Reference:** `design/screens/01_onboarding/01_onboarding_screen.png` & `01_onboarding_screen.html`
* **Asset:** `assets/images/onboarding_hero_illustration.png`

#### Layout Specifications:
1. **Container Scaffold**: `backgroundColor: Color(0xFFFAF7F2)`.
2. **Top Bar**:
   - Height: `56.0`, horizontal padding `24.0`.
   - Leading: OpenPages brand mark / icon (`18px`).
   - Trailing: Text button `"Skip"` in `Inter 14px w600`, color `Color(0xFF6B655D)`.
3. **Hero Illustration (Top 55%)**:
   - Centered container max-width `320px`, aspect ratio `1:1`.
   - `Image.asset('assets/images/onboarding_hero_illustration.png', fit: BoxFit.contain)`.
   - Underneath: Subtle radial blur shadow in `Color(0xFFF0EDE9)` with `opacity: 0.6`.
4. **Copy Block**:
   - Title: `"Your books, all in one place"` (`Newsreader 28px w600`, color `Color(0xFF1C1B1A)`).
   - Subtitle: `"EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone."` (`Inter 15px w400`, color `Color(0xFF6B655D)`).
5. **Format Pills Row**:
   - Horizontally centered wrap with `gap: 6.0`.
   - Formats: `['EPUB', 'PDF', 'TXT', 'MD', 'FB2']`.
   - Chip styling: `backgroundColor: Color(0xFFFFFFFF)`, `border: Border.all(color: Color(0xFFE8E2D9))`, `borderRadius: BorderRadius.circular(9999)`, padding: `symmetric(horizontal: 10, vertical: 4)`. Text: `Inter 11px w500 Color(0xFF6B655D)`.
6. **Carousel Indicator Dots**:
   - Active pill: `width: 24.0, height: 8.0, borderRadius: 9999, color: Color(0xFF2F4A7A)`.
   - Inactive dots (3): `width: 8.0, height: 8.0, borderRadius: 9999, color: Color(0xFFCEC5BB)`.
   - Gap: `8.0`.
7. **Bottom Action**:
   - `FilledButton` / Stadium Container: `height: 56.0`, `borderRadius: 9999`, `backgroundColor: Color(0xFF2F4A7A)`.
   - Label: `"Next"` (`Inter 15px w600 Color(0xFFFFFFFF)`) + `Icon(Icons.arrow_forward_rounded, size: 18)`.
   - Bottom Offline note: Centered lock icon `14px` + `"Offline-first & zero telemetry"` (`Inter 12px Color(0xFF6B655D)`).

---

### 01b. Onboarding Carousel — Page 2: Reading Styles

* **Target File:** Integrated inside `onboarding_screen.dart` (`PageView` index `1`)
* **Stitch Node ID:** `ebb14c4cc542497d8d69e7b450363062`
* **Stitch Canvas:** [Open Screen 01b](https://stitch.google.com/projects/8671147000524611054?node-id=ebb14c4cc542497d8d69e7b450363062)
* **Local Reference:** `design/screens/01b_onboarding_page2/`
* **Asset:** `assets/images/onboarding_page_2_reading_styles.png`

#### Layout Specifications:
1. **Hero Illustration**: `Image.asset('assets/images/onboarding_page_2_reading_styles.png')` showing open book with typography swatches and bookmark ribbons.
2. **Typography**:
   - Title: `"Read the way you like"` (`Newsreader 28px w600`).
   - Subtitle: `"Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page."` (`Inter 15px w400`).
3. **Indicator**: Dot 2 is active (`width: 24px`, `#2F4A7A`); dots 1, 3, 4 are circular (`8px`, `#CEC5BB`).
4. **Action**: Full-width stadium button `"Next"`.

---

### 01c. Onboarding Carousel — Page 3: Read Aloud

* **Target File:** Integrated inside `onboarding_screen.dart` (`PageView` index `2`)
* **Stitch Node ID:** `20ed4f1571d044229f5caa0a4ddcc73d`
* **Stitch Canvas:** [Open Screen 01c](https://stitch.google.com/projects/8671147000524611054?node-id=20ed4f1571d044229f5caa0a4ddcc73d)
* **Local Reference:** `design/screens/01c_onboarding_page3/`
* **Asset:** `assets/images/onboarding_page_3_read_aloud.png`

#### Layout Specifications:
1. **Hero Illustration**: `Image.asset('assets/images/onboarding_page_3_read_aloud.png')` showing acoustic harmonic soundwaves and book resonance.
2. **Typography**:
   - Title: `"Listen when your eyes rest"` (`Newsreader 28px w600`).
   - Subtitle: `"Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked."` (`Inter 15px w400`).
3. **Indicator**: Dot 3 is active (`width: 24px`); dots 1, 2, 4 are circular.
4. **Action**: Full-width stadium button `"Next"`.

---

### 01d. Onboarding Carousel — Page 4: Privacy & Dictionary

* **Target File:** Integrated inside `onboarding_screen.dart` (`PageView` index `3`)
* **Stitch Node ID:** `8a586c73cb324ef38359eac34e6ee3ce`
* **Stitch Canvas:** [Open Screen 01d](https://stitch.google.com/projects/8671147000524611054?node-id=8a586c73cb324ef38359eac34e6ee3ce)
* **Local Reference:** `design/screens/01d_onboarding_page4/`
* **Asset:** `assets/images/onboarding_page_4_privacy.png`

#### Layout Specifications:
1. **Hero Illustration**: `Image.asset('assets/images/onboarding_page_4_privacy.png')` showing leather open book with brass lock & dictionary cards.
2. **Typography**:
   - Title: `"Private by design"` (`Newsreader 28px w600`).
   - Subtitle: `"No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup."` (`Inter 15px w400`).
3. **Indicator**: Dot 4 is active (`width: 24px`); dots 1, 2, 3 are circular.
4. **Action Area**:
   - Primary: Full-width stadium button `"Import your first book"` (`Color(0xFF2F4A7A)`).
   - Secondary: Text link button `"Explore first"` (`Inter 14px w600 Color(0xFF6B655D)`).

---

### 02. Library Home (Main Screen)

* **Target File:** `lib/presentation/screen/home/home_portrait_view.dart` & `library_content.dart`
* **Stitch Node ID:** `9d845920b6d64a1bbe0f24b877a97774`
* **Stitch Canvas:** [Open Screen 02](https://stitch.google.com/projects/8671147000524611054?node-id=9d845920b6d64a1bbe0f24b877a97774)
* **Local Reference:** `design/screens/02_library/02_library_screen.png` & `02_library_screen.html`

#### Layout Specifications:
1. **Top App Bar**:
   - Title: `"Library"` (`Newsreader 26px w600 Color(0xFF1C1B1A)`).
   - Actions: `Icon(Icons.search_rounded)` and `Icon(Icons.settings_outlined)`.
   - Side margin: `20.0`.
2. **Section 1: "Continue Reading" Hero Card**:
   - Background: Pure White `Color(0xFFFFFFFF)`, `borderRadius: 16.0`, `border: Border.all(color: Color(0xFFE8E2D9))`.
   - Padding: `16.0`.
   - Horizontal Row:
     - Left: Book Cover (`width: 80px, height: 120px, borderRadius: 4.0`, soft drop shadow).
     - Right:
       - Title: `"The Shadow of the Wind"` (`Newsreader 18px w600`).
       - Author: `"Carlos Ruiz Zafón"` (`Inter 13px Color(0xFF6B655D)`).
       - Status: `"Chapter 7 · 64%"` (`Inter 12px Color(0xFF6B655D)`).
       - Linear Progress Bar: `height: 4.0, borderRadius: 2.0, value: 0.64, color: Color(0xFF2F4A7A), backgroundColor: Color(0xFFE8E2D9)`.
       - Button: Stadium pill `"Resume"` (`padding: symmetric(horizontal: 16, vertical: 8), color: Color(0xFF2F4A7A), text: Inter 13px w600 white`).
3. **Recent Books Row**:
   - Horizontally scrolling list (`height: 140px, padding: symmetric(horizontal: 20)`).
   - Card (`width: 100px`): Book cover with circular progress indicator ring (`24px`, stroke `2.5px`, ink blue).
4. **Section 2: Filter Chips Row**:
   - Chips: `['All', 'Reading', 'To read', 'Finished', 'Favorites', 'Collections ▾']`.
   - Active Chip (`'All'`): `backgroundColor: Color(0xFF2F4A7A), textColor: Color(0xFFFFFFFF)`.
   - Inactive Chips: `backgroundColor: Color(0xFFFFFFFF), border: 1px Color(0xFFE8E2D9), textColor: Color(0xFF6B655D)`.
   - End Action: Sort / Filter icon button `IconButton(icon: Icon(Icons.tune_rounded))`.
5. **Section 3: 3-Column Book Grid**:
   - `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 16)`.
   - Each Cell:
     - Cover: 2:3 ratio with format badge overlay (EPUB, PDF) in top-right.
     - Title: `Newsreader 14px w600, maxLines: 2, overflow: ellipsis`.
     - Author: `Inter 11px Color(0xFF6B655D)`.
     - Progress bar underneath in-progress books.
6. **Floating Action Button**:
   - Extended pill FAB bottom-right: `FloatingActionButton.extended`.
   - Background: `Color(0xFF2F4A7A)`.
   - Label: `"+ Import"` (`Inter 14px w600 Color(0xFFFFFFFF)`).

---

### 02b. Empty Library State

* **Target File:** `lib/presentation/screen/home/components/library_content.dart` (`_LibraryEmpty`)
* **Stitch Node ID:** `e53734ed1e36444c8244209319139409`
* **Stitch Canvas:** [Open Screen 02b](https://stitch.google.com/projects/8671147000524611054?node-id=e53734ed1e36444c8244209319139409)
* **Local Reference:** `design/screens/02b_empty_library/`
* **Asset:** `assets/images/empty_library_shelf.png`

#### Layout Specifications:
1. Centered empty state column (`padding: EdgeInsets.symmetric(horizontal: 32)`).
2. Illustration: `Image.asset('assets/images/empty_library_shelf.png', width: 220, height: 220)`.
3. Headline: `"Your shelf is quiet"` (`Newsreader 22px w600 Color(0xFF1C1B1A)`).
4. Body: `"Import a DRM-free book or a whole folder to start reading."` (`Inter 14px Color(0xFF6B655D)`).
5. Dual Action Buttons:
   - Primary: `"Import files"` (`FilledButton.icon`, stadium pill, `Color(0xFF2F4A7A)`, white text).
   - Secondary: `"Import a folder"` (`OutlinedButton.icon`, stadium pill, border `1.5px Color(0xFF2F4A7A)`, text `Color(0xFF2F4A7A)`).
6. Format badge pill: `"EPUB · PDF · TXT · Markdown · HTML · FB2 · Stored locally"`.

---

### 02c. Filter & Sort Bottom Sheet

* **Target File:** `lib/presentation/screen/home/components/filter_sort_sheet.dart`
* **Stitch Node ID:** `7a5f6480a9dd4f94874d0c16e35b4dbe`
* **Stitch Canvas:** [Open Screen 02c](https://stitch.google.com/projects/8671147000524611054?node-id=7a5f6480a9dd4f94874d0c16e35b4dbe)
* **Local Reference:** `design/screens/02c_filter_sort_sheet/`

#### Layout Specifications:
1. Modal bottom sheet with top `24px` radius, drag handle pill (`32×4px Color(0xFFE8E2D9)`).
2. Header: Serif title `"Filter & Sort"` + `"Reset"` text button right-aligned.
3. **Sort by Radio Section**:
   - Card rows: `"Recently read"`, `"Title"`, `"Author"`, `"Date added"`, `"Progress"`.
   - Selected radio styled with `Color(0xFF2F4A7A)`.
4. **Format Section**:
   - Multi-select chips row: `EPUB`, `PDF`, `TXT`, `MD`, `HTML`, `FB2`.
   - Active: `Color(0xFF2F4A7A)`, white text.
5. **Browse by Category List**:
   - ListTiles: Authors, Series, Collections, All annotations, Trash (each with icon + count badge).
6. **View Mode**:
   - Segmented control: `Grid` vs. `List`.
7. **Footer**:
   - Sticky `"Apply"` primary button in `Color(0xFF2F4A7A)`.

---

### 02d. Book Details Bottom Sheet

* **Target File:** `lib/presentation/screen/home/components/library_book_actions.dart`
* **Stitch Node ID:** `54ac31aea72a4e83b1e04e7c24d681e7`
* **Stitch Canvas:** [Open Screen 02d](https://stitch.google.com/projects/8671147000524611054?node-id=54ac31aea72a4e83b1e04e7c24d681e7)
* **Local Reference:** `design/screens/02d_book_details/`

#### Layout Specifications:
1. Header card:
   - Book Cover left: `100×150px`, 2:3 ratio, soft shadow.
   - Right metadata: Title (`Newsreader 20px w600`), Author (`Inter 14px`), Series (`"Dune Chronicles · Book 1"`), Format pill (`"EPUB · 2.4 MB"`), Progress (`"Chapter 12 · 48%"`).
2. Action Buttons Row:
   - `"Read"` (primary pill in `Color(0xFF2F4A7A)`).
   - `"Add to collection"` (outlined pill).
   - `"Edit details"` (outlined pill).
   - `"Share"` (square outline icon button).
3. Metadata Grid:
   - 2-column key-value grid (Publisher, Language, Encoding, Date Added, Storage Path).
4. Destructive Action at bottom:
   - `"Move to Trash"` (`Inter 14px w600 Color(0xFFBA1A1A)` with `Icons.delete_outline_rounded`).

---

### 03. Settings Screen

* **Target File:** `lib/presentation/screen/settings/settings_portrait_view.dart`
* **Stitch Node ID:** `0e2582dd012247b68a3368ad5eba12c8`
* **Stitch Canvas:** [Open Screen 03](https://stitch.google.com/projects/8671147000524611054?node-id=0e2582dd012247b68a3368ad5eba12c8)
* **Local Reference:** `design/screens/03_settings/`

#### Layout Specifications:
1. App Bar: Back button, Title `"Settings"` (`Newsreader 24px w600`).
2. Inset Grouped Cards (`backgroundColor: Color(0xFFFFFFFF), borderRadius: 16.0, border: Border.all(color: Color(0xFFE8E2D9))`):
   - **Section "Appearance"**: Theme (Light / Dark / System segmented pill), Text scale slider.
   - **Section "Reading defaults"**: Default theme swatch, Font picker (`Newsreader`, `Inter`, `Literata`), Tap zones switch, Volume keys page turn switch, Wake lock switch.
   - **Section "Read aloud"**: Voice selector (`"English (US) - Natural"`), Speed slider (`1.0×`), Skip page numbers switch.
   - **Section "Library & Backup"**: Import folder, Auto-mark finished at 100%, Trash auto-empty (30 days), `"Back up now"`, `"Restore backup"`.
   - **Section "Premium Appearance"**: Special highlighted card with deep ink blue outline: `"Unlock 12 themes and 8 fonts"` with primary button `"Unlock"`.
   - **Section "About"**: Dictionary credits (Wiktionary, CC BY-SA 3.0), Open-source licenses, Version (`v1.0.0`).

---

### 04. Reader Screen (Chrome Visible)

* **Target File:** `lib/presentation/screen/reader/reader_screen.dart` & `widgets/reader_chrome.dart`
* **Stitch Node ID:** `80a5b42582244aea8c4661094117f3f7`
* **Stitch Canvas:** [Open Screen 04](https://stitch.google.com/projects/8671147000524611054?node-id=80a5b42582244aea8c4661094117f3f7)
* **Local Reference:** `design/screens/04_reader_chrome_visible/`

#### Layout Specifications:
1. Canvas background: Warm Paper `#F6F1E7`.
2. Body text: `Newsreader 18px, height: 1.55, justified, 20px side margins`.
3. Top Bar:
   - Translucent paper surface with backdrop blur + hairline border `#E8E2D9`.
   - Left: Back arrow.
   - Center: Book title in small serif (`Newsreader 15px w600`).
   - Right: Search icon, Bookmark outline icon, Overflow menu ⋮.
4. Left Edge Indicator:
   - Thin vertical brightness slider line (`width: 3px, color: Color(0xFF747780)`).
5. Bottom Chrome Panel:
   - Top radius `24px`, background translucent paper.
   - Position label: `"Page 142 of 380 · 12 min left in chapter"`.
   - Draggable progress slider with chapter tick marks.
   - 4 Tool buttons with icons + text labels:
     1. `Contents` (`Icons.toc_rounded`)
     2. `Appearance` (`Icons.text_format_rounded`)
     3. `Listen` (`Icons.headphones_outlined`)
     4. `Notes` (`Icons.sticky_note_2_outlined`)

---

### 04-var. Reader Screen (Chrome Hidden / Zen Mode)

* **Target File:** `lib/presentation/screen/reader/reader_screen.dart`
* **Stitch Node ID:** `b868e1ced50640ff8de1949fcb0f8c2e`
* **Stitch Canvas:** [Open Screen 04-var](https://stitch.google.com/projects/8671147000524611054?node-id=b868e1ced50640ff8de1949fcb0f8c2e)
* **Local Reference:** `design/screens/04_reader_chrome_hidden/`

#### Layout Specifications:
1. Zero chrome: No top bar, no bottom bar, no system status bar.
2. 100% viewport reading text on warm paper canvas `#F6F1E7`.
3. At the very bottom center: Tiny unobtrusive page counter `"142 / 380"` (`Inter 11px Color(0xFF6B655D)`).
4. Tap center toggles chrome visibility. Left/right edge zones handle page turns.

---

### 04b. Reader Appearance Bottom Sheet

* **Target File:** `lib/presentation/screen/reader/widgets/appearance_sheet.dart`
* **Stitch Node ID:** `d8bb2a419ed94bd2912d8dd529e5c482`
* **Stitch Canvas:** [Open Screen 04b](https://stitch.google.com/projects/8671147000524611054?node-id=d8bb2a419ed94bd2912d8dd529e5c482)
* **Local Reference:** `design/screens/04b_appearance_sheet/`

#### Layout Specifications:
1. Bottom sheet top radius `24px`, drag handle.
2. **Themes Section**: 6 circular swatches (`diameter: 40px`):
   - `Paper (#F6F1E7)`, `White (#FFFFFF)`, `Sepia (#F4ECD8)`, `Grey (#EAE6DF)`, `Night (#23272A)`, `Black (#121212)`.
   - Premium swatches have a small lock icon. Active swatch has double ring.
3. **Font Picker**: Horizontal scroll cards (`Newsreader`, `Inter`, `Literata`, `EB Garamond`, `Source Serif 4`).
4. **Typography Sliders**: Font size, Line spacing, Margins with `A−` and `A+` end icons.
5. **Layout & Alignment**:
   - Layout mode segmented control: `Scroll` / `Pages` / `Two columns`.
   - Toggles: `Justify`, `Hyphenation`, `Publisher styles`.
6. **Brightness**: Horizontal slider with `"Follow system"` toggle.

---

### 04c. Text Selection & Dictionary Definition

* **Target File:** `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` & `marked_text.dart`
* **Stitch Node ID:** `3377a7d8be9f4c4a806e881edd365939`
* **Stitch Canvas:** [Open Screen 04c](https://stitch.google.com/projects/8671147000524611054?node-id=3377a7d8be9f4c4a806e881edd365939)
* **Local Reference:** `design/screens/04c_text_selection_dictionary/`

#### Layout Specifications:
1. Selected word highlighted with teardrop handles in `Color(0xFF2F4A7A)`.
2. Floating Action Toolbar:
   - Highlight (5 color dots: yellow `#FFD54F`, green `#81C784`, blue `#64B5F6`, pink `#F06292`, orange `#FFB74D`), Note, Define, Copy, Share.
3. Bottom Dictionary Sheet:
   - Header: Word in large serif (`Newsreader 24px w600`), phonetic spelling `/'lɪt(ə)rəl/'` + speaker audio icon button.
   - Part of speech chips: `adjective`, `noun`.
   - Numbered definition cards with italic usage sentences.
   - Footer: `"From Wiktionary · CC BY-SA 3.0 · Offline"`.

---

### 04d. Table of Contents & Annotations Panel

* **Target File:** `lib/presentation/screen/reader/widgets/notes_sheet.dart`
* **Stitch Node ID:** `60c9068ec7e6446eb55f8762102cb112`
* **Stitch Canvas:** [Open Screen 04d](https://stitch.google.com/projects/8671147000524611054?node-id=60c9068ec7e6446eb55f8762102cb112)
* **Local Reference:** `design/screens/04d_contents_annotations/`

#### Layout Specifications:
1. Side sheet sliding from left (or tall bottom sheet on mobile).
2. Segmented / Tab Header: `Contents`, `Bookmarks`, `Highlights`.
3. Top right action: `"Export as Markdown"` icon button.
4. Contents view: Nested chapter list with page numbers; current active chapter highlighted with an ink-blue vertical bar (`3px #2F4A7A`).
5. Highlights view: Cards with vertical color bar, quote text, page reference, creation date, and note preview.

---

### 04e. Search Inside Book

* **Target File:** `lib/presentation/screen/reader/widgets/reader_search.dart`
* **Stitch Node ID:** `c63b6121c3f6481fa466900795a02b89`
* **Stitch Canvas:** [Open Screen 04e](https://stitch.google.com/projects/8671147000524611054?node-id=c63b6121c3f6481fa466900795a02b89)
* **Local Reference:** `design/screens/04e_search_in_book/`

#### Layout Specifications:
1. Search Top Bar:
   - Search input holding query (`"harbour"`), result counter badge (`"23 results"`), clear button.
   - Up/down stepper buttons to jump between results.
2. Result Snippets List:
   - Grouped by chapter headers (`"Chapter 4"`, `"Chapter 7"`).
   - Snippet card: 2 lines with matching term bolded in deep ink blue (`#2F4A7A`) and page number (`"p. 142"`).

---

### 05. Read Aloud In-App Player

* **Target File:** `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`
* **Stitch Node ID:** `b44bfe8531334c9fab5c6e95ba2c2ac3`
* **Stitch Canvas:** [Open Screen 05](https://stitch.google.com/projects/8671147000524611054?node-id=b44bfe8531334c9fab5c6e95ba2c2ac3)
* **Local Reference:** `design/screens/05_read_aloud/`

#### Layout Specifications:
1. Reader canvas: Currently spoken sentence has soft translucent highlight band `Color(0xFFD6E2F5)`.
2. Expanded Player Bottom Sheet:
   - Top: Centered book cover (2:3 aspect ratio).
   - Book title in serif (`Newsreader 20px w600`) + chapter subtitle.
   - Active sentence rendered large in Newsreader serif; preceding and succeeding sentences faded in secondary slate (`opacity: 0.4`).
   - Chapter progress scrubber bar.
   - Controls: Previous sentence, circular Play/Pause button (`64×64px Color(0xFF2F4A7A)` with white icon), Next sentence.
   - Quick settings chips: Speed `"1.25×"`, Voice `"English (Natural)"`, Sleep timer `"30 min"`.

---

### 06. Android Lock Screen Media Session

* **Target File:** Handled via Android native `MediaSessionCompat` / `audio_service` integration
* **Stitch Node ID:** `cb0c0e53f6d845b193205ead7b7aeb7e`
* **Stitch Canvas:** [Open Screen 06](https://stitch.google.com/projects/8671147000524611054?node-id=cb0c0e53f6d845b193205ead7b7aeb7e)
* **Local Reference:** `design/screens/06_lock_screen/`

#### Layout Specifications:
1. System Media Player card format:
   - Artwork: Book Cover thumbnail.
   - Title: Chapter title (`"Chapter Four: The Silent Harbour"`).
   - Artist / Subtitle: Book title + app (`"The Shadow of the Wind · OpenPages"`).
   - Actions: Previous sentence, Play/Pause, Next sentence, Sleep timer button.

---

### 07. Premium Appearance Paywall

* **Target File:** `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`
* **Stitch Node ID:** `e4e1f70641644d55af19ba91bec03cb5`
* **Stitch Canvas:** [Open Screen 07](https://stitch.google.com/projects/8671147000524611054?node-id=e4e1f70641644d55af19ba91bec03cb5)
* **Local Reference:** `design/screens/07_premium_paywall/`

#### Layout Specifications:
1. Top bar with close `"✕"` button.
2. Hero Section: Side-by-side preview of 3 premium reading themes (Linen, Midnight Blue, Forest).
3. Headline: `"Make every page yours"` (`Newsreader 28px w600`).
4. Body: `"Unlock handcrafted themes, fonts, and style presets."`
5. Feature Bullets with checkmark icons: 12 handcrafted themes, 8 book fonts, custom accents.
6. Reassurance footnote: `"Reading, offline storage, dictionary, and search remain free forever."`
7. Two Plan Cards:
   - Card 1: `"Lifetime"` ($14.99 one-time) with `"Best Value"` chip.
   - Card 2: `"Yearly"` ($4.99/year).
8. Primary Action: Full-width stadium button `"Unlock Premium"` in `Color(0xFF2F4A7A)`.
9. Bottom text link: `"Restore purchases"` in `Inter 13px Color(0xFF6B655D)`.

---

### 08. All Annotations Screen

* **Target File:** `lib/presentation/screen/annotations/annotations_screen.dart`
* **Stitch Node ID:** `837a423b40e84dc6b4abbdfbdf90bd99`
* **Stitch Canvas:** [Open Screen 08](https://stitch.google.com/projects/8671147000524611054?node-id=837a423b40e84dc6b4abbdfbdf90bd99)
* **Local Reference:** `design/screens/08_all_annotations/`

#### Layout Specifications:
1. App Bar: Back arrow, Title `"Annotations"` (`Newsreader 24px w600`), Search icon, Overflow menu ⋮ (`"Export as Markdown"`).
2. Search Bar: Input `"Search highlights & notes..."`.
3. Filter Chips: `All (42)`, `Highlights (30)`, `Notes (12)`, `Bookmarks (8)`.
4. Grouped Cards List:
   - Header: Book cover thumbnail + Book title in serif + Author.
   - Annotation Item Card:
     - Vertical color strip indicator (yellow, green, blue, pink).
     - Quoted passage in serif italics (`Newsreader 15px`).
     - Attached user note in sans (`Inter 13px`).
     - Footer: Page reference (`"Page 84"`) + date (`"Oct 28"`).

---

## 5. Fallback Assets Integration

When a book cover image is unavailable in an imported EPUB/PDF, use the fallback cover asset:

* **File Path:** `assets/images/fallback_book_cover_default.png`
* **Stitch Canvas Node:** `16925914359237450860`
* **Flutter Implementation (`lib/presentation/widgets/book/book_cover.dart`):**

```dart
Widget buildBookCover({String? coverPath, double width = 80, double height = 120}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(4.0),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0x1F000000),
            blurRadius: 16.0,
            offset: const Offset(0, 8.0),
          ),
        ],
      ),
      child: coverPath != null && File(coverPath).existsSync()
          ? Image.file(File(coverPath), fit: BoxFit.cover)
          : Image.asset('assets/images/fallback_book_cover_default.png', fit: BoxFit.cover),
    ),
  );
}
```

---

## 6. Visual Quality Assurance & Golden Test Protocol

To guarantee pixel-by-pixel fidelity:

1. **Overlay Comparison Tooling**:
   - Run the app on an Android device or emulator with a `412 × 915 dp` viewport.
   - Use Flutter's `RepaintBoundary` or screenshot tool to capture each screen at 2× pixel density (`824 × 1830`).
   - Compare directly against the Stitch reference PNG in `design/screens/<slug>/<slug>_screen.png`.
2. **Automated Golden Tests**:
   - Place golden test files in `test/presentation/golden/`.
   - Set test surface size:
     ```dart
     await tester.binding.setSurfaceSize(const Size(412, 915));
     ```
   - Match against golden images with threshold difference `< 0.5%`.
3. **Typography Verification**:
   - Verify that all headings use Google Fonts `Newsreader` or asset serif, and all UI controls use `Inter`.
   - Ensure `FontFeature.tabularFigures()` is applied to all page counters and time indicators.


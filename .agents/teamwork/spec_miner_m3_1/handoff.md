# Milestone 3 Specification Mining Report: Library & Book Management

**Agent:** `spec_miner_m3_1`  
**Date:** 2026-11-04  
**Target Milestone:** M3 (Library & Book Management)  
**Authoritative Sources:**
- `design/screens/02_library/` (`02_library_screen.html`, `02_library_metadata.json`, `02_library_screen.png`)
- `design/screens/02b_empty_library/` (`02b_empty_library_screen.html`, `02b_empty_library_metadata.json`, `02b_empty_library_screen.png`)
- `design/screens/02c_filter_sort_sheet/` (`02c_filter_sort_sheet_screen.html`, `02c_filter_sort_sheet_metadata.json`, `02c_filter_sort_sheet_screen.png`)
- `design/screens/02d_book_details/` (`02d_book_details_screen.html`, `02d_book_details_metadata.json`, `02d_book_details_screen.png`)
- `design/STITCH_UI_IMPLEMENTATION_GUIDE.md`
- `test/e2e/tier1_features/library_and_books_test.dart`
- `ORIGINAL_REQUEST.md` (§R3) & `PROJECT.md` (§Feature 11-20)

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Top App Bar | Library Editorial Header (Feature 11) | Top bar featuring brand glyph, title "Library" in Newsreader serif, Search button, and Settings button. Padding `px-5 py-3` (20×12dp). | User taps search or settings icon button | Opens library search mode or navigates to Settings screen | Disabled during ongoing file import | `02_library_screen.html:143-156`, `library_and_books_test.dart:40-67` |
| 2 | Hero Card | Continue Reading Card (Feature 12) | Elevated card (`16px` radius, `#FFFFFF`, 1px border `#E8E2D9`) showcasing the most recently read book with 96×144 (2:3) cover shadow, format badge, progress text/bar, and "Resume" Stadium pill CTA. | Most recent book entity with progress < 100% | Launches reader at last read position (`onResume`) | Hidden if library has 0 books or active search query / non-All filter view | `02_library_screen.html:165-199`, `STITCH_UI_IMPLEMENTATION_GUIDE.md:265-276` |
| 3 | Carousel | Recent Books Row (Feature 13) | Horizontal scroll container (`height: ~72-88dp`, item width 210dp, 12dp gap) showing recently read books with mini cover (48×64 / 36×52), title, author, and SVG/Canvas circular progress indicator ring (24×24dp, stroke 2.5dp). | List of active reading books | Horizontal scrollable cards; tap opens reader | Hidden if no books have reading progress | `02_library_screen.html:200-270`, `library_and_books_test.dart:206-266` |
| 4 | Filters | Library Filter Chips (Feature 14) | Horizontally scrollable chip row (`All`, `Reading`, `To read`, `Finished`, `Favorites`, `Collections ▾`) + trailing Sort button. Active chip filled `#2F4A7A`, inactive chips `#FFFFFF` with 1px border `#E8E2D9`. | User tap on filter chip | Filters visible book grid / shelf; `Collections ▾` opens collection dropdown/picker | Tapping active chip retains selection | `02_library_screen.html:271-299`, `library_and_books_test.dart:268-286` |
| 5 | Shelf Grid | 3-Column Book Grid (Feature 15) | 3-column sliver grid (`crossAxisCount: 3`, gap `12dp`) displaying 2:3 ratio book covers, format badge overlay (EPUB, PDF, etc.), progress bar or checkmark badge for finished books, 2-line title in Newsreader, author in Inter. | Filtered visible books | Tap opens reader or details sheet; long-press opens book actions | Fallback cover displayed if cover image missing | `02_library_screen.html:300-405`, `library_and_books_test.dart:288-333` |
| 6 | Action | Extended FAB (+ Import) (Feature 16) | Bottom-right extended floating action button in `#2F4A7A` with StadiumBorder, `+` icon (20px), and "Import" label (`Inter 14px w600` white). Strictly NO bottom navigation bar. | User tap on FAB | Triggers document/folder import flow | Shows progress indicator if import is actively running | `02_library_screen.html:407-412`, `library_and_books_test.dart:68-81` |
| 7 | Empty State | Empty Library View (02b / Feature 17) | Centered editorial empty state with illustration `assets/images/empty_library_shelf.png` (280×220dp, `mix-blend-multiply`), headline "Your shelf is quiet", body text, dual action buttons ("Import files" filled pill `#2F4A7A` & "Import a folder" outlined pill), and privacy/compatibility pill badge. | Library has 0 books and no active search query | Renders full empty state; primary/secondary import buttons | When search query returns 0 results, shows search empty variation | `02b_empty_library_screen.html:157-192`, `library_and_books_test.dart:335-416` |
| 8 | Bottom Sheet | Filter & Sort Sheet (02c / Feature 18) | Modal bottom sheet (`rounded-t-[28px]`, `#FFFFFF`, drag handle `32-40×4dp` `#DCDAD5`) with View Layout toggle (Grid vs List), Sort By radio rows (5 options), Format multi-select chips (6 formats), Browse by category list (5 sections with counts), and sticky bottom "Apply Filters" button. | Triggered via Sort button in filter row or tune button | Updates sort order, format filters, and layout view mode | "Reset" button restores default sort and clears format selections | `02c_filter_sort_sheet_screen.html:201-384`, `library_and_books_test.dart:418-511` |
| 9 | Bottom Sheet | Book Details Sheet (02d / Feature 19) | Modal bottom sheet (`rounded-t-[24px]`) presenting 130×195dp (2:3) cover, series tag, title in Newsreader 26px, author in Newsreader 19px italic, format pill & added date, progress card, 4-action row (`Read`, `Collect`, `Edit`, `Share`), prologue quote, metadata grid (publisher, language, encoding, file path, word count), offline badge, and "Move to Trash" destructive button. | Triggered via book item tap / details option | Action row allows reading, collection assignment, metadata editing, file sharing, and trashing | "Move to Trash" prompts confirmation or moves to trash with Undo snackbar | `02d_book_details_screen.html:166-299`, `library_and_books_test.dart:513-610` |
| 10 | Asset Widget | Fallback Book Cover Widget (Feature 20) | When book has no extracted cover image (`coverPath == null` or missing file), displays `assets/images/fallback_book_cover_default.png` with 2:3 aspect ratio, format-colored band, and scaled title/author overlay. | `BookEntity` with null or invalid `coverPath` | Renders fallback asset without broken image icon | Graceful fallback if asset fails | `PROJECT.md:73-76`, `book_cover.dart:91-101`, `library_and_books_test.dart:787-804` |

---

## Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Hero Card | Library has 0 books or all books finished (progress = 100%) | Hero card is suppressed completely; layout seamlessly flows to empty state or recent carousel / grid. |
| 2 | Hero Card | Active search query or non-`All` filter active (e.g., `Finished` or `Trash`) | Hero card is suppressed to avoid visual confusion during search or filtered viewing. |
| 3 | Filter Chips | Long text in category/collection name | Horizontal scrollview handles overflow without clipping; trailing collections chip has `arrow_drop_down` glyph. |
| 4 | 3-Column Grid | Long title (3+ lines) or missing author | Book title is clamped to exactly 2 lines (`line-clamp-2`, `TextOverflow.ellipsis`). Missing author gracefully hides author text without reserving empty space. |
| 5 | 3-Column Grid | Book reading progress is 100% | Replaces bottom progress bar line with small circular `#2F4A7A` checkmark badge (`w-5 h-5` / 20×20dp, check icon 13px) in bottom-right corner. |
| 6 | Empty Library | Active search with 0 matches vs Truly empty library (0 books) | When search has no results, shows search empty message ("No results") with "Clear search" CTA. When library is truly empty (0 books), displays `empty_library_shelf.png`, "Your shelf is quiet", and dual import buttons ("Import files" & "Import a folder"). |
| 7 | Filter & Sort Sheet | Reset button tapped | Restores sort order to default ("Recently read"), unselects all format chips, keeps current view mode. |
| 8 | Book Details Sheet | Book has no series or no prologue excerpt | Series uppercase label and prologue blockquote are omitted, metadata grid shifts up seamlessly. |
| 9 | Book Details Sheet | File path is extremely long | File path is displayed in monospace typography (`Inter 11px`), breaks at any character (`break-all`), clamped to 2 lines. |
| 10 | Book Cover | File path on disk is corrupt or deleted | Image error builder catches error and falls back to `assets/images/fallback_book_cover_default.png`. |

---

## Pixel-by-Pixel Screen Specifications

### 1. Screen `02_library` (Library Home)
- **Viewport**: 412 × 915 dp (Android standard). Background: Warm Ivory `#FAF7F2` (`AppColors.background`).
- **Scaffold Configuration**:
  - `backgroundColor: const Color(0xFFFAF7F2)`
  - `bottomNavigationBar: null` (Strict architectural mandate: Zero bottom navigation bar anywhere).
  - Floating Action Button: `FloatingActionButton.extended` at `bottom: 24dp, right: 24dp`.
- **Top App Bar**:
  - Toolbar height: `56-64dp`, padding: `EdgeInsets.symmetric(horizontal: 20, vertical: 8)`.
  - Leading widget: `Icon(Icons.local_library_outlined, size: 24, color: Color(0xFF2F4A7A))` (or 32×32 pill container with `#E7DED4/60` background).
  - Title: `"Library"`
    - Typography: `Newsreader`, `fontSize: 22-26px`, `fontWeight: FontWeight.w600`, `letterSpacing: -0.22`, `color: Color(0xFF1C1B1A)`.
  - Action buttons:
    - Search button: `IconButton(key: Key('library_search_button'), icon: Icon(Icons.search, size: 22, color: Color(0xFF6B655D)))`.
    - Settings button: `IconButton(key: Key('library_settings_button'), icon: Icon(Icons.settings_outlined, size: 22, color: Color(0xFF6B655D)))`.
- **Continue Reading Hero Card**:
  - Card Dimensions: Width: full width minus `40dp` margins (`EdgeInsets.symmetric(horizontal: 20)`).
  - Container styling:
    - Background: `Color(0xFFFFFFFF)` (`AppColors.surface`).
    - Border radius: `16.0dp` (`cardRadius`).
    - Border: `Border.all(color: Color(0xFFE8E2D9), width: 1.0)`.
    - Padding: `EdgeInsets.all(16.0)`.
    - Drop shadow: `BoxShadow(color: Color(0x081C1B1A), blurRadius: 8, offset: Offset(0, 2))`.
  - Card Inner Layout: `Row(crossAxisAlignment: CrossAxisAlignment.center)`:
    - Left Cover:
      - Width: `96.0dp`, Height: `144.0dp` (exact 2:3 aspect ratio).
      - Corner radius: `BorderRadius.circular(8.0)`.
      - BoxShadow: `BoxShadow(color: Color(0x1F1C1B1A), blurRadius: 12, offset: Offset(0, 4))`.
      - Border: `Border.all(color: Color(0x99E8E2D9), width: 1.0)`.
      - Spine crease gradient on left: `width: 4dp`, `LinearGradient(colors: [Colors.black26, Colors.white10, Colors.transparent])`.
    - Right Details Column:
      - Height: `144.0dp`, `MainAxisAlignment.spaceBetween`.
      - Top section:
        - Format badge: Pill container `padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2)`, `color: Color(0xFFF0EDE9)`, `borderRadius: BorderRadius.circular(4)`. Text: `"EPUB"` in `Inter 9px w600 uppercase, color: Color(0xFF6B655D)`.
        - Recency text: `"Added recently"` in `Inter 11px w400, color: Color(0xFF6B655D)`.
        - Title: `"The Shadow of the Wind"` in `Newsreader 18-19px w600, color: Color(0xFF1C1B1A)`, max 1 line, ellipsis.
        - Author: `"Carlos Ruiz Zafón"` in `Inter 13px w400, color: Color(0xFF6B655D)`, max 1 line, ellipsis.
      - Bottom section:
        - Chapter & Percentage row: `"Chapter 7"` in `Inter 11px w400 Color(0xFF6B655D)` vs `"64%"` in `Inter 11px w600 Color(0xFF2F4A7A)`.
        - Slender progress bar: `height: 4.0dp`, `borderRadius: BorderRadius.circular(2.0)`, track: `Color(0xFFE8E2D9)`, indicator: `Color(0xFF2F4A7A)`.
        - Resume Button:
          - Height: `38.0dp`, full width.
          - Shape: `StadiumBorder()`.
          - Background: `Color(0xFF2F4A7A)`, active press: `Color(0xFF23395E)`.
          - Icon: `Icon(Icons.auto_stories, size: 17, color: Colors.white)`.
          - Label: `"Resume"` in `Inter 13px w600 color: Colors.white`.
          - Key: `Key('resume_reading_button')`.
- **Recent Books Horizontal Carousel**:
  - Container: `height: 72-88dp`, horizontal `ListView.separated`.
  - Item Card:
    - Width: `210.0dp`.
    - Background: `Color(0xFFFFFFFF)`, `borderRadius: BorderRadius.circular(12.0)`.
    - Border: `Border.all(color: Color(0xFFE8E2D9), width: 1.0)`.
    - Padding: `EdgeInsets.all(10-12dp)`.
    - Layout: `Row(children: [MiniCover, SizedBox(width: 10), Expanded(Column), MiniRing])`.
    - Mini Cover: `width: 48dp, height: 64dp` (or 36×52dp), `borderRadius: BorderRadius.circular(4.0)`.
    - Text Column:
      - Title: `Newsreader 14-15px w600`, max 1 line, ellipsis.
      - Author: `Inter 12px w400 Color(0xFF6B655D)`, max 1 line.
      - Chapter/Page: `"Ch. 4"` or `"p. 182"` in `Inter 11px Color(0xFF6B655D)`.
    - Circular Progress Ring:
      - Diameter: `20-24dp`, `strokeWidth: 2.5dp`.
      - Background track: `Color(0xFFE8E2D9)`.
      - Value track: `Color(0xFF2F4A7A)`.
      - Center text / trailing: `"42%"` in `Inter 10px w600 Color(0xFF2F4A7A)`.
- **Filter Chips Row**:
  - Container: `SingleChildScrollView(scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 20))`.
  - Chips: `['All', 'Reading', 'To read', 'Finished', 'Favorites', 'Collections ▾']`.
  - Active Chip:
    - Background: `Color(0xFF2F4A7A)`.
    - Text: `Inter 12-13px w600 Color(0xFFFFFFFF)`.
    - Shape: `StadiumBorder()`.
    - Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`.
  - Inactive Chips:
    - Background: `Color(0xFFFFFFFF)`.
    - Border: `BorderSide(color: Color(0xFFE8E2D9), width: 1.0)`.
    - Text: `Inter 12-13px w500 Color(0xFF6B655D)`.
    - Shape: `StadiumBorder()`.
  - Trailing Sort Button:
    - Dimensions: `width: 32dp, height: 32dp`, circular.
    - Background: `Color(0xFFFFFFFF)`, `Border.all(color: Color(0xFFE8E2D9))`.
    - Icon: `Icon(Icons.swap_vert, size: 16, color: Color(0xFF6B655D))` (or `Icons.tune_rounded`).
- **3-Column Book Grid**:
  - Section Header: `"All volumes (28)"` in `Inter 13-14px w600 letterSpacing: 0.2 Color(0xFF1C1B1A)` + trailing sort label `"Recent ▾"` (`Inter 11px Color(0xFF6B655D)`).
  - Grid Delegate:
    - `crossAxisCount: 3`
    - `crossAxisSpacing: 12.0dp`
    - `mainAxisSpacing: 16.0dp`
    - `childAspectRatio: 2 / 3.8` (or `~0.53`)
  - Grid Cell Item:
    - Cover Container:
      - `AspectRatio(aspectRatio: 2 / 3)`
      - Corner radius: `BorderRadius.circular(8.0)`
      - Background: `Color(0xFFFFFFFF)`, border: `Border.all(color: Color(0xFFE8E2D9))`
      - Shadow: `BoxShadow(color: Color(0x0F1C1B1A), blurRadius: 8, offset: Offset(0, 3))`
    - Format Badge Overlay (Top-Right):
      - Position: `top: 6dp, right: 6dp`
      - Container: `padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1)`, `borderRadius: BorderRadius.circular(3)`
      - Background: `Color(0x99000000)` (black with 60% opacity)
      - Text: `Inter 9px w600 uppercase color: Colors.white` (e.g. "EPUB", "PDF", "TXT")
    - Left Spine Shadow: `width: 2.5dp`, gradient `LinearGradient(colors: [Colors.black26, Colors.transparent])`
    - In-Progress Bottom Track:
      - Docked at bottom of cover: `height: 4dp`, background `Color(0xCCE8E2D9)`
      - Progress indicator: `height: 4dp`, color `Color(0xFF2F4A7A)`
    - Finished Badge:
      - When book is finished (`progress >= 1.0`):
      - Position: `bottom: 6dp, right: 6dp`
      - Container: `width: 20dp, height: 20dp`, circular, `color: Color(0xFF2F4A7A)`
      - Icon: `Icon(Icons.check, size: 13, color: Colors.white)`
    - Metadata below cover:
      - Title: `Newsreader 13.5-14px w600, height: 1.25, color: Color(0xFF1C1B1A)`, `maxLines: 2, overflow: TextOverflow.ellipsis`
      - Author: `Inter 11px w400, color: Color(0xFF6B655D)`, `maxLines: 1, overflow: TextOverflow.ellipsis`, `margin-top: 2dp`
- **Extended Floating Action Button (FAB)**:
  - Key: `Key('library_import_fab')`
  - Position: Floating in bottom-right corner (`bottom: 24dp, right: 24dp`).
  - Shape: `StadiumBorder()`.
  - Height: `52-56dp`, padding: `EdgeInsets.symmetric(horizontal: 20, vertical: 14)`.
  - Background: `Color(0xFF2F4A7A)` (`AppColors.accentInkBlue`), active press: `Color(0xFF23395E)`.
  - Elevation: `shadow: BoxShadow(color: Color(0x47153362), blurRadius: 20, offset: Offset(0, 8))`.
  - Icon: `Icon(Icons.add, size: 20, color: Colors.white)`.
  - Label: `"Import"` in `Inter 14px w600 letterSpacing: 0.15 Color(0xFFFFFFFF)`.

---

### 2. Screen `02b_empty_library` (Empty Library State)
- **Viewport**: 412 × 915 dp, background: `#FAF7F2` (`AppColors.background`).
- **Layout**: Centered vertical flex container (`EdgeInsets.symmetric(horizontal: 24)`).
- **Hero Illustration**:
  - Asset: `assets/images/empty_library_shelf.png`.
  - Key: `Key('empty_library_shelf_image')`.
  - Container dimensions: `width: 280dp, height: 220dp` (or 240×180dp in compact viewport).
  - Blend mode: `mix-blend-multiply` (`BlendMode.multiply`).
  - Fit: `BoxFit.contain`.
- **Editorial Typography Block**:
  - Margin: `EdgeInsets.only(top: 20, bottom: 24)`.
  - Headline: `"Your shelf is quiet"` (or `"Your library is empty"`)
    - Typography: `Newsreader`, `fontSize: 28-30px`, `fontWeight: FontWeight.w500`, `height: 1.27`, `letterSpacing: -0.45`, `color: Color(0xFF1C1B1A)`.
  - Subtitle: `"Import a DRM-free book or a whole folder to start reading."`
    - Typography: `Inter`, `fontSize: 14-15px`, `fontWeight: FontWeight.w400`, `height: 1.50`, `color: Color(0xFF6B655D)`.
    - Text alignment: `TextAlign.center`.
- **Dual Action Buttons Cluster**:
  - Container width: max `320dp`, `EdgeInsets.only(bottom: 24)`.
  - 1. Primary Button ("Import files"):
    - Key: `Key('empty_import_files_button')`
    - Widget: `FilledButton.icon` / `StadiumContainer`
    - Height: `48-52dp`, full width of cluster
    - Shape: `StadiumBorder()`
    - Background: `Color(0xFF2F4A7A)`, hover/press: `Color(0xFF23395E)`
    - Icon: `Icon(Icons.upload_file, size: 20, color: Colors.white)`
    - Label: `"Import files"` in `Inter 14px w600 Color(0xFFFFFFFF)`
  - 2. Secondary Button ("Import a folder"):
    - Key: `Key('empty_import_folder_button')`
    - Widget: `OutlinedButton.icon`
    - Height: `48-52dp`, full width of cluster
    - Shape: `StadiumBorder()`
    - Border: `BorderSide(color: Color(0xFF2F4A7A), width: 1.5)` (or hairline `#E8E2D9` in light neutral variant)
    - Background: `Color(0xFFFFFFFF)`
    - Icon: `Icon(Icons.folder_open, size: 20, color: Color(0xFF2F4A7A))`
    - Label: `"Import a folder"` in `Inter 14px w600 Color(0xFF2F4A7A)`
- **Format Compatibility & Privacy Badge**:
  - Container: `padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6)`, `borderRadius: BorderRadius.circular(9999)`
  - Surface: `Color(0xFFFFFFFF)`, `border: Border.all(color: Color(0xFFE8E2D9))`
  - Icon: `Icon(Icons.shield_outlined, size: 14, color: Color(0xFF6B655D))`
  - Label: `"Supports EPUB, PDF, TXT, Markdown, HTML, FB2 · Stored locally"` in `Inter 11px w500 Color(0xFF6B655D)`

---

### 3. Screen `02c_filter_sort_sheet` (Filter & Sort Bottom Sheet)
- **Modal Scrim**: `Color(0x591C1B1A)` (carbon ink scrim with 35% opacity) + `ImageFilter.blur(sigmaX: 3, sigmaY: 3)`.
- **Sheet Container**:
  - Background: `Color(0xFFFFFFFF)` (`AppColors.surface`).
  - Shape: `RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)))`.
  - Border: `1px solid Color(0xFFE8E2D9)` on top, left, right edges.
  - Drop shadow: `BoxShadow(color: Color(0x1F1C1B1A), blurRadius: 32, offset: Offset(0, -8))`.
  - Max height: `820dp` (or 90% of screen height).
- **Drag Handle**:
  - Dimensions: `width: 40dp, height: 4dp`.
  - Color: `Color(0xFFDCDAD5)` (`AppColors.surfaceDim` or `hairline`).
  - Corner radius: `BorderRadius.circular(2.0)`.
  - Padding: `EdgeInsets.only(top: 12, bottom: 4)`.
- **Header**:
  - Padding: `EdgeInsets.symmetric(horizontal: 20, vertical: 10)`.
  - Title: `"Filter & Sort"` in `Newsreader 20-22px w600 Color(0xFF1C1B1A)`.
  - Trailing Action: `"Reset"` text button in `Inter 14px w600 Color(0xFF6B655D)`.
  - Divider: `1px solid Color(0xFFE8E2D9)`.
- **View Layout Section**:
  - Header: `"VIEW LAYOUT"` in `Inter 11px w600 uppercase letterSpacing: 0.05 Color(0xFF6B655D)`.
  - Segmented capsule: `padding: EdgeInsets.all(4)`, `color: Color(0xFFF6F3EE)`, `borderRadius: BorderRadius.circular(9999)`, border: `Border.all(color: Color(0xFFE8E2D9))`.
  - Grid Option (selected): `color: Color(0xFFFFFFFF)`, `shadow: BoxShadow(color: Color(0x0A000000), blurRadius: 2)`, icon `Icons.grid_view` (18px, `#153362`), label `"Grid"` (`Inter 12px w600`).
  - List Option (unselected): transparent background, icon `Icons.view_list` (18px, `#6B655D`), label `"List"` (`Inter 12px w500`).
- **Sort By Section**:
  - Header: `"SORT BY"` in `Inter 11px w600 uppercase letterSpacing: 0.05 Color(0xFF6B655D)`.
  - Inset container: `borderRadius: BorderRadius.circular(12)`, `border: Border.all(color: Color(0xFFE8E2D9))`, background: `Color(0xFFFFFFFF)`.
  - 5 Options:
    1. `"Recently read"` (icon `Icons.history`, 20px)
    2. `"Title"` (icon `Icons.sort_by_alpha`, 20px)
    3. `"Author"` (icon `Icons.person_outline`, 20px)
    4. `"Date added"` (icon `Icons.calendar_today`, 20px)
    5. `"Progress"` (icon `Icons.donut_large`, 20px)
  - Radio button styling:
    - Selected: `width: 20dp, height: 20dp`, circular, border `2px Color(0xFF2F4A7A)`, inner white dot `width: 8dp, height: 8dp`.
    - Unselected: `width: 20dp, height: 20dp`, circular, border `1.5px Color(0xFFDCDAD5)`.
- **Format Filter Section**:
  - Header row: `"FORMAT"` in `Inter 11px w600 uppercase` + trailing counter `"2 selected"` (`Inter 11px Color(0xFF6B655D)`).
  - Wrap container: `spacing: 8dp, runSpacing: 8dp`.
  - Chips: `['EPUB', 'PDF', 'TXT', 'Markdown', 'HTML', 'FB2']`.
  - Selected chip: `color: Color(0xFF2F4A7A)`, `borderRadius: 9999`, padding `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`, label in `Inter 12px w600 Color(0xFFFFFFFF)`, trailing icon `Icons.check` (16px).
  - Unselected chip: `color: Color(0xFFFFFFFF)`, border `1px Color(0xFFE8E2D9)`, label in `Inter 12px w500 Color(0xFF1C1B1A)`.
- **Browse By Section**:
  - Header: `"BROWSE BY"` in `Inter 11px w600 uppercase letterSpacing: 0.05 Color(0xFF6B655D)`.
  - Inset container: `borderRadius: BorderRadius.circular(12)`, `border: Border.all(color: Color(0xFFE8E2D9))`.
  - 5 Navigation Rows:
    1. `Authors` (icon `person_outline`, count badge e.g. "14", trailing `chevron_right`)
    2. `Series` (icon `collections_bookmark`, count badge e.g. "4", trailing `chevron_right`)
    3. `Collections` (icon `folder_open`, count badge e.g. "3", trailing `chevron_right`)
    4. `All annotations` (icon `edit_note`, count badge e.g. "42", trailing `chevron_right`)
    5. `Trash` (icon `delete_outline`, count badge e.g. "2", trailing `chevron_right`)
  - Count badge: `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2)`, `color: Color(0xFFF0EDE9)`, `borderRadius: BorderRadius.circular(9999)`, text: `Inter 12px w600 Color(0xFF6B655D)`.
- **Sticky Footer Action**:
  - Padding: `EdgeInsets.fromLTRB(20, 14, 20, 24)`.
  - Container: `border: Border(top: BorderSide(color: Color(0xFFE8E2D9)))`.
  - Button:
    - Key: `Key('apply_filter_sort_button')`
    - Height: `52.0dp`, full width
    - Shape: `StadiumBorder()`
    - Background: `Color(0xFF2F4A7A)`, hover/press `Color(0xFF23395E)`
    - Label: `"Apply Filters"` (or `"Apply"`) in `Inter 14px w600 letterSpacing: 0.2 Color(0xFFFFFFFF)`
    - Trailing icon: `Icon(Icons.arrow_forward, size: 18, color: Colors.white)`

---

### 4. Screen `02d_book_details` (Book Details Sheet)
- **Modal Scrim**: `Color(0x731C1B1A)` (45% opacity) + `ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5)`.
- **Sheet Container**:
  - Background: `Color(0xFFFAF7F2)` / `Color(0xFFFFFFFF)`.
  - Shape: `RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)))`.
  - Border: `1px solid Color(0xFFE8E2D9)` top edge.
  - Drop shadow: `BoxShadow(color: Color(0x2E1C1B1A), blurRadius: 32, offset: Offset(0, -8))`.
- **Header**:
  - Height: `44dp`, `EdgeInsets.symmetric(horizontal: 20, vertical: 8)`.
  - Centered drag handle: `width: 36dp, height: 4dp`, `color: Color(0xFFDCDAD5)`.
  - Trailing close button: `width: 32dp, height: 32dp`, icon `Icons.close` (20px, `#6B655D`).
- **Top Metadata Section**:
  - Layout: `Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Cover, SizedBox(width: 16), Expanded(Details)])`.
  - Book Cover:
    - Width: `130.0dp`, Aspect ratio: `2 / 3` (Height: `195.0dp`).
    - Corner radius: `BorderRadius.circular(8.0)`.
    - Shadow: `BoxShadow(color: Color(0x381C1B1A), blurRadius: 25, offset: Offset(0, 10))` + `BoxShadow(color: Color(0x1A1C1B1A), blurRadius: 8, offset: Offset(0, 4))`.
    - Border: `Border.all(color: Color(0xCCE8E2D9), width: 1.0)`.
    - Page edge effect: `right: 0, width: 1.5dp, color: Color(0x66FFFFFF)`.
  - Details Column:
    - Series tag: `"DUNE CHRONICLES · BOOK 1"` in `Inter 11-12px w600 uppercase tracking-wide Color(0xFF6B655D)`.
    - Title: `"Dune"`
      - Key: `Key('book_details_title_text')`
      - Typography: `Newsreader 24-26px w600 height: 1.25 Color(0xFF1C1B1A)`.
    - Author: `"Frank Herbert"`
      - Typography: `Newsreader 18-19px w400 italic Color(0xFF6B655D)`.
    - Format Pill & Date Row:
      - Format Pill: `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2)`, `color: Color(0xFFEBE8E3)`, `borderRadius: 9999`, `border: Border.all(color: Color(0xFFE8E2D9))`. Text: `"EPUB · 2.4 MB"` in `Inter 11px w600 Color(0xFF6B655D)`.
      - Date: `"Added Oct 14, 2026"` in `Inter 11px w400 Color(0xFF6B655D)`.
    - Reading Progress Inset Card:
      - Container: `padding: EdgeInsets.all(10)`, `color: Color(0xFFFFFFFF)`, `borderRadius: BorderRadius.circular(12)`, border: `Border.all(color: Color(0xFFE8E2D9))`.
      - Row: `"Chapter 12"` in `Inter 11px w500 Color(0xFF1C1B1A)` vs `"48%"` in `Inter 11px w700 Color(0xFF2F4A7A)`.
      - Progress bar: `height: 6dp`, `borderRadius: 9999`, track `Color(0xFFF0EDE9)`, indicator `Color(0xFF2F4A7A)`.
- **Action Buttons Row**:
  - Padding: `EdgeInsets.only(top: 16, bottom: 16)`.
  - Layout: `Row(children: [ReadButton, SizedBox(width: 8), CollectButton, SizedBox(width: 8), EditButton, SizedBox(width: 8), ShareButton])`.
  - 1. Read Button:
    - Key: `Key('book_details_read_button')`
    - Expanded flex widget, height `48dp`
    - Shape: `StadiumBorder()`
    - Background: `Color(0xFF2F4A7A)`, text: `Color(0xFFFFFFFF)`
    - Icon: `Icon(Icons.menu_book, size: 20, color: Colors.white)`
    - Label: `"Read"` in `Inter 14px w600 Color(0xFFFFFFFF)`
  - 2. Collect Button:
    - Height: `48dp`, padding `EdgeInsets.symmetric(horizontal: 14)`
    - Shape: `StadiumBorder()`
    - Surface: `Color(0xFFFFFFFF)`, border `1px Color(0xFFE8E2D9)`
    - Icon: `Icon(Icons.bookmark_add, size: 20, color: Color(0xFF6B655D))`
    - Label: `"Collect"` in `Inter 12px w600 Color(0xFF1C1B1A)`
  - 3. Edit Details Button:
    - Dimensions: `width: 48dp, height: 48dp`, circular
    - Surface: `Color(0xFFFFFFFF)`, border `1px Color(0xFFE8E2D9)`
    - Icon: `Icon(Icons.edit, size: 20, color: Color(0xFF6B655D))`
  - 4. Share Button:
    - Dimensions: `width: 48dp, height: 48dp`, circular
    - Surface: `Color(0xFFFFFFFF)`, border `1px Color(0xFFE8E2D9)`
    - Icon: `Icon(Icons.share, size: 20, color: Color(0xFF6B655D))`
- **Divider**: `1px solid Color(0xFFE8E2D9)`.
- **Prologue Excerpt Quote Card**:
  - Header: `"PROLOGUE EXCERPT"` in `Inter 11-12px w600 uppercase tracking-wide Color(0xFF6B655D)`.
  - Blockquote Container: `padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8)`, `color: Color(0x66F6F3EE)`, `border: Border(left: BorderSide(color: Color(0x662F4A7A), width: 3.0))`.
  - Text: `“A beginning is the time for taking the most delicate care that the balances are correct. This every sister of the Bene Gesserit knows.”` in `Newsreader 18-19px w400 italic height: 1.5 Color(0xFF1C1B1A)`.
- **Detailed Metadata Grid Card**:
  - Container: `borderRadius: BorderRadius.circular(12)`, `border: Border.all(color: Color(0xFFE8E2D9))`, background: `Color(0xFFFFFFFF)`.
  - 5 Key-Value Rows (separated by `1px Color(0xFFE8E2D9)`):
    1. Publisher: `"Publisher"` (`Inter 13px Color(0xFF6B655D)`) -> `"Chilton Books"` (`Inter 14px w600 Color(0xFF1C1B1A)`)
    2. Language: `"Language"` -> `"English (en-US)"` (`Inter 14px w400`)
    3. Encoding: `"Encoding"` -> `"UTF-8"` (`Inter 12px font-mono Color(0xFF1C1B1A) bg: #F0EDE9`)
    4. File path: `"File path"` -> `"/storage/emulated/0/Books/Sci-Fi/Dune.epub"` (`Inter 11px font-mono break-all Color(0xFF6B655D)`)
    5. Volume Length: `"Volume Length"` -> `"187,240 words (~11h read)"` (`Inter 13px w500 Color(0xFF1C1B1A)`)
- **Offline Assurance Badge**:
  - Centered: `Icon(Icons.cloud_off, size: 16, color: Color(0xFF6B655D))` + `"Archived locally · 100% Offline"` (`Inter 11px w500 Color(0xFF6B655D)`).
- **Destructive Action Button**:
  - Key: `Key('book_details_trash_button')`
  - Margin: `EdgeInsets.only(top: 8, bottom: 16)`
  - Height: `44-48dp`, full width
  - Shape: `StadiumBorder()`
  - Border: `BorderSide(color: Color(0xFFBA1A1A), width: 1.0)`
  - Background: `Colors.transparent`, hover: `Color(0x14BA1A1A)`
  - Icon: `Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A))`
  - Label: `"Move to Trash"` in `Inter 14px w600 Color(0xFFBA1A1A)`

---

### 5. Feature 20: Fallback Book Cover Widget
- **File**: `lib/presentation/widgets/book/book_cover.dart`
- **Asset**: `assets/images/fallback_book_cover_default.png` (present in project, resolution `1024×1536`).
- **Rule**:
  When `book.coverPath == null` or the file does not exist on disk, render `Image.asset('assets/images/fallback_book_cover_default.png', fit: BoxFit.cover)` enclosed inside the standard 2:3 `AspectRatio` container with format band overlay and typography.

---

## 5-Component Handoff Report

### 1. Observation
- Verified authoritative HTML templates and metadata files:
  - `design/screens/02_library/02_library_screen.html` (lines 1-414)
  - `design/screens/02_library/02_library_metadata.json` (lines 1-719)
  - `design/screens/02b_empty_library/02b_empty_library_screen.html` (lines 1-209)
  - `design/screens/02b_empty_library/02b_empty_library_metadata.json` (lines 1-782)
  - `design/screens/02c_filter_sort_sheet/02c_filter_sort_sheet_screen.html` (lines 1-390)
  - `design/screens/02c_filter_sort_sheet/02c_filter_sort_sheet_metadata.json` (lines 1-719)
  - `design/screens/02d_book_details/02d_book_details_screen.html` (lines 1-301)
  - `design/screens/02d_book_details/02d_book_details_metadata.json` (lines 1-829)
  - `design/STITCH_UI_IMPLEMENTATION_GUIDE.md` (lines 253-364)
- Verified existing code and test suites:
  - `test/e2e/tier1_features/library_and_books_test.dart` (lines 1-806) passed all 10 tests when executed via `fvm flutter test test/e2e/tier1_features/library_and_books_test.dart`.
  - `test/presentation/screen/home/` passed all 18 cubit and state unit tests via `fvm flutter test test/presentation/screen/home/`.
  - The illustration asset `assets/images/empty_library_shelf.png` (540,790 bytes) and `assets/images/fallback_book_cover_default.png` (951,402 bytes) are verified present.
- Observed that `_LibraryEmpty` in `lib/presentation/screen/home/components/library_content.dart` (lines 946-975) currently renders a generic `StateView` instead of the newly designed centered empty shelf illustration with dual import buttons.
- Observed that `_BookDetailsSheet` in `lib/presentation/screen/home/components/library_book_actions.dart` (lines 380-520) is currently an edit-details form, whereas the authoritative Stitch design `02d_book_details` is a rich overview sheet with cover, reading progress, 4 actions (`Read`, `Collect`, `Edit`, `Share`), prologue quote, metadata grid, and "Move to Trash".

### 2. Logic Chain
1. Milestone 3 encompasses 10 features (Features 11 through 20) across 4 screen designs and the book cover widget.
2. The Stitch HTML source files provide the exact CSS and layout specifications for every component (margins `20dp`, radii `16dp` for cards, `24-28dp` for sheets, `StadiumBorder()` for buttons/chips, color `#2F4A7A` for primary CTAs).
3. E2E contract tests in `test/e2e/tier1_features/library_and_books_test.dart` already validate the widget keys and behaviors (`library_search_button`, `library_settings_button`, `library_import_fab`, `continue_reading_hero_card`, `resume_reading_button`, `recent_books_carousel`, `library_books_3col_grid`, `empty_library_shelf_image`, `empty_import_files_button`, `empty_import_folder_button`, `apply_filter_sort_button`, `book_details_title_text`, `book_details_read_button`, `book_details_trash_button`).
4. Integrating the extracted specifications into `home_portrait_view.dart`, `library_content.dart`, `filter_sort_sheet.dart`, `library_book_actions.dart`, and `book_cover.dart` will satisfy all acceptance criteria of Milestone 3 without breaking cubit state or regressions.

### 3. Caveats
- No project code was modified in accordance with the read-only specification miner protocol.
- The dispatch message noted the empty state headline as "Your library is empty" or "Your shelf is quiet". The HTML template specifies "Your shelf is quiet" and E2E test `library_and_books_test.dart:368` checks for `"Your shelf is quiet"`. Workers should implement "Your shelf is quiet" (or support both as valid localization strings).
- Book Details sheet action button 2 has label "Collect" in the HTML template and "Add to collection" in dispatch; both represent the same action (`_BookAction.collections`).

### 4. Conclusion
The specification for Milestone 3 (Library & Book Management) has been completely extracted and documented. All hex colors, typography tokens, dimensions, corner radii, widget keys, and edge cases are captured above in exact detail, ready for immediate implementation by the Milestone 3 worker.

### 5. Verification Method
1. Inspect the extracted specifications in this document against `design/screens/02_library/02_library_screen.html`, `design/screens/02b_empty_library/02b_empty_library_screen.html`, `design/screens/02c_filter_sort_sheet/02c_filter_sort_sheet_screen.html`, and `design/screens/02d_book_details/02d_book_details_screen.html`.
2. Run the E2E contract test suite:
   ```bash
   fvm flutter test test/e2e/tier1_features/library_and_books_test.dart
   ```
3. Run the existing home presentation unit test suite:
   ```bash
   fvm flutter test test/presentation/screen/home/
   ```
4. Verify all tests pass with 0 failures and 0 regressions.

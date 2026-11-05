# Handoff Report: Exhaustive Design Specification & Token Survey

**Agent ID:** `spec_miner_survey_1`  
**Parent Agent:** `2283687a-5c7c-4e1f-9d03-d89b8d745253`  
**Timestamp:** 2026-11-04T19:25:00Z  
**Type:** Hard Handoff  

---

## 1. Observation

### 1.1 Inspected Authoritative Sources
1. **User Request & Requirements:**
   - Path: `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/ORIGINAL_REQUEST.md` (Lines 1–110).
   - Core Mandate: Material 3 Warm Editorial Minimalism; 412×915 dp viewport; pixel-by-pixel fidelity; strictly **NO persistent bottom navigation bar** anywhere.
2. **Master Implementation Blueprint:**
   - Path: `design/STITCH_UI_IMPLEMENTATION_GUIDE.md` (Lines 1–633).
   - Contains exact token matrix, screen-by-screen breakdown, and verification protocol.
3. **Screen Manifest & Directory Catalog:**
   - Path: `design/screens/screens_manifest.json` (19 screen slugs, 4 standalone stitch assets).
   - Path: `design/screens/README.md` (Catalog linking HTML templates, mockups, and node IDs).
   - 19 screen directories under `design/screens/` inspected across HTML, CSS, and metadata.
4. **Local Standalone Assets:**
   - Path: `assets/images/` checked via `file` and `ls -la`:
     - `book_cover_dune.png` (848×1264 px, 2:3 ratio)
     - `empty_library_shelf.png` (1024×1024 px, 1:1 ratio)
     - `fallback_book_cover_default.png` (848×1264 px, 2:3 ratio)
     - `onboarding_hero_illustration.png` (1024×1024 px, 1:1 ratio)
     - `onboarding_page_2_reading_styles.png` (1024×1024 px, 1:1 ratio)
     - `onboarding_page_3_read_aloud.png` (1024×1024 px, 1:1 ratio)
     - `onboarding_page_4_privacy.png` (1024×1024 px, 1:1 ratio)
     - `explore-icon.svg`, `settings-icon.svg`
5. **Existing Codebase State:**
   - Path: `lib/presentation/screen/dashboard/dashboard_portrait.dart` (Lines 18–33): currently implements `bottomNavigationBar: NavigationBar(...)` which directly violates the non-negotiable architectural constraint.
   - Path: `lib/presentation/theme/base/app_colors.dart` and `lib/presentation/theme/dark/`: dark color theme implemented, but Warm Editorial light theme (`#FAF7F2`, `#1C1B1A`, `#E8E2D9`, `#2F4A7A`, `#D6E2F5`, `#F6F1E7`) needs to be fully wired up as the default theme.

---

## 2. Logic Chain

1. **Derivation of Coordinates and Sizing:**
   All 19 screens in `design/screens/` were compiled from Tailwind CSS schemas at `1rem = 16px`. Standard margins are `px-5` (`20px`), card padding is `p-4` (`16px`), and sheet headers are `px-5 py-3.5` (`20px × 14px`). Corner radii follow semantic tokens: cards = `rounded-2xl` (`16px`), sheets = `rounded-t-[24px]` / `rounded-t-[28px]`, action chips & CTA buttons = `rounded-full` (`StadiumBorder()`).
2. **Typography System Logic:**
   Editorial hierarchy uses `Newsreader` (serif) for book titles, headings, and reader text for warm literary immersion, and `Inter` (sans-serif) for UI controls, metadata badges, timestamps, and body labels. Counters, timers, and percentages require `FontFeature.tabularFigures()`.
3. **No Bottom Navigation Bar Mandate:**
   Examining `design/screens/02_library/02_library_screen.html`, `design/screens/03_settings/03_settings_screen.html`, and `design/STITCH_UI_IMPLEMENTATION_GUIDE.md` reveals that OpenPages does not have a persistent `NavigationBar`. Navigation between library, settings, reader, and annotations is contextual. The existing `DashboardPortrait` with bottom navigation bar must be replaced or stripped of its `bottomNavigationBar`.
4. **Color Palette Mapping:**
   The Warm Editorial palette anchors the experience: Canvas `#FAF7F2`, Elevated Card Surfaces `#FFFFFF`, Hairline `#E8E2D9`, Text `#1C1B1A`, Secondary `#6B655D`, Accent `#2F4A7A`, Read-Aloud Highlight `#D6E2F5`, Reader Paper Canvas `#F6F1E7`, and Destructive `#BA1A1A`.

---

## 3. Caveats

1. **Lock Screen Implementation (`06_lock_screen`):**
   Screen 06 depicts the Android 15 Lock Screen MediaSession notification card. In Flutter, native lock screen rendering is handled by the OS media session subsystem (via `audio_service` / `MediaSessionCompat`). The specification describes the exact metadata, playback actions, and artwork format required to feed the native session.
2. **Side Sheet vs Bottom Sheet on Compact Viewports (`04d_contents_annotations`):**
   In HTML reference, `04d` is rendered as an 85% width drawer sliding from the left (leaving ~15% scrimmed reader visible on the right). On narrow phones or landscape, it behaves responsively as a navigation drawer / bottom sheet.

---

## 4. Conclusion

All design tokens, 19 screen slugs (16 functional screens/sheets), assets, interactions, and strict architectural constraints have been mined, verified, and cross-referenced with exact HTML and reference PNG files. The complete specification is documented below.

---

## 5. Verification Method

To verify these findings:
1. Compare tokens against `design/STITCH_UI_IMPLEMENTATION_GUIDE.md` §3 and §4.
2. View HTML templates in `design/screens/<slug>/<slug>_screen.html`.
3. View high-resolution retina mockups in `design/screens/<slug>/<slug>_screen.png`.
4. Run `flutter analyze` and `flutter test` to ensure existing tests pass before implementation.

---

# SECTION A: MASTER TOKEN SPECIFICATION

### A.1 Color Palette

| Token Name | Hex Code | Flutter Definition | Semantic Purpose & Usage |
|---|---|---|---|
| `background` | `#FAF7F2` | `const Color(0xFFFAF7F2)` | Warm ivory app canvas, page background |
| `surface` | `#FFFFFF` | `const Color(0xFFFFFFFF)` | Elevated cards, dialogs, input fields |
| `surfaceDim` | `#F0EDE9` | `const Color(0xFFF0EDE9)` | Secondary container, inactive chip fills |
| `surfaceContainerLow` | `#F6F3EE` | `const Color(0xFFF6F3EE)` | Tonal background for sub-panels |
| `surfaceContainerHighest` | `#E5E2DD` | `const Color(0xFFE5E2DD)` | Inactive toggle tracks, dividers |
| `hairline` | `#E8E2D9` | `const Color(0xFFE8E2D9)` | 1px border on cards, sheets, chips, dividers |
| `paperReader` | `#F6F1E7` | `const Color(0xFFF6F1E7)` | Dedicated reader paper canvas background |
| `primaryInk` | `#1C1B1A` | `const Color(0xFF1C1B1A)` | Primary headlines, titles, body reading text |
| `secondarySlate` | `#6B655D` | `const Color(0xFF6B655D)` | Metadata, subtitles, secondary captions, icons |
| `outline` | `#747780` | `const Color(0xFF747780)` | Inactive slider tracks, subtle outlines |
| `outlineVariant` | `#C4C6D0` | `const Color(0xFFC4C6D0)` | Secondary border/track tone |
| `accentInkBlue` | `#2F4A7A` | `const Color(0xFF2F4A7A)` | Primary CTA buttons, active pills, progress bars |
| `accentHover` | `#23395E` | `const Color(0xFF23395E)` | Active/pressed state for primary buttons |
| `accentContainer` | `#D6E2F5` | `const Color(0xFFD6E2F5)` | Read aloud sentence highlight band |
| `destructive` | `#BA1A1A` | `const Color(0xFFBA1A1A)` | Move to trash, delete, destructive actions |
| `destructiveContainer` | `#FFDAD6` | `const Color(0xFFFFDAD6)` | Container fill for warnings/errors |

#### Highlighting Annotations Palette
| Highlight Name | Hex Code | Flutter Definition | Usage |
|---|---|---|---|
| `highlightYellow` | `#FDE047` / `#FFD54F` | `const Color(0xFFFDE047)` | General literary highlights |
| `highlightGreen` | `#86EFAC` / `#4E8752` | `const Color(0xFF86EFAC)` | Quotes, sensory passages |
| `highlightBlue` | `#93C5FD` / `#2F4A7A` | `const Color(0xFF93C5FD)` | Key concepts, philosophy |
| `highlightPink` | `#F472B6` / `#F06292` | `const Color(0xFFF472B6)` | Character definitions, emotion |
| `highlightOrange` | `#FDBA74` / `#C85A54` | `const Color(0xFFFDBA74)` | Themes, epigraphs, warnings |
| `highlightAmber` | `#E5A93C` / `#D99B26` | `const Color(0xFFE5A93C)` | Chapter active notes strip |

#### Reader Theme Swatches
| Swatch | Hex Code | Locked? | Background Color | Text Color |
|---|---|---|---|---|
| `Paper` | `#F6F1E7` | Free (Default) | `Color(0xFFF6F1E7)` | `Color(0xFF1C1B1A)` |
| `White` | `#FFFFFF` | Free | `Color(0xFFFFFFFF)` | `Color(0xFF1C1B1A)` |
| `Sepia` | `#F4ECD8` | Free | `Color(0xFFF4ECD8)` | `Color(0xFF382E1E)` |
| `Grey` | `#EAE6DF` | Free | `Color(0xFFEAE6DF)` | `Color(0xFF242220)` |
| `Night` | `#23272A` | Premium (Lock) | `Color(0xFF23272A)` | `Color(0xFFE3E5E8)` |
| `OLED` | `#121212` | Premium (Lock) | `Color(0xFF121212)` | `Color(0xFFFAF7F2)` |

#### Premium Paywall Themes
| Theme Name | Background | Border | Primary Text | Accent |
|---|---|---|---|---|
| `Warm Linen` | `#F5EFEB` | `#E3DDD4` | `#2D2A26` | `#A67C47` |
| `Midnight Blue`| `#161E2E` | `#25324B` | `#FAF7F2` | `#8EA7D8` |
| `Forest` | `#1B2921` | `#283E32` | `#F3EFEA` | `#6E9E81` |

---

### A.2 Typography Hierarchy

Headings and editorial titles use **Newsreader** (Google Fonts). Controls, metadata, body UI, and buttons use **Inter** (Google Fonts).

| Token | Font Family | Size | Weight | Line Height | Letter Spacing | Flutter Implementation |
|---|---|---|---|---|---|---|
| `display-lg` | Newsreader | `36px` | 400 | `44px` | `-0.02em` | `GoogleFonts.newsreader(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22, letterSpacing: -0.72)` |
| `display-lg-mobile`| Newsreader | `30px` | 400 | `38px` | `-0.015em`| `GoogleFonts.newsreader(fontSize: 30, fontWeight: FontWeight.w400, height: 1.27, letterSpacing: -0.45)` |
| `headline-lg` | Newsreader | `26px` | 500 / 600| `34px` | `-0.01em` | `GoogleFonts.newsreader(fontSize: 26, fontWeight: FontWeight.w600, height: 1.30, letterSpacing: -0.26)` |
| `headline-md` | Newsreader | `22px` | 500 / 600| `28px` | `-0.01em` | `GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: -0.22)` |
| `headline-sm` | Newsreader | `18px` | 600 | `26px` | `0.0em` | `GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w600, height: 1.44)` |
| `body-lg` (Reader)| Newsreader | `18px` | 400 | `28px` | `0.01em` | `GoogleFonts.newsreader(fontSize: 18, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0.18)` |
| `body-md` | Inter | `15px` / `16px` | 400 | `22px` / `24px` | `-0.005em`| `GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.47, letterSpacing: -0.08)` |
| `body-sm` | Inter | `13px` | 400 | `18px` | `0.0em` | `GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.38)` |
| `label-lg` | Inter | `14px` | 600 | `20px` | `0.01em` | `GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.42, letterSpacing: 0.14)` |
| `label-md` | Inter | `12px` | 500 / 600| `16px` | `0.02em` | `GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.24)` |
| `label-sm` | Inter | `11px` | 500 | `14px` | `0.03em` | `GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.27, letterSpacing: 0.33)` |

*Note: All page numbers, counters, timestamps, and percentages MUST apply `fontFeatures: [FontFeature.tabularFigures()]`.*

---

### A.3 Radii, Borders, and Elevation

| Component | Radius Value | Flutter Border / Shape |
|---|---|---|
| **Cards (Containers)** | `16.0` (`rounded-2xl`) | `BorderRadius.circular(16.0)` |
| **Bottom Sheets** | `24.0` / `28.0` (`rounded-3xl` / `rounded-t-[28px]`) | `const BorderRadius.vertical(top: Radius.circular(24.0))` |
| **Chips / Filter Pills**| Full Stadium (`rounded-full`) | `const StadiumBorder()` or `BorderRadius.circular(9999)` |
| **Action CTA Buttons** | Full Stadium (`height: 48–56px`) | `const StadiumBorder()` |
| **Book Covers** | `4.0` – `8.0` (`rounded` / `rounded-lg`) | `BorderRadius.circular(4.0)` (or `8.0` for large covers) |
| **Dialogs / Menus** | `16.0` – `20.0` | `BorderRadius.circular(16.0)` |
| **Standard Hairline** | Width `1.0px` | `Border.all(color: const Color(0xFFE8E2D9), width: 1.0)` |

#### Shadows Matrix
```dart
// Book cover soft diffuse drop shadow (2:3 aspect ratio)
final bookCoverShadow = [
  const BoxShadow(
    color: Color(0x1F000000), // ~12% black
    blurRadius: 16.0,
    offset: Offset(0, 8.0),
  ),
];

// Card subtle elevation
final cardShadow = [
  const BoxShadow(
    color: Color(0x081C1B1A), // 3%
    blurRadius: 8.0,
    offset: Offset(0, 2.0),
  ),
];

// Modal Bottom Sheet elevation
final bottomSheetShadow = [
  const BoxShadow(
    color: Color(0x1F1C1B1A), // 12%
    blurRadius: 32.0,
    offset: Offset(0, -8.0),
  ),
];

// Primary Action CTA button shadow
final buttonCtaShadow = [
  const BoxShadow(
    color: Color(0x2E2F4A7A), // 18% primary ink blue
    blurRadius: 12.0,
    offset: Offset(0, 4.0),
  ),
];

// Floating Action Button (FAB)
final fabShadow = [
  const BoxShadow(
    color: Color(0x47153362), // 28% deep ink blue
    blurRadius: 20.0,
    offset: Offset(0, 8.0),
  ),
];
```

---

### A.4 Spacing & Margins Matrix
- **Screen Lateral Margin:** `20px` (`EdgeInsets.symmetric(horizontal: 20.0)` or `px-5`)
- **Card Inner Padding:** `16px` (`EdgeInsets.all(16.0)` or `p-4`)
- **Vertical Section Spacing:** `24px` – `28px` (`SizedBox(height: 24.0)` or `space-y-7`)
- **List / Grid Spacing:** Horizontal gap `12px`, vertical gap `16px` (`crossAxisSpacing: 12, mainAxisSpacing: 16`)
- **Chip Horizontal Row Gap:** `8px` (`gap: 8.0`)

---

# SECTION B: SCREEN-BY-SCREEN SPECIFICATION (ALL 19 SLUGS)

---

### 01a. Onboarding Page 1: Formats & Offline
- **Slug / Node ID:** `01_onboarding` / `ce71ef5341e7435abff9e5eab14d0402`
- **Target File:** `lib/presentation/screen/onboarding/onboarding_screen.dart` (`PageView` index 0)
- **Visual Reference:** `design/screens/01_onboarding/01_onboarding_screen.png` & `01_onboarding_screen.html`
- **Asset Used:** `assets/images/onboarding_hero_illustration.png` (Aspect 1:1, centered, max-width 320px)
- **Layout Hierarchy:**
  - Status Bar (9:41, wifi, cellular, battery)
  - Top Bar (`px-5 py-3.5`): Leading `local_library` icon in `#153362` + "OpenPages" in `Newsreader 22px w500`. Trailing "Skip" button in `Inter 12px w500 #44474F`.
  - Hero Stage (Top ~52%): Soft radial glow `#F6F3EE` (288×288px blur-2xl) + Centered book illustration (aspect 1:1).
  - Copy Block:
    - Headline: `"Your books, all in one place"` (`Newsreader 30px w400`, line height 38px, letter spacing -0.015em).
    - Subtitle: `"EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone."` (`Inter 15px w400 #635D56`).
  - Format Pills Row (gap 6px): Badges for `EPUB`, `PDF`, `TXT`, `MD`, `FB2` (`bg #FFFFFF`, border `1px #E8E2D9`, radius full, padding 10×4px, `Inter 11px w500 #635D56`).
  - Indicator Dots (gap 8px): Dot 1 active (w-24px, h-8px, radius-full, `#2F4A7A`), Dots 2, 3 inactive (w-8px, h-8px, `#CEC5BB`).
  - Action Footer (`px-6 pt-4 pb-8`):
    - Primary CTA: Height 56px, Stadium container, `bg #2F4A7A`, label `"Next"` (`Inter 14px w600 #FFFFFF`) + `arrow_forward` icon (18px).
    - Offline note: Lock icon (14px) + `"Offline-first & zero telemetry"` (`Inter 11px #635D56`).

---

### 01b. Onboarding Page 2: Reading Styles
- **Slug / Node ID:** `01b_onboarding_page2` / `ebb14c4cc542497d8d69e7b450363062`
- **Target File:** `lib/presentation/screen/onboarding/onboarding_screen.dart` (`PageView` index 1)
- **Visual Reference:** `design/screens/01b_onboarding_page2/01b_onboarding_page2_screen.png` & `.html`
- **Asset Used:** `assets/images/onboarding_page_2_reading_styles.png` (Aspect 1:1, max-width 340px)
- **Layout Hierarchy:**
  - Top Bar: Brand mark + "OpenPages" + "Skip" button.
  - Hero Card (`aspect-[4/3.8]`, `rounded-2xl`, border `1px #E8E2D9`): Illustration of open volume with typography samples & bookmark ribbons.
  - Feature Pills Row (gap 8px):
    - `format_size` + `"Custom Fonts"`
    - `format_align_justify` + `"Margins & Spacing"`
    - `stylus_note` + `"Highlights & Notes"`
  - Copy Block:
    - Headline: `"Read the way you like"` (`Newsreader 26px w500`).
    - Subtitle: `"Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page."` (`Inter 15px w400 #635D56`).
  - Indicators: Dot 2 active (`24×8px #2F4A7A`), Dots 1, 3, 4 circular (`8×8px #C4C6D0`).
  - Action Footer: Height 48px/56px Stadium CTA `"Next"`, Offline note: `"100% Offline • Zero telemetry & personal storage"`.

---

### 01c. Onboarding Page 3: Read Aloud
- **Slug / Node ID:** `01c_onboarding_page3` / `20ed4f1571d044229f5caa0a4ddcc73d`
- **Target File:** `lib/presentation/screen/onboarding/onboarding_screen.dart` (`PageView` index 2)
- **Visual Reference:** `design/screens/01c_onboarding_page3/01c_onboarding_page3_screen.png` & `.html`
- **Asset Used:** `assets/images/onboarding_page_3_read_aloud.png` (Aspect 1:1, max-width 310px)
- **Layout Hierarchy:**
  - Hero Frame (`rounded-3xl`, bg `#FFFFFF`, border `1px #E8E2D9`): Acoustic resonance soundwaves and book illumination.
  - Feature Pills Row:
    - `record_voice_over` + `"Natural Voices"`
    - `format_underlined` + `"Sentence Tracking"`
    - `bedtime` + `"Sleep Timer"`
  - Copy Block:
    - Headline: `"Listen when your eyes rest"` (`Newsreader 30px w400`).
    - Subtitle: `"Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked."` (`Inter 15px w400 #635D56`).
  - Indicators: Dot 3 active (`24×8px #2F4A7A`), Dots 1, 2, 4 circular.
  - Action Footer: Stadium CTA `"Next"` + Note: `"Offline-first & zero telemetry · Background audio session"`.

---

### 01d. Onboarding Page 4: Privacy & Dictionary
- **Slug / Node ID:** `01d_onboarding_page4` / `8a586c73cb324ef38359eac34e6ee3ce`
- **Target File:** `lib/presentation/screen/onboarding/onboarding_screen.dart` (`PageView` index 3)
- **Visual Reference:** `design/screens/01d_onboarding_page4/01d_onboarding_page4_screen.png` & `.html`
- **Asset Used:** `assets/images/onboarding_page_4_privacy.png` (Aspect 1:1, max-width 348px)
- **Layout Hierarchy:**
  - Hero Frame (`rounded-3xl`, bg `#FFFFFF`, border `1px #E8E2D9`): Antique leatherbound volume with brass padlock and dictionary proof sheets.
  - Feature Pills Row:
    - `lock` + `"100% Offline Vault"`
    - `shield` + `"Zero Telemetry"`
    - `translate` + `"Offline Dictionary"`
  - Copy Block:
    - Headline: `"Private by design"` (`Newsreader 26px w500`).
    - Subtitle: `"No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup."` (`Inter 15px w400`).
  - Indicators: Dot 4 active (`24×8px #2F4A7A`), Dots 1, 2, 3 circular.
  - Dual Action Area:
    - Primary CTA: Height 48px/56px stadium button, `bg #2F4A7A`, icon `folder_open`, text `"Import your first book"` (`Inter 14px w600 white`).
    - Secondary Action: Text button `"Explore first"` (`Inter 12px w500 #6B655D`).
    - Reassurance Note: `"Archived locally • Zero cloud sync required"`.

---

### 02. Library Home
- **Slug / Node ID:** `02_library` / `9d845920b6d64a1bbe0f24b877a97774`
- **Target File:** `lib/presentation/screen/home/home_portrait_view.dart` & `library_content.dart`
- **Visual Reference:** `design/screens/02_library/02_library_screen.png` & `.html`
- **Layout Hierarchy:**
  - Status Bar (9:41)
  - Top App Bar (`px-5 pt-3 pb-3`):
    - Leading: `local_library` icon (24px, `#2F4A7A`) + Title `"Library"` (`Newsreader 22px w600 #1C1B1A`).
    - Trailing: `search` icon button (22px) and `tune` / `settings` icon button (22px).
  - Section 1: "Continue reading" + "Offline storage" tag
    - Hero Card (`rounded-2xl`, bg `#FFFFFF`, border `1px #E8E2D9`, shadow `0 2px 8px rgba(28,27,26,0.03)`):
      - Left: Cover `96×144px` (2:3 aspect ratio, subtle spine highlight, rounded-lg, soft drop shadow).
      - Right Details (height 144px, flex between):
        - Format badge (`EPUB`) + `"Added recently"`.
        - Title: `"The Shadow of the Wind"` (`Newsreader 18px w600`).
        - Author: `"Carlos Ruiz Zafón"` (`Inter 13px #6B655D`).
        - Progress Row: `"Chapter 7"` and `"64%"` (`#2F4A7A`).
        - Progress Bar: Height 4px, bg `#E8E2D9`, fill `#2F4A7A` at 64%.
        - Button: Stadium pill (height 38px, bg `#2F4A7A`), icon `auto_stories` (17px) + `"Resume"` (`Inter 12px w600 white`).
  - Recent Carousel: Horizontal list, cards width 210px (`rounded-xl`, border `1px #E8E2D9`, cover `48×64px`).
    - Mini circular progress ring (SVG 20×20, r=7, stroke 2.5px, stroke-dashoffset matching progress).
    - Book 1: `"Stoner"` by John Williams (`Ch. 4`, 42%).
    - Book 2: `"Essays"` by Michel de Montaigne (`Bk. 1`, 18%).
    - Book 3: `"Selected Poems"` by Tomas Tranströmer (`p. 182`, 85%).
  - Section 2: Horizontal Filter Pills (`px-5`):
    - Active Pill: `"All"` (`bg #2F4A7A`, text white).
    - Outlined Pills: `"Reading"`, `"To read"`, `"Finished"`, `"Favorites"`, `"Collections ▾"` (`bg #FFFFFF`, border `1px #E8E2D9`, text `#6B655D`).
    - Sort Button: Circular outline button with `swap_vert` icon.
  - Section 3: All Books 3-Column Grid (`gap: 12px`):
    - Subheader: `"All volumes (28)"` + sort dropdown `"Recent ▾"`.
    - Grid cells: Aspect 2:3 cover, format overlay badge top-right (`EPUB`, `PDF`, `TXT`, `FB2`), in-progress bottom bar or finished checkmark circle (`Ficciones`), Title in `Newsreader 13.5px line-clamp-2`, Author in `Inter 11px #6B655D`.
  - Floating Action Button (FAB): Extended pill FAB bottom-right (`#2F4A7A`), icon `add` (20px), text `"Import"` (`Inter 14px w600 white`).
  - **Constraint:** Strictly NO persistent bottom navigation bar.

---

### 02b. Empty Library State
- **Slug / Node ID:** `02b_empty_library` / `e53734ed1e36444c8244209319139409`
- **Target File:** `lib/presentation/screen/home/components/library_content.dart` (`_LibraryEmpty`)
- **Visual Reference:** `design/screens/02b_empty_library/02b_empty_library_screen.png` & `.html`
- **Asset Used:** `assets/images/empty_library_shelf.png` (280×220px container)
- **Layout Hierarchy:**
  - Top App Bar with "Library", Search, and Settings buttons.
  - Centered Empty Content Column:
    - Serene Illustration: `Image.asset('assets/images/empty_library_shelf.png', width: 280, height: 220)`.
    - Headline: `"Your shelf is quiet"` (`Newsreader 30px w400 #1C1B1A`).
    - Body: `"Import a DRM-free book or a whole folder to start reading."` (`Inter 15px w400 #6B655D`).
    - Action Cluster (max-width 320px):
      - Primary Button: Height 48px, Stadium container, `bg #2F4A7A`, icon `upload_file`, text `"Import files"`.
      - Secondary Button: Height 48px, Stadium container, `border: 1.5px solid #2F4A7A`, `bg #FFFFFF`, icon `folder_open`, text `"Import a folder"`.
    - Format & Privacy Badge: Shield icon + `"Supports EPUB, PDF, TXT, Markdown, HTML, FB2 · Stored locally"`.

---

### 02c. Filter & Sort Bottom Sheet
- **Slug / Node ID:** `02c_filter_sort_sheet` / `7a5f6480a9dd4f94874d0c16e35b4dbe`
- **Target File:** `lib/presentation/screen/home/components/filter_sort_sheet.dart`
- **Visual Reference:** `design/screens/02c_filter_sort_sheet/02c_filter_sort_sheet_screen.png` & `.html`
- **Layout Hierarchy:**
  - Scrim: Dimmed backdrop `#1C1C19` at 35% opacity with 3px blur.
  - Modal Bottom Sheet: Top radius `28px`, background `#FFFFFF`, border-top `1px #E8E2D9`, shadow `0 -8px 32px rgba(28,27,26,0.12)`.
  - Drag handle: `40×6px` pill, `#DCDAD5`.
  - Header: Title `"Filter & Sort"` (`Newsreader 18px w500`) + `"Reset"` text button right-aligned.
  - View Mode Toggle: Full stadium segmented control with `"Grid"` (`grid_view`, active white card) vs `"List"` (`view_list`).
  - Sort by Radio Group (enclosed card with `1px #E8E2D9` border):
    - Rows: `"Recently read"` (active, `#2F4A7A` filled radio), `"Title"`, `"Author"`, `"Date added"`, `"Progress"`.
  - Format Multi-Select Chips (gap 8px):
    - Selected pills (`#2F4A7A`, white text + check icon): `EPUB`, `PDF`.
    - Unselected pills (`#FFFFFF`, border `1px #E8E2D9`, text `#1C1B1A`): `TXT`, `Markdown`, `HTML`, `FB2`.
  - Browse by Category List (enclosed card with dividers):
    - Authors (`person_outline`, count badge `14`, chevron)
    - Series (`collections_bookmark`, count badge `4`, chevron)
    - Collections (`folder_open`, count badge `3`, chevron)
    - All annotations (`edit_note`, count badge `42`, chevron)
    - Trash (`delete_outline`, count badge `2`, chevron)
  - Sticky Footer Bar: Height 52px Stadium CTA `"Apply Filters"` (`#2F4A7A`, white text + arrow forward icon).

---

### 02d. Book Details Sheet
- **Slug / Node ID:** `02d_book_details` / `54ac31aea72a4e83b1e04e7c24d681e7`
- **Target File:** `lib/presentation/screen/home/components/library_book_actions.dart`
- **Visual Reference:** `design/screens/02d_book_details/02d_book_details_screen.png` & `.html`
- **Asset Used:** `assets/images/book_cover_dune.png` (or dynamic book cover, fallback `fallback_book_cover_default.png`)
- **Layout Hierarchy:**
  - Modal Bottom Sheet: Top radius `24px`, background `#FAF7F2`, drag handle + close `"✕"` button.
  - Header Row (`gap: 16px`):
    - Left: Book Cover `130×195px` (2:3 aspect ratio, rounded-lg, spine emboss, drop shadow).
    - Right Metadata:
      - Series: `"DUNE CHRONICLES · BOOK 1"` (`Inter 12px w600 uppercase #6B655D`).
      - Title: `"Dune"` (`Newsreader 26px w600`).
      - Author: `"Frank Herbert"` (`Newsreader 18px italic #6B655D`).
      - Format Pill: `"EPUB · 2.4 MB"` + `"Added Oct 14, 2026"`.
      - Reading Progress Card: `"Chapter 12"` / `"48%"` with 6px linear progress bar.
  - Action Buttons Row:
    - Primary CTA: Height 48px, Stadium container, `bg #2F4A7A`, icon `menu_book`, text `"Read"`.
    - Secondary: `"Collect"` (`bookmark_add`), `"Edit"` (`edit`), `"Share"` (`share`).
  - Synopsis Block:
    - Label: `"PROLOGUE EXCERPT"`
    - Blockquote (with left 2px bar `#2F4A7A`): *“A beginning is the time for taking the most delicate care that the balances are correct. This every sister of the Bene Gesserit knows.”*
  - Metadata Grid Card (enclosed card with dividers):
    - Publisher: `"Chilton Books"`
    - Language: `"English (en-US)"`
    - Encoding: `"UTF-8"` (monospace badge)
    - File path: `"/storage/emulated/0/Books/Sci-Fi/Dune.epub"` (monospace)
    - Volume Length: `"187,240 words (~11h read)"`
  - Offline Badge: `cloud_off` + `"Archived locally · 100% Offline"`.
  - Destructive Danger Button: Height 44px stadium button, border `1px #BA1A1A`, text `#BA1A1A`, icon `delete`, label `"Move to Trash"`.

---

### 03. Settings Screen
- **Slug / Node ID:** `03_settings` / `0e2582dd012247b68a3368ad5eba12c8`
- **Target File:** `lib/presentation/screen/settings/settings_portrait_view.dart`
- **Visual Reference:** `design/screens/03_settings/03_settings_screen.png` & `.html`
- **Layout Hierarchy:**
  - Top Bar: Arrow back button, Title `"Settings"` (`Newsreader 22px w500`), trailing badge `"Offline"`.
  - Patron Promotion Banner (`rounded-2xl`, bg `#FFFFFF`, border `1px #2F4A7A/20`):
    - Badge: `verified` + `"PATRON EDITION"`.
    - Headline: `"Unlock 12 themes and 8 fonts"`.
    - Subtitle: `"Support private, DRM-free offline reading."`.
    - Button: `"Unlock"` (`bg #2F4A7A`, text white).
  - Group 1: Appearance
    - App Theme: Segmented pill (Light [active], Dark, System).
    - Interface scale: Slider with `A` and `A` labels (80%–130%, default 100%).
  - Group 2: Reading Defaults
    - Paper tone swatches: Ivory (`#FAF7F2`, active check), Sepia (`#F4ECD8`), Slate (`#2B2D31`), OLED (`#0F0F10`).
    - Default typeface: Newsreader (active check), Inter Sans, Literata.
    - Tap zones & gestures: Chevron navigation to subpage.
    - Volume keys turn pages: Toggle switch (enabled).
    - Keep screen on while reading: Toggle switch (enabled).
  - Group 3: Read Aloud (TTS)
    - Default voice: `"English (US) — Natural"`.
    - Reading speed slider: 0.5x to 2.5x with step 0.1, badge `"1.0x"`.
    - Skip page numbers & footnotes: Toggle switch (enabled).
  - Group 4: Library & Backup
    - Import a folder: Auto-sync DRM-free files.
    - Auto-mark finished at 100%: Toggle switch (enabled).
    - Trash auto-empty: Dropdown selector (`"30 days"`).
    - Local Vault Snapshot: Dual outlined buttons `"Back up now"` and `"Restore backup"`.
  - Group 5: About & Licenses
    - Dictionary sources: `"Wiktionary, CC BY-SA 3.0"`.
    - Open-source licenses: `"MuPDF, Readium, Foliate engines"`.
    - Offline privacy manifest: `"No analytics, no cloud tracking, 0 telemetry"`.
    - Version & Quote: `"OpenPages v1.0.0 (Build 104) · 100% Offline & Private"`, *“A serene sanctuary for personal stewardship.”*

---

### 04. Reader Screen (Chrome Visible)
- **Slug / Node ID:** `04_reader_chrome_visible` / `80a5b42582244aea8c4661094117f3f7`
- **Target File:** `lib/presentation/screen/reader/reader_screen.dart` & `reader_chrome.dart`
- **Visual Reference:** `design/screens/04_reader_chrome_visible/04_reader_chrome_visible_screen.png` & `.html`
- **Layout Hierarchy:**
  - Canvas: Warm Paper Reader background `#F6F1E7`.
  - Underlying Reading Text: Running head ("The Shadow of the Wind · Carlos Ruiz Zafón"), Chapter heading ("Chapter Four: The Silent Harbour"), drop cap "I", justified body text (`Newsreader 18px`, line height 1.72).
  - Left Edge Brightness Rail: Floating capsule (`left: 10px`, top 50%), brightness icon, vertical slider track with thumb (height 65%), label `"65"`.
  - Top Chrome Overlay: Translucent paper `#F6F1E7/90` with blur, hairline border `#E8E2D9`.
    - Left: Arrow back button.
    - Center: Book title (`Newsreader 15px w600`) + Author (`Inter 11px`).
    - Right: Search button, Bookmark outline button, Overflow menu ⋮.
  - Bottom Chrome Panel: Translucent paper `#FAF7F2/95` with blur, top radius `28px`, border-top `1px #E8E2D9`, shadow `0 -8px 28px rgba(28,27,26,0.08)`.
    - Grab handle pill (`40×4px`).
    - Status Row: `"Chapter Four"`, `"Page 142 of 380 · 12 min left in chapter"`, percentage badge `"37%"`.
    - Scrubber Row: Previous chapter button, draggable slider with chapter tick marks along the track, Next chapter button.
    - 4 Tool Buttons Grid (outlined rounded-xl cards):
      1. `Contents` (`format_list_bulleted` / `toc_rounded`)
      2. `Appearance` (`text_fields` / `text_format_rounded`)
      3. `Listen` (`headphones`)
      4. `Notes` (`edit_note`)

---

### 04-var. Reader Screen (Zen Mode / Chrome Hidden)
- **Slug / Node ID:** `04_reader_chrome_hidden` / `b868e1ced50640ff8de1949fcb0f8c2e`
- **Target File:** `lib/presentation/screen/reader/reader_screen.dart`
- **Visual Reference:** `design/screens/04_reader_chrome_hidden/04_reader_chrome_hidden_screen.png` & `.html`
- **Layout Hierarchy:**
  - 100% immersive reading text on paper texture `#F6F1E7` with subtle grain. Zero system status bar, zero top/bottom chrome bars.
  - Top Right Corner: Archival bookmark ribbon (deep ink blue `#2F4A7A`, hanging 40px down).
  - Tap Zone Feedback: Center tap toggles chrome. Ephemeral capsule indicator: `"Zen Mode Active · Tap sides to turn"`.
  - Running Book Header (`pt-7 px-7 pb-2`): `"The Shadow of the Wind · Carlos Ruiz Zafón"` in `Newsreader 12px italic uppercase`.
  - Chapter Heading & Vignette: `"Chapter Four: The Silent Harbour"` + classical literary ornament `❦` with hairline horizontal rules.
  - Body Narrative: Drop cap in `#2F4A7A`, paragraph indentation (`indent-5`), justified text.
  - Calm Uncluttered Footer (`pb-7 px-8`):
    - Left: `"12 min left in chapter"` (`Inter 11px #6B655D`).
    - Center: Hairline progress dot.
    - Right: `"142 / 380 · 37%"` (`Inter 11px #6B655D` with `37%` in `#2F4A7A`).

---

### 04b. Reader Appearance Bottom Sheet
- **Slug / Node ID:** `04b_appearance_sheet` / `d8bb2a419ed94bd2912d8dd529e5c482`
- **Target File:** `lib/presentation/screen/reader/widgets/appearance_sheet.dart`
- **Visual Reference:** `design/screens/04b_appearance_sheet/04b_appearance_sheet_screen.png` & `.html`
- **Layout Hierarchy:**
  - Modal Bottom Sheet: Top radius `24px` / `28px`, drag handle, Header `"Appearance"` + `"Offline reading aesthetics"` + `"Reset"` + Close button.
  - Section 1: Page Tone / Themes (6 circular swatches, diameter 44px):
    - `Paper` (`#F6F1E7`, active ring + checkmark)
    - `White` (`#FFFFFF`)
    - `Sepia` (`#F4ECD8`)
    - `Grey` (`#EAE6DF`)
    - `Night` (`#23272A`, premium lock badge)
    - `OLED` (`#121212`, premium lock badge)
  - Section 2: Typeface Carousel (horizontal scroll cards):
    - `Newsreader` (active, `#2F4A7A` filled card with checkmark)
    - `Inter` (Modern Sans)
    - `Literata` (Book Serif)
    - `EB Garamond` (Classic)
    - `Source Serif 4` (Warm)
  - Section 3: Typography & Spacing Sliders:
    - Font Size: `12` – `28 pt`, `A−` / `A+` icons, default `18 pt`.
    - Line Spacing: `1.1×` – `2.2×`, default `1.6×`.
    - Side Margins: `12` – `44 px`, default `24 px`.
  - Section 4: Layout & Flow:
    - Reading Mode Segmented Control: `Scroll` / `Pages` (active) / `Two Columns`.
    - Toggles: `Justify text` (enabled), `Hyphenation` (enabled), `Publisher styles` (disabled).
  - Section 5: Display Brightness:
    - Horizontal slider (10%–100%, default 85%).
    - Toggle: `"Follow system brightness"`.

---

### 04c. Text Selection & Dictionary Definition
- **Slug / Node ID:** `04c_text_selection_dictionary` / `3377a7d8be9f4c4a806e881edd365939`
- **Target File:** `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` & `marked_text.dart`
- **Visual Reference:** `design/screens/04c_text_selection_dictionary/04c_text_selection_dictionary_screen.png` & `.html`
- **Layout Hierarchy:**
  - Selected text highlighted with teardrop pins in `#2F4A7A`.
  - Floating Contextual Toolbar (positioned directly above selection):
    - Highlight Button with 5 Color Dots (Yellow `#FDE047`, Green `#86EFAC`, Blue `#93C5FD`, Pink `#F472B6`, Orange `#FDBA74`).
    - Add Note (`edit_note`).
    - Define (`local_library` + `"Define"`, active primary button).
    - Copy (`content_copy`), Share (`share`), More (`more_horiz`).
    - Triangular pointer arrow beneath toolbar.
  - Bottom Modal Dictionary Sheet (top radius `28px`):
    - Header: Word `"littoral"` in `Newsreader 30px w600`, phonetic `/ˈlɪt(ə)rəl/`, audio speaker button (`volume_up`), etymology note (*Latin littoralis, from litus ‘shore’*), Bookmark word button, Close button.
    - Part of Speech Chips: `adjective` (active `#2F4A7A`), `noun` (outlined), `"Local Lexicon"` badge with green dot.
    - Definitions List:
      - 1. Relating to, or situated on the shore of the sea or a lake. (Quote: *“The littoral zone teemed with ancient kelp and brine-crusted stones.”*)
      - 2. (Ecology) Of or pertaining to the biogeographic region between high and low tide marks. (Quote: *“A delicate littoral ecosystem vulnerable to maritime surges.”*)
      - 3. (Noun) A coastal region; shore zone.
    - Quick Action Buttons: `"Add to Flashcards"`, `"Copy"`, `"Full entry"`.
    - Footer: `"From Wiktionary · CC BY-SA 3.0 · Offline Lexicon · 0 B used"`.

---

### 04d. Table of Contents & Annotations Panel
- **Slug / Node ID:** `04d_contents_annotations` / `60c9068e`
- **Target File:** `lib/presentation/screen/reader/widgets/notes_sheet.dart`
- **Visual Reference:** `design/screens/04d_contents_annotations/04d_contents_annotations_screen.png` & `.html`
- **Layout Hierarchy:**
  - Sliding Drawer (width 350px / 85% of viewport width, sliding from left, leaving 15% dimmed reader visible on right).
  - Header: Back arrow, Search button, `"Export as Markdown"` button (`ios_share`), Book Title in `Newsreader 18px italic` + Author.
  - Tab Switcher:
    - `Contents (18)` (active `#2F4A7A` pill)
    - `Bookmarks (3)`
    - `Highlights (12)`
  - Progress Banner: `"Chapter 4 · Page 142 of 380 · 37% completed · ~2h 14m left"`.
  - Contents Tree:
    - Front Matter: Title Page (p. 1), Epigraph (p. 3).
    - Part I: City of the Mist: Chapter 1 (p. 7), Chapter 2 (p. 42), Chapter 3 (p. 88).
    - Chapter 4 (Active Chapter): Highlighted with vertical ink-blue bar (width 6px), `"Reading now · Page 142"`, badge `"Current"`.
    - Chapter 5 (p. 185), Part II (collapsed, p. 240).
  - In-Chapter Highlights Preview Cards:
    - Highlight Card 1: Blue vertical strip, quote, attached user note (*"Echoes the prologue theme of stewardship"*), `Chapter 4 · Page 144 · Oct 18`.
    - Highlight Card 2: Amber vertical strip, quote, attached user note (*"Atmospheric sensory description"*), `Chapter 4 · Page 143 · Oct 17`.
  - Drawer Footer: Full-width button `"Export as Markdown (.md)"` + `"Local Offline Vault · 24.8 KB"`.

---

### 04e. Search Inside Book
- **Slug / Node ID:** `04e_search_in_book` / `c63b6121c3f6481fa466900795a02b89`
- **Target File:** `lib/presentation/screen/reader/widgets/reader_search.dart`
- **Visual Reference:** `design/screens/04e_search_in_book/04e_search_in_book_screen.png` & `.html`
- **Layout Hierarchy:**
  - Subheader: Back arrow, Book title `"The Shadow of the Wind"` + Author, `"EPUB"` tag.
  - Search Header Card (`rounded-2xl`, border `1px #E8E2D9`):
    - Input Row: Search icon, query text `"harbour"` with blinking cursor, result badge `"23 results"`, clear button `"✕"`.
    - Stepper Row: `"Match 4 of 23 in current chapter"`, up/down stepper buttons.
  - Scope Filter Chips: `"This book (23)"` (active), `"All chapters"`, `"Notes & Highlights"`, `"Case sensitive"`.
  - Results List Grouped by Chapter:
    - Chapter 2: 3 results (cards with matching keyword bolded in `#2F4A7A` with light blue background).
    - Chapter 4: 11 results, Card 3 is Active Focused Match with left 3.5px primary border, badge `"MATCH 4 OF 23"`, page `"p. 142 (Current)"`.
    - Chapter 7: 9 results.
  - Bottom Floating Mini Bar: Stadium capsule with `"Return to position · Page 142 (62%)"` + `"Done"` button (`#2F4A7A`).

---

### 05. Read Aloud In-App Player
- **Slug / Node ID:** `05_read_aloud` / `b44bfe8531334c9fab5c6e95ba2c2ac3`
- **Target File:** `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart`
- **Visual Reference:** `design/screens/05_read_aloud/05_read_aloud_screen.png` & `.html`
- **Layout Hierarchy:**
  - Background Reader Canvas: Currently spoken sentence highlighted in `#D6E2F5` / `bg-primary-fixed/40`.
  - Expanded Player Bottom Sheet: Top radius `24px` / `28px`, drag handle, minimize chevron.
  - Header Row: Book cover thumbnail (`48×64px`), Title (`Newsreader 18px w600`), Author, Chapter subtitle.
  - Spoken Sentence Focus Card:
    - Preceding sentence (faded, opacity 0.5, italic).
    - Currently spoken sentence (large `Newsreader 18px w600` with left 2px vertical bar in `#2F4A7A`).
    - Succeeding sentence (faded, opacity 0.6).
  - Audio Timeline: Progress slider (width 34%), timestamps (`04:18`, `Sentence 14 of 48`, `-08:42`).
  - Primary Playback Controls:
    - Bookmark audio snippet (`bookmark_add`).
    - Skip back 10s (`replay_10`).
    - Hero Play/Pause Button: Diameter `64×64px`, `bg #2F4A7A`, white pause/play icon, shadow `0 4px 16px rgba(47,74,122,0.28)`.
    - Skip forward 10s (`forward_10`).
    - More options (`more_vert`).
  - Adjustment Pills: Speed (`1.25x`), Voice (`Natural 2`), Sleep timer (`30 min`).
  - Trust Footer: `"Local On-Device TTS · 0 KB network used"`.

---

### 06. Android Lock Screen Controls
- **Slug / Node ID:** `06_lock_screen` / `cb0c0e53f6d845b193205ead7b7aeb7e`
- **Target File:** Native Android `MediaSessionCompat` / `audio_service` integration
- **Visual Reference:** `design/screens/06_lock_screen/06_lock_screen_screen.png` & `.html`
- **Layout Hierarchy:**
  - System Media Player card in Android 15 lock screen style:
    - App attribution: OpenPages brand icon + `"OpenPages · Read Aloud"`.
    - Audio output route: `"Pixel Buds Pro"`.
    - Book Cover artwork: 80×112px thumbnail.
    - Title: `"Dune: The Arrakis Awakening"`.
    - Subtitle: `"Frank Herbert · Narrated by Neural Eleanor"`.
    - Chapter/Sentence Marker: `"Chapter 4 · Paragraph 42"`.
    - Interactive Scrubber: 44.8% progress, `14:20` / `-17:40` / `32:00`.
    - Controls: Sleep timer button (`30m`), Rewind 10s, Circular Play/Pause button (56×56px `#2F4A7A`), Forward 10s, Playback speed (`1.1x`).
    - Archival note: `"Archival Offline Mode · Private Sanctuary"`.

---

### 07. Premium Appearance Paywall
- **Slug / Node ID:** `07_premium_paywall` / `e4e1f70641644d55af19ba91bec03cb5`
- **Target File:** `lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`
- **Visual Reference:** `design/screens/07_premium_paywall/07_premium_paywall_screen.png` & `.html`
- **Layout Hierarchy:**
  - Header: `"Patron Edition"` badge + Close `"✕"` button.
  - Headline: `"Make every page yours"` (`Newsreader 26px w600`), Subtitle: `"Unlock premium reading themes, handcrafted fonts, and visual style presets."`.
  - 3-Theme Hero Carousel (`h: 210px`, horizontal snap):
    - Warm Linen (`#F5EFEB`, Newsreader Serif)
    - Midnight Blue (`#161E2E`, Literata Book)
    - Forest (`#1B2921`, EB Garamond)
  - Feature Bullets (with `#2F4A7A` checkmark icons):
    - 12 handcrafted reading themes
    - 8 editorial book fonts
    - Custom accent colors & paper textures
    - Reading statistics & atmospheric soundscapes
  - Reassurance Ethos Card: `"Reading, offline storage, dictionary, and search remain free forever. OpenPages is strictly DRM-free and private."`
  - Two Plan Cards:
    - Lifetime Card (selected by default): Radio button, `"Lifetime"`, `"Best Value"` badge, `"Pay once. Own it forever."`, Price `"$14.99 one-time"`.
    - Yearly Card: Radio button, `"Yearly"`, `"~$0.42 / month • 7-day trial"`, Price `"$4.99 / year"`.
  - Action Footer:
    - Full-width stadium button `"Unlock Premium"` (`#2F4A7A`).
    - Secondary text link `"Restore purchases"`.
    - Legal footnote: `"One-time purchase applies to all your Android devices. No account required."`.

---

### 08. All Annotations Screen
- **Slug / Node ID:** `08_all_annotations` / `837a423b40e84dc6b4abbdfbdf90bd99`
- **Target File:** `lib/presentation/screen/annotations/annotations_screen.dart`
- **Visual Reference:** `design/screens/08_all_annotations/08_all_annotations_screen.png` & `.html`
- **Layout Hierarchy:**
  - Top Bar: Arrow back button, Title `"Annotations"`, counter badge `"42 items"`, search button, overflow menu ⋮ (`"Export as Markdown (.md)"`, `"Export as Plain Text"`, `"Clear Selected"`).
  - Search Bar: Stadium input `"Search highlights & notes..."` + filter icon.
  - Filter Chips: `"All (42)"` (active `#2F4A7A`), `"Highlights (30)"`, `"Notes (12)"`, `"Bookmarks (8)"` + color dots (Amber `#E5A93C`, Sage `#4E8752`, Ink Blue `#2F4A7A`, Terracotta `#C85A54`).
  - Grouped Feed by Book:
    - Book Group 1: `"The Shadow of the Wind"` (Cover thumbnail, Author, `"18 annotations"`).
      - Card 1: Amber vertical strip, quote in Newsreader italics, attached user note container, tags `#theme` `#fatherhood`, `Chapter 4 · Page 142 · Oct 28, 2026`, Copy & Share buttons.
      - Card 2: Soft Sage vertical strip, quote, `Chapter 4 · Page 144 · Oct 26, 2026`, Copy, Share, Delete buttons.
    - Book Group 2: `"Dune"` by Frank Herbert (Cover thumbnail, Author, `"14 annotations"`).
      - Card 3: Deep Ink Blue strip, quote, attached note with bookmark icon, `Prologue · Page 3 · Oct 19, 2026`, Bookmark icon, Copy, Share.
      - Card 4: Rose Terracotta strip, Litany against fear quote, `Chapter 2 · Page 22 · Oct 15, 2026`.
  - Trust Footer: `"Archived locally in Offline Sanctuary · 42 annotations synced to device · Zero cloud telemetry"`.

---

# SECTION C: ASSET INVENTORY

| Asset Name | Local File Path | Resolution / Aspect | MIME Type | Usage & Screen Target |
|---|---|---|---|---|
| **Onboarding Hero** | `assets/images/onboarding_hero_illustration.png` | 1024×1024 px (1:1) | image/png | `01_onboarding` Page 1 hero |
| **Reading Styles Art** | `assets/images/onboarding_page_2_reading_styles.png` | 1024×1024 px (1:1) | image/png | `01b_onboarding_page2` Page 2 hero |
| **Read Aloud Waves** | `assets/images/onboarding_page_3_read_aloud.png` | 1024×1024 px (1:1) | image/png | `01c_onboarding_page3` Page 3 hero |
| **Privacy Padlock Art** | `assets/images/onboarding_page_4_privacy.png` | 1024×1024 px (1:1) | image/png | `01d_onboarding_page4` Page 4 hero |
| **Empty Shelf** | `assets/images/empty_library_shelf.png` | 1024×1024 px (1:1) | image/png | `02b_empty_library` empty state |
| **Fallback Book Cover** | `assets/images/fallback_book_cover_default.png` | 848×1264 px (2:3) | image/png | Fallback cover in `book_cover.dart` when EPUB cover missing |
| **Dune Book Cover** | `assets/images/book_cover_dune.png` | 848×1264 px (2:3) | image/png | Book details `02d`, Lock screen `06`, Annotations `08` |
| **Explore Icon** | `assets/images/explore-icon.svg` | Vector | image/svg+xml | Library navigation |
| **Settings Icon** | `assets/images/settings-icon.svg` | Vector | image/svg+xml | Settings navigation |

---

# SECTION D: NON-NEGOTIABLE ARCHITECTURAL & DESIGN CONSTRAINTS

1. **Strictly NO Persistent Bottom Navigation Bar:**
   - Under no circumstances may a `NavigationBar`, `BottomNavigationBar`, or persistent bottom tab bar be present in the application.
   - `lib/presentation/screen/dashboard/dashboard_portrait.dart` currently contains a `bottomNavigationBar` which must be removed. All navigation is contextual: Library home leads to reader, search icon, filter sheet, book details sheet, and settings screen.
2. **20px Lateral Screen Margins:**
   - All standard screens use `20px` side padding (`EdgeInsets.symmetric(horizontal: 20.0)`).
3. **1px Hairline Borders (`#E8E2D9`):**
   - Cards, bottom sheets, search inputs, and chips must feature a crisp `1.0px` border in `#E8E2D9`.
4. **Corner Radii Hierarchy:**
   - Cards & Inset Grouped Containers: Exactly `16.0px` (`rounded-2xl`).
   - Modal Bottom Sheets: Exactly `24.0px` or `28.0px` top radius.
   - Action Chips, Pills, and FAB: `StadiumBorder()` (`rounded-full`).
   - Book Covers: `4.0px` to `8.0px` with 2:3 aspect ratio and soft drop shadow.
5. **Strict Dual-Font Typography:**
   - Editorial headings, book titles, and reader text: `Newsreader` serif.
   - UI controls, buttons, metadata labels, body UI: `Inter` sans.
   - Tabular figures (`FontFeature.tabularFigures()`) required on all numeric counters, timers, and percentages.
6. **Offline-First & Zero-Telemetry Privacy Ethos:**
   - Reassurance messaging must remain true and prominent on all screens ("Offline-first & zero telemetry", "Archived locally", "0 KB network used").

---

# SECTION E: SPECIFICATION MINER FINDINGS & EDGE CASES

## Features Discovered
| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|---|---|---|---|---|---|---|
| 1 | Navigation | Contextual Top-Bar Navigation | Navigation via top bar icons instead of bottom nav | Tap search/settings/back | Route navigation | No-op if at root | `02_library_screen.html`, `dashboard_portrait.dart` |
| 2 | Onboarding | 4-Page Horizontal Carousel | Horizontal swipe onboarding with animated dots | Horizontal drag, "Next", "Skip" | Advances page index or finishes onboarding | Clamped at 0..3 | `01_onboarding/` HTMLs |
| 3 | Library | Continue Reading Hero Card | Displays last read book with 2:3 cover, progress bar, Resume pill | Book metadata, progress fraction | Renders hero card, tapping Resume opens reader | Fallback cover if null | `02_library_screen.html` |
| 4 | Library | Recent Volumes Carousel | Horizontal carousel of cards with circular progress ring | List of recent books | Horizontal list of 210px cards | Hidden if < 2 books | `02_library_screen.html` |
| 5 | Library | 3-Column Grid with Format Badges | Responsive 3-col grid with EPUB/PDF/TXT/FB2 badge and progress/done check | Book collection | 3-column sliver grid | Shows empty state if 0 books | `02_library_screen.html` |
| 6 | Library | Empty Shelf State | Dual action buttons (Import files vs Import folder) | 0 books in library | Illustration + dual pills | Shows file picker on tap | `02b_empty_library_screen.html` |
| 7 | Library | Filter & Sort Sheet | Radio sort, format multi-select, browse list, grid/list toggle | Filter state, sort selection | Updates library display | "Reset" resets to defaults | `02c_filter_sort_sheet_screen.html` |
| 8 | Book Details | Metadata Bottom Sheet | 2:3 cover, series, format, progress, actions, word count, Move to Trash | Book record | Detailed modal sheet | Prompts confirmation on Trash | `02d_book_details_screen.html` |
| 9 | Settings | Inset Grouped Settings Cards | 5 grouped cards for Appearance, Reading, TTS, Backup, About | User preferences | Toggles, sliders, selectors | Persisted via Cubit/SharedPrefs | `03_settings_screen.html` |
| 10 | Settings | Patron Promotion Card | Highlight card in Settings promoting 12 themes & 8 fonts | Patron status | Banner with "Unlock" CTA | Hidden or disabled if already Patron | `03_settings_screen.html` |
| 11 | Reader | Paper Canvas & Chrome Toggle | Paper background `#F6F1E7`, tap center toggles top/bottom chrome | Tap center, tap edges | Animates chrome in/out | Clamped to reader viewport | `04_reader_chrome_visible.html`, `_hidden.html` |
| 12 | Reader | Left Edge Brightness Rail | Vertical brightness slider capsule on left reader edge | Vertical drag | Sets screen brightness | Clamped 0.1..1.0 | `04_reader_chrome_visible.html` |
| 13 | Reader | Scrubber with Chapter Ticks | Slider track with visual chapter boundary markers | Drag scrubber | Jumps to book location | Clamped 0..maxPages | `04_reader_chrome_visible.html` |
| 14 | Reader | Appearance Sheet | 6 theme swatches (2 premium), 5 fonts, 3 sliders, layout toggles | Appearance settings | Live preview in reader | Locks trigger paywall | `04b_appearance_sheet_screen.html` |
| 15 | Reader | Floating Selection Toolbar | 5-color highlight dots, Note, Define, Copy, Share | Text selection | Floating popup above text | Clamped within screen | `04c_text_selection_dictionary.html` |
| 16 | Reader | Offline Wiktionary Sheet | Offline word definition, IPA phonetics, audio, etymology | Word query | Modal sheet with definition cards | Shows fallback if word missing | `04c_text_selection_dictionary.html` |
| 17 | Reader | Contents & Annotations Drawer | Left side drawer with TOC tree, Bookmarks, Highlights, Export | TOC data, annotations | Nested tree list | Empty state for 0 annotations | `04d_contents_annotations.html` |
| 18 | Reader | In-Book Search & Stepper | Search input with result counter, up/down match stepper, chapter groups | Search query | Highlights matching terms | Shows "0 results" if no match | `04e_search_in_book.html` |
| 19 | Read Aloud | Sentence Sync Highlight | Highlights spoken sentence in `#D6E2F5` in reader | TTS engine sentence event | Background tint on active sentence | Clears on pause/stop | `05_read_aloud_screen.html` |
| 20 | Read Aloud | Expanded Bottom Player Sheet | Cover, large Newsreader active sentence, scrubber, controls | Playback state | Audio player sheet | Pauses on audio focus loss | `05_read_aloud_screen.html` |
| 21 | Lock Screen | MediaSession Notification Card | Android lock screen media player with cover, chapter, controls | AudioService state | Native lock screen widget | Handled via OS | `06_lock_screen_screen.html` |
| 22 | Paywall | 3-Theme Hero & Plan Cards | Linen/Midnight/Forest carousel, Lifetime vs Yearly cards | In-app purchase | Triggers purchase flow | Shows restore link | `07_premium_paywall_screen.html` |
| 23 | Annotations | Book-Grouped Annotation Cards | Color indicator strip, quote in Newsreader italics, user note, export | Annotation database | Grouped list by volume | "Export as Markdown" downloads file | `08_all_annotations_screen.html` |

## Edge Cases
| # | Feature | Input | Observed Behavior |
|---|---|---|---|
| 1 | Book Cover | Missing cover image in EPUB/PDF | Renders `fallback_book_cover_default.png` with 2:3 aspect ratio and shadow |
| 2 | Library Empty | Library has 0 books imported | Displays `02b_empty_library` illustration with dual import buttons |
| 3 | Reader Chrome | Tap on bookmark or scrubber | Does NOT toggle chrome visibility (event propagation stopped) |
| 4 | Zen Mode | Reader in Zen Mode (chrome hidden) | Unobtrusive footer shows `"12 min left in chapter · 142 / 380 · 37%"` |
| 5 | Selection Toolbar | Text selected near top screen boundary | Floating toolbar flips below selection or clamps to top margin |
| 6 | Wiktionary Lookup | Word not found in offline dictionary | Graceful fallback card: "Definition not found in offline lexicon" |
| 7 | Read Aloud | End of chapter reached | Advances to next chapter automatically or pauses according to user settings |
| 8 | Search Inside Book | Search query has 0 matches | Results list shows clear empty state: "No matches found for '<query>'" |
| 9 | Bottom Nav Violation | User navigating inside application | Persistent bottom navigation bar must NOT appear on any screen |

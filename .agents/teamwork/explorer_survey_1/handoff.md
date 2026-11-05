# Core UI Codebase Survey Handoff Report (R1, R2, R3)

**Agent**: `explorer_survey_1`  
**Working Directory**: `/home/tn-99778/Towha/LinguaPages/.agents/teamwork/explorer_survey_1/`  
**Target Milestone**: Survey & Gap Analysis for R1 (Tokens/Theme), R2 (Onboarding), R3 (Library & Book Management)  
**Parent Conversation ID**: `2283687a-5c7c-4e1f-9d03-d89b8d745253`  

---

## 1. Observation

### 1.1 Baseline Project Health & Tooling Status
- Command executed: `flutter analyze`
  - Output:
    ```
    Resolving dependencies...
    The current Flutter SDK version is 3.44.2.

    Because flutter_readium 0.6.2 requires Flutter SDK version >=3.44.8 and no
      versions of flutter_readium match >0.6.2 <0.7.0, flutter_readium ^0.6.2 is
      forbidden.
    So, because lingua_pages depends on flutter_readium ^0.6.2, version solving
      failed.

    You can try the following suggestion to make the pubspec resolve:
    * Try using the Flutter SDK version: 3.47.9. 
    Failed to update packages.
    ```
- Command executed: `flutter test`
  - Output: Same dependency solving error due to Flutter SDK version constraint mismatch.
- Environment check (`fvm list`, `which flutter`, `pubspec.lock`):
  - Current active Flutter binary: `/home/tn-99778/fvm/default/bin/flutter` (Flutter `3.44.2` on channel stable).
  - `pubspec.lock` (`sdks:` section lines 627-629):
    ```yaml
    sdks:
      dart: ">=3.13.0 <4.0.0"
      flutter: ">=3.47.0"
    ```
  - Available in FVM cache / remote releases: Flutter `3.47.9` (stable channel).
  - Note: Dependency resolution requires Flutter SDK version `>=3.47.0` (or `3.47.9`), which can be selected via `fvm use 3.47.9` / `fvm global 3.47.9`.

### 1.2 Pubspec Dependencies, Fonts, and Asset Registrations
- In `pubspec.yaml`:
  - Assets registered (lines 72-77):
    - `assets/images/`
    - `assets/fonts/figtree/OFL.txt`
    - `assets/fonts/literata/OFL.txt`
    - `assets/fonts/source_serif_4/OFL.txt`
    - `assets/fonts/eb_garamond/OFL.txt`
  - Fonts declared (lines 79-120):
    - `Figtree` (Regular, Medium, SemiBold, Bold, ExtraBold)
    - `Literata` (Regular, Italic, Bold, BoldItalic)
    - `Source Serif 4` (Regular, Italic, Bold, BoldItalic)
    - `EB Garamond` (Regular, Italic, Bold, BoldItalic)
  - Missing from `pubspec.yaml`:
    - `Newsreader` font is NOT declared in `pubspec.yaml` and does NOT have files in `assets/fonts/`.
    - `Inter` font is NOT declared in `pubspec.yaml` and does NOT have files in `assets/fonts/`.
    - `google_fonts` package is NOT listed in `pubspec.yaml` dependencies.
  - Image assets in `assets/images/`:
    - `onboarding_hero_illustration.png` (506 KB, present)
    - `onboarding_page_2_reading_styles.png` (450 KB, present)
    - `onboarding_page_3_read_aloud.png` (538 KB, present)
    - `onboarding_page_4_privacy.png` (472 KB, present)
    - `empty_library_shelf.png` (540 KB, present)
    - `fallback_book_cover_default.png` (951 KB, present)
    - `book_cover_dune.png` (819 KB, present)

### 1.3 Theme & Tokens (`lib/presentation/theme/`)
- `lib/presentation/app/app.dart` (lines 35-39):
  ```dart
  // The app chrome is dark-only; reading pages keep their own themes.
  themeMode: ThemeMode.dark,
  darkTheme: EnDarkMode().getAppTheme(
    orientation: MediaQuery.of(context).orientation,
  ),
  ```
- `lib/presentation/theme/dark/dark_color_theme.dart`:
  - Implements legacy "Paperback Bands: near-black ink ground, one lifted card surface and flat print colours".
  - Core colors: `_ink = Color(0xFF111315)`, `_card = Color(0xFF1C1F22)`, `_orange = Color(0xFFE0742E)` (primary), `_paper = Color(0xFFECEAE4)`, `_rule = Color(0xFF33383D)`.
  - Font family used: `Figtree` (line 9).
  - Explicitly registers `NavigationBarThemeData` for bottom navigation bar (lines 130-149).
- Design Specification Requirement (R1 & `STITCH_UI_IMPLEMENTATION_GUIDE.md` Section 3):
  - Palette:
    - Canvas / Background: `#FAF7F2` (Warm ivory)
    - Surface / Card: `#FFFFFF` (Pure white)
    - Hairline divider / border: `#E8E2D9` (1px)
    - Primary Ink / Headings: `#1C1B1A`
    - Secondary Slate / Metadata: `#6B655D`
    - Outline / Inactive tracks: `#747780`
    - Accent Ink Blue / CTAs: `#2F4A7A`
    - Accent Container / Sentence highlight: `#D6E2F5`
    - Dedicated Paper Reader Canvas: `#F6F1E7`
    - Destructive: `#BA1A1A`
  - Typography:
    - Headings/Titles in `Newsreader` serif
    - UI controls/metadata/labels in `Inter` sans
  - Radii: Cards `16.0`, Bottom Sheets `24.0`, Action pills/chips `StadiumBorder()`.

### 1.4 Persistent Bottom Navigation Bar Check
- Search: `grep -rn "bottomNavigationBar" lib/`
- Observation:
  - `lib/presentation/screen/dashboard/dashboard_portrait.dart` (lines 18-34):
    ```dart
    bottomNavigationBar: NavigationBar(
      selectedIndex: tabsRouter.activeIndex,
      onDestinationSelected: tabsRouter.setActiveIndex,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.auto_stories_outlined),
          selectedIcon: const Icon(Icons.auto_stories),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: l10n.navSettings,
        ),
      ],
    ),
    ```
  - Requirement: "Strictly ensure NO bottom navigation bar is added anywhere. By architectural mandate, LinguaPages strictly contains no persistent bottom navigation bar anywhere in the app."

### 1.5 Onboarding Flow (`lib/presentation/screen/onboarding/`)
- Current File: `lib/presentation/screen/onboarding/onboarding_screen.dart` (254 lines)
  - Layout: Single vertical `ListView` inside `SafeArea`.
  - Illustration: Custom generated `_FormatShelf` widget rendering colored bands for 6 formats.
  - Content: 3 static points (`_Point`).
  - Action: Single button calling `_continue()` which executes `injector<OnboardingPreferences>().complete()` and `context.router.replaceAll([const DashboardRoute()])`.
- Target Design Specification (R2):
  - 4-page horizontal `PageView` carousel with animated page indicator dots (active pill `24×8` in `#2F4A7A`, inactive dots `8×8` in `#CEC5BB`, gap `8.0`).
  - Top Bar: Brand icon/title ("OpenPages" with `local_library` icon) + trailing text button "Skip".
  - Page 1 (`ce71ef53`): "Your books, all in one place" + `onboarding_hero_illustration.png` + 5 format pills (`EPUB`, `PDF`, `TXT`, `MD`, `FB2`) + "Next" button + "Offline-first & zero telemetry" lock note.
  - Page 2 (`ebb14c4c`): "Read the way you like" + `onboarding_page_2_reading_styles.png` + subtitle + "Next" button.
  - Page 3 (`20ed4f15`): "Listen when your eyes rest" + `onboarding_page_3_read_aloud.png` + subtitle + "Next" button.
  - Page 4 (`8a586c73`): "Private by design" + `onboarding_page_4_privacy.png` in card frame + micro-badges ("100% Offline Vault", "Zero Telemetry", "Offline Dictionary") + primary button "Import your first book" + secondary link "Explore first" + "Archived locally • Zero cloud sync required" note.

### 1.6 Library & Book Management (`lib/presentation/screen/home/`)
- `lib/presentation/screen/home/home_portrait_view.dart`:
  - AppBar: Title "Library", with action buttons for Annotations and Import (`IconButton.filledTonal`).
  - Body: `LibraryContent`.
- `lib/presentation/screen/home/components/library_content.dart`:
  - Section 1: "Continue Reading" card (`_ContinueReadingCard`) uses dark card background and paperback band cover.
  - Missing: Recent books horizontal carousel row with circular progress rings (as seen in `02_library`).
  - Section 2: `_ViewChips` uses simple filter chips without the full design styling and lacks the sort button right-aligned.
  - Section 3: `_BookGrid` uses dynamic column count (2 or 3) and paperback band covers, rather than the 3-column editorial grid with full-bleed cover art, format badges (EPUB, PDF, etc.), and in-progress/finished indicators.
  - FAB: No FAB currently in `home_portrait_view.dart` or `library_content.dart` (import is in the app bar). Design requires an extended pill FAB bottom-right (`+ Import`).
- Empty State (`_LibraryEmpty` lines 946-975 of `library_content.dart`):
  - Uses generic `StateView` with `Icons.auto_stories_outlined` and a single "Import" button.
  - Missing: `empty_library_shelf.png` illustration (`280×220`), headline "Your shelf is quiet", dual buttons ("Import files" filled pill and "Import a folder" outlined pill), and format/privacy badge ("Supports EPUB, PDF, TXT, Markdown, HTML, FB2 · Stored locally").
- Filter & Sort Sheet (`02c_filter_sort_sheet`):
  - Currently: Sorting is inside `PopupMenuButton` in `_ShelfHeader`, view toggle is a standalone icon button, format filtering is not supported as a multi-select chip set.
  - Missing: Dedicated `FilterSortSheet` modal bottom sheet (`24px` top radius, drag handle, Reset button, View Layout Grid/List toggle, Sort by radio rows, Format multi-select chips, Browse by categories with counts, sticky "Apply Filters" button).
- Book Details Sheet (`02d_book_details`):
  - Currently: `showBookActions` in `library_book_actions.dart` is a basic vertical `ListTile` popup, and `_BookDetailsSheet` is an edit form.
  - Missing: Editorial Book Details modal bottom sheet displaying 2:3 book cover with drop shadow, metadata header, reading progress card, action button row (Read, Collect, Edit, Share), 2-column metadata grid, offline assurance badge, and "Move to Trash" destructive action.

### 1.7 Book Cover Widget (`lib/presentation/widgets/book/book_cover.dart`)
- Current implementation:
  - Generates 3-part paperback band structure (top band, middle cover face, bottom band with format code).
  - Fallback when `coverPath == null` or missing: displays `_TitleLabel` (colored rectangle with title text).
- Design Specification Requirement (R3 & Section 5 of implementation guide):
  - Uses full-bleed 2:3 cover rendering with soft drop shadow (`BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 8))`).
  - When `coverPath == null` or file does not exist, directly renders `Image.asset('assets/images/fallback_book_cover_default.png', fit: BoxFit.cover)`.

---

## 2. Logic Chain

1. **Baseline Health & Toolchain**:
   - Observation 1.1 shows `flutter analyze` and `flutter test` fail because `flutter_readium 0.6.2` requires Flutter SDK `>=3.44.8`, while the global FVM is pinned to `3.44.2`. Furthermore, `pubspec.lock` specifies SDK constraint `flutter: ">=3.47.0"`.
   - Therefore, the toolchain must be pointed to Flutter SDK `>=3.47.0` (such as `3.47.9` available in FVM) for dependencies to resolve and tests to run.

2. **Typography & Assets**:
   - Observation 1.2 shows `Newsreader` and `Inter` are required by R1 and all Stitch screens, but neither are bundled in `assets/fonts/` nor declared in `pubspec.yaml`, and `google_fonts` is not installed.
   - Therefore, to achieve pixel fidelity without telemetry (offline-first requirement), `Newsreader` and `Inter` font assets should be bundled in `assets/fonts/` and registered in `pubspec.yaml`, or `google_fonts` must be configured with offline bundling.

3. **Theme Synchronization (R1)**:
   - Observation 1.3 shows `app.dart` enforces `ThemeMode.dark` with `DarkColorTheme`, which uses dark gray `#111315` and vibrant orange `#E0742E`.
   - Target specification mandates Warm Editorial Minimalism: ivory `#FAF7F2`, pure white cards `#FFFFFF`, hairline dividers `#E8E2D9`, primary ink `#1C1B1A`, secondary slate `#6B655D`, ink blue accent `#2F4A7A`, and spoken highlight `#D6E2F5`.
   - Therefore, a synchronized Warm Editorial theme must be implemented in `lib/presentation/theme/` and wired into `MaterialApp.router`.

4. **No Bottom Navigation Bar Mandate**:
   - Observation 1.4 confirms a `NavigationBar` currently exists in `dashboard_portrait.dart:18`.
   - Removing this `NavigationBar` and having `DashboardPortrait` simply render `child` immediately fulfills the strict architectural requirement: "No bottom navigation bar exists anywhere in the application."

5. **Onboarding Flow (R2)**:
   - Observation 1.5 shows `onboarding_screen.dart` is currently a 1-page vertical list without carousel support.
   - All 4 page image assets already exist in `assets/images/`.
   - Refactoring `onboarding_screen.dart` into a 4-page `PageView` carousel with the specified animated dots (`24×8` active, `8×8` inactive), copy, and buttons matches `01_onboarding` through `01d_onboarding_page4` designs pixel-for-pixel while preserving the call to `OnboardingPreferences.complete()` and router navigation.

6. **Library & Book Management (R3)**:
   - Observation 1.6 shows `LibraryCubit` and `LibraryState` already provide rich state: `books`, `visibleBooks`, `collections`, `trash`, `query`, `sort`, `viewMode`, `isImporting`, `importDocument`, `importFolder`, `moveToTrash`, `restoreFromTrash`.
   - Replacing the UI layers in `home_portrait_view.dart`, `library_content.dart`, and `library_book_actions.dart` with the Stitch Warm Editorial layouts (Hero Continue Reading card, recent books row with mini progress rings, filter chips + filter sheet, 3-column grid with format badges, extended `+ Import` FAB, and the rich Book Details sheet) connects directly to the existing Cubit methods.
   - This ensures 100% state preservation with zero modifications needed to business logic or database layers.

7. **Book Cover Widget**:
   - Observation 1.7 shows `book_cover.dart` falls back to a plain title box instead of `fallback_book_cover_default.png`.
   - Updating `book_cover.dart` to render `fallback_book_cover_default.png` when `coverPath` is absent fulfills R3.5.

---

## 3. Caveats

1. **Flutter SDK Version**:
   - In accordance with the strictly READ-ONLY instruction, no SDK switch or project file modifications were performed during this survey.
   - The implementing agent or orchestrator must switch or upgrade the Flutter SDK to `3.47.9` (via FVM: `fvm install 3.47.9 && fvm use 3.47.9` or `fvm global 3.47.9`) before running `flutter pub get`, `flutter analyze`, and `flutter test`.
2. **Reader & Settings (R4, R5)**:
   - This survey focused primarily on R1, R2, and R3. Detailed reader chrome (`04_*`) and settings/annotations (`03_*`, `05_*` - `08_*`) are covered by subsequent tasks/agents.
3. **Responsive / Landscape Layouts**:
   - The primary target viewport specified is Mobile `412 × 915 dp`. Tablet/Landscape layouts reuse the responsive wrapper or navigation rail where appropriate.

---

## 4. Conclusion

1. **Codebase Preparedness**:
   - The architectural foundation (`lib/presentation/screen/home/cubits/`, `OnboardingPreferences`, `injector`) is solid, clean, and completely decoupled.
   - All high-resolution PNG illustrations required for R2 and R3 are already present in `assets/images/`.
2. **Key UI Gaps Identified**:
   - **R1**: Theme currently forces dark mode `#111315`/`#E0742E` with `Figtree` font instead of Warm Editorial `#FAF7F2`/`#2F4A7A` with `Newsreader`/`Inter`.
   - **R1 Mandate**: `dashboard_portrait.dart` has a lingering `NavigationBar` that must be removed.
   - **R2**: `onboarding_screen.dart` is a 1-page `ListView`; needs full 4-page `PageView` carousel with animated dots and dual buttons on page 4.
   - **R3**: Library screen needs Continue Reading hero card, recent books carousel with circular progress rings, 3-column grid, extended `+ Import` FAB, `empty_library_shelf.png` empty state with dual buttons, dedicated `FilterSortSheet`, and rich `BookDetailsSheet`.
   - **R3 Widget**: `book_cover.dart` needs full-bleed cover rendering and `fallback_book_cover_default.png` integration.
3. **Actionable Implementation Path**:
   - Set Flutter SDK to `3.47.9`.
   - Update theme tokens in `lib/presentation/theme/`.
   - Remove `bottomNavigationBar` in `dashboard_portrait.dart`.
   - Refactor `onboarding_screen.dart` to 4-page `PageView`.
   - Update `book_cover.dart` with fallback asset.
   - Update `home_portrait_view.dart`, `library_content.dart`, `library_book_actions.dart`.

---

## 5. Verification Method

To verify these findings and subsequent implementations:
1. **Toolchain & Static Analysis**:
   ```bash
   fvm flutter analyze
   ```
   (Must complete with 0 errors after resolving SDK version to 3.47.9).
2. **Test Suite Execution**:
   ```bash
   fvm flutter test test/presentation/screen/home/
   ```
   (Verifies library cubit and state unit tests).
3. **Widget Inspection**:
   - Inspect `lib/presentation/screen/dashboard/dashboard_portrait.dart`: verify absence of `NavigationBar`.
   - Inspect `lib/presentation/screen/onboarding/onboarding_screen.dart`: verify `PageView` with 4 pages and animated dot indicator.
   - Inspect `lib/presentation/screen/home/components/library_content.dart`: verify `_ContinueReadingCard`, recent books carousel, 3-column grid, and `empty_library_shelf.png` empty state.
   - Inspect `lib/presentation/widgets/book/book_cover.dart`: verify reference to `assets/images/fallback_book_cover_default.png`.

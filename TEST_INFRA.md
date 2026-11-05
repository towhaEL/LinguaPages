# TEST_INFRA.md: OpenPages E2E Testing Infrastructure & Suite Specification

## 1. Executive Summary & Testing Philosophy

OpenPages is an offline-first, DRM-free private e-reader application built with Flutter, Material 3, and Warm Editorial Minimalism. To guarantee uncompromising quality, stability, and pixel-by-pixel fidelity against the master design specifications, this project employs an **Authoritative Dual-Track E2E Testing Architecture**.

### 1.1 Dual-Track Testing Philosophy
- **Independence from Implementation Milestones**: Tests are derived strictly from the authoritative requirements specified in `ORIGINAL_REQUEST.md`, `PROJECT.md` (Features 1–32), and the visual specifications mined in `spec_miner_survey_1/handoff.md`.
- **Opaque-Box Verification**: The test suite treats screens, sheets, and components as opaque user-facing systems. Tests assert strictly on observable UI contracts: visible text, semantics, color tokens, layout hierarchy, touch targets, state transitions, and user flows.
- **Progressive Testability**: The architecture supports standalone widget-level E2E tests, isolated sheet/screen harnesses, and multi-step integrated workflows.
- **Zero Production Mutation**: The E2E test suite resides exclusively in `test/e2e/` and `test/` without modifying production application code in `lib/`.

---

## 2. The 4-Tier Testing Methodology

The OpenPages E2E test suite implements a rigorous 4-tier testing hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│ Tier 4: Real-World Application Scenarios (End-to-End Flows) │
├─────────────────────────────────────────────────────────────┤
│ Tier 3: Cross-Feature Combinations & State Synchronization  │
├─────────────────────────────────────────────────────────────┤
│ Tier 2: Boundary, Extreme Input & Corner Case Hardening     │
├─────────────────────────────────────────────────────────────┤
│ Tier 1: Isolated Feature & Token Coverage (Features 1–32)   │
└─────────────────────────────────────────────────────────────┘
```

### Tier 1: Feature Coverage (Isolated System Contracts)
Isolates and validates every individual feature defined in the PROJECT.md Feature Inventory (Features 1–32):
- **Core Design Tokens & Theme (Features 1–5)**: Warm Editorial palette (`#FAF7F2`, `#FFFFFF`, `#E8E2D9`, `#1C1B1A`, `#6B655D`, `#2F4A7A`, `#D6E2F5`, `#F6F1E7`, `#BA1A1A`), typography pairings (`Newsreader` serif for headings/titles, `Inter` sans for labels/controls), shape tokens (`16px` cards, `24-28px` bottom sheets, `StadiumBorder` pills), and the strict absence of any bottom navigation bar.
- **Onboarding Flow (Features 6–10)**: 4-page horizontal `PageView` carousel (`ce71ef53`, `ebb14c4c`, `20ed4f15`, `8a586c73`), hero illustrations, format badges, and animated indicator dots (`24×8px` active pill, `8×8px` inactive dots).
- **Library & Book Management (Features 11–20)**: Top bar with Newsreader title, Continue Reading hero card (2:3 aspect cover shadow, progress bar, Resume pill), Recent books horizontal carousel with circular SVG progress rings, horizontal filter chips & sort button, 3-column book grid, extended pill FAB (`+ Import`), empty shelf state, filter & sort modal sheet, book details sheet with metadata grid and destructive trash action, and fallback book cover rendering `fallback_book_cover_default.png`.
- **Reader Experience & Overlays (Features 21–26)**: Visible reader chrome with translucent top bar, left edge brightness rail, bottom panel with scrubber chapter ticks and 4 tool buttons (`Contents`, `Appearance`, `Listen`, `Notes`), Zen mode (100% reading viewport, footer counter `142 / 380 · 37%`), standalone appearance sheet (6 theme swatches with premium locks, font picker, typography sliders), text selection floating toolbar with 5 color dots and offline Wiktionary definition card, unified TOC side drawer with Bookmarks/Highlights tabs and Markdown export, and in-book search overlay with match stepper and bold highlights.
- **Audio, Monetization, Settings & Annotations (Features 27–32)**: Read aloud sentence highlight band in `#D6E2F5`, expanded bottom player sheet (cover, serif sentence, scrubber, 64px play/pause, speed/voice/timer chips), MediaSession lock screen contract, grouped inset settings cards (6 cards), premium paywall sheet (3-theme preview, plan cards, unlock CTA), and all annotations screen grouped by book with vertical color strips and Markdown export.

### Tier 2: Boundary, Extreme Input & Corner Cases
Hardens the application against unexpected runtime conditions, data anomalies, and edge scenarios:
- **Null Cover Handling**: Books missing cover art gracefully fallback to `fallback_book_cover_default.png` with 2:3 aspect ratio preservation.
- **Empty Shelf State**: Library with 0 imported volumes displays `empty_library_shelf.png`, "Your shelf is quiet", and dual import buttons ("Import files" / "Import a folder").
- **Zero Search Results**: In-book search and library search gracefully display "No results found" states without crashes or layout overflow.
- **Text Overflow & Extreme Strings**: Ultra-long book titles, multi-line authors, and extensive dictionary definitions safely truncate or wrap without RenderFlex overflow.
- **Boundary Navigation & Sliders**: Reading progress slider clamps accurately between `0.0` and `1.0`; chapter pagination gracefully stops at first/last chapters.
- **Wiktionary Missing Word Fallback**: Words not present in the local offline dictionary show a clean offline notice without exceptions.

### Tier 3: Cross-Feature Combinations & State Synchronization
Tests the compound behavior of interdependent subsystems:
- **Theme Switching ↔ Reader Canvas Live Sync**: Changing themes in the appearance sheet (e.g. Paper -> Sepia -> Night) immediately updates reader canvas background and contrast.
- **Filter Chips ↔ 3-Column Book Grid**: Tapping "Reading", "Finished", or format filter pills actively filters the displayed book grid in real time.
- **Selection Toolbar ↔ Wiktionary Sheet**: Highlighting text in the reader and tapping "Define" opens the dictionary sheet populated with the exact selected term.
- **In-Book Search ↔ Reader Position**: Selecting a search match navigates the reader to the matching chapter and page location.
- **Read Aloud Controls ↔ Sentence Highlighter**: Changing playback speed, pausing, or skipping sentences synchronously updates the `#D6E2F5` highlight band.

### Tier 4: Real-World Application Scenarios (End-to-End User Journeys)
Simulates complete realistic user journeys through the application:
1. **First-Launch Onboarding Journey**: User launches app -> swipes through pages 1 to 4 -> explores privacy promises -> completes onboarding -> lands in library.
2. **Library Management & Reader Entry Journey**: User browses library -> filters by format -> inspects book details modal -> taps "Read" -> launches Reader screen.
3. **Reader Immersion & Customization Journey**: User enters reader -> toggles Zen mode -> adjusts typography in Appearance sheet -> selects text to lookup dictionary -> bookmarks chapter -> toggles TOC sheet -> exports annotations to Markdown.
4. **Read Aloud Listening Journey**: User activates audio mode -> inspects expanded player -> seeks scrubber -> changes speech rate -> verifies active sentence tracking highlight.
5. **Patron Upgrade Journey**: User navigates to Settings -> clicks Patron banner -> views 3-theme paywall carousel -> selects Lifetime plan -> simulates unlock.

---

## 3. Test Suite Inventory & Traceability Matrix

| Test Suite File | Tier | Covered Features | Description |
|---|---|---|---|
| `test/e2e/tier1_features/tokens_and_theme_test.dart` | Tier 1 | Features 1–5 | Warm Editorial color tokens, typography styles, radii, absence of bottom navigation bar. |
| `test/e2e/tier1_features/onboarding_carousel_test.dart` | Tier 1 | Features 6–10 | 4-page PageView carousel, hero images, format badges, animated dot indicators. |
| `test/e2e/tier1_features/library_and_books_test.dart` | Tier 1 | Features 11–20 | Top bar, Continue Reading card, recent books, filter chips, 3-col grid, FAB, empty state, details, fallback cover. |
| `test/e2e/tier1_features/reader_and_overlays_test.dart` | Tier 1 | Features 21–26 | Paper canvas `#F6F1E7`, chrome toggle, Zen mode, appearance sheet, selection toolbar, Wiktionary sheet, TOC, in-book search. |
| `test/e2e/tier1_features/audio_settings_paywall_test.dart` | Tier 1 | Features 27–32 | Sentence highlight `#D6E2F5`, read aloud sheet, MediaSession contract, grouped settings, paywall, annotations feed. |
| `test/e2e/tier2_boundary/boundary_and_corners_test.dart` | Tier 2 | Edge Cases 1–9 | Null covers fallback, empty library, 0 search results, extreme strings overflow, clamp limits, missing word fallback. |
| `test/e2e/tier3_cross_feature/cross_feature_sync_test.dart` | Tier 3 | Cross-Subsystems | Theme switching live update, filter chips filtering grid, selection toolbar launching dictionary, audio highlight sync. |
| `test/e2e/tier4_scenarios/user_journeys_test.dart` | Tier 4 | Complete Flows | Full end-to-end user journeys: Onboarding -> Library -> Reader -> Audio -> Paywall -> Annotations. |

---

## 4. Test Harness & Infrastructure Design

The E2E testing framework provides a dedicated, hermetic test environment:

```
test/e2e/
├── helpers/
│   ├── test_app_harness.dart        # Reusable MaterialApp harness with Warm Editorial theme & 412x915 viewport
│   ├── mock_data_fixtures.dart       # Mock books, annotations, search results, dictionary entries
│   └── test_finders.dart            # Custom WidgetFinders for design tokens, borders, and custom shapes
├── tier1_features/
│   ├── tokens_and_theme_test.dart
│   ├── onboarding_carousel_test.dart
│   ├── library_and_books_test.dart
│   ├── reader_and_overlays_test.dart
│   └── audio_settings_paywall_test.dart
├── tier2_boundary/
│   └── boundary_and_corners_test.dart
├── tier3_cross_feature/
│   └── cross_feature_sync_test.dart
├── tier4_scenarios/
│   └── user_journeys_test.dart
└── all_e2e_tests.dart               # Master test runner aggregating all 4 tiers
```

### 4.1 TestAppHarness
- Wraps tested components in a standard mobile viewport (412 × 915 dp) with simulated device pixel ratio.
- Configures Material 3 `ThemeData` with OpenPages Warm Editorial color scheme, font pairings (`Newsreader` and `Inter`), and shape themes (`CardTheme` 16px, `BottomSheetTheme` 24px, `ChipTheme` StadiumBorder).
- Provides optional mock dependencies (Blocs, Cubits, navigation callbacks) so each test executes in total isolation.

---

## 5. Execution & CI Commands

To execute the entire E2E test suite:
```bash
fvm flutter test test/e2e/
```

To execute specific tiers:
```bash
# Tier 1: Feature Coverage
fvm flutter test test/e2e/tier1_features/

# Tier 2: Boundary & Corner Cases
fvm flutter test test/e2e/tier2_boundary/

# Tier 3: Cross-Feature Combinations
fvm flutter test test/e2e/tier3_cross_feature/

# Tier 4: Real-World Application Scenarios
fvm flutter test test/e2e/tier4_scenarios/
```

---

## 6. Verification & Quality Gates
- **Zero Failures**: All tests across Tiers 1–4 must execute and pass cleanly.
- **Visual Token Compliance**: Hex color values, corner radii, and padding verified against the master token specification.
- **Architectural Guard**: Any presence of a `NavigationBar` or `BottomNavigationBar` in the widget tree will immediately fail the suite.

# Project: LinguaPages UI Generation Plan

## Architecture
- **Objective**: Produce a complete, exhaustive, component-wise UI generation plan at `design/ui_generation_plan.md` based on `design/design.md` for LinguaPages (Android offline ebook reader).
- **Core Design System (Shared Style Block)**:
  - Form factor: 412×915 mobile viewport (Material 3 structure, custom editorial look).
  - Background canvas: Warm ivory `#FAF7F2`.
  - Elevated surfaces / cards / sheets: Pure white `#FFFFFF`.
  - Hairline dividers: `#E8E2D9`.
  - Typography: Serif display (Newsreader / Fraunces) for titles and book names; clean sans (Inter) for UI labels.
  - Text colors: Ink `#1C1B1A`, secondary slate `#6B655D`.
  - Single accent: Deep ink blue `#2F4A7A` (buttons, progress bars, active chips). No bright saturated colors.
  - Geometry: 16px card radius, 24px bottom sheet radius, 9999px pill shapes for buttons/chips.
  - Shadows: Soft diffuse long drop shadow under 2:3 book covers only; 0 elevation shadow elsewhere.
  - Navigation: Generous whitespace, 20px side margins, strictly no bottom navigation bar anywhere.
  - Iconography: Outlined 1.5px stroke.
- **Image Naming Schema**:
  - Format: `<screen_number>_<screen_name>_<component_name>.png`
  - Zero-padded two-digit screen numbers with variant suffixes: `01`, `02`, `02b`, `02c`, `02d`, `03`, `04`, `04b`, `04c`, `04d`, `04e`, `05`, `06`, `07`, `08`.
  - Target output directory: `design/components/<screen_number>_<screen_name>/<screen_number>_<screen_name>_<component_name>.png`.

## Feature Inventory
| # | Feature / Screen | Description | Milestone | Source |
|---|------------------|-------------|-----------|--------|
| 1 | Shared Style Block | Design tokens, typography, radii, color palette | M1 | design.md §0 |
| 2 | Screen 1: Onboarding | 4-page carousel, hero illustrations, skip, pagination dots, action buttons | M1 | design.md §1 |
| 3 | Screen 2: Library | App bar, continue reading hero, recent books row, filter chips, 3-column shelf grid, FAB | M1 | design.md §2 |
| 4 | Screen 2b: Empty Library | Centered bookshelf illustration, headline, dual import buttons (files vs folder) | M1 | design.md §2b |
| 5 | Screen 2c: Filter and Sort Sheet | Modal sheet, sort radio group, format chips, browse by rows, grid/list toggle, footer | M1 | design.md §2c |
| 6 | Screen 2d: Book Details Sheet | Tall bottom sheet, cover hero, metadata specs, progress card, action row, trash action | M1 | design.md §2d |
| 7 | Screen 3: Settings | Grouped inset cards: Appearance, Reading defaults, Read aloud, Library, Backup, Premium, About | M1 | design.md §3 |
| 8 | Screen 4: Reader (Chrome Visible) | Paper reading page, top translucent chrome bar with blur, bottom control panel, brightness strip | M1 | design.md §4 |
| 9 | Screen 4: Reader (Hidden Chrome) | Distraction-free reading canvas with minimal bottom position indicator "142 / 380" | M1 | design.md §4 |
| 10 | Screen 4b: Appearance Sheet | 6 theme swatches, font picker row, typography sliders (A-/A+), toggles, layout segmented control, brightness | M1 | design.md §4b |
| 11 | Screen 4c: Text Selection & Dictionary | Selection handles, floating pill toolbar (5 color dots + actions), rich dictionary sheet with Wiktionary CC BY-SA 3.0 | M1 | design.md §4c |
| 12 | Screen 4d: Contents & Annotations | Left side drawer, 3 tabs (Contents, Bookmarks, Highlights), nested chapter list, highlights cards, export icon | M1 | design.md §4d |
| 13 | Screen 4e: Search in Book | Search app bar, query with count badge, up/down nav chevrons, grouped chapter result snippets with bold ink blue | M1 | design.md §4e |
| 14 | Screen 5: Read Aloud Player Variants | Auto-scroll spoken highlight band, docked mini player, expanded bottom sheet player, sleep timer picker sheet | M1 | design.md §5 |
| 15 | Screen 6: Lock-Screen Controls | Android 15 lock screen frame with blurred book cover wallpaper, expanded Material You media player card, collapsed card | M1 | design.md §6 |
| 16 | Screen 7: Premium Appearance | Full-page paywall, close X, 3-theme hero comparison (Linen, Midnight Blue, Forest), value propositions, plan cards, Unlock CTA | M1 | design.md §7 |
| 17 | Screen 8: All Annotations | Global annotations feed, search bar, book group headers, highlight cards with color strips, Markdown export sheet | M1 | design.md §8 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | UI Generation Plan Authoring | Full authoring of `design/ui_generation_plan.md` covering all 17 feature areas across 15 screens/variants with 71 discrete modular components | Survey complete | DONE |

## Interface Contracts & Code Layout
- Target deliverable: `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md` (1557 lines, 141 KB, 71 components)
- Subcomponent output paths: `/Users/uswer/StudioProjects/linguaPages/design/components/<screen_dir>/<component_filename>`
- Zero image files generated in this planning phase (verified 100% compliant).

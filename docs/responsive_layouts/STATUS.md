# Landscape & tablet layouts — status (paused 2026-11-18)

Goal: give every screen a phone-landscape and a tablet layout, and rename the
app to **OpenPages**. Work is paused; continue **one screen at a time**.

## How layouts are chosen

`Screen` (`lib/presentation/widgets/_screen.dart`) picks a view per device:

| Device | Method | Design size |
|---|---|---|
| Phone portrait / split screen | `buildMobilePortraitView` | 402×874 |
| Phone landscape (shortest side < 600) | `buildMobileLandscapeView` | 874×402 |
| Tablet, both orientations (shortest side ≥ 600) | `buildTabletView` | 768×1024 / 1024×768 |

Landscape and tablet fall back to the portrait view when they return `null`.
Branch inside a tablet view with `Screen.isTabletLandscape(context)` or the
available width. Screens that are plain `StatelessWidget` routes (privacy,
annotations, saved words, onboarding) can wrap their body in a private
`Screen` subclass, like `_ResponsiveDashboard` in `dashboard_screen.dart`.

Shared widget: `TwoPane` (`lib/presentation/widgets/_two_pane.dart`), a
fixed-width side pane, a hairline divider and a flexible main pane.

## Done (uncommitted in the working tree)

- **Rename to OpenPages** (only the names users see): `app_en.arb` and its
  generated `l10n/gen`, Android `appName` placeholders, iOS
  `FLAVOR_APP_NAME`, the paywall's "OPENPAGES PATRON" label, backup file names
  (`openpages-backup.zip`, `openpages-restore-*`), README, PRODUCT and DESIGN.
  - **Not renamed, on purpose:** the Dart package `lingua_pages` (every
    import), the `com.linguapages.app` applicationId (changing it makes a new
    store listing), the `lingua_page` Drift database file (renaming it loses
    user data), and the `lingua_pages/*` method channels (they must match the
    Kotlin code). Each of these needs a separate decision.
- **`Screen` base fix:** a tablet is now detected before split screen. Before,
  a landscape tablet (aspect ratio about 1.33) was treated as split screen and
  got the phone portrait view.
- **Dashboard:** the NavigationRail shows labels, and becomes the extended
  rail at 1200dp wide and up.

## Home / Library — done

`LibraryLayout { phone, phoneLandscape, tablet }` drives `HomeView` and
`LibraryContent`. Phone landscape: 48dp app bar, compact hero, icon-only
import, side-by-side empty state. Tablet portrait: 72dp app bar, wide hero,
larger tiles. Tablet ≥ 840dp: `TwoPane` (340dp start pane with continue
reading, search and shelves; book grid at the end). `book_cover.dart` sets
title `maxLines` from the label band height. Tests:
`test/presentation/screen/home/home_layout_test.dart` (29 passing).

## Settings — done

`settings.patch` applied and reviewed. Phone landscape and tablets ≥ 840dp
use `SettingsWideView` (`TwoPane`, nav 240dp on phone / 300dp on tablet);
tablet portrait keeps the centred 640dp column. Review changes:
- The detail pane is an `IndexedStack`, so switching groups keeps scroll and
  in-flight work (a backup export no longer loses its result snackbar).
- The patron banner shows once, above Appearance, not over every group.
- `_SectionEntry` has a string `id`; keys are `settings_card_<id>` and
  `settings_nav_<id>`.
Tests: `test/presentation/screen/settings/settings_layout_test.dart`.

## Privacy — done

`privacy.patch` applied and reviewed. Phone landscape and tablets ≥ 720dp
show a section index (220dp / 260dp) beside the reading column; tapping
scrolls to the section. Review changes:
- The index highlight now follows manual scrolling (last section once the
  end is reached), and a tapped section stays highlighted even when it
  can't scroll to the top.
- The patch's test never ran green: it didn't register `ReadAloudSession`
  for the mini player host. Fixed, plus tablet portrait and highlight tests.
Tests: `test/presentation/screen/privacy/privacy_screen_test.dart`.

## Onboarding — done

`onboarding.patch` applied and reviewed; no code changes needed. The four
pages are now `_PageSpec` data rendered by `_OnboardingLayout`: phone
portrait keeps the stacked column (480dp); tablet portrait stacks larger
(600dp, 1.2× type, 380dp visual); landscape puts the visual beside the copy
with progress, the privacy note and actions in one bar (phone 0.9× type,
48dp app bar; tablet 1.2×). Tests added for 402×874 and 874×402 and for an
error message in the landscape bar.
Tests: `test/presentation/screen/onboarding/onboarding_responsive_test.dart`.

## Splash — no change (decided)

The native launch screens draw the mark at a fixed size on every device
(Android `launch_background.xml` gravity center, iOS `contentMode="center"`),
so scaling `AppMark` on tablets would make it jump on the one-frame handoff.
The centred 108dp mark already works in every orientation.
**Open question:** Android 12+ (`values-v31/styles.xml`) shows the system
splash with the adaptive icon, which renders the 108-unit grid in a 240dp
box, about 2.2× the Flutter `AppMark`. Probably a visible shrink at handoff
on all Android 12+ devices; not verified on a device.

## Premium paywall sheet — done (redesigned, concise)

Rewritten to be short: title, the "stays free" line (`premiumFreeNote`), one
strip of the 4 premium themes with "Aa" in the premium fonts, a 2×2 one-line
benefit list (counted from the catalog), the two plans as compact cards side
by side (stacked under 320dp), then CTA, fine print and restore. Dropped: the
eyebrow badge, the big 3-page hero, benefit descriptions, the separate theme
and font sections and the "Choose your plan" heading. On a ~874dp phone the
sheet is ~480dp tall with no scrolling (it was capped at 92% and scrolled).
Phone landscape (landscape and height < 600): offer on the start side, plans
and actions on the end side. Tablets get the bottom sheet's 640dp max width.
ARB keys `premiumThemesHeading`, `premiumFontsHeading`, `premiumPresets` are
now unused.
Tests: `test/presentation/screen/premium/premium_paywall_sheet_test.dart`.

## Annotations — done

`annotations.patch` applied and reviewed; no code changes needed. Phone
portrait: filters scroll above the list. Phone landscape and tablet portrait:
filters in a 300dp side panel (search, wrapping type chips, book picker,
colour chips). Tablet landscape: filters (280dp), list (360dp), and the
selected annotation in full with an "Open in book" button; tapping a card
selects instead of opening the reader. The search field takes the cubit's
query as its initial value, so it survives rotation. Added tests for
1024×768, rotation, side-panel filtering and detail fallback.
Tests: `test/presentation/screen/annotations/annotations_screen_layout_test.dart`.

## Saved words — done

`saved_words.patch` applied and reviewed; no code changes needed. Phone
portrait keeps the list. Phone landscape and tablets show a grid of
equal-height cards (rows of `IntrinsicHeight`, columns from width: 300dp min,
up to 4) and cap the search field at 560dp. The search field takes the
cubit's query as its initial value, so it survives rotation. Added tests for
a very long word at 320dp and 1024×768, rotation and deleting from the grid.
Tests: `test/presentation/screen/saved_words/saved_words_screen_layout_test.dart`.

## Reader — done

`reader.patch` applied and reviewed (~340 real lines once whitespace is
ignored; the rest was reformatting). New `reader_layout.dart`:
`isReaderCompact` (height < 480), `readerSheetHeight` (92% when compact),
`readerControlsMaxWidth` (720). Compact chrome: 44dp top bar, a bottom bar
without handle, chapter line or tool labels (icons with tooltips). Sheets
(notes, dictionary, search, PDF thumbnails, voice picker) use
`readerSheetHeight`; the PDF thumbnail grid uses a max tile extent. Appearance
sheet and read-aloud controls go two-column on landscape screens ≥ 600dp.
Pagination untouched. Review changes:
- Search sheet height clamp could throw `ArgumentError` with a tall
  keyboard; now `max(0, min(...))`.
- Continuous-text padding and caret scrolling now use
  `readerTopBarExtent`/`readerBottomBarExtent`, so compact mode gains ~48dp.
- Icon-only tool tooltips are excluded from semantics (no double label).
- Appearance sheet hides its drag handle and subtitle when compact.
- **Bug fixed (it predates this work):** the bottom bar is ~166dp with a
  chapter line and page arrows, but the read-aloud player docked at the 120dp
  constant and covered its top. The reader now measures the bar
  (`_MeasureHeight`) and docks above it; the constant is only the fallback.
  The continuous-text bottom padding still uses the constants.
- The TOC drawer was already clamped to 280–380dp; no change.
Tests: `test/presentation/screen/reader/reader_layout_test.dart`.

## All screens done

Nothing is committed yet. Check on devices before merging: paywall look
(widget tests don't render real fonts), the reader at 874×402 with
read-aloud playing, and the Android 12+ splash question above.

## Suggested order

1. ~~Home~~ ✓
2. ~~Settings~~ ✓ → ~~Privacy~~ ✓ → ~~Onboarding~~ ✓ → ~~Splash~~ (no change) → ~~Paywall~~ ✓.

3. ~~Annotations~~ ✓ → ~~Saved words~~ ✓.
4. ~~Reader~~ ✓.

Check each screen at 402×874, 874×402, 800×1280 and 1280×800 for overflow
before moving on.

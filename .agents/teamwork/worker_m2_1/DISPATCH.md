## 2026-11-04T20:15:47Z
You are worker_m2_1, a Flutter Implementation Worker assigned to Milestone 2: Onboarding Flow (R2).
Your working directory is: /home/tn-99778/Towha/LinguaPages/.agents/teamwork/worker_m2_1/
Your parent conversation ID is: 2283687a-5c7c-4e1f-9d03-d89b8d745253

FIRST STEP: Read /home/tn-99778/Towha/LinguaPages/.agents/teamwork/ORIGINAL_REQUEST.md in full.
Read /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator/PROJECT.md.
Read /home/tn-99778/Towha/LinguaPages/.agents/teamwork/spec_miner_survey_1/handoff.md (specifically Section B.01a to B.01d for exact copy, dimensions, and layout hierarchy).
Inspect `design/screens/01_onboarding/`, `design/screens/01b_onboarding_page2/`, `design/screens/01c_onboarding_page3/`, `design/screens/01d_onboarding_page4/`.
Inspect `test/e2e/tier1_features/onboarding_carousel_test.dart`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Exclusive Write Ownership:
- `lib/presentation/screen/onboarding/` (specifically `onboarding_screen.dart` and any widgets in this folder)
Do NOT touch other feature screens outside onboarding.

Objective & Implementation Specifications:
Refactor `lib/presentation/screen/onboarding/onboarding_screen.dart` from the current single-page vertical list into the complete pixel-perfect 4-page horizontal `PageView` carousel matching Stitch designs 01a–01d:

1. Top App Bar:
   - Leading brand mark: `Icons.local_library_outlined` in `#2F4A7A` + "OpenPages" in `Newsreader` 22px w600 `#1C1B1A`.
   - Trailing action: "Skip" text button (`Inter` 12px w500 `#6B655D` or `#44474F`). Tapping "Skip" jumps to Page 4 or completes onboarding.

2. PageView (4 Pages):
   - Page 1 (`ce71ef53`):
     - Illustration: `Image.asset('assets/images/onboarding_hero_illustration.png')` (aspect 1:1, max width ~320px).
     - Headline: "Your books, all in one place" (`Newsreader` 30px w400, line height 38px, letter spacing -0.015em).
     - Subtitle: "EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone." (`Inter` 15px w400 `#6B655D`).
     - 5 Format Pills: `EPUB`, `PDF`, `TXT`, `MD`, `FB2` (StadiumBorder chips, `#FFFFFF` surface, `1px #E8E2D9` border, `Inter` 11px w500).
     - Bottom CTA: Height 52-56px Stadium button in `#2F4A7A`, "Next" with `arrow_forward` icon.
     - Note: Lock icon + "Offline-first & zero telemetry" (`Inter` 11px `#6B655D`).
   - Page 2 (`ebb14c4c`):
     - Illustration: `Image.asset('assets/images/onboarding_page_2_reading_styles.png')` (aspect 1:1).
     - Headline: "Read the way you like" (`Newsreader` 26px w500).
     - Subtitle: "Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page." (`Inter` 15px w400 `#6B655D`).
     - Feature pills (Custom Fonts, Margins & Spacing, Highlights & Notes).
     - Bottom CTA: "Next" stadium button.
   - Page 3 (`20ed4f15`):
     - Illustration: `Image.asset('assets/images/onboarding_page_3_read_aloud.png')` (aspect 1:1).
     - Headline: "Listen when your eyes rest" (`Newsreader` 30px w400).
     - Subtitle: "Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked." (`Inter` 15px w400 `#6B655D`).
     - Feature pills (Natural Voices, Sentence Tracking, Sleep Timer).
     - Bottom CTA: "Next" stadium button.
   - Page 4 (`8a586c73`):
     - Illustration: `Image.asset('assets/images/onboarding_page_4_privacy.png')` (aspect 1:1).
     - Headline: "Private by design" (`Newsreader` 26px w500).
     - Subtitle: "No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup." (`Inter` 15px w400 `#6B655D`).
     - Dual Actions:
       - Primary CTA: Height 52-56px stadium button, `bg #2F4A7A`, icon `Icons.folder_open`, label "Import your first book" (white text).
       - Secondary Action: Text button "Explore first" (`Inter` 12-14px `#6B655D`).
     - Reassurance note: "Archived locally • Zero cloud sync required".

3. Animated Page Indicator Dots:
   - Displayed consistently above or within the footer area across all pages.
   - Active dot: Width 24px, Height 8px, border radius 4px in `#2F4A7A`.
   - Inactive dots: Width 8px, Height 8px, border radius 4px in `#C4C6D0` or `#CEC5BB`.
   - Smooth animation using `AnimatedContainer` with duration 250ms.

4. State Preservation & Navigation:
   - Preserve `injector<OnboardingPreferences>().complete()`.
   - When "Import your first book" or "Explore first" is tapped, mark onboarding complete and navigate via `context.router.replaceAll([const DashboardRoute()])` (for "Import your first book", optionally trigger file import).
   - Ensure strictly NO bottom navigation bar exists.

5. Verification:
   - Run `fvm flutter analyze lib/presentation/screen/onboarding/`
   - Run `fvm flutter test test/e2e/tier1_features/onboarding_carousel_test.dart`
   - Run `fvm flutter test`

Deliverables:
- Maintain /home/tn-99778/Towha/LinguaPages/.agents/teamwork/worker_m2_1/progress.md with timestamps.
- Write handoff report to /home/tn-99778/Towha/LinguaPages/.agents/teamwork/worker_m2_1/handoff.md with all code diffs and test output.
- Send completion message to parent via send_message.

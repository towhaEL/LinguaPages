## 2026-11-04T22:10:38Z

Complete the remaining screen UI and components for LinguaPages as production code integrated into the Flutter app, matching the Stitch canvas designs and design implementation guides.

Working directory: /home/tn-99778/Towha/LinguaPages
Integrity mode: development

## Verification Resources
- Design documentation: `design/STITCH_UI_IMPLEMENTATION_GUIDE.md`, `design/screens/README.md`
- Stitch Canvas Project ID: `8671147000524611054`
- Existing tokens and themes: `lib/presentation/theme/app_tokens.dart`, `app_colors.dart`, `app_theme.dart`

## Requirements

### R1. Settings Screen
Implement the settings screen (`lib/presentation/screen/settings/`) and its grouped inset cards matching `03_settings` (`0e2582dd`).

### R2. Reader Widgets and Sheets
Implement the remaining reader UI sheets and overlays matching their respective Stitch canvas designs:
- Appearance bottom sheet (`lib/presentation/screen/reader/widgets/appearance_sheet.dart`) matching `04b_appearance_sheet` (`d8bb2a41`).
- Wiktionary definition card & floating text selection toolbar (`lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart`, `highlight_editor_sheet.dart`) matching `04c_text_selection_dictionary` (`3377a7d8`).
- Contents TOC & Annotations side sheet matching `04d_contents_annotations` (`60c9068e`).
- In-book search overlay (`lib/presentation/screen/reader/widgets/reader_search.dart`) matching `04e_search_in_book` (`c63b6121`).
- Full-screen Read Aloud player sheet matching `05_read_aloud` (`b44bfe85`).

### R3. Paywall and Annotations Screens
Implement the remaining application screens:
- Premium paywall sheet (`lib/presentation/screen/premium/widgets/premium_paywall_sheet.dart`) matching `07_premium_paywall` (`e4e1f706`).
- All annotations screen (`lib/presentation/screen/annotations/`) matching `08_all_annotations` (`837a423b`).

### R4. Architecture, State Integration, and Navigation Constraints
Connect screens with existing app state/blocs/services where available, providing fallback/mock data where backend logic is not yet built. Follow Material 3 Warm Editorial Minimalism throughout all components. Strictly zero bottom navigation bars anywhere in the app. All Flutter CLI commands must be executed with `fvm flutter <cmd>`.

## Acceptance Criteria

### UI Fidelity and Completeness
- [ ] Settings screen and grouped inset cards match Stitch screen `03_settings` (`0e2582dd`).
- [ ] Reader appearance sheet matches Stitch screen `04b_appearance_sheet` (`d8bb2a41`).
- [ ] Wiktionary definition card and floating text selection toolbar match Stitch screen `04c_text_selection_dictionary` (`3377a7d8`).
- [ ] Contents TOC and annotations side sheet match Stitch screen `04d_contents_annotations` (`60c9068e`).
- [ ] In-book search overlay matches Stitch screen `04e_search_in_book` (`c63b6121`).
- [ ] Full-screen Read Aloud player sheet matches Stitch screen `05_read_aloud` (`b44bfe85`).
- [ ] Premium paywall sheet matches Stitch screen `07_premium_paywall` (`e4e1f706`).
- [ ] All annotations screen matches Stitch screen `08_all_annotations` (`837a423b`).
- [ ] Strictly zero bottom navigation bars anywhere in the app.
- [ ] Presentation widgets connect to existing state/blocs/services where available, using mock or fallback data where backend logic is not yet built.

### Code Quality and Verification
- [ ] `fvm flutter analyze` produces zero errors or warnings.
- [ ] `fvm flutter test` runs with 100% of tests passing.

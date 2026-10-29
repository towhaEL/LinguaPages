# LinguaPage implementation plan

Target: Android-first v1.0 of a private ebook reader for every common DRM-free format (EPUB, PDF, TXT, Markdown, HTML, FB2). Built with Flutter Clean Architecture and BLoC. English UI only. Dark, premium, simple design. Product context is in [PRODUCT.md](PRODUCT.md); verified progress is in [implementation_status.md](implementation_status.md).

## Decisions (2026-10-29)

| Topic | Decision |
|---|---|
| Scope | An ebook reader only. All language-learning features are removed. |
| Dictionary | English definitions from the free Free Dictionary API, `GET https://api.dictionaryapi.dev/api/v2/entries/en/<word>`. The data is Wiktionary content under CC BY-SA 3.0, so attribution is required. |
| Network | The dictionary is the app's only network call. Results are cached locally, so a word looked up once works offline. |
| Premium | Appearance only: extra reading themes, fonts and style presets. Reading, annotations, export, backup and the dictionary are free. |
| App language | English only. Spanish UI localization is removed. |
| Visual direction | Dark, premium, simple. The app chrome is dark-only; reading pages keep their own selectable themes. All UI work goes through the Impeccable skill. |
| Out of scope | Accounts, cloud sync, AI Recap, vocabulary, spaced-repetition review, translation and language packs. |

## Where we are

Already built and verified (see the status doc): Drift foundation (schema v6), import with validation, metadata, covers and TOC, the library UI, the native Readium EPUB/PDF reader plus fallback engines, reader settings, search, bookmarks, highlights, notes, Markdown export, metadata backup/restore and a local entitlement cache. The code also still contains vocabulary, review, reminders, translation, language packs, AI Recap, Spanish UI and a two-word EN→ES dictionary fixture. All of that is removed in Phase 1.

## Architecture rules

- Keep the existing layers: `core/`, `domain/`, `data/`, `presentation/`, plus BLoC and auto_route.
- SQLite/Drift is the local source of truth. Book files and covers live in app-private storage.
- `DocumentEngine` stays a domain abstraction with one adapter per format.
- BLoCs/Cubits call use cases or repository interfaces, never plugins, Dio or Drift directly.
- Network access exists only for the dictionary. It goes through the CLAUDE.md data-source pattern: an interface plus `remote/` (Retrofit) and `mock/` implementations behind `DataSourceFactory`. The development flavor uses the mock and stays fully offline.
- Platform features (file import, billing, wake-lock) stay behind interfaces.

## Phase plan

| Phase | Duration | Outcome |
|---|---:|---|
| 1. Cleanup and English-only | 1–1.5 weeks | No language-learning code, data, flags or copy; English is the only locale |
| 2. Design foundation (Impeccable) | 1–1.5 weeks | A recorded dark design world in DESIGN.md, implemented as Flutter theme tokens with bundled fonts |
| 3. Online dictionary | 1.5–2 weeks | Free Dictionary API lookup with cache, offline/error states and attribution |
| 4. Premium appearance | 2 weeks | Theme/font/style catalog, gating, Play Billing, restore |
| 5. Surface redesign (Impeccable) | 3–4 weeks | Library, reader chrome, sheets, settings, paywall, onboarding and splash rebuilt on the new design |
| 6. Library and backup completion | 1.5 weeks | PDF covers, chapter progress, backup without study data, optional book files |
| 7. Hardening | 3 weeks | Corpus, performance, accessibility, failure testing |
| 8. Beta and Android release | 1–2 weeks | Closed beta, store listing, Data Safety, release |

Estimated remaining effort: about 14–17 weeks for one experienced developer.

---

## Phase 1 — Cleanup and English-only

Goal: the codebase contains only the reader product.

Remove:

- **Vocabulary:** screen, Cubit, use cases, repository, entity and tests, plus the dashboard tab.
- **Review:** screen, Cubit, `ReviewCardUseCase`, SM-2 repository, statistics, streaks, history and tests, plus the dashboard tab.
- **Library extras:** the due-count shortcut, the daily new-card limit setting and the 500-word premium gate.
- **Reminders:** the review reminder scheduler. Also drop `flutter_local_notifications`, `flutter_timezone` and `timezone` if nothing else uses them.
- **Translation:** the language-pack manager, repository and bundled pack, the lemmatizer, the sentence translation service and `lib/data/data_source/translation/local/`.
- **AI Recap:** the recap entity and repositories, plus the `aiRecapEnabled`, `mockTranslationEnabled` and `cloudSyncEnabled` flags.
- **Spanish UI:** `app_es.arb` and its generated files, `lib/presentation/locale/` and the locale picker. `supportedLocales` becomes `[Locale('en')]`.
- **Unused code:** `l10n` keys that no longer have a caller, and the template Retrofit/Dio code apart from what Phase 3 reuses.

Data:

- Add a Drift migration from v6 to v7 that drops the vocabulary, review-card and review-history tables.
- Add an upgrade test showing that a v6 database keeps its books, highlights, bookmarks, reading sessions and settings.
- Backup export no longer writes study data. Restoring an older backup ignores those sections instead of failing.

Copy:

- The delete-book dialog changes from "Keep study data" to "Keep annotations".
- Remove the onboarding and privacy text about translation and Spanish. Onboarding is fully rewritten in Phase 5; until then it only needs to stop lying.

Exit criteria:
- `dart run build_runner build`, `flutter analyze` and `flutter test` pass.
- `grep -riE "vocab|review|translat|spanish|recap" lib/` returns nothing product-related.
- A v6 database upgrades with no annotation loss.

## Phase 2 — Design foundation (Impeccable)

Goal: one dark, premium, simple design world, recorded in DESIGN.md and expressed as Flutter tokens before any screen is rebuilt.

Steps:

1. Run `/impeccable shape library` and `/impeccable shape reader`. These confirm the brief for the two most-used surfaces; both are Operate mode, where precision and restraint matter more than decoration.
2. Let Impeccable's new-work flow choose the replacement visual world (the current Plus Jakarta Sans/Roboto Material look is treated as the old look being replaced). Record it in `DESIGN.md`.
3. Implement the world as tokens in `lib/presentation/theme/`:
   - The app chrome is dark-only. Remove the light app theme, `system_mode.dart` and the theme-mode switch for chrome.
   - Define color roles, type scale, spacing, radius, elevation and motion tokens as a `ThemeExtension`. Widgets read tokens, never hex values.
   - Reading-page themes (Light, Sepia, Dark and the premium themes) are a separate token set applied to page content only. A light page inside dark chrome is intended.
4. Bundle fonts as assets. Set `GoogleFonts.config.allowRuntimeFetching = false` or drop `google_fonts`, because runtime font downloads break offline use and leak network traffic.
5. Build the shared widget kit on the tokens: app bar, sheet, list row, button, chip, empty/error state, skeleton loader and lock badge for premium items.

Exit criteria:
- DESIGN.md exists.
- Every screen still runs on the new tokens, even before redesign.
- No hard-coded colors remain in `lib/presentation/screen/`.
- The app starts in airplane mode with correct fonts.

## Phase 3 — Online dictionary

Goal: select a word, then see its English definition, offline after the first lookup.

Domain:

- Reshape `DictionaryEntry` to match the API:
  - `word` and `phonetic` (the first `phonetics[].text` that is not empty);
  - `meanings`, each with `partOfSpeech`, a list of definitions (`definition`, optional `example`, `synonyms`, `antonyms`), and meaning-level `synonyms` and `antonyms`;
  - `license` (name and url) and `sourceUrls`.
- A lookup result is one of `found(entries)`, `notFound`, `offline` or `failed`.
- `LookupWordUseCase` normalizes input before any call: trim, lowercase, strip surrounding punctuation and possessive `'s`. It accepts only one word; for a phrase or empty input, the sheet offers Highlight and Copy only.

Data:

- `DictionaryDataSource` interface:
  - `remote/` is a Retrofit `@RestApi(baseUrl: 'https://api.dictionaryapi.dev/api/v2/')` with `@GET('entries/en/{word}')`, which returns a JSON array;
  - `mock/` returns fixture entries, including "hello" from the API sample;
  - both are wired into `DataSourceProvider` and both factories.
- Response handling:
  - HTTP 404 (body `{"title":"No Definitions Found",...}`) maps to `notFound`;
  - `DioException` connection and timeout errors map to `offline`;
  - other failures map to `failed`;
  - use short timeouts (about 8 seconds) and no automatic retry loop.
- Cache: a new Drift table `dictionary_cache` with columns `word` (primary key, normalized), `json` and `fetched_at`.
  - The repository checks the cache first and only calls the network on a miss.
  - Not-found results are cached for 7 days.
  - Found results are kept until the user clears the cache in Settings.
  - The existing in-memory cache stays in front of Drift.
- Android: add the `INTERNET` permission to the **main** manifest (it is missing today, so release builds would fail every lookup).

Presentation:

- The lookup sheet shows the word, phonetic, part-of-speech groups, numbered definitions, examples and synonym chips.
  - Actions: Highlight and Copy.
  - It has states for loading, not found, offline ("Connect to look up new words") and failed with Retry.
- Attribution: every result shows its license name and Wiktionary source link, opened with `url_launcher`.
- Settings:
  - an "Online dictionary" switch, on by default; off means cache-only;
  - a "Clear dictionary cache" action.
- Privacy screen and first lookup: state that only the selected word is sent to dictionaryapi.dev.

Not in v1.0: pronunciation audio (it needs an audio player dependency and per-file CC licensing); moved to v1.1.

Tests:
- remote mapper with the "hello" fixture;
- 404 mapping to not found;
- offline mapping;
- cache hit avoiding the network;
- normalization cases;
- Cubit states.

Exit criteria:
- Lookups work online.
- A repeat lookup works in airplane mode.
- A missing word shows not found.
- No crash when the API is down.
- The development flavor never touches the network.

## Phase 4 — Premium appearance

Goal: users can pay for extra looks. Nothing functional is ever locked.

- **Catalog:** a domain `AppearanceCatalog` lists every reading theme, font and style preset with a `premium` flag.
  - Free: Light, Sepia and Dark themes, the default serif and sans fonts, and the default style.
  - Premium: the extra themes, fonts and presets designed in Phase 2.
  - A **style preset** is a named bundle of font, size, line spacing, margins and alignment.
- **Gating:**
  - The reader settings sheet shows premium items with a lock badge and lets the user try them as a live preview; applying one opens the paywall.
  - When premium expires, the reader falls back to the free default without deleting the user's saved choices.
- **Billing:**
  - Use Google Play Billing through the official `in_app_purchase` plugin behind a `BillingService` interface. The mock implementation is used in development, which already disables gating.
  - Keep the existing local entitlement cache, verify periodically when online, and never lock the user out offline.
  - Support restoring purchases.
  - **Open:** product type (one-time unlock or subscription), product IDs and price. These must be set in Play Console before this phase finishes.
- **Cleanup:** remove the export-limit and vocabulary-limit rules from `premium_entitlement_repository`.
- **Tests:** the catalog flags, the gate's behavior on expiry and offline, restore, and billing errors.

Exit criteria:
- Purchase and restore work in the Play sandbox.
- An expired entitlement falls back cleanly.
- Every feature apart from appearance works without premium.

## Phase 5 — Surface redesign (Impeccable)

Goal: every screen rebuilt on the Phase 2 world. Do one surface per pass, in this order, so the most-used surfaces set the bar:

1. **Library:** grid/list, search, sort, format badges, progress, and the empty, no-results and import-error states.
2. **Reader chrome:** top and bottom bars, the page progress, the settings sheet (themes, fonts, styles, with premium previews), TOC, search and thumbnails.
3. **Selection and lookup:** the selection toolbar, the dictionary sheet from Phase 3, highlight colors and the note editor.
4. **Annotations panel and export.**
5. **Settings:** reading defaults, the dictionary toggle and cache, backup/restore, privacy and premium status.
6. **Paywall:** a calm screen with no countdowns or dark patterns. It lists what premium includes and has a restore action.
7. **Onboarding:** rewritten for the reader in at most three steps: private by design, import your first book, and select text to highlight or define.
8. **Splash and app icon.**

For each surface:
1. Run `/impeccable <surface>` (new work on the agreed world).
2. Run `/impeccable harden <surface>` for loading, empty, error, offline and long-text states.
3. Run `/impeccable audit <surface>` for contrast, touch targets, TalkBack labels and large text.

Finish with `/impeccable polish` across the app and `/impeccable adapt` for tablets and landscape.

Exit criteria:
- Every route uses the shared widget kit and tokens.
- Audits show no contrast or touch-target failures.
- Screenshots of all surfaces are reviewed at phone and tablet sizes.

## Phase 6 — Library and backup completion

- PDF cover rendering at import (render the first page with pdfrx and store it in cover storage).
- Chapter-aware progress labels on library cards, using the stored TOC and locator.
- Split and harden the format-specific text adapters (TXT, Markdown, HTML, FB2) instead of sharing one reflowable adapter.
- Backup:
  - export covers library metadata, annotations, settings and the dictionary cache (optional);
  - book files can optionally be included as a zip;
  - restore merges without duplicates;
  - encrypted backup with a user passphrase is optional.
- Annotation export: keep Markdown, and add sharing through the system share sheet.

## Phase 7 — Hardening

- Build a compatibility corpus of 20–30 documents: valid, malformed, large, DRM-protected and right-to-left samples.
- Tests:
  - widget tests for the library, reader controls, annotations, lookup and paywall;
  - an Android integration test for the path import → read → highlight → define → export;
  - performance checks for startup, import, first page, page turn and cached versus network lookups on a mid-range device.
- Failure testing:
  - offline and flaky-network dictionary behavior, and the API being down;
  - interrupted imports, corrupt files and malicious archives;
  - Play Billing sandbox, including refunds and expiry.
- Accessibility: TalkBack and large-text passes on every surface.

## Phase 8 — Beta and Android release

Release gates:
- all P0 flows pass;
- no known data-loss or crash defects;
- at least 95% of the corpus renders without critical failure;
- a crash-free beta rate of at least 99%;
- no secrets in the app.

Store requirements:
- Play Data Safety declares the network use: the looked-up word goes to dictionaryapi.dev, and no personal data is collected.
- The privacy policy matches that declaration.
- An in-app credits screen lists Wiktionary (CC BY-SA 3.0) and the open-source licenses (`showLicensePage`).

Ship a closed beta first, then production.

## v1.1 candidates

- Pronunciation audio from the dictionary (with per-file license attribution).
- CSV export of annotations.
- Home-screen widgets.
- DOCX, MOBI and AZW3 conversion.
- OCR for scanned PDFs.
- A CBZ comic reader.
- Web article import.

## Open decisions

- Premium product type, product IDs and price (needed by the end of Phase 4).
- Whether "Online dictionary" defaults to on (planned) or asks on first use.
- A self-hosted or bundled fallback if dictionaryapi.dev becomes unreliable. It has no SLA and no published rate limits.

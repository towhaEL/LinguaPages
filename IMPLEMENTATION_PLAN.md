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
| ReadEra review (2026-11-01) | ReadEra 26.05.20 was reviewed for feature ideas. Reader-comfort, library-organisation and read-aloud features that fit the scope above are added as Phases 7 and 8. Features that conflict with the decisions above are listed under "Considered and excluded". Features are built independently; no ReadEra code, text or assets are used. |

## Where we are

Already built and verified (see the status doc): Drift foundation (schema v8), import with validation, metadata, covers and TOC, the library UI, the native Readium EPUB/PDF reader plus fallback engines, reader settings, search, bookmarks, highlights, notes, Markdown export, metadata backup/restore and a local entitlement cache. Phase 1 (cleanup and English-only), Phase 2 (design foundation, "Paperback Bands"), Phase 3 (online dictionary, physical-device check pending) Phase 4 (premium appearance, Play sandbox check pending) and Phase 5 (surface redesign, tablet hardware check pending) and Phase 6 (library and backup completion, device check pending) Phase 7 (reader and library parity, gaps listed in its section) and Phase 8 (read aloud, gaps listed in its section) are done.

## Architecture rules

- Keep the existing layers: `core/`, `domain/`, `data/`, `presentation/`, plus BLoC and auto_route.
- SQLite/Drift is the local source of truth. Book files and covers live in app-private storage.
- `DocumentEngine` stays a domain abstraction with one adapter per format.
- BLoCs/Cubits call use cases or repository interfaces, never plugins, Dio or Drift directly.
- Network access exists only for the dictionary. It goes through a data-source interface with `remote/` (Retrofit) and `mock/` implementations, chosen per flavor with `@Environment` bindings. The development flavor uses the mock and stays fully offline.
- Platform features (file import, billing, wake-lock) stay behind interfaces.

## Phase plan

| Phase | Duration | Outcome |
|---|---:|---|
| 1. Cleanup and English-only ✅ | 1–1.5 weeks | No language-learning code, data, flags or copy; English is the only locale |
| 2. Design foundation (Impeccable) ✅ | 1–1.5 weeks | A recorded dark design world in DESIGN.md, implemented as Flutter theme tokens with bundled fonts |
| 3. Online dictionary ✅ | 1.5–2 weeks | Free Dictionary API lookup with cache, offline/error states and attribution |
| 4. Premium appearance ✅ | 2 weeks | Theme/font/style catalog, gating, Play Billing, restore |
| 5. Surface redesign (Impeccable) ✅ | 3–4 weeks | Library, reader chrome, sheets, settings, paywall, onboarding and splash rebuilt on the new design |
| 6. Library and backup completion ✅ | 1.5 weeks | PDF covers, chapter progress, backup without study data, optional book files |
| 7. Reader and library parity ✅ | 3–4 weeks | Typography and layout controls, page-turn controls, shelves, collections, trash, metadata editing, cross-book annotations |
| 8. Read aloud ✅ | 2 weeks | Readium text-to-speech with voice, speed, sleep timer, sentence highlight and background playback |
| 9. Hardening | 3 weeks | Corpus, performance, accessibility, failure testing |
| 10. Beta and Android release | 1–2 weeks | Closed beta, store listing, Data Safety, release |

Estimated remaining effort (Phases 6–10): about 10.5–12.5 weeks for one experienced developer. Phases 7 and 8 can run before Phase 5 so the redesign covers their screens; otherwise Phase 5 needs a second pass for them.

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

## Phase 4 — Premium appearance ✅

> Implemented 2026-11-01 as a one-time non-consumable product, `premium_appearance` (an assumption; confirm under Open decisions). Remaining: create the product in Play Console and run the sandbox checks in the exit criteria. Font import was not built and moved to v1.1 candidates. Details are in the status doc.

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
- **Catalog candidates from the ReadEra review:** Night-contrast, Sepia-contrast and Twilight reading themes, and importing the user's own font files (`.ttf`/`.otf`, copied into app-private storage). Both are appearance, so both may be premium.
- **Cleanup:** remove the export-limit and vocabulary-limit rules from `premium_entitlement_repository`.
- **Tests:** the catalog flags, the gate's behavior on expiry and offline, restore, and billing errors.

Exit criteria:
- Purchase and restore work in the Play sandbox.
- An expired entitlement falls back cleanly.
- Every feature apart from appearance works without premium.

## Phase 5 — Surface redesign (Impeccable) ✅

> Done 2026-11-01. All eight surfaces were rebuilt in order and checked on a phone; highlights now draw on every renderer (they were saved but never shown). Remaining: a tablet-size review on hardware, and the Readium limits noted in the status doc (hard-coded heading colours on dark themes, green selection handles). Phases 7 and 8 add new screens that will need the same treatment.

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

## Phase 6 — Library and backup completion ✅

Done 2026-11-02. Verified on a device: PDF cover rendering, encrypted backup export and restore (including a wrong passphrase), and the annotation share sheet. Backups are a zip (`backup.json` plus optional `books/` and `covers/`), optionally AES-encrypted with WinZip AES (PBKDF2-SHA1, 1000 iterations, passphrase of 8+ characters). Restore still reads the old JSON backups, matches books by content fingerprint and remaps their annotations. Chapter labels come from the saved Readium locator, so TXT/Markdown/HTML/FB2 cards still show only a percentage.

- PDF cover rendering at import (render the first page with pdfrx and store it in cover storage).
- Chapter-aware progress labels on library cards, using the stored TOC and locator.
- Split and harden the format-specific text adapters (TXT, Markdown, HTML, FB2) instead of sharing one reflowable adapter.
- Backup:
  - export covers library metadata, annotations, settings and the dictionary cache (optional);
  - book files can optionally be included as a zip;
  - restore merges without duplicates;
  - encrypted backup with a user passphrase is optional.
- Annotation export: keep Markdown, and add sharing through the system share sheet.

## Phase 7 — Reader and library parity ✅

Done 2026-11-02 with these gaps: tap-zone schemes and page-turn animation apply to the fallback reader only, because `flutter_readium` hard-codes Readium's edge taps (left as is); PDF smart crop and "time left in chapter" are not built. Checklist and device results are in the status doc.

Goal: close the everyday reading and organising gaps a heavy reader notices against a mature reader such as ReadEra. Nothing here needs the network, an account or extra storage permissions.

Reader comfort. Most of these are existing `flutter_readium` EPUB preferences that only need a control and a persisted setting:

- Hyphenation, paragraph spacing, paragraph indent, letter and word spacing (`hyphens`, `paragraphSpacing`, `paragraphIndent`, `letterSpacing`, `wordSpacing`).
- "Use publisher styles" on/off (`publisherStyles`).
- Two-column layout on tablets and two pages in landscape (`columnCount`, `spread`).
- Reading direction and vertical text taken from the book, with a manual override (`readingProgression`, `verticalText`).
- Invert or dim images in dark reading themes (`imageFilter`), and the same for fallback PDF pages.
- Font weight (`fontWeight`).
- Fallback text engine: apply the same settings where they make sense, and fix the known bug where pagination splits a word across pages.

Page turning and screen:

- Configurable tap zones: a left/right scheme and a top/bottom scheme, plus "tapping does not turn pages".
- Turn pages with the volume keys (an opt-in setting). This needs a small key-event hook in `MainActivity` behind a platform interface.
- Page-turn animation on/off where the engine allows it.
- Full-screen reading that hides the status and navigation bars, and an orientation lock (portrait, landscape, auto).
- Brightness by vertical swipe on the page edge, kept separate from the system brightness and reset on leaving the reader. This needs a brightness plugin (for example `screen_brightness`) behind an interface.
- A choice of progress display: page number, percentage, time left in chapter, or none.
- Optional corner shortcuts: tap the top-right corner to add a bookmark and the top-left corner to switch the reading theme.
- Smart crop of blank PDF margins.

Selection menu:

- Add Share, Search the web (opens the browser with the selected text) and "Send to app", which uses Android `ACTION_PROCESS_TEXT` so installed apps (dictionaries, note apps) can take the selection. LinguaPages sends nothing itself.

Library organisation (schema v9):

- Reading shelves: To read, Reading and Finished, plus Favorites. A finished book can be marked manually or automatically at 100%.
- Collections: user-named shelves, with a book allowed in several.
- Authors and Series views, built from imported metadata (EPUB `belongs-to-collection`/Calibre series and FB2 `sequence`).
- Edit book details: title, authors, series, series number and language, with a "reset from file" action.
- Trash: deleting moves a book to Trash, keeping its file and annotations; restore and empty-trash actions; books in Trash are purged automatically after 30 days.
- Duplicate detection at import using a content hash; offer "open existing" instead of importing twice.
- Import a whole folder through the Storage Access Framework, copying supported files into app-private storage. Start with a spike to confirm `file_picker` directory access returns readable URIs on Android 11+.
- Persist the grid/list view choice (a known bug).

Annotations:

- An "All annotations" screen across every book, filterable by colour, type (highlight, note, bookmark) and book, with search, opening each item at its position.
- Markdown export of the filtered selection.

Data and backup: the new shelf, collection, series and trash fields are included in the JSON backup, and restoring an older backup fills defaults.

Tests:
- the v8→v9 migration keeps books and annotations;
- shelf, collection and trash use cases;
- duplicate-hash detection;
- the reader settings mapping to Readium preferences;
- the tap-zone scheme hit-testing.

Exit criteria:
- Each new reader setting persists and applies to native and fallback engines.
- Volume-key turning works on a physical device and is off by default.
- A deleted book can be restored from Trash with its annotations.
- No new Android permission apart from what the brightness plugin needs (if any).

## Phase 8 — Read aloud ✅

Done 2026-11-02 with gaps: footnote skipping (Readium has no filter; page numbers can be skipped), no media notification for TXT/Markdown/HTML/FB2, and the 30-minute locked-screen run is still to do. Details are in the status doc.

Goal: listen to any EPUB (and PDFs with a text layer) using the device's own text-to-speech voices, fully offline.

- Use `flutter_readium`'s built-in TTS (`ttsEnable`, `ttsSetPreferences`, `ttsGetAvailableVoices`, `ttsSetVoice`, `play`/`pause`/`resume`/`stop`) for EPUB and PDF. It already highlights the sentence being read through decorations and follows the content language.
- For TXT, Markdown, HTML and FB2, use `flutter_tts` on the fallback engine's paragraphs, highlighting the current sentence. Put both behind one `ReadAloudService` domain interface.
- Controls: play/pause, previous/next sentence, speed (0.5×–3×), voice per language with a sensible default, and a sleep timer (15, 30, 60 minutes or end of chapter).
- Options: skip footnotes and page headers on or off, and keep the screen on during playback.
- Background playback with the screen locked: media notification and lock-screen controls through a foreground media service (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`). Start with a spike to see whether Readium's TTS navigator keeps running in the background or needs `audio_service`.
- Empty states: no TTS engine installed, and no voice for the book's language (with a link to the system TTS settings).
- Reading position follows playback, so stopping leaves the reader where the audio stopped.

Tests: the `ReadAloudService` state machine, the sleep timer and voice selection fallback.

Exit criteria:
- An EPUB plays for 30 minutes with the screen locked on a physical device.
- Pausing and resuming keep the position.
- The sleep timer stops playback.

## Phase 9 — Hardening

- Build a compatibility corpus of 20–30 documents: valid, malformed, large, DRM-protected and right-to-left samples.
- Tests:
  - widget tests for the library, reader controls, annotations, lookup, paywall, shelves and read-aloud controls;
  - an Android integration test for the path import → read → highlight → define → export;
  - performance checks for startup, import, first page, page turn and cached versus network lookups on a mid-range device.
- Failure testing:
  - offline and flaky-network dictionary behavior, and the API being down;
  - interrupted imports, corrupt files and malicious archives;
  - Play Billing sandbox, including refunds and expiry.
- Accessibility: TalkBack and large-text passes on every surface.

## Phase 10 — Beta and Android release

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
- More formats seen in ReadEra: RTF, ODT, DJVU, CHM, CBR and books inside ZIP archives. Check each library's licence first: MuPDF and DjVuLibre-based engines are AGPL/GPL, which would force the app's source to be published.
- A personal book rating and review.
- Android Auto playback for read aloud.
- Importing the user's own font files (`.ttf`/`.otf`) as a premium appearance item, copied into app-private storage.

## Considered and excluded (ReadEra review, 2026-11-01)

These ReadEra features conflict with the decisions above and stay out unless a decision changes:

- **Personal word dictionary, word forms and context sentences.** This is a vocabulary feature, which was removed from the product.
- **Built-in translator.** Translation was removed. "Send to app" in Phase 7 lets the user pick their own translator app instead.
- **Cloud sync, accounts and cloud backup** (Google Drive, Huawei Drive). The product has no account or cloud.
- **Scanning the whole device for books.** It needs the `MANAGE_EXTERNAL_STORAGE` permission, which Google Play restricts, and it breaks the app-private library model. Folder import (Phase 7) covers the need.
- **Kids mode with a passcode.** Niche for the target users.
- **Locking reading features behind premium.** ReadEra makes background read-aloud and sync premium; here premium stays appearance-only.
- **Analytics SDKs, seasonal promotions and rating prompts.** These conflict with the calm, private positioning.

## Open decisions

- Premium product type and price. Built as a one-time non-consumable unlock with product ID `premium_appearance`; changing to a subscription means adding base-plan offers and expiry handling in `PlayBillingService`. The price is set only in Play Console.
- Whether "Online dictionary" defaults to on (planned) or asks on first use.
- A self-hosted or bundled fallback if dictionaryapi.dev becomes unreliable. It has no SLA and no published rate limits.

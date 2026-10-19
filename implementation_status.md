# LinguaPages — Implementation Status & Task List

## Current Status Summary

**Last verified: 2026-10-19.** The project is in an active migration from the Flutter template to LinguaPages. The Dart package has been renamed and the old auth/user/architecture screens and data sources have been removed. The application now **builds and passes its current automated checks**. The working product now includes a first reader route and screen, but no end-to-end study flow exists yet.

The practical status is approximately **Phase 0: 70%**, **Phase 1: 75%**, **Phase 2: 85%**, **Phase 3: 90%**, **Phase 4: 55%**, **Phase 5: 63%**, and **Phase 6: 20%**. The project has a working local foundation, validated import storage and library flow, Android "Open with" intake, shared text-format support, typed corrupt/unsupported import feedback, imported EPUB/Markdown/HTML/FB2 TOC metadata, early EPUB/PDF adapters, a native Readium EPUB/PDF reader on Android/iOS, a format-aware fallback engine, locator-backed TOC/outline navigation, in-document search, paginated/continuous reflowable reading, debounced locator-based progress persistence, persisted reader appearance/alignment settings, persisted PDF fit-to-page/fit-to-width and selectable-text controls, lazy PDF page thumbnails, explicit fallback-PDF zoom controls, screen wake-lock support, accessible fallback page tap zones, persisted bookmarks/highlights, a unified annotation list with editable notes and Markdown export, an offline dictionary-to-vocabulary lookup flow with normalized in-memory response caching, Vocabulary and Review tabs with book/language/status filters and a Library due-count shortcut, a persisted Settings control for the daily new-card limit, hidden-word context cards with local review statistics/streaks, a local English→Spanish language-pack manager, and metadata backup/restore controls. PDF cover rendering, chapter-aware library progress, real downloadable/checksum-backed language packs, sentence translation, binary/encrypted backups, and broader device-level interaction testing remain. Overall v1.0 implementation is approximately **64%**, with architectural scaffolding counted separately from product functionality.

### Native book handling decision

`flutter_readium` **0.6.2** is now the native reader backend for EPUB and PDF on Android/iOS. It owns native pagination, reflow, PDF rendering, text selection, TOC navigation and locator events. The app stores the Readium locator JSON and percentage in the library database so reading resumes at the saved position. TXT, Markdown, HTML and FB2 continue through the local `DocumentEngine`; EPUB/PDF retain that engine as the desktop/fallback path.

Readium's Android integration uses `FlutterFragmentActivity`, Android API 24+ and core-library desugaring. `flutter_readium` 0.6.2 declares Java 18, so [android/settings.gradle.kts](file:///Users/uswer/StudioProjects/linguaPages/android/settings.gradle.kts) applies a project-local Java 17 compatibility override for the plugin; the configured Flutter JDK 17 toolchain now builds successfully. iOS is configured for deployment target 15.0 with the Readium 3.11 pods. Protected LCP publications and native macOS reading are not part of this integration.

### Verification snapshot

- `dart run build_runner build` — passed; generated Drift, injectable and route outputs.
- `flutter analyze` — passed with **no issues**.
- `flutter test` — passed: **39 tests**, with **2 PDF runtime tests skipped** because Flutter VM tests do not provide pdfrx's native PDFium assets.
- Metadata tests — EPUB title/author/language/cover extraction, PDF Info metadata extraction, cover storage wiring and repository persistence are covered by focused tests.
- Import error tests — unsupported extensions, malformed EPUB packages, invalid signatures and empty files now produce typed failures; the library maps them to localized feedback.
- Library view-mode test — grid/list state switching is covered; the library now supports both grid and list presentations.
- Library sorting test — repository progress ordering is covered; the UI exposes recent, title, author, and progress sorting.
- Library presentation — format badges and localized progress status labels are now rendered in both grid and list cards.
- Reader search — the reader exposes localized search for native Readium EPUB/PDF documents and fallback formats, with chapter/context results and locator/page jumps.
- Reader progress persistence — rapid page/locator events are coalesced, then flushed on app backgrounding and reader disposal so the newest position is retained without writing on every event.
- Reader appearance settings — light/sepia/dark themes, font size, line spacing and margins are persisted locally and applied to fallback pages plus native Readium EPUB/PDF preferences where supported.
- Reader alignment settings — left, centered and justified text layouts are persisted and applied to fallback pages and native Readium EPUB preferences.
- Reader modes — Pages/Continuous selection is persisted; fallback reflowable documents scroll continuously with progress tracking, while Readium applies the matching native EPUB/PDF mode.
- Reader PDF fit — Fit-to-page and fit-to-width selection is persisted and applied to fallback PDF rendering and native Readium PDF preferences.
- Reader fallback TOC navigation — EPUB, Markdown/HTML/FB2 and fallback PDF outline entries now carry locators and jump to the matching page or continuous-scroll position.
- PDF thumbnails — fallback PDF thumbnails render on demand in a localized grid, cache while open, highlight the current page and jump to the selected page.
- PDF zoom — fallback PDF pages support explicit zoom in, zoom out and reset controls alongside pinch-to-zoom; zoom resets when the page or fit mode changes.
- PDF text mode — fallback PDF settings persist a visual page-image or selectable-text mode; native Readium PDF remains the platform renderer.
- Screen wake-lock — the persisted reader setting enables `wakelock_plus` while reading and disables it when the reader is disposed.
- Reader tap zones — fallback paginated reading exposes accessible transparent left/right page-turn zones while retaining the visible controls.
- Bookmarks — reader bookmarks persist format-neutral locators, list and delete from a bottom sheet, and jump to fallback or native Readium positions.
- Highlights — fallback selectable text and native Readium selection actions can create persisted highlights in yellow, green, blue or pink.
- Annotation management — bookmarks and highlights share a reader panel with locator jumps, deletion, highlight color editing and optional notes.
- Annotation export — the reader copies a stable Markdown export containing book title, highlight text/colors/notes/locators and bookmarks.
- Lookup flow — selected text can use the offline English→Spanish dictionary fixture, copy the result, save a vocabulary item with book/locator context, or create a highlight.
- Lookup caching — normalized dictionary lookups and misses are cached in memory for the app session; failed provider requests are evicted and can be retried.
- Vocabulary/review flow — the dashboard exposes Vocabulary and Review tabs; saved words create review cards, vocabulary search/delete are available, and Again/Hard/Good/Easy actions update deterministic local scheduling.
- Daily review limit — the persisted default of 15 new cards is enforced when due cards are loaded for review.
- Vocabulary filters — the Vocabulary tab filters by book, source language and review status using all persisted review cards.
- Home review shortcut — the Library app bar shows the current due-card count and opens the Review tab; the count refreshes when the app resumes.
- Study settings — Settings persists a selectable daily new-card limit, and Review enforces it when loading new cards.
- Review cards — the prompt masks the saved word in its context sentence before reveal and shows due/reviewed/streak/active-day statistics from local card timestamps.
- Language-pack manager — Settings exposes the replaceable language-pack repository with persisted local install/delete state for the bundled English→Spanish fixture.
- Backup controls — Settings exports the metadata JSON snapshot through the native save dialog and restores/merges a selected backup with localized restored/duplicate counts; book binaries and encryption remain out of scope for this slice.
- Delete-flow tests — keep-study-data soft deletion and delete-study-data transactional cleanup are covered, including linked bookmarks, vocabulary, and review cards.
- `flutter build apk --debug --flavor development -t lib/main_development.dart` — passed with Readium under the configured **JDK 17** toolchain; output: `build/app/outputs/flutter-apk/app-development-debug.apk`.
- Development device startup — the configured `flutter run --machine` command built, installed and reached `app.started` on CPH2819; the debug session was then stopped cleanly.
- Android `ACTION_VIEW` — a cold launch with a device EPUB imported through the native intent bridge and persisted in app-private storage; Flutter deep-link routing is disabled for this document handoff.
- `flutter build ios --debug --simulator --flavor development -t lib/main_development.dart` — passed with Readium pods.
- `l10n.yaml` — removed the obsolete `synthetic-package` setting.
- `lingua_page_database.g.dart` — now exposes all seven declared tables and schema version 5, including persisted `readingLocatorJson`, imported `tableOfContentsJson` and soft-deleted book state.

---

## What Exists Today

### ✅ Infrastructure (from template)
| Item | File(s) | Notes |
|---|---|---|
| BLoC + auto_route architecture | Throughout | Matches plan decision to keep BLoC over Riverpod |
| Flavor system (dev/staging/prod) | [main_development.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/main_development.dart), etc. | Three entry points |
| DI via get_it + injectable | [injector.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/core/injector/injector.dart) | Working with `@LazySingleton`, `@singleton` |
| DataSource factory pattern | Removed with template data sources | No longer part of the active v1.0 path; translation and recap use explicit interfaces |
| English + Spanish localization | [app_localizations_en.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/l10n/gen/app_localizations_en.dart), [app_localizations_es.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/l10n/gen/app_localizations_es.dart) | Has library-specific l10n strings added |
| Theme system (light/dark) | `lib/presentation/theme/` | Color tokens, text themes, dark mode |
| Dio + Retrofit networking | `pubspec.yaml` | Dependencies remain, but the template auth/user data sources using them were removed |
| Secure storage | [secure_storage_service.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/core/helper/secure_storage_service.dart) | |

### ✅ Phase 0 — Technical Validation (Partial)
| Item | File(s) | Status |
|---|---|---|
| `DocumentLocator` sealed class | [document_locator.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/core/document/document_locator.dart) | ✅ Done — `EpubLocator`, `PdfLocator`, `TextLocator` with JSON serialization |
| `DocumentEngine` interface | [document_engine.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/service/document_engine.dart) | ✅ Done — `open`, `close`, `tableOfContents`, `renderPage`, `search`, `resolveSelection` |
| Document models | [document_models.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/entity/document/document_models.dart) | ✅ Done — `DocumentFormat` enum (6 formats), `DocumentInfo`, `DocumentTextSelection`, `DocumentSearchResult` |
| `DictionaryRepository` interface | [dictionary_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/repository/translation/dictionary_repository.dart) | ✅ Done — with `DictionaryEntry` model |
| Mock dictionary fixture | [mock_dictionary_data_source.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/data_source/translation/mock/mock_dictionary_data_source.dart) | ✅ Done — 2 fixture entries (book→libro, read→leer) |
| `LanguagePackRepository` interface | [language_pack_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/repository/translation/language_pack_repository.dart) | ✅ Done — with `LanguagePackInfo` model |
| Feature flags | [app_feature_flags.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/core/feature_flags/app_feature_flags.dart) | ✅ Done — includes `aiRecapEnabled`, `premiumEnabled`, `cloudSyncEnabled`, `mockServicesEnabled`, and `mockTranslationEnabled` |
| Feature flags unit test | [app_feature_flags_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/core/feature_flags/app_feature_flags_test.dart) | ✅ Done |
| DocumentLocator unit test | [document_locator_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/core/document/document_locator_test.dart) | ✅ Done |

### ✅ Phase 1 — Foundation (Partial)
| Item | File(s) | Status |
|---|---|---|
| `BookEntity` | [book_entity.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/entity/library/book_entity.dart) | ✅ Done — full model with copyWith |
| `RecapEntity` | [recap_entity.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/entity/recap/recap_entity.dart) | ✅ Done |
| `LibraryRepository` | [library_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/repository/library/library_repository.dart) | ✅ Done — `getAll`, `search`, `getById`, `importDocument`, `updateProgress`, and delete/retain-study-data behavior |
| `RecapRepository` | [recap_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/repository/recap/recap_repository.dart) | ✅ Done |
| Subscription/billing repository | — | ❌ The old template subscription repository was removed; real entitlement and billing work is still pending |
| `DocumentImportService` | [document_import_service.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/service/document_import_service.dart) | ✅ Done |
| Drift database definitions | [lingua_page_database.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/data_source/library/local/lingua_page_database.dart) | ✅ Schema v5 with seven tables, persisted Readium locator, imported TOC metadata, and soft-deleted book state; generated output is synchronized |
| `DriftLibraryRepository` | [drift_library_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/repository_impl/library/drift_library_repository.dart) | ✅ Done — full CRUD, duplicate detection, sorting |
| Repository unit test | [drift_library_repository_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/data/repository_impl/library/drift_library_repository_test.dart) | ✅ Passing |
| `DuplicateDocumentException` | [duplicate_document_exception.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/exceptions/duplicate_document_exception.dart) | ✅ Done |
| `SubscriptionRequiredException` | — | Removed with the template subscription flow; replacement entitlement rules are still pending |
| Use case: `ImportDocumentUseCase` | [import_document_use_case.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/use_cases/library/import_document_use_case.dart) | ✅ Done for the current library flow |
| Use cases: `GetLibraryBooksUseCase` | [get_library_books_use_case.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/use_cases/library/get_library_books_use_case.dart) | ✅ Done |
| Use cases: `SearchLibraryUseCase` | [search_library_use_case.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/use_cases/library/search_library_use_case.dart) | ✅ Done |
| Use case: `DeleteLibraryBookUseCase` | [delete_library_book_use_case.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/use_cases/library/delete_library_book_use_case.dart) | ✅ Done — removes the document/cover files and coordinates keep/delete study-data behavior |
| `FilePickerDocumentImportService` | [file_picker_document_import_service.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/data_source/library/local/file_picker_document_import_service.dart) | ✅ Fingerprinting, signature validation, safe copy and optional metadata/cover extraction are wired |
| Signature validation and private storage | [document_signature_validator.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/service/document_signature_validator.dart), [app_file_storage_service.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/data_source/library/local/app_file_storage_service.dart) | ✅ Extension/content validation and app-private document copy are wired into the picker |
| `DisabledRecapRepository` | [disabled_recap_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/repository_impl/recap/disabled_recap_repository.dart) | ✅ Done |
| `MockRecapRepository` | [mock_recap_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/repository_impl/recap/mock_recap_repository.dart) | ✅ Done |
| Reader repositories | `lib/data/repository_impl/reader/` | ✅ Drift-backed highlights, bookmarks and reading sessions |
| Vocabulary/review repositories | `lib/data/repository_impl/vocabulary/`, `lib/data/repository_impl/review/` | ✅ Drift-backed vocabulary storage and deterministic review scheduling |
| Settings repository | [drift_settings_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/repository_impl/settings/drift_settings_repository.dart) | ✅ Key/value persistence with defaults |
| Backup repository | [local_backup_repository.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/repository_impl/backup/local_backup_repository.dart) | ✅ Metadata JSON backup/restore with duplicate skipping; book binaries not yet included |
| Review/settings tests | `test/data/repository_impl/review/`, `test/data/repository_impl/settings/` | ✅ Scheduling and persistence behavior covered |

### ✅ Phase 2 — Library & Importing (Early)
| Item | File(s) | Status |
|---|---|---|
| `LibraryCubit` | [library_cubit.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/home/cubits/library_cubit.dart) | ✅ Done — load, search, importDocument with error handling |
| Library grid/list UI | [library_content.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/home/components/library_content.dart) | ✅ Search bar, grid/list toggle, sorting, delete menu/dialog, book cards, empty/error states, format badges, progress summaries and localized import-error feedback exist |
| Reader navigation entry | [library_content.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/home/components/library_content.dart), [app_router.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/presentation/route/app_router.dart) | ✅ Book cards open the reader route |

### 🟡 Phase 3 — Reader Core (Early)

| Item | File(s) | Status |
|---|---|---|
| Reflowable text engine | [plain_text_document_engine.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/document_engine/text/plain_text_document_engine.dart) | ✅ Opens TXT/Markdown/HTML/FB2, paginates, extracts headings, searches and resolves selections |
| EPUB adapter | [epub_document_engine.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/document_engine/epub/epub_document_engine.dart), [readium_document_session.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/reader/readium/readium_document_session.dart) | ✅ Native `flutter_readium` backend on Android/iOS with the local EPUB adapter retained as desktop/fallback |
| PDF adapter | [pdf_document_engine.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/document_engine/pdf/pdf_document_engine.dart), [readium_document_session.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/reader/readium/readium_document_session.dart) | ✅ Native Readium PDF backend builds on Android/iOS; pdfrx/PDFium remains the desktop/fallback adapter and still needs target-device interaction coverage |
| Engine factory | [document_engine_factory.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/domain/service/document_engine_factory.dart), [local_document_engine_factory.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/data/document_engine/local_document_engine_factory.dart) | ✅ DI-backed format selection for EPUB, PDF, TXT, Markdown, HTML and FB2 |
| Reader screen | [reader_screen.dart](file:///Users/uswer/StudioProjects/linguaPages/lib/presentation/screen/reader/reader_screen.dart) | ✅ Uses Readium for EPUB/PDF on Android/iOS, restores/saves locators, supports native and fallback TOC/search jumps, paginated/continuous modes, debounced progress flushes, persisted appearance/alignment/PDF-fit/text-mode settings, wake-lock, bookmarks, highlights, unified annotation management with editable notes, lazy fallback-PDF thumbnails, explicit fallback-PDF zoom controls, tap-zone navigation and custom page controls for fixed fallback formats |
| Text engine tests | [plain_text_document_engine_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/data/document_engine/text/plain_text_document_engine_test.dart) | ✅ Passing |
| EPUB adapter tests | [epub_document_engine_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/data/document_engine/epub/epub_document_engine_test.dart) | ✅ Passing with a generated EPUB fixture |
| PDF adapter tests | [pdf_document_engine_test.dart](file:///Users/uswer/StudioProjects/linguaPages/test/data/document_engine/pdf/pdf_document_engine_test.dart) | ⚠️ Fixture and assertions are present, but runtime tests are skipped under Flutter VM because bundled PDFium assets are unavailable there |

---

## What's Missing — Task List

### 🔴 Baseline Tasks (Pre-Phase 1)

- [x] **Rename the Dart package to `lingua_pages`** — imports and `pubspec.yaml` are updated. Android still uses the generic `com.hadi.me` application ID and Flutter Template labels, so the platform rename is incomplete.
- [x] **Remove the obsolete template screens** — auth, architecture, widget-screen and template home components were removed; the remaining dashboard shell still needs LinguaPages-specific navigation.
- [x] **Remove the obsolete template auth/user data sources** — deleted from `lib/data/`; unused Dio/Retrofit dependencies remain in `pubspec.yaml`.
- [x] **Reduce the router to the current shell** — routes now include Splash, Dashboard, Home, Vocabulary, Review, Settings and the Reader route. Onboarding is not present yet.
- [ ] **Replace the template README** with LinguaPages setup, flavors, architecture and environment documentation; the current README still describes the old user/auth template.
- [ ] **Restore or intentionally replace deleted template tests** — three new focused test files exist, but the old suite was deleted and the current suite does not fully compile.
- [ ] **Confirm Android minimum API level and finalize the application ID**
- [ ] **Choose dictionary dataset and verify redistribution rights**
- [ ] **Define English–Spanish direction** (EN-native/ES-target, ES-native/EN-target, or both)
- [ ] **Repair and update CI checks** — `.github/workflows/main.yaml` exists, but is still named `flutter_template` and currently cannot pass the repository's compile/test state.

### 🟡 Phase 0 — Technical Validation (Remaining)

- [x] **EPUB spike** — `flutter_readium` opens native EPUB content, renders and exposes text-selection/locator APIs on Android/iOS; broader corpus coverage remains
- [x] **PDF spike** — `flutter_readium` native PDF support compiles on Android/iOS; run representative documents on physical targets to complete runtime validation
- [x] **Android file picker "Open with" spike** — validated `ACTION_VIEW` with a representative EPUB on CPH2819
- [ ] **Create 20–30 document test corpus** — valid, malformed, large, DRM-protected samples
- [x] **Add `premiumEnabled` and `mockTranslationEnabled` to feature flags** — all planned switches now exist; production AI Recap remains disabled by default
- [ ] **Evaluate dictionary licensing** — the only remaining external decision per plan

### 🟡 Phase 1 — Foundation (Remaining)

#### Domain entities
- [x] **`Highlight` entity** — highlight color, text, locator, note, timestamps
- [x] **`Bookmark` entity** — title, locator, timestamp
- [x] **`VocabItem` entity** — word, lemma, sentence, book reference, locator, language, timestamp
- [x] **`ReviewCard` entity** — linked to VocabItem, SM-2 scheduling fields
- [x] **`ReadingSession` entity** — bookId, start/end timestamps, progress
- [x] **`LanguagePack` entity** — local language-pack state contract
- [x] **`Settings` entity** — reader preferences and study configuration
- [x] **`PremiumEntitlement` entity** — subscription state, expiry and source

#### Missing Use Cases
- [x] **`SaveReadingProgressUseCase`** — persists through the library repository
- [x] **`LookupWordUseCase`** — uses the injectable local fixture dictionary
- [x] **`SaveVocabularyUseCase`** — persists through the Drift vocabulary repository
- [x] **`ReviewCardUseCase`** — uses the Drift review repository and deterministic scheduling
- [x] **`CreateBackupUseCase`** — creates a metadata JSON backup
- [x] **`RestoreBackupUseCase`** — restores metadata and study data with duplicate skipping

#### Missing Database Tables
- [x] **Generate and verify Drift tables for Highlights, Bookmarks, VocabItems, ReviewCards, ReadingSessions and Settings** — schema v5 also adds imported library TOC JSON alongside the schema v4 soft-delete flag
- [x] **Make the schema v2 migration compile**
- [ ] **Add explicit upgrade-path migration tests**

#### Missing Repositories
- [x] **Implement `HighlightRepository`** — Drift-backed
- [x] **Implement `BookmarkRepository`** — Drift-backed
- [x] **Implement `VocabularyRepository`** — Drift-backed
- [x] **Implement `ReviewRepository`** — Drift-backed with deterministic SM-2-style scheduling
- [x] **Implement `ReadingSessionRepository`** — Drift-backed
- [x] **Implement `SettingsRepository`** — Drift-backed key/value storage
- [x] **Implement `BackupRepository`** — local metadata JSON backup/restore; binary book-file backup remains pending

### 🔴 Phase 2 — Library & Importing (Remaining)

- [x] **File signature + extension validation** (PDF/EPUB signatures and text validation)
- [x] **Android `ACTION_VIEW` / "Open with" support** — manifest MIME filters, native URI copy and Dart import integration are implemented
- [x] **Safe copy into app-private storage** (stored under the application support directory)
- [x] **Metadata extraction** — EPUB title/author/language/TOC plus PDF Info/XMP title/author/language are extracted during import; Markdown/HTML/FB2 headings are used as TOC fallback metadata and malformed optional metadata falls back safely
- [x] **Cover image extraction and storage** — EPUB 2/3 cover images are extracted and copied to app-private cover storage; PDF cover rendering remains pending
- [x] **Library list view** — toggle between compact list and grid presentations from the library toolbar
- [x] **Sort controls** — recent, title, author, and progress sorting are exposed from the library toolbar and preserved through search/refresh
- [x] **Format badges** on book cards — EPUB, PDF, TXT, MD, HTML and FB2 badges are shown
- [x] **Progress indicators** — progress bars now include percentage plus localized not-started/in-progress/finished status; chapter-specific labels remain pending chapter metadata persistence
- [x] **Delete book flow** — confirmation dialog supports keeping linked study data or deleting annotations, bookmarks, vocabulary and review cards; files are removed from app-private storage
- [x] **Corrupt-file and unsupported-format error UX** — typed import failures distinguish unsupported formats, unavailable files, empty/invalid signatures and corrupt EPUB/PDF/FB2 content; the library presents localized messages
- [x] **Table of contents extraction during import** — EPUB 3 navigation, EPUB 2 NCX and chapter-heading fallbacks are stored as JSON with Markdown/HTML/FB2 heading extraction

### 🔴 Phase 3 — Reader Core (Remaining)

- [ ] **Split and harden format-specific text adapters** — current implementation is a shared reflowable adapter and needs corpus coverage
- [x] **EPUB adapter** implementing `DocumentEngine` — early implementation; corpus hardening and richer locators remain
- [x] **PDF adapter** implementing `DocumentEngine` — initial fixed-layout adapter with rendering, text extraction, outline TOC, search and selection locators; target-device validation remains
- [x] **Reader screen** with document rendering — first route supports reflowable text and fixed PDF pages
- [x] **Paginated and continuous scroll modes** — reflowable fallback documents support both modes with scroll progress; Readium EPUB/PDF receives the matching native preference, while fixed fallback PDFs remain paginated
- [x] **TOC/outline panel** — lists entries and jumps through Readium locators for native EPUB/PDF plus locator-backed page/offset jumps for fallback EPUB, text formats and PDF outlines
- [x] **PDF fit-to-width and fit-to-page controls** — persisted and applied to fallback PDF rendering and native Readium PDF preferences
- [x] **PDF thumbnails** — lazy fallback-PDF previews with current-page highlighting and direct page selection
- [x] **PDF zoom controls** — explicit zoom in, zoom out and reset actions alongside pinch-to-zoom for fallback PDF pages
- [x] **PDF text mode** — fallback PDFs can switch between rendered page images and selectable extracted text; the choice is persisted
- [x] **Font, size, line spacing and margin controls** — persisted reader settings apply to fallback pages and native Readium preferences
- [x] **Text alignment control** — left, centered and justified layouts apply to fallback pages and native Readium EPUB preferences
- [x] **Light / Sepia / Dark reading themes** — persisted and applied to fallback pages and native Readium EPUB preferences
- [x] **Reading progress display** (page count and progress bar)
- [x] **Debounced progress persistence** — page and Readium locator events coalesce for 650 ms and flush on lifecycle backgrounding or reader disposal
- [x] **In-document search** — localized search sheet uses Readium text search on Android/iOS and `DocumentEngine.search` for fallback formats, with chapter/context results and page/locator jumps
- [x] **Screen wake-lock** — `wakelock_plus` follows the persisted reader preference and is released on reader disposal
- [x] **Tap-zone controls** — accessible left/right zones turn pages in fallback paginated mode
- [ ] **Format-specific settings** — PDF fit/text settings are implemented; broader per-format options remain

### 🟡 Phase 4 — Annotations & Translation (Early)

- [x] **Highlight creation** (4 colors) — native Readium selection actions and fallback selectable text are wired to Drift
- [x] **Notes attached to highlights** — notes and colors can be edited from the annotation panel
- [x] **Bookmark creation** — reader toolbar action persists a format-neutral locator
- [x] **Bookmark list with jump-to-location** — reader bottom sheet supports navigation and deletion
- [x] **Annotation list with jump-to-location** — unified bookmark/highlight list is available from the reader
- [x] **Edit and delete annotations** — highlight notes/colors can be edited and both annotation types can be deleted
- [x] **Format-neutral locators for all formats** — fallback locators plus optional native Readium payloads are persisted
- [x] **Markdown export contract** — reader annotation panel copies portable Markdown
- [x] **English–Spanish language-pack manager UI** — Settings exposes persisted local install/delete state for the bundled fixture
- [x] **Dictionary lookup UI** (lemma, translation, POS, example)
- [ ] **Lemmatization interface**
- [ ] **On-device sentence/paragraph translation**
- [ ] **Language pack download/checksum/delete**
- [x] **Lookup bottom sheet** (Save, Highlight, Copy actions)
- [x] **Response caching for lookups** — normalized in-memory cache supports hits, misses and failure retry

### 🟡 Phase 5 — Vocabulary & Review (Early)

- [x] **Save word with full context** (sentence, book, locator, lemma, timestamp) — lookup sheet persists the selected context
- [x] **Vocabulary list screen**
- [x] **Search and filters** (by book, language, status)
- [x] **Automatic flashcard generation**
- [x] **Hidden-word context sentence cards** — Review masks the saved word until the answer is revealed
- [x] **Review actions** (Again, Hard, Good, Easy)
- [x] **SM-2 scheduling algorithm** with deterministic repository tests; broader boundary coverage remains
- [x] **Daily new-card limit** (default 15) — configurable in Settings and enforced by the Review screen
- [x] **Free limit of 500 saved words** — non-premium saves are blocked at the boundary with localized feedback; premium remains extensible
- [x] **Due count on home screen** — Library app bar badge opens the Review tab
- [ ] **Local review notification**
- [x] **Review streak and statistics** — basic due/reviewed/active-day/current-streak metrics derive from persisted card timestamps; full review history remains pending

### 🔴 Phase 6 — Onboarding, Premium & Backup (Not Started)

- [ ] **Onboarding flow** — language selection, pack size explanation, download, first import, "tap a word" tutorial
- [ ] **Google Play Billing integration**
- [ ] **Local entitlement cache** with periodic online verification
- [ ] **Restore purchases**
- [ ] **Premium themes and fonts**
- [ ] **Premium limits enforcement** (exports, language packs, vocabulary)
- [x] **Backup export** (metadata, annotations, vocabulary, reviews, settings) — Settings exports the local metadata JSON snapshot
- [x] **Backup restore** with merge and duplicate prevention — Settings imports a JSON snapshot and reports restored/duplicate counts
- [ ] **Encrypted backup** (optional)
- [ ] **Privacy screen**

### 🔴 Phase 7 — Hardening & Android Launch (Not Started)

- [ ] **Domain unit tests** (entities, use cases)
- [ ] **BLoC/Cubit tests**
- [ ] **Widget tests** (library, reader controls, lookup, review)
- [ ] **Android integration tests** (import → read → lookup → save → review)
- [ ] **Compatibility testing** against document corpus
- [ ] **Performance tests** (startup, import, first page, lookup, page turn)
- [ ] **TalkBack and large-text accessibility testing**
- [ ] **Offline and interrupted-import testing**
- [ ] **Corrupt-file and malicious-archive testing**
- [ ] **Billing sandbox testing**
- [ ] **All P0 release gate checks**

---

## Progress Gauge

| Phase | Estimated Completion |
|---|---|
| Baseline tasks | 🟡 ~50% (Dart/template cleanup is underway; README, platform identity, decisions and CI repair remain) |
| Phase 0 — Technical validation | 🟡 ~70% (native EPUB/PDF builds and Android `ACTION_VIEW` are validated; corpus, broader physical-device behavior and licensing validation remain) |
| Phase 1 — Foundation | 🟡 ~75% (entities, schema v5, locator persistence, local repositories and use cases exist; explicit migration coverage and production integrations remain) |
| Phase 2 — Library & importing | 🟡 ~85% (picker and Android intent import, private storage, metadata/EPUB covers/TOC, grid/list UI, sorting, badges, progress summaries, deletion and localized import-error handling exist; PDF covers and richer library controls remain) |
| Phase 3 — Reader core | 🟡 ~90% (native Readium EPUB/PDF reader, fallback adapters, native and fallback TOC/search jumps, paginated/continuous modes, debounced locator persistence, appearance/alignment controls, PDF fit/text modes, wake-lock, tap zones, fallback thumbnails and explicit zoom controls exist; adapter hardening and target-device validation remain) |
| Phase 4 — Annotations & translation | 🟡 ~55% (bookmarks, four-color highlights, unified annotation management, editable notes, Markdown export, cached lookup UI and a local English→Spanish pack manager are connected; real pack downloads, lemmatization and sentence translation remain) |
| Phase 5 — Vocabulary & review | 🟡 ~63% (lookup can save vocabulary with context, Vocabulary and Review tabs support search/filtering plus a Library due-count shortcut, automatic cards, hidden-word prompts, configurable daily limits, free-limit enforcement, basic statistics/streaks and review actions use local deterministic scheduling; notifications and full review history remain) |
| Phase 6 — Onboarding, premium, backup | 🔴 ~20% (metadata backup/export/restore is available from Settings; onboarding, billing, entitlement, binary-file backup and encryption remain) |
| Phase 7 — Hardening & launch | 🔴 ~5% (analysis clean and the automated suite covers metadata/TOC import persistence, typed import failures, locator serialization and delete cleanup with 2 environment-skipped PDF tests; integration, compatibility and performance coverage remain) |

> **Overall: ~64% of v1.0 scope is implemented.** The strongest areas are the architecture foundation, local persistence, validated library import flow and the end-to-end library-to-reader-to-vocabulary/review path. The largest product gaps are PDF cover rendering, chapter-aware progress, adapter/target-device validation, real language-pack downloads/checksums, sentence translation, review notifications/full history, onboarding, billing, binary/encrypted backups and release hardening across Phases 4–7.

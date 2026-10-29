# LinguaPage implementation plan

Target: Android-first v1.0, offline-first and private ebook reader for every common DRM-free format (EPUB, PDF, TXT, Markdown, HTML, FB2), Flutter Clean Architecture with BLoC. No account, no cloud, no AI. Product context is in [PRODUCT.md](PRODUCT.md).

> **Requirements change (2026-10-29):** the product is no longer a language-learning app. Removed from scope: the English–Spanish language pair, language packs, sentence translation, lemmatization, vocabulary, flashcards and SM-2 review, review reminders and statistics, AI Recap, and cloud sync/authentication. Kept: the reader, annotations, a single-language dictionary (definitions only), premium, and local backup. Phase 5 is now the removal of the code already built for the dropped features.

The SRS mentions Riverpod and `go_router`, but the existing template uses BLoC and `auto_route`. We should retain the existing template conventions rather than introduce a second architecture.

Current template foundations are already available in [CLAUDE.md](/Users/uswer/StudioProjects/linguaPages/CLAUDE.md), [pubspec.yaml](/Users/uswer/StudioProjects/linguaPages/pubspec.yaml), the DI setup, flavors, localization, and mock/remote data-source factories.

## Architecture rules

Use the existing layers:

```text
lib/
├── core/
│   ├── database/
│   ├── document/
│   ├── feature_flags/
│   ├── storage/
│   ├── services/
│   └── injector/
├── domain/
│   ├── entity/
│   ├── repository/
│   ├── service/
│   └── use_cases/
├── data/
│   ├── database/
│   ├── document_engine/
│   │   ├── epub/
│   │   ├── pdf/
│   │   ├── text/
│   │   ├── markdown/
│   │   ├── html/
│   │   └── fb2/
│   ├── data_source/
│   ├── models/
│   ├── remapper/
│   └── repository_impl/
└── presentation/
    ├── screen/
    │   ├── onboarding/
    │   ├── library/
    │   ├── reader/
    │   ├── premium/
    │   └── settings/
    ├── route/
    └── widgets/
```

Important rules:

- SQLite/Drift is the local source of truth.
- The app works fully offline. There is no account or cloud dependency.
- `DocumentEngine` must be a domain-level abstraction.
- Each format must have its own adapter.
- BLoCs/Cubits coordinate use cases; they must not access databases or plugins directly.
- Platform-specific code should be isolated behind interfaces for file import, billing, brightness, and screen wake-lock.
- Existing `DataSourceFactory` should be extended only for service selection. Local database and document engines should not be forced through the remote/mock API pattern unnecessarily.

## Phase plan

| Phase | Duration | Main deliverables |
|---|---:|---|
| 0. Technical validation | 1–2 weeks | EPUB/PDF spike, document abstraction, Android import spike, dictionary/licensing evaluation |
| 1. Application foundation | 2 weeks | Database, storage, entities, migrations, feature flags, DI, navigation foundation |
| 2. Library and importing | 2–3 weeks | File picker, Android “Open with”, hashing, metadata, covers, library UI |
| 3. Reader core | 4–5 weeks | EPUB, PDF, TXT, Markdown, HTML, FB2, pagination, scrolling, progress, TOC, search |
| 4. Annotations and dictionary | 2–3 weeks | Highlights, notes, bookmarks, export, word-definition lookup sheet |
| 5. Language-learning removal | 1 week | Remove translation, language packs, vocabulary, review, reminders and AI Recap code, data and copy |
| 6. Premium, onboarding and backup | 2–3 weeks | Reader onboarding, billing, premium themes/fonts, local backup/restore, privacy |
| 7. Hardening and Android launch | 3 weeks | Compatibility corpus, performance, accessibility, beta, store release |
| 8. v1.1 | Post-launch | Exports, widgets, OCR, converters, comics |

Estimated v1.0 duration: approximately 18–20 weeks for one experienced developer.

## Phase 0 — Technical validation

Before building the complete UI, validate the riskiest technical areas:

- Open an EPUB and text-based PDF through one `DocumentEngine`.
- Extract selectable words, sentences and format-neutral locators.
- Verify Android file picker and “Open with” behavior.
- Confirm the chosen PDF and EPUB libraries support text selection.
- Choose the dictionary lookup language.
- Evaluate dictionary data sources and licenses.
- Create a 20–30 document test corpus containing valid, malformed, large and DRM-protected samples.
- Add CI checks for formatting, analysis, tests and generated files.

The dictionary language and source are the remaining external decisions. Until selected, use a local fixture dictionary behind:

```dart
abstract interface class DictionaryRepository {
  Future<DictionaryEntry?> lookup(String word);
}
```

## Phase 1 — Foundation

Implement the application core before feature screens:

Entities:

- `Book`
- `Highlight`
- `Bookmark`
- `ReadingSession`
- `Settings`
- `PremiumEntitlement`

Use cases should remain small and single-purpose, for example:

- `ImportDocumentUseCase`
- `GetLibraryUseCase`
- `SaveReadingProgressUseCase`
- `LookupWordUseCase`
- `CreateBackupUseCase`
- `RestoreBackupUseCase`

Add Drift tables and migrations for the entities above. Store document files and dictionary data in app-private storage or assets, not inside the database.

Add feature flags:

- `premiumEnabled`
- `mockServicesEnabled`

## Phase 2 — Library and importing

Implement:

- File picker for EPUB, PDF, TXT, Markdown, HTML and FB2.
- Android `ACTION_VIEW`/“Open with” support.
- File signature plus extension validation.
- Content hashing and duplicate detection.
- Metadata extraction: title, author, language, cover and table of contents.
- Safe copying into app storage.
- Library grid/list views.
- Search by title and author.
- Sorting by recent, title, author and progress.
- Format badges and progress indicators.
- Delete flow with “keep or delete annotations”.
- Corrupt-file and unsupported-format errors.

Exit criteria: a user can import supported documents, close the app, reopen it, and see the same library.

## Phase 3 — Reader core

Build the reader around one interface:

```dart
abstract interface class DocumentEngine {
  Future<DocumentInfo> open(File file);
  Future<void> close();
  Future<TableOfContents> getTableOfContents();
  Future<DocumentPage> getPage(int index);
  Future<List<TextSearchResult>> search(String query);
  Future<SelectedText> resolveSelection(TextSelectionRange range);
  Future<DocumentLocator> resolveLocator(DocumentPosition position);
}
```

Implement adapters in this order:

1. EPUB
2. TXT
3. Markdown
4. HTML/XHTML
5. FB2
6. Text-based PDF

Reader features:

- Paginated and continuous modes.
- EPUB chapters and TOC navigation.
- PDF zoom, fit-to-width, fit-to-page, thumbnails and outline.
- PDF Text mode.
- Font, size, line spacing, margins and alignment.
- Light, Sepia and Dark themes.
- Reading progress and chapter information.
- Debounced progress persistence, maximum two seconds.
- In-document search.
- Screen wake-lock and tap-zone controls.
- Format-specific settings only.

Every format must be equally well supported; no format should feel second-class.

Exit criteria: first-page load and page-turn performance meet the SRS targets on a mid-range Android device.

## Phase 4 — Annotations and dictionary

Annotations:

- Four highlight colors.
- Notes attached to highlights.
- Bookmarks.
- Annotation list with jump-to-location.
- Edit and delete.
- Format-neutral locators for every supported format.
- Markdown export contract.

Dictionary:

- Single-language word-definition lookup (lookup language is an open decision).
- Definition, part of speech and example where the dataset provides them.
- Lookup bottom sheet with Highlight and Copy actions.
- Response caching for fast repeated lookups.
- Fully offline after install.

The dictionary implementation should be replaceable without changing presentation or domain code.

## Phase 5 — Language-learning removal

The language-learning features were partly built before the requirements change. Remove them completely so no dead code, data or copy ships:

- Delete vocabulary and review screens, Cubits, use cases, repositories, entities and tests, and the Vocabulary/Review dashboard tabs.
- Delete the Library due-count shortcut, study settings (daily new-card limit) and the review reminder scheduler, including the `flutter_local_notifications`/`flutter_timezone`/`timezone` dependencies if nothing else uses them.
- Delete the language-pack manager, lemmatizer, sentence translation service and the English→Spanish dictionary fixture; replace the lookup with the single-language definition contract from Phase 4.
- Delete the recap entity, repositories and `aiRecapEnabled`/`mockTranslationEnabled` flags.
- Add a Drift migration that drops vocabulary, review-card and review-history tables, with an upgrade test proving books, highlights, bookmarks and settings survive.
- Remove vocabulary/review data from backup export; restoring an older backup must ignore those sections without failing.
- Remove learning copy from onboarding, privacy and the delete-book dialog (“keep study data” becomes “keep annotations”), and delete unused ARB keys.
- Remove the vocabulary free-limit premium gate.

Exit criteria: `flutter analyze` and `flutter test` pass, an existing v6 database upgrades without losing annotations, and no screen or string mentions vocabulary, review, translation or Spanish study.

## Phase 6 — Onboarding, premium and backup

Onboarding:

- Explain offline, private storage.
- Import first document.
- Show the “select text to highlight or define” tutorial.

Premium (exact entitlements are an open decision):

- Google Play Billing for Android.
- Local entitlement cache with periodic online verification.
- Restore purchases.
- Candidate entitlements: premium themes and fonts, export limits.
- No premium lockout when offline.

Backup:

- Export library metadata, annotations and settings.
- Optional inclusion of book files.
- Restore with merge and duplicate prevention.
- Optional encrypted backup support.
- Privacy screen explaining that all data stays on the device.

The SRS also lists French, German and Japanese UI localization; those should be added if that launch requirement remains active. Whether the existing Spanish UI localization stays is an open decision (it is UI language, not study content).

## Phase 7 — Quality, beta and Android release

Testing layers:

- Domain unit tests.
- Database and repository tests.
- Document-engine adapter tests.
- BLoC/Cubit tests.
- Widget tests for library, reader controls, annotations and lookup.
- Android integration tests for import → read → highlight/define → export.
- Compatibility testing against the document corpus.
- Performance tests for startup, import, first page, lookup and page turning.
- TalkBack and large-text testing.
- Offline and interrupted-import testing.
- Corrupt-file and malicious-archive testing.
- Billing sandbox testing.

Release gates:

- All P0 requirements pass.
- No known data-loss or crash defects.
- At least 95% of the v1.0 document corpus renders without critical failure.
- Crash-free beta target of at least 99%.
- No API key or cloud credential is included in the app.
- Privacy policy and Google Play Data Safety information match actual behavior.

## v1.1 plan

After v1.0 stabilization:

1. CSV export of annotations.
2. Widgets.
3. DOCX/MOBI/AZW3 conversion.
4. OCR for scanned PDFs and images.
5. CBZ comic reader.
6. Web article import.

### Out of scope

These were in the earlier plan and conflict with the offline, no-account, private positioning. Revisit only if that positioning changes:

- Clerk authentication, Appwrite sync, offline queue and conflict resolution.
- Account deletion and cloud-data cleanup.
- AI Recap and AI quotas.
- Anki export and anything else built on vocabulary or review.

## Important baseline tasks

Before Phase 1 begins:

- Restore or intentionally replace the currently deleted template tests.
- Rename the generic package/app identifiers from `flutter_template`.
- Add a real project README and environment documentation.
- Add database, file-storage and document-engine dependency decisions.
- Confirm Android minimum API and billing product IDs.
- Choose the dictionary lookup language, choose the dataset and verify redistribution rights.

This plan keeps the application offline-first, preserves the existing BLoC-based clean architecture, and leaves the unresolved dictionary choice isolated behind a stable domain interface.

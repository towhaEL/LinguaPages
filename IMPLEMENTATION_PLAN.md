# LinguaPage implementation plan

Target: Android-first v1.0, English–Spanish learning pair, offline-first, Flutter Clean Architecture with BLoC, and AI Recap disabled in release builds.

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
    │   ├── vocabulary/
    │   ├── review/
    │   ├── premium/
    │   └── settings/
    ├── route/
    └── widgets/
```

Important rules:

- SQLite/Drift is the local source of truth.
- Cloud synchronization is a future replica, not a dependency of v1.0.
- `DocumentEngine` must be a domain-level abstraction.
- Each format must have its own adapter.
- BLoCs/Cubits coordinate use cases; they must not access databases or plugins directly.
- Platform-specific code should be isolated behind interfaces for file import, billing, notifications, brightness, and screen wake-lock.
- Existing `DataSourceFactory` should be extended only for service selection. Local database and document engines should not be forced through the remote/mock API pattern unnecessarily.

## Phase plan

| Phase | Duration | Main deliverables |
|---|---:|---|
| 0. Technical validation | 1–2 weeks | EPUB/PDF spike, document abstraction, Android import spike, dictionary/licensing evaluation |
| 1. Application foundation | 2 weeks | Database, storage, entities, migrations, feature flags, DI, navigation foundation |
| 2. Library and importing | 2–3 weeks | File picker, Android “Open with”, hashing, metadata, covers, library UI |
| 3. Reader core | 4–5 weeks | EPUB, PDF, TXT, Markdown, HTML, FB2, pagination, scrolling, progress, TOC, search |
| 4. Annotations and translation | 3–4 weeks | Highlights, notes, bookmarks, word lookup, sentence translation, lookup sheet |
| 5. Vocabulary and review | 3 weeks | Saved words, flashcards, SM-2 scheduling, due counts, reminders |
| 6. Premium, onboarding and backup | 2–3 weeks | Language setup, billing, limits, local backup/restore, privacy, premium themes |
| 7. Hardening and Android launch | 3 weeks | Compatibility corpus, performance, accessibility, beta, store release |
| 8. v1.1 cloud and AI | Post-launch | Clerk, Appwrite sync, AI Recap, exports, widgets, OCR, converters, comics |

Estimated v1.0 duration: approximately 20–22 weeks for one experienced developer.

## Phase 0 — Technical validation

Before building the complete UI, validate the riskiest technical areas:

- Open an EPUB and text-based PDF through one `DocumentEngine`.
- Extract selectable words, sentences and format-neutral locators.
- Verify Android file picker and “Open with” behavior.
- Confirm the chosen PDF and EPUB libraries support text selection.
- Define the English–Spanish language-pack contract.
- Evaluate dictionary data sources and licenses.
- Create a 20–30 document test corpus containing valid, malformed, large and DRM-protected samples.
- Add CI checks for formatting, analysis, tests and generated files.

The dictionary source is the only remaining external decision. Until selected, use a local fixture dictionary behind:

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
- `VocabItem`
- `ReviewCard`
- `ReadingSession`
- `LanguagePack`
- `Settings`
- `RecapCache`
- `PremiumEntitlement`

Use cases should remain small and single-purpose, for example:

- `ImportDocumentUseCase`
- `GetLibraryUseCase`
- `SaveReadingProgressUseCase`
- `LookupWordUseCase`
- `SaveVocabularyUseCase`
- `ReviewCardUseCase`
- `CreateBackupUseCase`
- `RestoreBackupUseCase`

Add Drift tables and migrations for the entities above. Store document files and language packs in app-private storage, not inside the database.

Add feature flags:

- `aiRecapEnabled`
- `premiumEnabled`
- `cloudSyncEnabled`
- `mockTranslationEnabled`

Development can expose mock AI Recap for UI testing. Production must compile with AI Recap disabled and hide all related entry points.

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
- Delete flow with “keep or delete annotations/vocabulary”.
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

Exit criteria: first-page load and page-turn performance meet the SRS targets on a mid-range Android device.

## Phase 4 — Annotations and translation

Annotations:

- Four highlight colors.
- Notes attached to highlights.
- Bookmarks.
- Annotation list with jump-to-location.
- Edit and delete.
- Format-neutral locators for every supported format.
- Markdown export contract, with premium enforcement later.

Translation:

- English–Spanish language-pack manager.
- Dictionary lookup with lemma, translation, part of speech and example.
- Lemmatization interface.
- On-device sentence/paragraph translation.
- Download, checksum validation and deletion of language packs.
- Offline behavior after installation.
- Lookup bottom sheet with Save, Highlight and Copy actions.
- Response caching for fast repeated lookups.

The dictionary and translation implementations should be replaceable without changing presentation or domain code.

## Phase 5 — Vocabulary and review

Implement:

- Save word with sentence, book, locator, lemma and timestamp.
- Vocabulary list.
- Search and filters by book, language and status.
- Automatic card generation.
- Hidden-word context sentence.
- Again, Hard, Good and Easy actions.
- Deterministic SM-2-style scheduling.
- Daily new-card limit, default 15.
- Free limit of 500 saved words.
- Due count on the home screen.
- Optional local review notification.
- Review streak and basic statistics.

The SM-2 algorithm should be covered with extensive unit tests, including first review, failed review, repeated reviews and date boundaries.

## Phase 6 — Onboarding, premium and backup

Onboarding:

- Select native and target language.
- Explain language-pack size.
- Download English–Spanish assets.
- Import first document.
- Show the “tap a word” tutorial.

Premium:

- Google Play Billing for Android.
- Local entitlement cache with periodic online verification.
- Restore purchases.
- Premium themes and fonts.
- Premium limits for exports, language packs and vocabulary.
- No premium lockout when offline.

Backup:

- Export library metadata, annotations, vocabulary, reviews and settings.
- Optional inclusion of book files.
- Restore with merge and duplicate prevention.
- Optional encrypted backup support.
- Privacy screen explaining local and future cloud data behavior.

The existing English and Spanish localization files can be extended here. The SRS also lists French, German and Japanese UI localization; those should be added if that launch requirement remains active.

## Phase 7 — Quality, beta and Android release

Testing layers:

- Domain unit tests.
- Database and repository tests.
- Document-engine adapter tests.
- BLoC/Cubit tests.
- Widget tests for library, reader controls, lookup and review.
- Android integration tests for import → read → lookup → save → review.
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
- Android release build has `aiRecapEnabled == false`.
- No AI API key or cloud credential is included in the app.
- Privacy policy and Google Play Data Safety information match actual behavior.

## v1.1 plan

After v1.0 stabilization:

1. Clerk authentication behind `AuthService`.
2. Clerk-to-Appwrite token exchange.
3. Appwrite database sync with offline queue.
4. Last-write-wins conflict resolution.
5. Account deletion and cloud-data cleanup.
6. Real AI Recap through an Appwrite Function.
7. AI quota and cached recaps.
8. CSV/Anki export.
9. Widgets.
10. DOCX/MOBI/AZW3 conversion.
11. OCR for scanned PDFs and images.
12. CBZ comic reader.
13. Web article import.

The current mock AI implementation should be reused for presentation and domain testing, then replaced by a remote implementation without changing the reader or vocabulary layers.

## Important baseline tasks

Before Phase 1 begins:

- Restore or intentionally replace the currently deleted template tests.
- Rename the generic package/app identifiers from `flutter_template`.
- Add a real project README and environment documentation.
- Add database, file-storage and document-engine dependency decisions.
- Confirm Android minimum API and billing product IDs.
- Choose the dictionary dataset and verify redistribution rights.
- Define the exact English–Spanish direction: English-native/Spanish-target, Spanish-native/English-target, or both.

This plan keeps the application offline-first, preserves the existing BLoC-based clean architecture, and leaves the unresolved dictionary choice isolated behind a stable domain interface.
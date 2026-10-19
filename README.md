# LinguaPages

LinguaPages is an offline-first Flutter reading and language-learning app for
English → Spanish study. It imports DRM-free EPUB, PDF, TXT, Markdown, HTML
and FB2 documents, stores the library and study data locally, and lets readers
look up words, save vocabulary and review it with spaced repetition.

## Current scope

The implemented local flow is:

`import → library → read → search/select → dictionary lookup → save vocabulary → review`

The reader uses `flutter_readium` for native EPUB/PDF reading on Android and
iOS. TXT, Markdown, HTML and FB2 use the local document engine; EPUB and PDF
also retain fallback adapters for desktop and unsupported native contexts.

The current dictionary is a small original fixture used for development and
testing. It is intentionally limited to English → Spanish and contains no
third-party dictionary data. A production dictionary dataset must be selected
and license-reviewed before shipping additional vocabulary data.

## Requirements

- Flutter 3.44.8 or newer (the checked-in lockfile is verified with Flutter
  3.47.7).
- Dart supplied by the selected Flutter SDK.
- JDK 17 for the Android build. The Readium integration targets Android API 24
  and newer.
- Xcode with iOS deployment target 15.0 for iOS builds.

## Run locally

```text
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor development -t lib/main_development.dart
```

The app has development, staging and production entry points:

```text
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

The development flavor enables local mock services and disables premium
gating. Production keeps AI Recap disabled and does not include cloud or AI
credentials. The available build-time flag is:

```text
--dart-define=LINGUAPAGE_AI_RECAP=true
```

AI Recap remains disabled in production regardless of that flag.

## Architecture

The project keeps the existing BLoC + auto_route template conventions while
following clean-architecture boundaries:

```text
lib/
├── core/       database-adjacent services, storage, flags and DI contracts
├── domain/     entities, repository interfaces, services and use cases
├── data/       Drift database, importers, document engines and repositories
└── presentation/
    ├── screen/ reader, library, vocabulary, review and settings screens
    ├── route/  auto_route definitions and generated routes
    └── widgets shared UI components
```

SQLite/Drift is the local source of truth. BLoCs and widgets call domain use
cases or repository interfaces; they do not access plugins or database tables
directly. Book files and extracted covers are kept in app-private storage,
while metadata, progress, annotations, vocabulary, reviews and settings live
in Drift.

## Supported reader behavior

- Native Readium pagination, selection, TOC and locator persistence for EPUB/PDF
  on Android and iOS.
- Fallback pagination and continuous scrolling for reflowable text formats.
- PDF fit-to-page, fit-to-width, text mode, thumbnails and zoom in fallback mode.
- Search, bookmarks, four-color highlights, notes and portable Markdown export.
- Persisted theme, font, spacing, margin, alignment, wake-lock and reader-mode
  preferences.
- Android `ACTION_VIEW` intake for supported document MIME types.

## Data and privacy model

The v1.0 product is local-first. Imported files, covers, annotations,
vocabulary, reviews and settings remain on the device unless the user exports
a backup. Metadata JSON backup and restore are available from Settings. Cloud
sync, authentication and AI Recap are not part of the v1.0 runtime path.

Do not put API keys, billing credentials or cloud secrets in Dart source,
assets or checked-in flavor files.

## Verification

```text
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug --flavor development -t lib/main_development.dart
```

The VM test suite includes database/repository, document-engine, import,
locator, lookup, review and presentation-state coverage. Two PDF runtime tests
are skipped in Flutter VM runs because pdfrx's native PDFium assets are not
available there; PDF rendering still needs physical-device verification.

## Project status and next work

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for the product roadmap
and [implementation_status.md](implementation_status.md) for the verified
implementation snapshot. The largest remaining areas are production dictionary
licensing and remote pack downloads, billing/entitlements, full review history,
encrypted/binary backups, PDF cover rendering, compatibility testing and
Android release hardening.

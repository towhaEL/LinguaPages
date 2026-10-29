# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

Android-first for v1.0, also built for iOS from the same Flutter codebase. The visual language is custom and platform-neutral: one brand-driven look on both platforms, built on a Material base. It does not follow Cupertino conventions on iOS.

## Users

There are two primary audiences, weighted equally:

- **Heavy readers with their own files.** They keep a personal library of DRM-free books and documents in several formats and want one private app that reads all of them.
- **Researchers and students.** They read books, PDFs and papers, annotate heavily and export their notes.

## Product Purpose

LinguaPages (the app name in code is "LinguaPage") is an offline-first ebook reader for every common DRM-free format: EPUB, PDF, TXT, Markdown, HTML and FB2. Users import their own files, read them in an e-reader they can configure, and keep highlights, notes, bookmarks and word definitions alongside the text. It succeeds when a reader can open any of their documents in one place and the reading and annotating never pull them out of the book.

It is no longer a language-learning app. Spanish, translation, vocabulary lists and spaced-repetition review are out of the product.

## Positioning

- **Offline and private.** Books and reading data stay on the device. There is no account and no cloud. The one network call is a dictionary lookup, which sends only the selected word.
- **Bring your own books.** It reads any DRM-free file in any supported format and has no store or catalog.
- **Reading comes first, with study tools inside the book.** It is a serious e-reader, and lookups and annotations happen in the book rather than in a separate tool.
- **Simple, no gamification.** There are no streaks, leaderboards or nagging.

## Operating Context

- **Getting books in:** the in-app file picker, plus Android "Open with" (`ACTION_VIEW`) for supported document types.
- **Reading:** native Readium reading for EPUB and PDF on Android and iOS. TXT, Markdown, HTML and FB2 use the local document engine, which offers both pagination and continuous scroll. PDFs support fit-to-page, fit-to-width, text mode, thumbnails and zoom.
- **Reading data:** search, bookmarks, highlights in four colors, notes and portable Markdown export.
- **Reader preferences:** theme, font, spacing, margins, alignment, keeping the screen awake and reader mode.
- **Data ownership:** a local JSON backup and restore is available from Settings.

## Capabilities and Constraints

- SQLite/Drift is the local source of truth. Book files and covers are stored in app-private storage.
- **Dictionary:** English definitions from the free Free Dictionary API (`https://api.dictionaryapi.dev/api/v2/entries/en/<word>`). The content is Wiktionary data under CC BY-SA 3.0, so every definition shows its license and source link. A lookup needs a network connection the first time; afterwards the result is cached on the device. The API has no SLA, so failures and missing words must be handled gracefully.
- **Premium** unlocks only appearance: extra reading themes, extra fonts and style presets. Reading, annotations, export, backup and the dictionary stay free.
- **App language:** English only.
- **Removed from the product:** AI Recap, the English→Spanish language pair, sentence translation, vocabulary lists, spaced-repetition review and review reminders. The codebase still contains these features, and removing them is separate work.
- Cloud sync and authentication are not part of v1.0.

## Brand Commitments

- Calm and trustworthy. Never manipulate, never nag, never gamify.
- Privacy is a promise to the user: product copy must not imply cloud storage or accounts that do not exist, and it must state plainly that dictionary lookups go online.
- Visual direction set by the owner: dark, premium, simple. UI improvement work uses the Impeccable skill.

## Evidence on Hand

- There are no testimonials, user counts, reviews or press. Do not invent any.
- No pricing has been set. Do not show premium prices or claims.

## Product Principles

1. The book stays in front. Every tool works on top of the text rather than taking the reader somewhere else.
2. The user's files and data belong to the user. Everything except a first-time dictionary lookup works offline, and their data can always be exported.
3. Support every format equally well. No format should feel second-class.
4. Calm over engagement. Measure success by reading done, not time spent in the app.
5. Annotations are durable work. Never lose them, and always let the user take them with them.

## Accessibility & Inclusion

Reader comfort settings (font, spacing, margins, alignment, themes) are core features, not extras. No specific accessibility standard has been set yet; the plan schedules an accessibility pass during the Android launch-hardening phase.

---
version: 1
slug: "lib-presentation-screen-reader-reader-screen-dart"
primary_target: "lib/presentation/screen/reader/reader_screen.dart"
related_targets: []
---

# Reader chrome — surface brief

Scope: everything around the reading page: top bar, bottom bar with progress and tools, loading and error states, and the reader's sheets (appearance, contents, search, annotations, thumbnails). The page itself keeps its own reading themes. Visitor mode: Operate.

Audience and job: someone mid-book, often at night, who wants the text and nothing else, and reaches for a tool (contents, search, annotations, appearance) a few times per session.

Constraints: Paperback Bands world (DESIGN.md). Dark-only chrome over a page that may be light. No ornament. Material 3 components; system Back works; 48dp targets.

## Direction contract

THESIS: The book stays in front. Chrome is a dark band that appears on a tap and leaves on the next page turn; refuses a permanent toolbar of six unlabeled icons.

OWN-WORLD: Nav-ink bars, paper type, Figtree. The book's format band colour fills the progress bar, carrying the signature from cover to reader. Tabular percent and page numbers.

STORY: Open the book and see where you are; the bars step away on the first page turn; tap the middle to bring them back and reach a tool in one tap.

FIRST VIEWPORT: Top bar: back, book title (one line), bookmark. Page fills the rest. Bottom bar: band progress bar with percent (and "Page n of m" plus prev/next for paged fallback books), then four labeled tools: Contents, Search, Notes (annotations), Appearance; PDF fallback adds Pages (thumbnails).

FORM: Two overlay bands in nav ink that slide away (200ms ease-out, none with reduced motion). Status bar icons follow whatever is behind them: the bar when shown, the page when hidden.

## Adaptations
- No chapter name in the bar yet: Readium locators carry a title only sometimes; percent stands in.
- Continuous fallback scrolling hides the bars on scroll down and shows them on scroll up, since a centre tap conflicts with text selection there.

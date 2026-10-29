---
version: 1
slug: "lib-presentation-screen-home-home-screen-dart"
primary_target: "lib/presentation/screen/home/home_screen.dart"
related_targets: ["lib/presentation/screen/home/components/library_content.dart"]
---

---
version: 1
slug: "lib-presentation-screen-home-home-screen-dart"
primary_target: "lib/presentation/screen/home/home_screen.dart"
related_targets: ["lib/presentation/screen/home/components/library_content.dart"]
---

# Library (home) — surface brief

Scope: the Library tab (continue reading + shelf) and the app chrome it establishes; the reader inherits the world later. Visitor mode: Operate.

Audience and job: heavy readers and annotating researchers open the app to resume the current book in one tap, then find or import another document. Frequent, short sessions, often at night.

Constraints: dark-only chrome; no gold-on-black luxury, no decoration, no generic Material look, never dim or low contrast. Material 3 components and navigation stay; brand lives in colour roles, type and the cover bands.

## Direction contract

THESIS: Every document wears its format as a coloured series band, like a paperback list on a dark shelf; refuses the generic grey cover grid with one purple accent.

OWN-WORLD: Near-black ink ground with one lifted card surface; flat print colours, one per format (EPUB orange, PDF green, TXT blue, MD violet, HTML teal, FB2 mustard), always paired with the format code in dark ink; cream label panel for coverless documents; Figtree in a tight weight range; pill buttons; tabular numerals.

STORY: The reader sees what they were reading and how far along, resumes in one tap, and scans the shelf by colour before reading titles.

FIRST VIEWPORT: App bar "Library" with import action. "Continue reading" section heading, then the continue-reading card: banded cover left, title, author when known, progress bar in the book's band colour, one meta row with percent read left and last-read recency right, Resume pill. Below: "Your shelf" header with count and search, sort, view actions (search opens inline on demand), then the three-column banded cover grid with title and state caption. Material navigation bar (Library, Settings), active indicator in brand orange.

FORM: Mid-century paperback series design (colour-coded horizontal bands), IMPECCABLE'S PICK, ranked first of my grounded list after the user ruled out gilt luxury; seed: seed:7e811d53b795fbdf. Signature move: the format band, carried from cover to progress bar to the reader's chrome accent.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Adaptations
- Chapter line and time-left are omitted: books store no chapter position or reading-speed data; percent read and last-read recency stand in.
- The contract's kicker became a section heading: kickers are banned by the craft floor.

## Unresolved
- Reading-page fonts arrive with Phase 4 premium appearance.

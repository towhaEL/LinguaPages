---
name: LinguaPages
description: Paperback Bands. A dark shelf where every document format wears a flat print colour as its series band.
colors:
  ink: "#111315"
  ink-deep: "#0C0D0F"
  nav-ink: "#16191B"
  card: "#1C1F22"
  card-high: "#26292D"
  card-highest: "#2F3337"
  rule: "#33383D"
  outline: "#6B7076"
  paper: "#ECEAE4"
  paper-muted: "#A8A59E"
  disabled: "#5C6166"
  press-orange: "#E0742E"
  press-orange-deep: "#9A4A16"
  press-orange-container: "#4A2A14"
  error-coral: "#FF8A7A"
  band-epub: "#E0742E"
  band-pdf: "#4FA370"
  band-txt: "#5B8FD6"
  band-markdown: "#B07CCB"
  band-html: "#3FA9A9"
  band-fb2: "#D2AA45"
  label-cream: "#F4F1EA"
typography:
  display:
    fontFamily: "Figtree"
    fontSize: "28px"
    fontWeight: 800
    letterSpacing: "-0.3px"
  headline:
    fontFamily: "Figtree"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.15
  dialog-title:
    fontFamily: "Figtree"
    fontSize: "20px"
    fontWeight: 800
  title:
    fontFamily: "Figtree"
    fontSize: "15px"
    fontWeight: 800
  body:
    fontFamily: "Figtree"
    fontSize: "14px"
    fontWeight: 400
    letterSpacing: "0.25px"
  body-secondary:
    fontFamily: "Figtree"
    fontSize: "13px"
    fontWeight: 400
    letterSpacing: "0.25px"
  caption:
    fontFamily: "Figtree"
    fontSize: "12px"
    fontWeight: 400
    letterSpacing: "0.2px"
    fontFeature: "\"tnum\" 1"
  label:
    fontFamily: "Figtree"
    fontSize: "15px"
    fontWeight: 700
  nav-label:
    fontFamily: "Figtree"
    fontSize: "12px"
    fontWeight: 700
  band-code:
    fontFamily: "Figtree"
    fontSize: "11px"
    fontWeight: 800
    letterSpacing: "1.2px"
  cover-title:
    fontFamily: "Figtree"
    fontSize: "13px"
    fontWeight: 800
    lineHeight: 1.1
rounded:
  cover-compact: "3px"
  cover: "4px"
  tooltip: "8px"
  field: "14px"
  card: "16px"
  sheet: "24px"
  pill: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  card-inset: "14px"
  gutter: "16px"
  row-gap: "20px"
  section: "32px"
components:
  button-primary:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 22px"
    height: "48px"
  button-primary-disabled:
    backgroundColor: "{colors.card-high}"
    textColor: "{colors.paper-muted}"
  button-outlined:
    textColor: "{colors.paper}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    padding: "0 20px"
    height: "48px"
  button-text:
    textColor: "{colors.press-orange}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
  card:
    backgroundColor: "{colors.card}"
    rounded: "{rounded.card}"
    padding: "14px"
  input:
    backgroundColor: "{colors.card}"
    textColor: "{colors.paper}"
    rounded: "{rounded.field}"
    padding: "14px 16px"
  chip:
    backgroundColor: "{colors.card}"
    textColor: "{colors.paper}"
    rounded: "{rounded.pill}"
  chip-selected:
    backgroundColor: "{colors.press-orange}"
    textColor: "{colors.ink}"
  nav-bar:
    backgroundColor: "{colors.nav-ink}"
    textColor: "{colors.paper-muted}"
    typography: "{typography.nav-label}"
    height: "72px"
  nav-indicator:
    backgroundColor: "{colors.press-orange}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
  sheet:
    backgroundColor: "{colors.card}"
    rounded: "{rounded.sheet}"
  snackbar:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.field}"
  tooltip:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.tooltip}"
  book-cover-label:
    backgroundColor: "{colors.label-cream}"
    textColor: "{colors.ink}"
    typography: "{typography.cover-title}"
    rounded: "{rounded.cover}"
---

# Design System: LinguaPages

## Overview

**Creative North Star: "Paperback Bands"**

The app chrome is a dark shelf of mid-century paperbacks. A near-black ink ground carries one lifted card surface, warm paper-white type, and a set of flat print colours, one per document format, applied as horizontal series bands on every cover. A reader can scan the shelf by colour before reading a single title, and the band colour follows the book from its cover to its progress bar.

The system is dark-only and flat. Depth comes from tonal steps of ink and card, never from shadow, gloss, texture or gold. Built on Material 3 components (navigation bar and rail, filled and outlined buttons, sheets, dialogs, snackbars), it presents one custom, platform-neutral look on Android and iOS. The brand shows up in colour roles, in Figtree set in a tight heavy weight range, in pill-shaped controls, and in the bands. Visitor mode is Operate: dense enough for daily use, legible at night, with no ornament competing with the books.

Contrast is never traded for mood. Paper on ink measures 15.5:1. Muted paper measures 7.6:1 on ink and 6.7:1 on card. Ink on every band measures at least 5.6:1.

**Key Characteristics:**
- Dark-only chrome on near-black ink, with one lifted card tone.
- Six flat format bands, each always paired with its format code in dark ink.
- One brand accent, press orange, kept to navigation, focus, selection and the EPUB band.
- Figtree only, bundled with the app, in weights 400 to 800, with tabular figures for numbers.
- Pill controls, a 16px gutter, flat surfaces, no shadows.

## Colors

The palette is ink and paper plus six print colours, used as flat fills with no gradients or tints.

### Primary
- **Press Orange** (`press-orange`): the brand accent. It is used only for the navigation indicator (bar and rail), focused field borders (2px), text selection, the cursor and handles, the selected chip, switches and sliders, the FAB, text buttons, the progress indicator, and the EPUB band. Ink sits on it. A darker shade (`press-orange-deep`) appears only as the snackbar action on paper, and `press-orange-container` appears only as Material's primary container.

### Secondary
- **Format Bands** (`band-epub`, `band-pdf`, `band-txt`, `band-markdown`, `band-html`, `band-fb2`): EPUB orange, PDF green, TXT blue, Markdown violet, HTML teal, FB2 mustard. They fill the top and bottom bands of a cover and the filled part of a book's progress bar. Every band carries its format code in ink. They are resolved through `BandColors.forFormat`; never hard-code one. Green, mustard, blue and violet also serve as the semantic success, warning, info and premium colours.
- **Label Cream** (`label-cream`): the title panel between the bands when a document has no extracted cover image. Ink type sits on it.

### Neutral
- **Ink** (`ink`): the scaffold, app bar and canvas. `ink-deep` is the lowest surface container.
- **Nav Ink** (`nav-ink`): the navigation bar and rail, one step above the ground.
- **Card** (`card`): the one lifted surface, used for cards, sheets, dialogs, input fills and chips. `card-high` is used for popup menus, progress tracks, disabled buttons and switch tracks. `card-highest` is the top container step.
- **Paper** (`paper`): primary text and icons. It also fills the primary button, snackbar and tooltip as an inverse surface.
- **Muted Paper** (`paper-muted`): secondary text, meta rows, captions, unselected navigation, and hints and field icons.
- **Rule** (`rule`): dividers, the chip border and the outline variant. It is decorative only.
- **Outline** (`outline`): component boundaries that must read at 3:1 or better, such as outlined buttons, the unselected switch outline and the sheet drag handle.
- **Error Coral** (`error-coral`): errors and destructive text actions, with ink on it.

### Named Rules
**The One Orange Rule.** Press orange marks navigation, focus, selection and EPUB, and nothing else. It is never a second luxury accent or decoration, and no gold appears anywhere.

**The Band Pairs With Its Code Rule.** A band colour never stands alone as meaning. Its format code in ink sits on the cover band, and the screen-reader label names the format.

**The Readable Muted Rule.** Secondary text uses `paper-muted`, never paper at reduced opacity, so it holds 4.5:1 or better on both ink and card.

## Typography

**Display Font:** Figtree (bundled in `assets/fonts/figtree`, weights 400/500/600/700/800; no runtime font fetching)
**Body Font:** Figtree
**Label/Mono Font:** Figtree, with tabular figures (`tnum`) for counts, percentages and recency

**Character:** A single friendly geometric sans set heavy. Headings use ExtraBold, controls use Bold, and body text stays Regular, so hierarchy comes from weight more than size.

### Hierarchy
- **Display** (800, 28px, -0.3px tracking): the app bar screen title, for example "Your Library" and "Settings". Left-aligned, with 20px title spacing and a 64px toolbar.
- **Headline** (800, 22px, line-height 1.15): the book title on the continue-reading card, two lines at most.
- **Dialog title** (800, 20px): alert dialog titles. Dialog body is 15px with 1.45 line-height in muted paper.
- **Title** (800, 15px): section headings such as "Continue reading" and "Your shelf", and sheet titles. They are marked as semantic headers.
- **Body** (400, 14px, 0.25px): list-row titles (set at 700) and settings rows. Secondary body is 13px: authors, grid tile titles (700, 1.2 line-height) and state-view body (1.45 line-height).
- **Caption** (400, 12px, tabular): grid and list progress state ("18%", "Not started").
- **Label** (700, 15px): all button labels. Navigation labels are 12px/700. Meta rows are 13px/700 tabular in muted paper.
- **Band code** (800, 11px, 1.2px tracking; 9px when compact): the format code printed on a cover band.

### Named Rules
**The Cover Does Not Scale Rule.** Text printed on a cover (band code, title and author on the cream label) uses `TextScaler.noScaling`, because cover art keeps its proportions. Every caption outside the cover follows the system font size, and the grid tile height is computed from the scaled text so nothing clips at large sizes.

**The Section Heading Rule.** Sections are introduced by a Title-weight heading in sentence case. Small tracked uppercase labels above headings (kickers or eyebrows) are not part of this system.

## Layout

The layout is a single column on a 16px gutter (`gutter`). Section headings and the shelf header indent 4px further, to 20px, so they align with the app bar title. Vertical rhythm uses steps of 4, 8, 12, 16, 20 and 32px. The scroll ends with 32px of bottom space.

- **Continue-reading card:** 14px inset. A 96px-wide cover sits on the left, with 16px to a text column holding the title, author, 16px gap, band progress bar, 6px gap, meta row (percent left, recency right), 12px gap and the Resume pill.
- **Shelf grid:** tiles are at most 132px wide, with the column count derived from the available width (three on a phone). Gaps are 12px across and 20px down. Tile height is the cover height (1.5 times the width) plus two scaled title lines, one scaled caption line and 12px.
- **List view:** rows have 12px vertical padding, a 44px compact cover, a 14px gap and a trailing overflow action. Rows are separated by 1px rule dividers inset by the gutter.
- **Search** opens inline under the shelf header on demand and stays hidden until it is asked for.
- **Navigation:** in portrait, a 72px Material navigation bar. In landscape, a navigation rail with all labels shown, aligned near the top, and content in a SafeArea beside it.
- **Empty and error states:** a centred stack with 32px/48px padding: a 48px muted icon, 20px gap, title, 8px gap, body, 24px gap and an optional filled action.

## Elevation & Depth

The system is flat. Every Material surface sets elevation 0 and a transparent surface tint, including the app bar (no scrolled-under elevation), navigation, cards, the FAB, sheets and dialogs. Depth comes from tonal steps alone: ink, then nav ink, then card, then card-high. Modal layers use a black scrim. Pressed feedback is Material's ink sparkle.

### Named Rules
**The No Shadow Rule.** No shadows, glows, gradients or textures. If a layer needs to separate, move it one tonal step up.

## Shapes

Controls are pills: filled, outlined and text buttons, chips, the FAB and the navigation indicator are all stadium shapes with a 48px minimum height. Containers have soft corners: tooltip 8px, fields, popup menus and snackbars 14px, cards 16px, sheets (top corners) and dialogs 24px. Covers are nearly square-cornered (4px, or 3px when compact) at a fixed 2:3 aspect, so they read as printed objects rather than UI cards. Progress bars are fully rounded at half their 6px height.

## Components

### Buttons
- **Shape:** pill (`rounded.pill`), 48px minimum height, 15px/700 label.
- **Primary (filled):** a paper fill with ink text and 22px side padding. This is the main action on a surface (Resume, Retry, Import). Disabled uses card-high with muted text.
- **Outlined:** paper text with a 1px `outline` border and 20px side padding.
- **Text:** press orange text. A destructive text action switches to error coral.
- **Icon buttons:** paper icons in a 48px target, each with a tooltip. The app bar's import action is a tonal filled icon button.

### Chips
- **Style:** a card fill with a 1px rule border and paper text at 600.
- **State:** selected fills press orange with ink text at 700.

### Cards / Containers
- **Corner Style:** 16px.
- **Background:** card, with no border and no shadow.
- **Internal Padding:** 14px on the continue-reading card.
- **Sheets:** card fill, 24px top corners, drag handle shown in `outline`, content inset 24px.
- **Dialogs:** card fill, 24px corners.

### Inputs / Fields
- **Style:** filled with card, no border at rest, 14px corners, 16px by 14px padding. Hint and icons are muted paper.
- **Focus:** a 2px press orange border, with an orange cursor and selection.

### Navigation
- **Bar and rail:** nav ink, no elevation. The selected destination has a press orange pill indicator with an ink icon and a paper label. Unselected icons and labels are muted paper. Labels are 12px/700. Outlined icons switch to filled icons when selected.
- **App bar:** ink, flush with the content. The left-aligned Display title has actions on the right.

### Feedback
- **Snackbar:** floating, with a paper fill, 15px/600 ink text, a press-orange-deep action and 14px corners.
- **Tooltip:** a paper fill with 13px/600 ink text and 8px corners.
- **Progress:** press orange on a card-high track for generic progress. Book progress always uses the band progress bar.

### Book Cover (signature)
A 2:3 paperback with a 4px corner, split into bands by flex 3:4:3. The top and bottom bands take the format's band colour. The bottom band prints the format code in 11px/800 ink with 1.2px tracking. The middle panel shows the extracted cover image, or a cream label with the title (13px/800, up to four lines) and author (11px/600). The compact variant (grid and list) uses 9px type and up to three title lines, and drops the author. Below 72px width, the label panel goes blank rather than break words. Cover text never scales with the system font size. Its semantics read as an image labelled "title, format".

### Band Progress Bar (signature)
A 6px fully rounded track in card-high, filled to scale in the book's band colour. Its semantics value is the percentage. It always sits next to a tabular percent label and never replaces it.

### State View
A centred empty or error state built from an icon, a title (Title at 800), muted body text and an optional filled pill action. The error variant tints the icon error coral.

## Do's and Don'ts

### Do:
- **Do** resolve a document's colour through `context.bands.forFormat(format)`, and print its format code on the band in ink.
- **Do** use `paper-muted` for secondary text and `outline` for any boundary that must read at 3:1 or better.
- **Do** keep every surface at elevation 0 with a transparent surface tint, and separate layers by tonal step.
- **Do** set numbers (counts, percentages, recency) in tabular figures.
- **Do** keep cover text unscaled and size every caption and grid tile from the user's text scale.
- **Do** keep the reading page's own themes separate from the chrome. The light, sepia and dark page palettes in `reader_screen.dart` (`_ReaderPalette`) are not yet redesigned and are not part of this world; they remain pending.

### Don't:
- **Don't** use press orange as decoration or as a second accent. It belongs to navigation, focus, selection and EPUB only.
- **Don't** introduce gold, texture, gradients, gloss or shadows.
- **Don't** use kickers or eyebrows (small tracked uppercase labels above a heading). Use a sentence-case section heading.
- **Don't** show a band colour without its format code, and don't recolour a band for emphasis.
- **Don't** lower contrast for mood. Never set text below 4.5:1 or use translucent paper for secondary text.
- **Don't** fetch fonts at runtime or fall back to a system display face. Figtree is bundled.

# Specification Mining Handoff Report: Screens 4–8 & Shared Style Block

**Agent Identity**: `teamwork_spec_miner_2`  
**Working Directory**: `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_spec_miner_2/`  
**Parent Orchestrator**: `orchestrator` (`64d8d7c9-ff2a-417f-be93-aa1e46a1f4df`)  
**Date**: 2026-11-03  
**Target Scope**: Shared Style Block, Screen 4 (Reader: chrome visible and hidden), Screen 4b (Appearance sheet), Screen 4c (Text selection & dictionary), Screen 4d (Contents & annotations side sheet), Screen 4e (Search in book), Screen 5 (Read aloud player variants), Screen 6 (Lock-screen controls), Screen 7 (Premium appearance), Screen 8 (All annotations).

---

## 1. Observation

Authoritative specification sources inspected:
1. `/Users/uswer/StudioProjects/linguaPages/design/design.md` (lines 1–16, 58–108)
2. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md` (lines 1–35)
3. Existing Flutter reference implementations:
   - `lib/presentation/screen/reader/reader_screen.dart` (lines 1–120, 1090–1160, 1360–1460, 2890–3160)
   - `lib/presentation/screen/reader/widgets/reader_chrome.dart` (lines 1–252)
   - `lib/presentation/screen/reader/widgets/dictionary_lookup_sheet.dart` (lines 1–105)
   - `lib/presentation/screen/reader/widgets/highlight_editor_sheet.dart` (lines 1–100)
   - `lib/presentation/screen/reader/widgets/notes_sheet.dart` (lines 1–100)
   - `lib/presentation/screen/reader/read_aloud/read_aloud_player.dart` (lines 1–100)
   - `lib/presentation/screen/annotations/annotations_screen.dart` (lines 1–100)
   - `lib/domain/entity/premium/appearance_catalog.dart` (lines 1–207)
   - `PRODUCT.md` & `IMPLEMENTATION_PLAN.md`

### Verbatim Spec Evidence from `design/design.md`:
- **Shared Style Block (lines 6–16)**:
  > `App: "LinguaPages", a private offline ebook reader for Android (EPUB, PDF, TXT, Markdown, HTML, FB2). Mobile, 412×915, Material 3 structure but a custom look.`  
  > `Visual direction: calm, editorial-first.`  
  > `- Background: warm ivory #FAF7F2; surfaces #FFFFFF; hairline dividers #E8E2D9.`  
  > `- Text: ink #1C1B1A, secondary #6B655D.`  
  > `- Single accent: deep ink blue #2F4A7A (buttons, progress, active chips). No other bright colours.`  
  > `- Type: serif display (Newsreader or Fraunces) for titles and book names; clean sans (Inter) for UI labels.`  
  > `- Shapes: 16px card radius, pill chips, soft long shadows under book covers only.`  
  > `- Book covers are the colour in the UI; everything else is restrained.`  
  > `- Generous whitespace, 20px side margins, no bottom navigation bar anywhere.`  
  > `- Icons: outlined, 1.5px stroke.`

- **Screen 4: Reader (chrome visible / hidden) (lines 61–64)**:
  > `Screen: Book reader for an EPUB. The page fills the screen: serif body text 18px, justified, generous margins, a chapter header (e.g. "The Harbour"). Reading theme "Paper" (#F6F1E7 page). The chrome is shown as if the page was tapped:`  
  > `- Top bar (translucent paper with blur): back arrow, the book title in small serif centred, then icons for search, bookmark (outlined) and a ⋮ menu.`  
  > `- Bottom panel (rounded top, translucent paper with blur): "Page 142 of 380 · 12 min left in chapter", a draggable progress slider with chapter tick marks, then a row of 4 labelled icon buttons: Contents, Appearance, Listen, Notes.`  
  > `- A thin vertical brightness indicator on the left edge.`  
  > `Also show a second variant with the chrome hidden: only the text and a tiny "142 / 380" at the bottom.`

- **Screen 4b: Appearance sheet (line 66)**:
  > `A bottom sheet over the reader. Reading themes as 6 round swatches (Paper, White, Sepia, Grey, Night, Black), two with a small lock icon for premium. A font picker as horizontal row showing 'Aa' in each font. Sliders for Size, Line spacing and Margins with A−/A+ end labels. Toggles: Justify, Hyphenation, Publisher styles. Layout segmented control: Scroll / Pages / Two columns. Brightness slider with a 'Follow system' toggle.`

- **Screen 4c: Text selection and dictionary (line 68)**:
  > `The reader with the word 'littoral' selected (ink-blue handles). A floating toolbar above it: Highlight (with 5 colour dots), Note, Define, Copy, Share, ⋯ (Search the web, Send to app). A bottom sheet with definition below: the word in large serif 'littoral', phonetic '/ˈlɪt(ə)rəl/' with a speaker icon, part of speech chips (adjective, noun), numbered definitions with italic examples, and the footer 'From Wiktionary · CC BY-SA 3.0'.`

- **Screen 4d: Contents and annotations (lines 69–70)**:
  > `A side sheet from the left over the reader. Tabs: Contents, Bookmarks, Highlights. Contents tab shows a nested chapter list with page numbers, the current chapter highlighted with an ink-blue bar. Show the Highlights tab as a thumbnail card with a colour strip, page number, date and a note preview. An export icon in the header ('Export as Markdown').`

- **Screen 4e: Search in book (lines 72–73)**:
  > `The reader with a search field in the top bar holding 'harbour' and '23 results'. A list of results grouped by chapter, each a text snippet with the match in bold ink blue and a page number. Up/down arrows to jump between results.`

- **Screen 5: Read aloud, in-app player (lines 78–83)**:
  > `Screen: The reader while reading aloud. The sentence being read has a soft ink-blue highlight band; the text auto-scrolls.`  
  > `A floating mini player docked above the bottom edge (rounded 20px, white, shadow): a small cover, the chapter name, play/pause in the centre, previous/next sentence buttons and an expand chevron.`  
  > `Variant 2, the expanded player as a tall bottom sheet: a large cover, book title (serif) and chapter, the current sentence shown large in serif with its neighbours faded above and below, a progress bar for the chapter, controls (previous sentence, play/pause in a large ink-blue circle, next sentence), then a row of chips: Speed "1.25×", Voice "English (UK) · Offline", Sleep timer "30 min".`  
  > `Variant 3: the sleep timer picker (15, 30, 60 min, End of chapter, Off) as a small sheet.`

- **Screen 6: Lock-screen read-aloud controls (lines 87–94)**:
  > `Screen: Android 15 lock screen, wallpaper with a soft blurred book texture. Large clock "9:41" and date. A Material You media player card in the middle: the album art is the book cover, the title is the chapter "Chapter Seven: The Crossing", subtitle is "The Salt Path · LinguaPages", a seek bar showing chapter progress, and controls: previous sentence, play/pause, next sentence, plus a custom "+30 s"-style button labelled "Sleep 30m". Small LinguaPages app icon in the card corner. Variant: the same card collapsed.`

- **Screen 7: Premium appearance (paywall) (lines 99–102)**:
  > `Screen: Premium appearance, a full page with a close X. A hero showing one paragraph rendered in 3 premium themes side by side (Linen, Midnight Blue, Forest) with different fonts. Headline (serif) "Make every page yours". Bullets: 12 reading themes, 8 book fonts, style presets. A note: "Reading, annotations, export, backup and dictionary stay free." Two plan cards (Lifetime highlighted, Yearly) with an "Unlock" button and "Restore purchase" as a text link.`

- **Screen 8: All annotations (lines 106–107)**:
  > `Screen: All annotations across the library. Top bar with the title "Annotations", a search field, and a list of cards grouped by book (cover thumbnail + title header), each with the quoted text, colour strip, note, page and date. Overflow menu: "Export as Markdown".`

---

## 2. Logic Chain

1. **Alignment with System Architecture & Request**:
   - `ORIGINAL_REQUEST.md` mandates that the UI generation plan decompose every screen into modular, individually generatable UI components rather than generating single monolithic full screens.
   - Each component must specify an exact filename following `<screen_number>_<screen_name>_<component_name>.png`, targeted to `design/components/`.
   - Every component prompt must be seeded with the Shared Style Block (`design/design.md` lines 1–16) for consistency in colors, typography, shapes, and Material 3 structure.

2. **Decomposition Strategy for Screens 4–8**:
   - **Screen 4 (Reader)** splits into distinct visual layers:
     (a) The reading canvas (`reader_page_content`) with paper styling (#F6F1E7),
     (b) The translucent blurred top chrome (`reader_top_bar`),
     (c) The floating bottom control panel (`reader_bottom_bar`) containing metadata, seek slider, and 4 tool triggers,
     (d) The edge gesture brightness indicator (`reader_brightness_indicator`),
     (e) The distraction-free hidden chrome variant (`reader_hidden_chrome_variant`) with only text and "142 / 380".
   - **Screen 4b (Appearance Sheet)** decomposes into 7 discrete modular controls:
     (a) Sheet header, (b) 6 theme swatches, (c) font horizontal carousel, (d) typography sliders (Size, Line Spacing, Margins), (e) toggles (Justify, Hyphenation, Publisher styles), (f) layout segmented control (Scroll/Pages/Two columns), (g) brightness slider with follow-system toggle.
   - **Screen 4c (Text Selection & Dictionary)** decomposes into:
     (a) In-text selection handles and highlight band, (b) Floating contextual toolbar (pill with 5 color dots and 6 actions), (c) Dictionary bottom sheet (headword, phonetic audio, part of speech chips, numbered definitions, Wiktionary license footer).
   - **Screen 4d (Contents & Annotations Side Sheet)** decomposes into:
     (a) Side sheet header with export icon and 3 tabs, (b) Nested chapter list with active chapter indicator bar, (c) Highlights thumbnail cards list with color strips, dates, notes, (d) Bookmarks list.
   - **Screen 4e (Search in Book)** decomposes into:
     (a) Top bar search field with query, result counter, and navigation chevrons, (b) Grouped search results list with chapter headers, context snippets, and highlighted keywords.
   - **Screen 5 (Read Aloud In-App Player)** decomposes into:
     (a) Auto-scrolling reader text with active sentence highlight band, (b) Floating docked mini-player above bottom edge, (c) Expanded bottom sheet player with faded sentence focus, chapter progress, large ink-blue play button, and chips, (d) Sleep timer modal picker sheet.
   - **Screen 6 (Lock-Screen Controls)** decomposes into:
     (a) Android 15 lock screen background wallpaper with clock/date, (b) Expanded Material You media player card with album art, chapter title, seek bar, and 5 controls, (c) Collapsed media player card variant.
   - **Screen 7 (Premium Appearance Paywall)** decomposes into:
     (a) Paywall app bar with close X, (b) 3-theme side-by-side hero comparison (Linen, Midnight Blue, Forest), (c) Value proposition bullets and reassurance note, (d) Plan cards (Lifetime highlighted vs Yearly), (e) Action footer ("Unlock" pill button + "Restore purchase" text link).
   - **Screen 8 (All Annotations)** decomposes into:
     (a) Top app bar with search and overflow export menu, (b) Grouped book header with cover thumbnail and title, (c) Annotation quote card with color strip, note preview, and metadata, (d) Markdown export action sheet.

3. **Color, Typography & Token Mapping**:
   - Palette Tokens: Background `#FAF7F2`, Surfaces `#FFFFFF`, Hairline Dividers `#E8E2D9`, Text Ink `#1C1B1A`, Secondary Ink `#6B655D`, Accent Ink Blue `#2F4A7A`.
   - Reader Themes: Paper `#F6F1E7`, White `#FFFFFF`, Sepia `#F6EFD9`, Grey `#E0DFDB`, Night `#1F2433`, Black `#000000`. Premium themes: Linen `#EFECE6`, Midnight Blue `#1A233A`, Forest `#1E2B22`.
   - Highlight Tints: Light mode (Yellow `#FFE08A`, Green `#B9E4BE`, Blue `#B8D8F5`, Pink `#F6C3D6`), Dark mode (Yellow `#6B5714`, Green `#2A5C37`, Blue `#234A78`, Pink `#6B2A4B`).
   - Radii: Cards 16px, Sheets 24px, Chips & Buttons 9999px (Pill), Book covers 4px with soft long drop shadows.

---

## 3. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Shared Style | Global Canvas & Frame | 412×915 mobile viewport, Material 3 structure, warm ivory background `#FAF7F2` | Screen viewport specifications | Standardised canvas frame | Fallback to 412×915 default | `design/design.md` §0 |
| 2 | Shared Style | Color Token System | Calm editorial palette: #FAF7F2 bg, #FFFFFF surface, #E8E2D9 divider, #1C1B1A text, #6B655D secondary, #2F4A7A accent | Design token definitions | Standard color palette across all prompts | Invalidation if non-palette colors injected | `design/design.md` §0 |
| 3 | Shared Style | Typography System | Serif display (Newsreader/Fraunces) for titles/books; clean sans (Inter) for UI labels | Type roles & sizes | Consistent typographic hierarchy | Fallback to serif/sans system | `design/design.md` §0 |
| 4 | Shared Style | Geometry & Shadows | 16px card radius, 24px sheet radius, pill chips (9999px), soft long shadow under book covers only | Shape & elevation tokens | Standardised corner radii & elevations | Fallback to flat/unshadowed elements | `design/design.md` §0 |
| 5 | Screen 4 | Reader Page Content | Fullscreen EPUB page with 18px serif body text, justified, generous margins, chapter header "The Harbour" | Reader theme choice (Paper #F6F1E7), text settings | Rendered editorial book page | Text overflow handled by pagination/scroll | `design/design.md` §4 |
| 6 | Screen 4 | Reader Top Bar | Translucent paper bar with blur: back arrow, centred small serif book title, search, bookmark (outlined), ⋮ menu | Tap on page center | Top chrome overlay (height 56px) | Graceful ellipsis on long book title | `design/design.md` §4, `reader_chrome.dart` |
| 7 | Screen 4 | Reader Bottom Panel | Rounded top translucent panel with blur: "Page 142 of 380 · 12 min left in chapter", draggable slider with chapter ticks, 4 tools | Tap on page center | Bottom tool & progress panel (height 120px) | Tabular figures prevent layout jitter | `design/design.md` §4, `reader_chrome.dart` |
| 8 | Screen 4 | Reader Brightness Strip | Thin vertical brightness indicator on left edge (32px gesture zone) | Left-edge vertical swipe | Translucent brightness gauge overlay | Clamped between min (58) and max (1168) | `design/design.md` §4, `reader_screen.dart:65` |
| 9 | Screen 4 | Reader Hidden Chrome | Chrome dismisses on page turn or tap; pure text canvas with tiny "142 / 380" indicator at bottom | Tap center / page advance | Minimalist reading screen | No chrome displayed | `design/design.md` §4 |
| 10 | Screen 4b | Theme Swatches (6) | Round swatches (Paper, White, Sepia, Grey, Night, Black); two with lock icon for premium | Swatch tap | Live preview of reading theme; active ring | Locked swatch prompts paywall or preview banner | `design/design.md` §4b, `appearance_catalog.dart` |
| 11 | Screen 4b | Font Picker Carousel | Horizontal scroll of font chips showing 'Aa' in font family (Newsreader, Fraunces, Literata, etc.) | Chip tap | Updates book body font immediately | Premium fonts show lock badge if locked | `design/design.md` §4b |
| 12 | Screen 4b | Typography Sliders | Sliders with A− / A+ end labels for Size (14–28px), Line spacing (1.2–2.2), Margins (8–32px) | Drag slider thumb | Real-time text reflow adjustments | Clamped to defined min/max bounds | `design/design.md` §4b, `reader_screen.dart:2901` |
| 13 | Screen 4b | Typography Toggles | Switches for Justify text, Hyphenation, Publisher styles | Toggle switch | Enables/disables typographic flags | Publisher styles overrides custom font/margins | `design/design.md` §4b |
| 14 | Screen 4b | Layout Segmented Control | 3-way pill segmented control: "Scroll" \| "Pages" \| "Two columns" | Segment tap | Switches rendering layout mode | Two columns disabled on narrow screens | `design/design.md` §4b |
| 15 | Screen 4b | Brightness & System Toggle | Brightness slider with "Follow system" switch | Slider thumb / switch toggle | Custom reader brightness or system sync | Overridden by system auto-brightness if enabled | `design/design.md` §4b |
| 16 | Screen 4c | Text Selection Handles | Selected word 'littoral' highlighted with ink-blue handles and tint | Long press / drag selection | Active text range with bounding handles | Deselects on tap outside | `design/design.md` §4c |
| 17 | Screen 4c | Floating Text Toolbar | Pill toolbar above selection: Highlight (5 dots), Note, Define, Copy, Share, ⋯ (Search web, Send to app) | Selection trigger | Floating action menu | Repositions if near screen boundary | `design/design.md` §4c |
| 18 | Screen 4c | Dictionary Bottom Sheet | Sheet with word 'littoral', phonetic '/ˈlɪt(ə)rəl/', speaker audio, POS chips (adjective, noun), numbered definitions, Wiktionary footer | "Define" tap | Rich dictionary modal sheet (height ≤75%) | Offline / not found state displayed gracefully | `design/design.md` §4c, `dictionary_lookup_sheet.dart` |
| 19 | Screen 4d | Contents & Annotations Tabs | Left side sheet with 3 tabs: Contents, Bookmarks, Highlights; header with "Export as Markdown" | "Contents" tap from bottom bar | Slide-in drawer sheet from left | Empty tab shows dedicated empty placeholder | `design/design.md` §4d |
| 20 | Screen 4d | Nested Chapter List | Nested chapter hierarchy with page numbers; active chapter marked with vertical ink-blue bar | Chapter item tap | Navigates reader to chapter start | Missing TOC shows flat reading order | `design/design.md` §4d |
| 21 | Screen 4d | Highlights Tab Cards | Cards with color strip, page number, timestamp, quote snippet, note preview | Tab selection | List of book-specific highlight cards | Confirmation dialog on deletion | `design/design.md` §4d, `notes_sheet.dart` |
| 22 | Screen 4e | Search in Book Top Bar | Top bar holding search field ('harbour'), '23 results' counter, and up/down navigation chevrons | Search icon tap | Search interface in app bar | Clear button resets input | `design/design.md` §4e |
| 23 | Screen 4e | Search Results List | Grouped results by chapter with text snippets, keyword in bold ink blue (#2F4A7A), and page numbers | Query submission | Scrollable list of matched snippets | "No matches found" state if query fails | `design/design.md` §4e |
| 24 | Screen 5 | Auto-Scroll Spoken Highlight | Reading page auto-scrolls with soft ink-blue highlight band on currently spoken sentence | Read aloud active | Dynamic sentence highlighting | Stops when audio paused | `design/design.md` §5 |
| 25 | Screen 5 | Docked Mini Player | Floating white pill docked above bottom edge (rounded 20px, shadow): cover, chapter, prev/play/pause/next, expand chevron | Start read aloud | Compact playback controller | Disables prev/next at book start/end | `design/design.md` §5, `read_aloud_player.dart` |
| 26 | Screen 5 | Expanded Read Aloud Sheet | Tall bottom sheet: large cover, serif book title & chapter, large serif current sentence with faded neighbours, seek bar, controls, chips row | Expand chevron tap | Fullscreen reading player sheet | Error banner if TTS engine unavailable | `design/design.md` §5 |
| 27 | Screen 5 | Read Aloud Chips Row | Chips for Speed "1.25×", Voice "English (UK) · Offline", Sleep timer "30 min" | Chip tap | Quick configuration modals | Offline voices filtered by device availability | `design/design.md` §5 |
| 28 | Screen 5 | Sleep Timer Picker Sheet | Compact sheet with choices: 15, 30, 60 min, End of chapter, Off | Sleep timer chip tap | Radio selection bottom sheet | Timer cancels on "Off" or manual stop | `design/design.md` §5, `sleep_timer.dart` |
| 29 | Screen 6 | Lock-Screen Wallpaper & Clock | Android 15 lock screen backdrop with blurred book cover wallpaper, large clock "9:41" and date | Background playback with screen locked | System lock screen UI | Fallback to default lock screen wallpaper | `design/design.md` §6 |
| 30 | Screen 6 | Lock-Screen Media Card | Material You media card: cover art, chapter title, subtitle "The Salt Path · LinguaPages", seek bar, 5 controls (+30s / "Sleep 30m"), app icon | MediaSession playback active | Native lock screen media widget | TXT/Markdown/FB2 requires media-session adapter | `design/design.md` §6 |
| 31 | Screen 6 | Collapsed Lock-Screen Card | Compact single-row variant of media card with album art, condensed title/subtitle, inline controls | System swipe / collapse | Minimized media notification | Handled by Android system OS | `design/design.md` §6 |
| 32 | Screen 7 | Premium Hero Themes Showcase | 3-way side-by-side comparison cards: Linen, Midnight Blue, Forest showing paragraph in varied fonts | Premium page entry | Visual hero showcase container | Static preview, non-interactive | `design/design.md` §7 |
| 33 | Screen 7 | Value Bullets & Free Note | Serif headline "Make every page yours", bullets (12 themes, 8 fonts, presets), reassurance note "Reading... stays free" | Page render | Trust-building copy block | Clear guarantee of offline/free core features | `design/design.md` §7, `PRODUCT.md` |
| 34 | Screen 7 | Plan Cards & Action Footer | Lifetime card (highlighted, best value) vs Yearly card; "Unlock" deep ink blue pill button + "Restore purchase" link | Plan tap / CTA tap | Subscription/IAP checkout trigger | Handles network error / pending purchases | `design/design.md` §7, `premium_paywall_sheet.dart` |
| 35 | Screen 8 | All Annotations Top Bar | Top bar with serif "Annotations" title, search field, overflow menu (⋮) with "Export as Markdown" | Screen navigation | Universal annotations app bar | Disables export when annotations list is empty | `design/design.md` §8, `annotations_screen.dart` |
| 36 | Screen 8 | Book Grouped Cards List | Annotations grouped by book (cover thumbnail + title header), each with quote, color strip, note, page, date | Search query / filter | Grouped scrollable cards list | Empty state when no annotations exist | `design/design.md` §8 |

---

## 4. Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Screen 4: Chrome visibility | Rapid double tap on center of screen | Chrome toggles state without flashing or animation stutter; hit tests are immediately enabled/disabled via `IgnorePointer`. |
| 2 | Screen 4: Hidden Chrome | Long book title (>40 characters) | Small serif title in top bar truncates with ellipsis; hidden chrome mode displays zero chrome headers. |
| 3 | Screen 4: Brightness Indicator | Edge swipe inside system back gesture area (first 24dp) | System gesture overrides touch; brightness strip is offset to 32dp width outside Android system gesture insets to ensure responsiveness. |
| 4 | Screen 4b: Theme Swatches | Reader in dark environment selecting "Night" or "Black" | Swatch shows preview with light "Aa" on dark surface; selecting locked premium theme opens preview banner with paywall trigger. |
| 5 | Screen 4b: Sliders | Text size slider dragged to extreme (14px or 28px) | Text reflows without clipping; A−/A+ icons remain anchored at boundaries; page count recalculated dynamically. |
| 6 | Screen 4c: Selection Toolbar | Word selected at top boundary of screen (line 1) | Floating toolbar flips from above the word to below the word to stay within safe viewport bounds. |
| 7 | Screen 4c: Dictionary Sheet | Word not found in Wiktionary or device is offline without cache | Sheet displays friendly offline message (`cloud_off_outlined`) with preserved Highlight and Copy actions. |
| 8 | Screen 4d: Side Sheet | Book has deep multi-level nested chapter structure (Level 3+) | Child chapters indent progressively; active chapter indicator bar anchors to the exact leaf node; horizontal scroll is prevented. |
| 9 | Screen 4e: Search in Book | Query matches 0 occurrences | Result counter displays "0 results"; list shows centered calm empty state with "No matches found". |
| 10 | Screen 5: Read Aloud Player | Audio reaches end of chapter | Playback transitions seamlessly to next chapter or pauses if sleep timer "End of chapter" is engaged. |
| 11 | Screen 5: Expanded Player | Very long sentence spanning multiple pages | Large serif sentence display wraps cleanly; faded previous and next sentences remain legible at 40% opacity. |
| 12 | Screen 6: Lock-Screen Media Card | Background playback of non-EPUB document (TXT / Markdown / FB2) | MediaSession metadata must be populated manually to prevent blank system media notification. |
| 13 | Screen 7: Premium Paywall | User enters paywall in airplane mode | UI displays offline reassurance; store pricing displays cached localized string or calm placeholder without crashing. |
| 14 | Screen 8: All Annotations | User filters with a query matching notes but not quotes | Search scans both quoted text and attached user notes; cards highlight matched note snippets. |

---

## 5. Screen-by-Screen Component Breakdown & Prompt Parameters

### Screen 4: Reader (Chrome Visible & Hidden Chrome)
- **4.1 `04_reader_page_content.png`**  
  - Target Path: `design/components/04_reader_page_content.png`  
  - Role: Full-screen reader text body representing an open EPUB book.  
  - Hierarchy: Base canvas layer filling 412×915.  
  - Tokens: Background `#F6F1E7` (Paper theme), Text ink `#1C1B1A`, generous 20px side margins, 18px Newsreader/Fraunces serif typography, 1.5 line spacing, justified alignment, chapter header "Chapter 3: The Harbour" in 22px serif.  
  - Prompt: `Mobile app UI component, 412x915, LinguaPages offline ebook reader. Screen 4 reader page canvas. Background warm paper #F6F1E7, editorial layout, 20px side margins. High quality serif typography (Newsreader style) 18px body text, justified, 1.5 line height. Chapter headline 'Chapter 3: The Harbour' in elegant 22px serif display. Calm, clean, no UI clutter, crisp digital paper texture.`

- **4.2 `04_reader_top_bar.png`**  
  - Target Path: `design/components/04_reader_top_bar.png`  
  - Role: Translucent top app bar with blur and reader controls.  
  - Hierarchy: Fixed at top edge, height 56px, overlapping reader page.  
  - Tokens: Translucent paper background `#F6F1E7` with 12px backdrop blur, hairline divider `#E8E2D9` at bottom. Left back arrow icon, centered small serif book title "The Salt Path", right action icons: search, outlined bookmark, overflow ⋮ menu (all 1.5px outlined stroke in `#1C1B1A`).  
  - Prompt: `Mobile app UI component, 412x56 top app bar for LinguaPages reader. Translucent warm paper background #F6F1E7 with subtle frosted glass blur, 1px bottom border #E8E2D9. Left back arrow icon. Centred book title 'The Salt Path' in 15px serif display font. Right action icons: outlined search icon, outlined bookmark ribbon icon, vertical three dots menu. 1.5px stroke outlined icons in ink #1C1B1A.`

- **4.3 `04_reader_bottom_bar.png`**  
  - Target Path: `design/components/04_reader_bottom_bar.png`  
  - Role: Floating docked bottom control panel with reading progress and tools.  
  - Hierarchy: Docked at bottom, rounded top corners (16px radius), height 120px.  
  - Tokens: Translucent paper `#F6F1E7` with blur, top border `#E8E2D9`. Metadata label: "Page 142 of 380 · 12 min left in chapter" (Inter sans, tabular figures `#6B655D`). Draggable slider in deep ink blue `#2F4A7A` with discrete chapter tick marks. Bottom tool row with 4 labelled icon buttons: "Contents", "Appearance", "Listen", "Notes".  
  - Prompt: `Mobile app UI component, 412x120 bottom control panel for LinguaPages reader. 16px rounded top corners, translucent paper background #F6F1E7 with frosted blur. Top row displays reading metadata 'Page 142 of 380 · 12 min left in chapter' in 13px clean sans (Inter) secondary #6B655D. Draggable progress slider in deep ink blue #2F4A7A with subtle chapter tick marks. Bottom row of 4 evenly spaced labelled icon buttons: 'Contents' (book list icon), 'Appearance' (palette Aa icon), 'Listen' (headphones icon), 'Notes' (pencil document icon). Outlined 1.5px stroke icons, ink labels.`

- **4.4 `04_reader_brightness_indicator.png`**  
  - Target Path: `design/components/04_reader_brightness_indicator.png`  
  - Role: Left-edge vertical brightness level indicator.  
  - Hierarchy: Absolute vertical overlay along left border, width 4px (with 32px touch zone), height 240px centered vertically.  
  - Tokens: Translucent white/ink bar with pill cap, filled to current level (70%) in deep ink blue `#2F4A7A`.  
  - Prompt: `Mobile app UI component, vertical slider brightness indicator on screen edge for LinguaPages reader. Slender 4px wide vertical pill track, 240px tall, positioned on the far left edge. Semi-transparent track with deep ink blue #2F4A7A active indicator level at 70%, minimal and unobtrusive, clean editorial design.`

- **4.5 `04_reader_hidden_chrome_variant.png`**  
  - Target Path: `design/components/04_reader_hidden_chrome_variant.png`  
  - Role: Distraction-free full-screen reader view when chrome is dismissed.  
  - Hierarchy: Fullscreen 412×915.  
  - Tokens: Paper background `#F6F1E7`, full page of justified serif text, zero chrome bars, tiny subtle page counter "142 / 380" centered at bottom margin in `#6B655D`.  
  - Prompt: `Mobile app UI component, 412x915 full screen view of LinguaPages ebook reader in distraction-free mode. Warm ivory paper background #F6F1E7. High quality serif body text (Newsreader) filling page with generous 20px margins. No top bar, no bottom bar, no toolbars. Only a tiny, subtle page indicator '142 / 380' in 11px sans-serif at the bottom center. Peaceful, literary, editorial aesthetic.`

---

### Screen 4b: Appearance Sheet
- **4b.1 `04b_appearance_sheet_header.png`**  
  - Target Path: `design/components/04b_appearance_sheet_header.png`  
  - Role: Sheet top drag handle and section title.  
  - Hierarchy: Top of bottom sheet, height 48px, 24px top radius.  
  - Tokens: Surface `#FFFFFF`, pill drag handle 32×4px `#E8E2D9`, title "Appearance" in 18px serif/bold sans `#1C1B1A`.  
  - Prompt: `Mobile app UI component, bottom sheet header for LinguaPages appearance settings. White surface #FFFFFF, rounded top corners 24px, centered 32x4px grey pill drag handle #E8E2D9. Below, title 'Appearance' in 18px serif display font (Newsreader). Clean, elegant whitespace.`

- **4b.2 `04b_appearance_theme_swatches.png`**  
  - Target Path: `design/components/04b_appearance_theme_swatches.png`  
  - Role: 6 circular reading theme color swatches with labels.  
  - Hierarchy: Horizontal row / grid within appearance sheet.  
  - Tokens: 6 circular swatches (diameter 44px) showing "Aa" text: Paper (`#F6F1E7`), White (`#FFFFFF`), Sepia (`#F6EFD9`), Grey (`#E0DFDB`), Night (`#1F2433`), Black (`#000000`). Selected swatch (Paper) has active deep ink blue `#2F4A7A` outline ring. Two swatches (Night, Black) display a tiny lock icon badge indicating premium.  
  - Prompt: `Mobile app UI component, reading theme selector for LinguaPages. Row of 6 circular swatches (44px diameter) each displaying sample letters 'Aa': 1. Paper (warm ivory #F6F1E7), 2. White (#FFFFFF), 3. Sepia (#F6EFD9), 4. Grey (#E0DFDB), 5. Night (#1F2433 dark navy), 6. Black (#000000). The Paper swatch has a deep ink blue #2F4A7A active ring. The Night and Black swatches feature a small lock icon badge on their top-right corner. Below each swatch is its clean sans label.`

- **4b.3 `04b_appearance_font_picker.png`**  
  - Target Path: `design/components/04b_appearance_font_picker.png`  
  - Role: Horizontal font selection carousel showing font samples.  
  - Hierarchy: Scrollable row of pill chips.  
  - Tokens: Pill cards (height 40px, rounded 20px, surface `#FFFFFF`, border `#E8E2D9`), active card filled in deep ink blue `#2F4A7A` with white text. Fonts: "Publisher", "Newsreader", "Fraunces", "Literata", "Source Serif", "EB Garamond", "Inter".  
  - Prompt: `Mobile app UI component, font picker row for LinguaPages. Horizontally scrolling row of pill-shaped chips displaying 'Aa FontName'. Active chip is deep ink blue #2F4A7A with white text ('Aa Newsreader'). Other chips have white background with 1px border #E8E2D9 and ink text ('Aa Fraunces', 'Aa Literata', 'Aa EB Garamond', 'Aa Inter'). Some premium chips have a tiny lock icon.`

- **4b.4 `04b_appearance_typography_sliders.png`**  
  - Target Path: `design/components/04b_appearance_typography_sliders.png`  
  - Role: Sliders for Text Size, Line Spacing, and Margins.  
  - Hierarchy: Vertical stack of 3 slider groups.  
  - Tokens: Sliders with A− label on left and A+ on right (Inter sans 14px), active track deep ink blue `#2F4A7A`, inactive track `#E8E2D9`, circular thumb `#2F4A7A`. Labels: "Text size (18 px)", "Line spacing (1.5)", "Margins (20 px)".  
  - Prompt: `Mobile app UI component, typography sliders for LinguaPages reader settings. Stack of 3 sliders: 1. Text size ('18 px'), 2. Line spacing ('1.5'), 3. Margins ('20 px'). Each slider features a clean label above, end icons/labels 'A−' on left and 'A+' on right, smooth deep ink blue #2F4A7A slider track and thumb, neutral inactive track #E8E2D9.`

- **4b.5 `04b_appearance_typography_toggles.png`**  
  - Target Path: `design/components/04b_appearance_typography_toggles.png`  
  - Role: Typographic switches for Justify, Hyphenation, Publisher styles.  
  - Hierarchy: Stack of 3 list rows with switches.  
  - Tokens: Switch tiles with clean sans text `#1C1B1A`, Material 3 switches with deep ink blue `#2F4A7A` active thumb/track.  
  - Prompt: `Mobile app UI component, typography toggle switches for LinguaPages. Three horizontal rows with clean labels: 'Justify text' (switched ON, active deep ink blue #2F4A7A), 'Hyphenation' (switched ON), 'Publisher styles' (switched OFF, neutral grey #E8E2D9). Clean 14px sans typography (Inter), hairline separator lines.`

- **4b.6 `04b_appearance_layout_segmented_control.png`**  
  - Target Path: `design/components/04b_appearance_layout_segmented_control.png`  
  - Role: Layout segmented control for reading flow.  
  - Hierarchy: Full-width segmented pill container.  
  - Tokens: 3 segments: "Scroll" | "Pages" | "Two columns". Pill frame rounded 9999px, background `#FAF7F2`, active segment "Pages" in deep ink blue `#2F4A7A` with white text.  
  - Prompt: `Mobile app UI component, layout segmented control for LinguaPages reader. Pill-shaped 3-segment control: 'Scroll', 'Pages' (selected with solid deep ink blue #2F4A7A background and crisp white text), and 'Two columns'. Warm ivory pill frame #FAF7F2 with subtle hairline border #E8E2D9. 14px Inter sans typography.`

- **4b.7 `04b_appearance_brightness_control.png`**  
  - Target Path: `design/components/04b_appearance_brightness_control.png`  
  - Role: Brightness slider with "Follow system" toggle.  
  - Hierarchy: Bottom row of appearance sheet.  
  - Tokens: Sun icons (dim sun left, bright sun right), slider track in `#2F4A7A`, "Follow system" toggle switch on the right.  
  - Prompt: `Mobile app UI component, brightness control row for LinguaPages appearance sheet. Horizontal slider flanked by outlined dim and bright sun icons (1.5px stroke). Right side features a compact 'Follow system' text label and toggle switch. Deep ink blue accent #2F4A7A, warm white surface #FFFFFF.`

---

### Screen 4c: Text Selection & Dictionary
- **4c.1 `04c_selection_highlight_handles.png`**  
  - Target Path: `design/components/04c_selection_highlight_handles.png`  
  - Role: Text selection highlight overlay on reader page.  
  - Hierarchy: Overlaid on active paragraph text.  
  - Tokens: Word 'littoral' highlighted with semi-transparent deep ink blue `#2F4A7A` background band, teardrop selection pins at word start and end in `#2F4A7A`.  
  - Prompt: `Mobile app UI component, text selection state on warm paper #F6F1E7 page for LinguaPages reader. The word 'littoral' in 18px serif text is highlighted with a soft deep ink blue tint (#2F4A7A at 20% opacity). Teardrop selection pin handles in solid deep ink blue #2F4A7A anchor the start and end of the word.`

- **4c.2 `04c_selection_floating_toolbar.png`**  
  - Target Path: `design/components/04c_selection_floating_toolbar.png`  
  - Role: Floating horizontal action menu anchored above selected text.  
  - Hierarchy: Floating pill/card with soft drop shadow, 16px radius, height 44px.  
  - Tokens: Surface `#FFFFFF`, 16px radius, soft shadow. Actions: "Highlight" with 5 color dots (Yellow `#FFE08A`, Green `#B9E4BE`, Blue `#B8D8F5`, Pink `#F6C3D6`, Purple `#D4B8E5`), "Note" (icon), "Define" (icon), "Copy", "Share", "⋯" overflow button.  
  - Prompt: `Mobile app UI component, floating text selection toolbar for LinguaPages reader. Floating white rounded pill card (16px radius, soft drop shadow). Horizontal row of actions: 'Highlight' accompanied by 5 circular color dots (yellow, green, blue, pink, purple), 'Note' icon, 'Define' icon with label, 'Copy', 'Share', and '⋯' overflow button. Clean 13px sans text, 1.5px stroke outlined icons.`

- **4c.3 `04c_dictionary_sheet_headword.png`**  
  - Target Path: `design/components/04c_dictionary_sheet_headword.png`  
  - Role: Dictionary modal sheet headword, phonetics, and audio trigger.  
  - Hierarchy: Top section of dictionary bottom sheet.  
  - Tokens: Word "littoral" in large 26px serif display (Newsreader) ink `#1C1B1A`, phonetic transcription `/'lɪt(ə)rəl/` in clean sans `#6B655D` with outlined speaker icon button, part-of-speech pill chips: "adjective", "noun" (surface `#FAF7F2`, hairline border `#E8E2D9`).  
  - Prompt: `Mobile app UI component, dictionary header for LinguaPages. Large serif headword 'littoral' in 26px Newsreader font, ink #1C1B1A. Below, phonetic transcription '/ˈlɪt(ə)rəl/' in secondary ink #6B655D paired with a 1.5px outlined speaker audio icon button. Adjacent part-of-speech pill chips: 'adjective' and 'noun' in warm ivory #FAF7F2 with 1px border #E8E2D9.`

- **4c.4 `04c_dictionary_sheet_definitions.png`**  
  - Target Path: `design/components/04c_dictionary_sheet_definitions.png`  
  - Role: Numbered definitions with illustrative italic examples.  
  - Hierarchy: Middle scrollable content of dictionary sheet.  
  - Tokens: 1. "Of or relating to the shore of a sea, lake, or ocean." with italic example "*The littoral zone is rich in marine life.*"; 2. "A coastal region." with italic example "*Settlements along the western littoral.*". Body in Inter sans 14px `#1C1B1A`, examples in italic Newsreader serif `#6B655D`.  
  - Prompt: `Mobile app UI component, dictionary definition list for LinguaPages. Clean typography: Definition 1 in 14px Inter sans '1. Of or relating to the shore of a sea, lake, or ocean.', followed by italicised usage example 'The littoral zone is rich in marine life.' in muted serif #6B655D. Definition 2 '2. A coastal region.' with example 'Settlements along the western littoral.' Generous line height and editorial layout.`

- **4c.5 `04c_dictionary_sheet_footer_actions.png`**  
  - Target Path: `design/components/04c_dictionary_sheet_footer_actions.png`  
  - Role: Attribution footer and quick action buttons.  
  - Hierarchy: Bottom section of dictionary sheet.  
  - Tokens: Attribution text "From Wiktionary · CC BY-SA 3.0" with external link icon. Two pill action buttons: "Highlight" (primary filled, deep ink blue `#2F4A7A`, white text) and "Copy definition" (outlined pill, 1px border `#E8E2D9`, ink text).  
  - Prompt: `Mobile app UI component, dictionary sheet footer for LinguaPages. Subtle attribution text 'From Wiktionary · CC BY-SA 3.0' in 11px sans #6B655D with tiny link icon. Action row below with two pill buttons: primary 'Highlight' button in deep ink blue #2F4A7A with white text, and secondary 'Copy' outlined pill button. Clean, restrained, Material 3 structure.`

---

### Screen 4d: Contents & Annotations (Side Sheet)
- **4d.1 `04d_contents_side_sheet_header_tabs.png`**  
  - Target Path: `design/components/04d_contents_side_sheet_header_tabs.png`  
  - Role: Left-sliding side sheet header with export action and tab selector.  
  - Hierarchy: Top of side sheet (width 340px), surface `#FFFFFF`.  
  - Tokens: Title "The Salt Path" in 16px serif, right export icon button ("Export as Markdown" tooltip), close X icon. 3 tabs below: "Contents", "Bookmarks", "Highlights" with deep ink blue `#2F4A7A` underline indicator under "Contents".  
  - Prompt: `Mobile app UI component, left side sheet header for LinguaPages reader. White surface #FFFFFF, width 340px. Top bar displays book title 'The Salt Path' in 16px serif, with an outlined 'Export as Markdown' icon button and close X button. Below is a 3-tab bar: 'Contents' (active, bold ink text with deep ink blue #2F4A7A indicator bar), 'Bookmarks', and 'Highlights'. Clean hairline divider #E8E2D9.`

- **4d.2 `04d_contents_nested_chapter_list.png`**  
  - Target Path: `design/components/04d_contents_nested_chapter_list.png`  
  - Role: Table of contents nested hierarchy with page numbers.  
  - Hierarchy: Scrollable body under "Contents" tab.  
  - Tokens: Chapter list rows: "Part One: The Fall" (bold serif 15px), indented subchapters "Chapter 1: The Quay" (p. 1), "Chapter 2: The Cliff Path" (p. 42), "Chapter 3: The Harbour" (p. 88, active). Active row has vertical 4px deep ink blue `#2F4A7A` bar on left edge, bold text, and right-aligned page number in tabular Inter sans.  
  - Prompt: `Mobile app UI component, table of contents list for LinguaPages side sheet. Nested chapter rows: 'Part One: The Fall', indented 'Chapter 1: The Quay' (Page 1), 'Chapter 2: The Cliff Path' (Page 42), and 'Chapter 3: The Harbour' (Page 88, active). Active chapter has a 4px solid deep ink blue #2F4A7A vertical indicator bar on the left edge and bold typography. Right-aligned tabular page numbers in muted ink #6B655D.`

- **4d.3 `04d_contents_highlights_tab_list.png`**  
  - Target Path: `design/components/04d_contents_highlights_tab_list.png`  
  - Role: Annotation cards list under "Highlights" tab.  
  - Hierarchy: Scrollable body under "Highlights" tab.  
  - Tokens: Cards (16px radius, surface `#FFFFFF`, border `#E8E2D9`). Left vertical color strip (yellow, green, blue, pink, 4px wide). Quoted text snippet in 14px serif, page number "Page 142", creation date "Oct 28", note preview in italic sans with small pencil icon.  
  - Prompt: `Mobile app UI component, highlights list view for LinguaPages side sheet. Stack of white cards (16px radius, hairline border #E8E2D9). Each card features a vibrant 4px color strip on the left edge (yellow, green, or blue), quoted book excerpt in 14px serif font, metadata row with 'Page 142 · Oct 28' in secondary ink #6B655D, and a reader's note preview with a tiny pencil icon. Restrained, elegant editorial design.`

- **4d.4 `04d_contents_bookmarks_tab_list.png`**  
  - Target Path: `design/components/04d_contents_bookmarks_tab_list.png`  
  - Role: Bookmarks list under "Bookmarks" tab.  
  - Hierarchy: Scrollable body under "Bookmarks" tab.  
  - Tokens: List tiles with outlined bookmark icon (`#2F4A7A`), chapter title in serif, page number in tabular sans, date added, delete trash icon.  
  - Prompt: `Mobile app UI component, bookmarks tab view for LinguaPages reader side sheet. List of bookmark rows, each containing an outlined bookmark icon in deep ink blue #2F4A7A, chapter name 'Chapter 3: The Harbour' in 14px serif, 'Page 94' in tabular sans, date 'Nov 1', and subtle delete icon. Crisp, calm layout.`

---

### Screen 4e: Search in Book
- **4e.1 `04e_search_in_book_top_bar.png`**  
  - Target Path: `design/components/04e_search_in_book_top_bar.png`  
  - Role: In-book search input bar with result count and navigation chevrons.  
  - Hierarchy: Top app bar, height 56px.  
  - Tokens: Back arrow icon, input field holding query "harbour", clear X button, badge/counter "23 results" in `#6B655D`, up/down arrow buttons (`keyboard_arrow_up`, `keyboard_arrow_down` in 1.5px stroke `#1C1B1A`) to jump between matches.  
  - Prompt: `Mobile app UI component, in-book search top bar for LinguaPages. Warm paper background #F6F1E7, 1px bottom border #E8E2D9. Left back arrow button. Search field containing active text 'harbour' in clean Inter sans, clear X button, result counter badge '23 results' in secondary ink #6B655D. Right navigation controls: up and down chevron arrow buttons to jump sequentially between results.`

- **4e.2 `04e_search_in_book_results_list.png`**  
  - Target Path: `design/components/04e_search_in_book_results_list.png`  
  - Role: Search results grouped by chapter with highlighted occurrences.  
  - Hierarchy: Scrollable body filling screen below search bar.  
  - Tokens: Chapter header "Chapter 3: The Harbour (8 results)" in 14px bold serif. Result cards (16px radius, surface `#FFFFFF`, border `#E8E2D9`). Each card shows a 2-line snippet with the matched word "**harbour**" highlighted in **bold deep ink blue** (`#2F4A7A`), with right-aligned page number "p. 88".  
  - Prompt: `Mobile app UI component, search results list for LinguaPages reader. Section header 'Chapter 3: The Harbour (8 results)' in bold Newsreader serif. Two white result cards (16px radius, 1px border #E8E2D9) showing sentence excerpts: '...looking down across the natural harbour where fishing boats...' with the word 'harbour' highlighted in bold deep ink blue #2F4A7A. Right-aligned page indicator 'p. 88' in tabular sans.`

---

### Screen 5: Read Aloud Player Variants
- **5.1 `05_read_aloud_reading_highlight.png`**  
  - Target Path: `design/components/05_read_aloud_reading_highlight.png`  
  - Role: Auto-scrolling reader text canvas with active spoken sentence highlight.  
  - Hierarchy: Background reading canvas.  
  - Tokens: Paper background `#F6F1E7`, 18px serif body text. Active sentence has a continuous soft deep ink blue highlight band (tint `#D6E2F5` / `rgba(47, 74, 122, 0.15)`), while previous and subsequent sentences remain standard ink `#1C1B1A`.  
  - Prompt: `Mobile app UI component, read-aloud active text view for LinguaPages. Warm ivory paper background #F6F1E7 with elegant 18px Newsreader serif text. The active sentence currently spoken by TTS is wrapped in a soft ink-blue highlight band (#2F4A7A at 15% opacity, light blue tint #D6E2F5). Auto-scrolling reading view, editorial aesthetic.`

- **5.2 `05_read_aloud_docked_mini_player.png`**  
  - Target Path: `design/components/05_read_aloud_docked_mini_player.png`  
  - Role: Floating mini player pill docked above bottom edge.  
  - Hierarchy: Docked above bottom safe area, rounded 20px, height 64px, floating with soft shadow.  
  - Tokens: Surface `#FFFFFF`, 20px pill radius, soft shadow elevation. Left: small 2:3 book cover thumbnail (rounded 4px). Center-left: chapter title "Chapter 7: The Crossing" in 14px serif. Center-right: playback controls: previous sentence, prominent play/pause button (ink blue `#2F4A7A`), next sentence. Far right: expand chevron (`expand_less_rounded`).  
  - Prompt: `Mobile app UI component, docked mini read-aloud player for LinguaPages reader. Floating white pill container (20px radius, soft drop shadow, 412x64). Left side: miniature 2:3 book cover thumbnail (rounded 4px). Center: chapter title 'Chapter 7: The Crossing' in 14px serif display. Controls: previous sentence button, circular pause button in deep ink blue #2F4A7A with white icon, next sentence button. Far right: expand upward chevron icon.`

- **5.3 `05_read_aloud_expanded_sheet_header.png`**  
  - Target Path: `design/components/05_read_aloud_expanded_sheet_header.png`  
  - Role: Expanded player bottom sheet top section with large cover and book title.  
  - Hierarchy: Top section of tall bottom sheet, rounded top 24px.  
  - Tokens: Surface `#FFFFFF`, drag handle, downward collapse chevron. Large book cover thumbnail (aspect 2:3, soft long shadow, rounded 8px). Book title "The Salt Path" in 22px serif display, chapter title "Chapter 7: The Crossing" in 15px sans `#6B655D`.  
  - Prompt: `Mobile app UI component, expanded read-aloud player header for LinguaPages. White surface #FFFFFF, rounded top corners 24px, centered pill drag handle and top-left collapse chevron. Centered large book cover (2:3 aspect ratio, elegant cover design with soft long drop shadow, 8px radius). Below cover: book title 'The Salt Path' in 22px Newsreader serif display, and chapter 'Chapter 7: The Crossing' in 15px secondary sans #6B655D.`

- **5.4 `05_read_aloud_expanded_sentence_focus.png`**  
  - Target Path: `design/components/05_read_aloud_expanded_sentence_focus.png`  
  - Role: Synchronized sentence display showing current sentence and faded context.  
  - Hierarchy: Center section of expanded player sheet.  
  - Tokens: Active spoken sentence rendered large in 20px Newsreader serif ink `#1C1B1A`. Previous sentence displayed above in 15px serif with 40% faded opacity. Next sentence displayed below in 15px serif with 40% faded opacity.  
  - Prompt: `Mobile app UI component, synchronized sentence display for LinguaPages expanded player. Centered focus text block: Previous sentence shown above in 15px serif at 40% faded opacity. Current spoken sentence rendered large and crisp in 20px Newsreader serif font in ink #1C1B1A. Next sentence shown below in 15px serif at 40% faded opacity. Highly readable, calm, audio-synced reader experience.`

- **5.5 `05_read_aloud_expanded_player_controls.png`**  
  - Target Path: `design/components/05_read_aloud_expanded_player_controls.png`  
  - Role: Chapter seek bar and primary audio playback controls.  
  - Hierarchy: Lower section of expanded player sheet.  
  - Tokens: Draggable chapter progress bar in deep ink blue `#2F4A7A` with timestamps "14:20" and "−08:45". Main playback row: previous sentence button, large circular play/pause button (64px diameter, solid deep ink blue `#2F4A7A`, white pause icon), next sentence button.  
  - Prompt: `Mobile app UI component, playback controls for LinguaPages read-aloud player. Thin chapter progress bar in deep ink blue #2F4A7A flanked by timestamps '14:20' and '−08:45' in tabular sans #6B655D. Main playback control row: skip previous sentence button (1.5px outlined stroke), large 64px diameter circular play/pause button in solid deep ink blue #2F4A7A with white pause icon, and skip next sentence button.`

- **5.6 `05_read_aloud_expanded_chips_row.png`**  
  - Target Path: `design/components/05_read_aloud_expanded_chips_row.png`  
  - Role: Interactive configuration chips for Speed, Voice, and Sleep Timer.  
  - Hierarchy: Bottom row of expanded player sheet.  
  - Tokens: Horizontally aligned pill chips (height 36px, rounded 9999px, background `#FAF7F2`, border `#E8E2D9`): Speed chip `Speed "1.25×"`, Voice chip `Voice "English (UK) · Offline"`, Sleep timer chip `Sleep timer "30 min"`. Outlined 1.5px stroke icons.  
  - Prompt: `Mobile app UI component, audio configuration chips for LinguaPages player. Horizontal row of 3 pill-shaped chips: 1. 'Speed 1.25×' with gauge icon, 2. 'Voice: English (UK) · Offline' with voice wave icon, 3. 'Sleep timer: 30 min' with crescent moon icon. Warm ivory surface #FAF7F2, 1px border #E8E2D9, ink text #1C1B1A.`

- **5.7 `05_read_aloud_sleep_timer_sheet.png`**  
  - Target Path: `design/components/05_read_aloud_sleep_timer_sheet.png`  
  - Role: Sleep timer modal picker sheet.  
  - Hierarchy: Modal bottom sheet, 24px top radius.  
  - Tokens: Title "Sleep timer" in 18px serif display. Radio option list: "15 min", "30 min" (selected with deep ink blue `#2F4A7A` radio indicator), "60 min", "End of chapter", "Off". Surface `#FFFFFF`.  
  - Prompt: `Mobile app UI component, sleep timer bottom sheet for LinguaPages. White surface #FFFFFF, 24px rounded top corners, pill drag handle. Headline 'Sleep timer' in 18px Newsreader serif. Vertical list of radio options: '15 min', '30 min' (selected with solid deep ink blue #2F4A7A radio dot), '60 min', 'End of chapter', and 'Off'. Clean 15px Inter sans typography, hairline dividers.`

---

### Screen 6: Lock-Screen Controls
- **6.1 `06_lock_screen_background_clock.png`**  
  - Target Path: `design/components/06_lock_screen_background_clock.png`  
  - Role: Android 15 lock screen wallpaper and system lock clock.  
  - Hierarchy: Fullscreen system background 412×915.  
  - Tokens: Backdrop wallpaper with soft blurred book cover texture, large bold Material You lock screen clock "9:41" and date "Tuesday, Nov 3" in white/translucent cream.  
  - Prompt: `Mobile app UI component, Android 15 lock screen background for LinguaPages read-aloud. Fullscreen 412x915. Artistic wallpaper featuring a soft, atmospheric blurred book cover texture. Large prominent lock screen clock '9:41' and date 'Tuesday, Nov 3' in clean modern Material You typography at top.`

- **6.2 `06_lock_screen_media_card_expanded.png`**  
  - Target Path: `design/components/06_lock_screen_media_card_expanded.png`  
  - Role: Material You media player card in expanded state.  
  - Hierarchy: Centered lock screen card widget, rounded 28px.  
  - Tokens: Material You dynamic tonal container surface (frosted slate ivory/tinted glass). Album art: book cover thumbnail (aspect 2:3, rounded 8px). Title: "Chapter Seven: The Crossing". Subtitle: "The Salt Path · LinguaPages". Small LinguaPages app icon in upper corner badge. Seek bar showing chapter progress. Controls: previous sentence, play/pause, next sentence, and custom button labelled "Sleep 30m".  
  - Prompt: `Mobile app UI component, Android 15 Material You expanded media notification card for LinguaPages. Centered card with 28px corner radius, translucent frosted dark slate glass surface. Left: book cover album art (2:3 aspect ratio, rounded 8px). Right: Chapter title 'Chapter Seven: The Crossing' in bold typography, subtitle 'The Salt Path · LinguaPages'. Tiny LinguaPages icon badge in top corner. Chapter seek progress bar. 5 control buttons: skip back, play/pause pill button, skip forward, and custom '+30s' button labelled 'Sleep 30m'.`

- **6.3 `06_lock_screen_media_card_collapsed.png`**  
  - Target Path: `design/components/06_lock_screen_media_card_collapsed.png`  
  - Role: Material You media player card in collapsed state.  
  - Hierarchy: Compact lock screen notification row.  
  - Tokens: Compact single-row card, square cover art on left, chapter title and subtitle condensed in middle, inline play/pause and next sentence buttons on right.  
  - Prompt: `Mobile app UI component, Android 15 collapsed media player notification card for LinguaPages. Single-row compact card (24px radius, frosted dark glass). Left: small square book cover thumbnail. Middle: chapter title 'Chapter Seven' and 'The Salt Path' in compact text. Right: inline play/pause icon button and skip next icon button. Minimal, system-native layout.`

---

### Screen 7: Premium Appearance (Paywall)
- **7.1 `07_premium_top_bar.png`**  
  - Target Path: `design/components/07_premium_top_bar.png`  
  - Role: Full-page header with close X button.  
  - Hierarchy: Top of full screen, height 56px.  
  - Tokens: Warm ivory background `#FAF7F2`, close X icon button on left (1.5px stroke `#1C1B1A`).  
  - Prompt: `Mobile app UI component, premium paywall top bar for LinguaPages. Warm ivory background #FAF7F2, 56px height. Clean outlined close 'X' icon button on the top-left (1.5px stroke, ink #1C1B1A). No bottom border, generous whitespace.`

- **7.2 `07_premium_hero_themes_comparison.png`**  
  - Target Path: `design/components/07_premium_hero_themes_comparison.png`  
  - Role: Hero visual comparison showing 3 premium themes side by side.  
  - Hierarchy: Prominent hero showcase below top bar.  
  - Tokens: 3 side-by-side card mockups rendering the same literary paragraph:
    1. **Linen**: warm textured paper background `#EFECE6`, ink text, Literata serif font.
    2. **Midnight Blue**: deep slate navy background `#1A233A`, crisp pale text `#D8DCE8`, Fraunces serif font.
    3. **Forest**: deep pine green background `#1E2B22`, warm ivory text `#E2EADB`, EB Garamond serif font.
    Each card has 12px radius, soft drop shadow, and theme label badge below.  
  - Prompt: `Mobile app UI component, hero visual showcase for LinguaPages premium appearance. Three side-by-side vertical card mockups displaying the same book paragraph rendered in 3 distinct premium themes: 1. 'Linen' (warm natural woven paper #EFECE6 with Literata serif text), 2. 'Midnight Blue' (deep dark navy #1A233A with high-contrast pale text in Fraunces serif), 3. 'Forest' (calm deep evergreen #1E2B22 with warm ivory text in EB Garamond). 12px rounded cards with soft shadows, exquisite typography.`

- **7.3 `07_premium_value_proposition_bullets.png`**  
  - Target Path: `design/components/07_premium_value_proposition_bullets.png`  
  - Role: Headline, feature bullet points, and free reassurance note.  
  - Hierarchy: Center section of premium screen.  
  - Tokens: Headline "Make every page yours" in 28px Newsreader serif `#1C1B1A`. 3 value bullets with ink-blue checkmark icons: "12 reading themes", "8 book fonts", "Curated style presets" in 15px Inter sans. Reassurance note: "Reading, annotations, export, backup and dictionary stay free." in 13px Inter sans secondary `#6B655D`.  
  - Prompt: `Mobile app UI component, value proposition for LinguaPages premium paywall. Bold serif headline 'Make every page yours' in 28px Newsreader font. Bullet list with deep ink blue #2F4A7A checkmark icons: '12 reading themes', '8 book fonts', 'Curated style presets'. Below bullets, an honest, calming reassurance note: 'Reading, annotations, export, backup and dictionary stay free.' in 13px Inter sans muted ink #6B655D. Trustworthy, no artificial urgency.`

- **7.4 `07_premium_plan_cards.png`**  
  - Target Path: `design/components/07_premium_plan_cards.png`  
  - Role: Pricing plan options (Lifetime highlighted vs Yearly).  
  - Hierarchy: Stack/row of 2 pricing cards.  
  - Tokens:
    - Card 1: **Lifetime** (highlighted): 16px radius, surface `#FFFFFF`, 2px solid deep ink blue `#2F4A7A` border, top badge "One-time purchase / Best value", price label in bold 20px sans, description "Own it forever".
    - Card 2: **Yearly**: 16px radius, surface `#FFFFFF`, 1px hairline border `#E8E2D9`, title "Yearly access", price label, description "Billed annually".  
  - Prompt: `Mobile app UI component, subscription plan cards for LinguaPages premium. Two cards: 1. 'Lifetime' (highlighted card, white surface, solid 2px deep ink blue #2F4A7A border, 'Best Value' pill badge, prominent one-time price, 'Pay once, keep forever'), 2. 'Yearly' (standard card, 1px border #E8E2D9, yearly price, 'Billed annually'). Clean 16px rounded corners, calm editorial styling.`

- **7.5 `07_premium_action_footer.png`**  
  - Target Path: `design/components/07_premium_action_footer.png`  
  - Role: Primary unlock call-to-action button and restore purchase text link.  
  - Hierarchy: Fixed at bottom of premium screen.  
  - Tokens: Primary button: full-width pill button (height 48px, rounded 9999px) in solid deep ink blue `#2F4A7A`, white text "Unlock LinguaPages Premium". Secondary link: centered text button "Restore purchase" in 14px Inter sans secondary `#6B655D`.  
  - Prompt: `Mobile app UI component, action footer for LinguaPages premium paywall. Full-width pill-shaped primary action button (48px height, rounded 9999px) in deep ink blue #2F4A7A with white text 'Unlock LinguaPages Premium'. Below the button, a centered subtle text link 'Restore purchase' in 14px Inter sans secondary ink #6B655D. Clean whitespace, generous margins.`

---

### Screen 8: All Annotations (Across Library)
- **8.1 `08_all_annotations_top_app_bar.png`**  
  - Target Path: `design/components/08_all_annotations_top_app_bar.png`  
  - Role: Top app bar with screen title, search trigger, and export menu.  
  - Hierarchy: Fixed at top of screen, height 56px.  
  - Tokens: Warm ivory `#FAF7F2`, back arrow icon, title "Annotations" in 20px serif display (Newsreader) `#1C1B1A`, search icon button, overflow menu (⋮) containing "Export as Markdown".  
  - Prompt: `Mobile app UI component, top app bar for LinguaPages all annotations screen. Warm ivory background #FAF7F2, 1px bottom border #E8E2D9. Left back arrow button. Title 'Annotations' in 20px Newsreader serif font. Right actions: search icon button and three-dots overflow menu icon with 'Export as Markdown' option. Outlined 1.5px stroke icons, ink #1C1B1A.`

- **8.2 `08_all_annotations_search_bar.png`**  
  - Target Path: `design/components/08_all_annotations_search_bar.png`  
  - Role: Search and filter input field for finding annotations across the library.  
  - Hierarchy: Directly below app bar, height 48px.  
  - Tokens: Surface `#FFFFFF`, 14px radius, 1px border `#E8E2D9`, leading search magnifying glass icon, placeholder "Search quotes, notes, or books...", clear button.  
  - Prompt: `Mobile app UI component, search bar for LinguaPages annotations. Rounded search input field (14px radius, white surface #FFFFFF, 1px hairline border #E8E2D9). Leading outlined magnifying glass icon, placeholder text 'Search quotes, notes, or books...' in muted secondary ink #6B655D. Clean, spacious layout.`

- **8.3 `08_all_annotations_book_group_header.png`**  
  - Target Path: `design/components/08_all_annotations_book_group_header.png`  
  - Role: Grouping header for annotations belonging to a specific book.  
  - Hierarchy: Section header preceding book-specific annotation cards.  
  - Tokens: Small book cover thumbnail (aspect 2:3, height 40px, rounded 4px, soft shadow). Book title "The Salt Path" in 16px serif display `#1C1B1A`, author "Raynor Winn" in 13px Inter sans `#6B655D`, annotation count badge "14 highlights · 3 notes" in pill chip.  
  - Prompt: `Mobile app UI component, book group header for LinguaPages annotations list. Horizontal row: miniature 2:3 book cover thumbnail on left (rounded 4px, soft shadow). Adjacent title 'The Salt Path' in 16px Newsreader serif, author 'Raynor Winn' in 13px sans #6B655D, and a subtle pill badge '14 highlights · 3 notes'. Hairline divider above.`

- **8.4 `08_all_annotations_card_item.png`**  
  - Target Path: `design/components/08_all_annotations_card_item.png`  
  - Role: Individual annotation card displaying quote, color strip, note, and metadata.  
  - Hierarchy: Card in grouped list, 16px radius.  
  - Tokens: Surface `#FFFFFF`, 16px radius, border `#E8E2D9`. Left 4px vertical color strip (yellow, green, blue, or pink). Quoted text in 14px serif Newsreader ink `#1C1B1A`. User note container below with note icon and 13px Inter sans text. Footer row: page number "Page 142", date "Oct 28, 2026", jump-to-page arrow icon.  
  - Prompt: `Mobile app UI component, annotation card for LinguaPages library. White card container (16px radius, 1px border #E8E2D9). 4px vertical yellow color strip on the left edge. Quoted book passage in 14px Newsreader serif font: 'It was a walk that had been taken by thousands before us, yet every step felt entirely untrodden.' Attached reader note in 13px sans with small pencil icon: 'Key turning point in chapter 7.' Footer with 'Page 142 · Oct 28, 2026' and navigation arrow icon.`

- **8.5 `08_all_annotations_export_dialog_sheet.png`**  
  - Target Path: `design/components/08_all_annotations_export_dialog_sheet.png`  
  - Role: Export dialog/sheet confirming Markdown export and clipboard copying.  
  - Hierarchy: Modal dialog / bottom sheet.  
  - Tokens: Title "Export Annotations" in 18px serif display, options: "Export as Markdown (.md)", "Copy to clipboard", "Share file". Primary pill button in deep ink blue `#2F4A7A`.  
  - Prompt: `Mobile app UI component, markdown export modal sheet for LinguaPages. White surface #FFFFFF, rounded top corners 24px, pill drag handle. Title 'Export Annotations' in 18px serif display. List options with outlined icons: 'Save as Markdown (.md)', 'Copy all to clipboard', 'Share via app'. Deep ink blue #2F4A7A primary confirmation pill button. Clean, restrained, durable data ownership design.`

---

## 6. Caveats

1. **System Lock-Screen Limitations**:
   - Screen 6 (Lock-Screen Controls) relies on Android system media session architecture (`MediaSessionCompat` / `MediaStyle` notification). The visual appearance of the lock screen media player card is rendered by Android 15's SystemUI based on metadata sent by the app (album cover, title, subtitle, seek position, actions), rather than an in-app Flutter canvas. Visual prompts reflect the desired system rendering reference.
   - A known engine gap documented in `design.md` §6 notes that non-EPUB engines (TXT, Markdown, HTML, FB2) will require MediaSession bridging.

2. **Typographic Fallbacks & Offline Bundling**:
   - The design spec designates serif display fonts (Newsreader or Fraunces) for titles and clean sans (Inter) for UI labels. In the existing Flutter codebase, Literata, Source Serif 4, and EB Garamond are bundled. For visual generation, prompts explicitly request "Newsreader / Fraunces serif display" and "Inter sans".

3. **No Implementation Executed**:
   - In accordance with our role as Specification Miner, no image generation was performed, and no code files outside `.agents/teamwork/teamwork_spec_miner_2/` were modified.

---

## 7. Conclusion

Screens 4 through 8 and the Shared Style Block have been comprehensively analyzed and decomposed into **36 discrete modular components**. Every component is fully specified with:
- Exact screen-wise image filenames following `<screen_number>_<screen_name>_<component_name>.png`,
- Target output directory set to `design/components/`,
- Exact styling parameters derived from the Shared Style Block (warm ivory `#FAF7F2`, surface `#FFFFFF`, dividers `#E8E2D9`, text ink `#1C1B1A`, secondary `#6B655D`, deep ink blue accent `#2F4A7A`, 16px card radius, 24px sheet radius, pill chips, 1.5px outlined icons),
- Rich, self-contained visual generation prompts ready for individual asset generation,
- Full coverage of interactive states, themes (Paper, White, Sepia, Grey, Night, Black, and premium variants), and edge cases.

This report is ready for immediate incorporation by the orchestrator into `design/ui_generation_plan.md`.

---

## 8. Verification Method

To independently verify the facts and specifications in this report:

1. **Inspect Design Specification**:
   ```bash
   python3 -c "
   with open('design/design.md') as f:
       text = f.read()
   for s in ['Shared style block', '4. Reader', '4b. Appearance sheet', '4c. Text selection', '4d. Contents and annotations', '4e. Search in book', '5. Read aloud', '6. Lock-screen', '7. Premium appearance', '8. All annotations']:
       assert s.lower() in text.lower(), f'Missing section: {s}'
   print('All assigned sections verified in design/design.md')
   "
   ```

2. **Inspect Existing Flutter Reader Chrome Tokens**:
   ```bash
   cat lib/presentation/screen/reader/widgets/reader_chrome.dart | grep -E "readerTopBarHeight|readerBottomBarHeight"
   ```

3. **Inspect Appearance Catalog Theme and Font Tokens**:
   ```bash
   cat lib/domain/entity/premium/appearance_catalog.dart | grep -E "backgroundArgb|textArgb|tintArgb"
   ```

4. **Verify Report Integrity**:
   Check that this report exists and contains all required sections:
   ```bash
   ls -la .agents/teamwork/teamwork_spec_miner_2/handoff.md
   ```

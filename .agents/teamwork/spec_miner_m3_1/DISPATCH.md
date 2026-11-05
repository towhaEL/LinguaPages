## 2026-11-04T20:56:25Z
You are spec_miner_m3_1, a Design Specification Miner for Milestone 3: Library & Book Management (R3).
Your working directory is: /home/tn-99778/Towha/LinguaPages/.agents/teamwork/spec_miner_m3_1/
Your parent conversation ID is: 2283687a-5c7c-4e1f-9d03-d89b8d745253

FIRST STEP:
Read /home/tn-99778/Towha/LinguaPages/.agents/teamwork/ORIGINAL_REQUEST.md in full.
Read /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator/PROJECT.md.

Objective:
Inspect the authoritative design templates, mockups, and guides for Milestone 3 screens:
1. `design/screens/02_library/` (`screen.html` and mockups)
   - Top bar: Search button and Settings button layout, header title "Library" in Newsreader serif.
   - Continue Reading hero card: dimensions, 2:3 aspect ratio book cover (96×144) with shadow, progress bar, percentage, "Resume" pill button.
   - Recent books horizontal carousel: item layout, mini circular progress rings (e.g. 24dp diameter, stroke 3), title, author.
   - Filter chips row: horizontal scrollable chips (`All`, `Reading`, `To read`, `Finished`, `Favorites`, `Collections ▾`), active vs inactive styling, count badges, trailing Sort button.
   - 3-column book grid: item cards, 2:3 cover ratio, percent progress overlay badge, title in Newsreader, author in Inter.
   - Extended pill FAB: position, shape (`StadiumBorder()`), background color `#2F4A7A`, icon `+`, label "Import".
2. `design/screens/02b_empty_library/` (`screen.html` and mockups)
   - Centered image asset: `assets/images/empty_library_shelf.png`.
   - Headline: "Your library is empty" in Newsreader. Subtitle in Inter.
   - Dual buttons: "Import files" (filled primary pill `#2F4A7A`) & "Import a folder" (outlined pill with hairline border `#E8E2D9`).
3. `design/screens/02c_filter_sort_sheet/` (`screen.html` and mockups)
   - Bottom sheet styling: radius 24px, drag handle.
   - Sort section: radio rows (Recent, Title, Author, Progress).
   - Format filter chips: multi-select pills (`EPUB`, `PDF`, `TXT`, `MD`, `FB2`).
   - Categories / collections multi-select or filter.
   - Grid / list layout toggle.
   - Sticky bottom action: "Apply" primary pill.
4. `design/screens/02d_book_details/` (`screen.html` and mockups)
   - Top metadata header: cover, title in Newsreader, author, format, file size, pages/reading time.
   - Action row: 4 pill buttons (`Read`, `Add to Collection`, `Edit`, `Share`).
   - Metadata grid: format, added date, last read date, reading status.
   - Destructive action: "Move to Trash" outlined red button (`#BA1A1A`).

Extract all exact CSS values, dimensions, hex codes, typography rules, corner radii, and padding. Deliver a complete specification in `handoff.md` and notify parent via `send_message`. Do NOT modify code.

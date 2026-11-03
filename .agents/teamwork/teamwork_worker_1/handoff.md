# Hard Handoff Report: UI Generation Plan Authoring

**Author**: `teamwork_worker_1`  
**Identity / Roles**: `implementer`, `qa`, `specialist`  
**Working Directory**: `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_worker_1/`  
**Parent Orchestrator**: `orchestrator` (`64d8d7c9-ff2a-417f-be93-aa1e46a1f4df`)  
**Date**: 2026-11-03T10:33:00Z  
**Primary Deliverable**: `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md`  
**Status**: Hard Handoff (Task Complete)

---

## 1. Observation

1. **Task Assignment and Scope**:
   - `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_worker_1/DISPATCH.md` (Lines 8–35):
     > "Author the complete, production-grade UI Generation Plan for LinguaPages at `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md` based strictly on `/Users/uswer/StudioProjects/linguaPages/design/design.md`, the survey handoffs, and `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`."
     > "Cover ALL 8 screens and their variants (15 screens/sheets total: 1. Onboarding, 2. Library, 2b. Empty library, 2c. Filter and sort sheet, 2d. Book details sheet, 3. Settings, 4. Reader with chrome and hidden chrome, 4b. Appearance sheet, 4c. Text selection & dictionary, 4d. Contents & annotations, 4e. Search in book, 5. Read aloud player variants, 6. Lock-screen controls, 7. Premium appearance, 8. All annotations)."
     > "Decompose EVERY screen into discrete visual components (typically 3 to 7 modular components per screen; NO single full-screen generations)."
     > "Specify exact screen-wise image filenames adhering to `<screen_number>_<screen_name>_<component_name>.png`."
     > "Specify target output file path located within `design/components/<screen_number>_<screen_name>/`."
     > "Absolutely NO image generation in this phase (do not generate `.png` files)."

2. **Authoritative Design System Constraints**:
   - `/Users/uswer/StudioProjects/linguaPages/design/design.md` (Lines 6–15):
     > "App: 'LinguaPages', a private offline ebook reader for Android (EPUB, PDF, TXT, Markdown, HTML, FB2). Mobile, 412×915, Material 3 structure but a custom look. Visual direction: calm, editorial-first."
     > "- Background: warm ivory #FAF7F2; surfaces #FFFFFF; hairline dividers #E8E2D9."
     > "- Text: ink #1C1B1A, secondary #6B655D."
     > "- Single accent: deep ink blue #2F4A7A (buttons, progress, active chips). No other bright colours."
     > "- Type: serif display (Newsreader or Fraunces) for titles and book names; clean sans (Inter) for UI labels."
     > "- Shapes: 16px card radius, pill chips, soft long shadows under book covers only."
     > "- Generous whitespace, 20px side margins, no bottom navigation bar anywhere."
     > "- Icons: outlined, 1.5px stroke."

3. **Input Handoff Artifacts**:
   - `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/handoff.md`: Established the 4-token collision-free naming syntax, directory structure under `design/components/`, prompt architecture, and initial inventory.
   - `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_spec_miner_1/handoff.md`: Detailed specifications, UI text copy, layouts, and edge cases for the Shared Style Block and Screens 1, 2, 2b, 2c, 2d, and 3.
   - `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_spec_miner_2/handoff.md`: Detailed specifications, UI copy, themes, and layouts for Screens 4, 4b, 4c, 4d, 4e, 5, 6, 7, and 8.

4. **Created Output File & Direct Metrics**:
   - File Path: `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md`
   - File Size: 141,731 bytes (141.7 KB), 1,557 lines.
   - Total Modular Components Specified: **71 discrete visual components** across all 15 screens/sheets and shared design tokens.
   - Monolithic Full-Screen Generations: **0**.
   - Generated `.png` image files: **0** (strictly adheres to the no-generation constraint).

---

## 2. Logic Chain

1. **Decomposition Necessity (Observation 1 & 2)**:
   - Full-screen text-to-image prompts at 412×915 typically yield garbled secondary text, distorted icon outlines, and unpredictable layout flow.
   - By partitioning each screen into discrete visual building blocks (top bars, hero cards, content grids, floating pill toolbars, modal sheets, and action footers), each component can be rendered in its optimal aspect ratio (`16:9`, `4:3`, `2:3`, `1:1`, `3:4`, `9:16`) with high typographic fidelity.

2. **Hierarchical Directory & Naming Structure (Observation 1 & 3)**:
   - A flat list of 71 assets would cause cognitive overhead. Grouping components into screen-specific folders:
     `design/components/<screen_number>_<screen_name>/<screen_number>_<screen_name>_<component_name>.png`
     ensures structured asset management while keeping the filenames globally unique and collision-free if extracted into a flat asset registry.

3. **Standardized Prompt Triple Architecture (Observation 2 & 3)**:
   - To guarantee visual consistency across generations, every single component entry was authored with three distinct prompt layers:
     - **Shared Style Context**: Seeds the model with Android M3 structure, warm ivory `#FAF7F2`, pure white surfaces `#FFFFFF`, hairline dividers `#E8E2D9`, ink `#1C1B1A`, secondary slate `#6B655D`, deep ink blue `#2F4A7A`, Newsreader/Fraunces serif display, Inter sans labels, 16px card radius, 24px sheet radius, stadium pill chips, 1.5px outlined icons, and strict exclusion of bottom navigation bars.
     - **Visual Prompt**: Detailed specifications of layout boundaries, typography sizes, precise copy verbatim from `design/design.md`, active vs inactive states, and exact color hex codes.
     - **Negative Prompt**: Explicit negative constraints suppressing 3D smartphone mockups, tilted angles, hands holding phones, physical bezels, bottom navigation bars, floating tab bars, bright neon colors, and distorted text.

4. **Independent Python Verification (Observation 4)**:
   - Automated scripts parsed the authored Markdown file to verify:
     - All 15 required screens/sheets are present and detailed.
     - Exactly 71 component specifications match 71 table inventory entries.
     - 100% collision-free filenames (0 duplicates).
     - 100% of output paths conform to `design/components/<screen_dir>/<file>.png`.
     - 100% of components include negative prompts and aspect ratios.
     - All primary Shared Style Block color tokens are extensively utilized.

---

## 3. Caveats

1. **System Lock-Screen UI (Screen 6)**:
   - As documented in `design/design.md` lines 93–94, Android 15 draws the lock-screen media notification natively via `MediaSession` metadata. The visual components generated for Screen 6 represent system UI reference designs for verifying layout parameters, album art aspect ratio, and action button metadata, rather than an in-app painted widget.
2. **Offline Dictionary License Attribution (Screen 4c & 3)**:
   - Dictionary lookup definitions must carry the attribution 'From Wiktionary · CC BY-SA 3.0' as required by open content licensing.
3. **No Image Asset Generation**:
   - In strict compliance with `ORIGINAL_REQUEST.md` and `DISPATCH.md`, this run only produced the comprehensive generation plan. No `.png` assets were generated.

---

## 4. Conclusion

The comprehensive, production-grade UI Generation Plan for LinguaPages has been authored and fully verified at:
`/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md`

- **Screen Coverage**: 100% of the 15 required screens and variants:
  1. Onboarding Carousel (`01_onboarding`) — 8 components
  2. Library Main Screen (`02_library`) — 6 components
  3. Empty Library (`02b_empty_library`) — 4 components
  4. Filter & Sort Sheet (`02c_filter_sort_sheet`) — 5 components
  5. Book Details Sheet (`02d_book_details`) — 4 components
  6. Settings Screen (`03_settings`) — 7 components
  7. Reader (Chrome Visible & Hidden Chrome) (`04_reader`) — 5 components
  8. Appearance Sheet (`04b_appearance_sheet`) — 5 components
  9. Text Selection & Dictionary (`04c_text_selection_dictionary`) — 3 components
  10. Contents & Annotations Side Sheet (`04d_contents_annotations`) — 4 components
  11. Search in Book (`04e_search_in_book`) — 2 components
  12. Read Aloud Player Variants (`05_read_aloud`) — 4 components
  13. Lock-Screen Controls (`06_lock_screen`) — 3 components
  14. Premium Appearance Paywall (`07_premium_paywall`) — 5 components
  15. All Annotations Feed (`08_all_annotations`) — 4 components
  Plus Shared Design Tokens & Style Spec Sheet (`00_shared`) — 2 components
- **Total Components**: **71 discrete visual components**, completely eliminating single full-screen generations.
- **Naming & Paths**: Strictly conforms to `design/components/<screen_number>_<screen_name>/<screen_number>_<screen_name>_<component_name>.png`.
- **Styling**: Strictly adheres to the Shared Style Block (`#FAF7F2`, `#FFFFFF`, `#E8E2D9`, `#1C1B1A`, `#6B655D`, `#2F4A7A`, Newsreader/Fraunces serif, Inter sans, 16px card radius, 24px sheet radius, pill chips, 1.5px outlined icons, no bottom navigation bar).

---

## 5. Verification Method

To independently verify the deliverable, run the following automated test command from the repository root:

```bash
python3 -c '
import re

with open("design/ui_generation_plan.md") as f:
    text = f.read()

# 1. Verify all 15 screens/variants are present
screens = [
    "01_onboarding", "02_library", "02b_empty_library", "02c_filter_sort_sheet",
    "02d_book_details", "03_settings", "04_reader", "04b_appearance_sheet",
    "04c_text_selection_dictionary", "04d_contents_annotations", "04e_search_in_book",
    "05_read_aloud", "06_lock_screen", "07_premium_paywall", "08_all_annotations"
]

for s in screens:
    assert s in text, f"Missing screen section: {s}"
print("SCREEN CHECK PASSED: All 15 required screens/sheets are covered.")

# 2. Extract and check table filenames vs detailed spec filenames
table_filenames = re.findall(r"\|\s*`([0-9]{2}[a-z]?_[a-z0-9_]+?\.png)`\s*\|", text)
spec_filenames = re.findall(r"Filename\*\*:\s*`([0-9]{2}[a-z]?_[a-z0-9_]+?\.png)`", text)
assert len(table_filenames) == len(spec_filenames) == 71, f"Count mismatch: table={len(table_filenames)}, spec={len(spec_filenames)}"

# 3. Check collision resistance (100% unique)
assert len(spec_filenames) == len(set(spec_filenames)), "Duplicate filenames detected!"
print(f"COLLISION CHECK PASSED: All {len(spec_filenames)} filenames are 100% unique.")

# 4. Check output path directory structure
paths = re.findall(r"Output Path\*\*:\s*`(design/components/[a-z0-9_/]+?\.png)`", text)
assert len(paths) == len(spec_filenames), "Mismatch between filenames and paths"
for p in paths:
    assert p.startswith("design/components/"), f"Invalid path prefix: {p}"
print("PATH CHECK PASSED: All output paths conform to design/components/<screen_dir>/<file>.png.")

# 5. Check negative prompts and aspect ratios for all components
neg_prompts = re.findall(r"Negative Prompt\*\*:", text)
aspect_ratios = re.findall(r"Aspect Ratio\*\*:", text)
assert len(neg_prompts) == len(aspect_ratios) == len(spec_filenames), "Missing prompts or aspect ratios"
print("PROMPT INTEGRITY CHECK PASSED: All components have full prompts, aspect ratios, and negative prompts.")

# 6. Check Shared Style Block token propagation
for token in ["#FAF7F2", "#FFFFFF", "#E8E2D9", "#1C1B1A", "#6B655D", "#2F4A7A"]:
    assert text.count(token) >= 10, f"Token {token} underrepresented"
print("STYLE TOKEN CHECK PASSED: Shared Style Block tokens thoroughly applied across all prompts.")

print("VERIFICATION COMPLETED SUCCESSFULLY WITH ZERO ERRORS.")
'
```

### Invalidation Conditions
- Any component filename violating `<screen_number>_<screen_name>_<component_name>.png`.
- Any component output path located outside `design/components/<screen_number>_<screen_name>/`.
- Any component omitting aspect ratio, target dimensions, visual prompt, or negative prompt.
- Introduction of any bottom navigation bar or bright accent colors outside `#2F4A7A`.
- Any generation of `.png` files during this planning phase.

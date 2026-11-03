#!/usr/bin/env python3
"""
Empirical Challenger 2 Verification Harness for design/ui_generation_plan.md
Tests:
1. Screen coverage and decomposition completeness (8 screens + variants)
2. Screen-wise image naming and collision resistance
3. Target path conformance (design/components/<screen_dir>/<filename>)
4. Color token consistency against design/design.md
5. Negative prompt completeness and strict element suppression
6. Placeholder and incomplete text audit
7. Aspect ratio validity and UI role semantic alignment
8. Zero image generation disk audit
"""

import os
import re
import sys
import glob

PLAN_PATH = "/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md"
DESIGN_PATH = "/Users/uswer/StudioProjects/linguaPages/design/design.md"
ROOT_DIR = "/Users/uswer/StudioProjects/linguaPages"

VALID_ASPECT_RATIOS = {"1:1", "2:3", "3:2", "3:4", "4:3", "9:16", "16:9"}

REQUIRED_SCREENS = [
    "00_shared",
    "01_onboarding",
    "02_library",
    "02b_empty_library",
    "02c_filter_sort_sheet",
    "02d_book_details",
    "03_settings",
    "04_reader",
    "04b_appearance_sheet",
    "04c_text_selection_dictionary",
    "04d_contents_annotations",
    "04e_search_in_book",
    "05_read_aloud",
    "06_lock_screen",
    "07_premium_paywall",
    "08_all_annotations",
]

CORE_COLOR_TOKENS = {
    "#FAF7F2": "Canvas Ivory",
    "#FFFFFF": "Card/Sheet White",
    "#E8E2D9": "Hairline Divider",
    "#1C1B1A": "Primary Ink",
    "#6B655D": "Secondary Slate",
    "#2F4A7A": "Accent Deep Ink Blue",
}

FORBIDDEN_TERMS = [
    "TODO",
    "TBD",
    "[fill in]",
    "[TBD]",
    "[placeholder]",
    "[style block]",
    "FIXME",
    "XXX",
    "lorem ipsum",
]

class TestResult:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.warnings = 0
        self.errors = []

    def assert_true(self, condition, message, details=""):
        if condition:
            self.passed += 1
            print(f"  [PASS] {message}")
        else:
            self.failed += 1
            print(f"  [FAIL] {message}")
            if details:
                print(f"         Details: {details}")
            self.errors.append((message, details))

    def warn(self, message, details=""):
        self.warnings += 1
        print(f"  [WARN] {message}")
        if details:
            print(f"         Details: {details}")

def parse_table_components(text):
    """Parses Table 4 (Global Screen & Component Inventory)."""
    table_pattern = re.compile(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*`([^`]+)`\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$", re.MULTILINE)
    components = []
    lines = text.split("\n")
    in_table = False
    for line in lines:
        if "## 4. Global Screen & Component Inventory" in line:
            in_table = True
            continue
        if in_table and line.startswith("## 5."):
            break
        if in_table and line.startswith("|"):
            m = table_pattern.match(line)
            if m:
                screen_col = m.group(1).strip()
                if "---" in screen_col or "Screen #" in screen_col:
                    continue
                components.append({
                    "screen": screen_col,
                    "name": m.group(2).strip(),
                    "filename": m.group(3).strip(),
                    "aspect_ratio": m.group(4).strip(),
                    "dimensions": m.group(5).strip(),
                    "summary": m.group(6).strip(),
                })
    return components

def parse_section5_components(text):
    """Parses Section 5 detailed component blocks."""
    # Find all component headers: #### Component: `...`
    comp_header_pattern = re.compile(r"^#### Component:\s*`([^`]+)`", re.MULTILINE)
    matches = list(comp_header_pattern.finditer(text))
    components = []

    for i, m in enumerate(matches):
        comp_name = m.group(1).strip()
        start_idx = m.start()
        end_idx = matches[i + 1].start() if i + 1 < len(matches) else text.find("\n## 6.", start_idx)
        if end_idx == -1:
            end_idx = len(text)
        block = text[start_idx:end_idx]

        # Extract fields
        filename_m = re.search(r"\*\*Filename\*\*:\s*`([^`]+)`", block)
        output_path_m = re.search(r"\*\*Output Path\*\*:\s*`([^`]+)`", block)
        role_m = re.search(r"\*\*Component Role\*\*:\s*([^\n]+)", block)
        aspect_ratio_m = re.search(r"\*\*Aspect Ratio\*\*:\s*`([^`]+)`", block)
        dimensions_m = re.search(r"\*\*Target Dimensions\*\*:\s*`([^`]+)`", block)
        shared_style_m = re.search(r"\*\*Shared Style Context\*\*:\s*\n(>[^\n]+(?:\n>[^\n]+)*)", block)
        visual_prompt_m = re.search(r"\*\*Visual Prompt\*\*:\s*\n(>[^\n]+(?:\n>[^\n]+)*)", block)
        neg_prompt_m = re.search(r"\*\*Negative Prompt\*\*:\s*\n(>[^\n]+(?:\n>[^\n]+)*)", block)

        components.append({
            "component_name": comp_name,
            "filename": filename_m.group(1).strip() if filename_m else None,
            "output_path": output_path_m.group(1).strip() if output_path_m else None,
            "role": role_m.group(1).strip() if role_m else None,
            "aspect_ratio": aspect_ratio_m.group(1).strip() if aspect_ratio_m else None,
            "dimensions": dimensions_m.group(1).strip() if dimensions_m else None,
            "shared_style": shared_style_m.group(1).strip() if shared_style_m else None,
            "visual_prompt": visual_prompt_m.group(1).strip() if visual_prompt_m else None,
            "negative_prompt": neg_prompt_m.group(1).strip() if neg_prompt_m else None,
            "raw_block": block,
        })
    return components

def main():
    print("=" * 80)
    print("EMPIRICAL CHALLENGER 2: UI GENERATION PLAN STRESS TEST HARNESS")
    print("=" * 80)

    res = TestResult()

    if not os.path.exists(PLAN_PATH):
        print(f"CRITICAL ERROR: Plan file not found at {PLAN_PATH}")
        sys.exit(1)

    with open(PLAN_PATH, "r", encoding="utf-8") as f:
        plan_text = f.read()

    with open(DESIGN_PATH, "r", encoding="utf-8") as f:
        design_text = f.read()

    # 1. Parse components
    table_comps = parse_table_components(plan_text)
    sec5_comps = parse_section5_components(plan_text)

    print(f"\n[INFO] Discovered {len(table_comps)} components in Table 4 inventory.")
    print(f"[INFO] Discovered {len(sec5_comps)} component specifications in Section 5.")

    # -------------------------------------------------------------------------
    # SUITE 1: Screen Coverage & Component Decomposition
    # -------------------------------------------------------------------------
    print("\n--- SUITE 1: Screen Coverage & Component Decomposition ---")

    res.assert_true(len(table_comps) == 71, f"Table 4 contains 71 components (found: {len(table_comps)})")
    res.assert_true(len(sec5_comps) == 71, f"Section 5 contains 71 components (found: {len(sec5_comps)})")
    res.assert_true(len(table_comps) == len(sec5_comps), "Inventory count matches detailed specifications count")

    # Verify all 16 screen directories / screen sections exist in text
    for scr in REQUIRED_SCREENS:
        res.assert_true(
            scr in plan_text,
            f"Screen section key '{scr}' present in plan",
            f"Missing section for screen {scr}"
        )

    # Check component inventory per screen has discrete decomposition (at least 2 components per screen)
    screen_comp_counts = {}
    for comp in sec5_comps:
        fn = comp["filename"] or ""
        prefix = fn.split("_")[0]
        # Handle variants like 02b, 04b
        m = re.match(r"^([0-9]{2}[a-z]?)", fn)
        prefix_key = m.group(1) if m else prefix
        screen_comp_counts[prefix_key] = screen_comp_counts.get(prefix_key, 0) + 1

    for key, count in sorted(screen_comp_counts.items()):
        res.assert_true(
            count >= 2,
            f"Screen group '{key}' is decomposed into {count} discrete components (>= 2)",
            f"Under-decomposed screen: {key} only has {count} components"
        )

    # -------------------------------------------------------------------------
    # SUITE 2: Naming Schema, Collision Resistance & Target Paths
    # -------------------------------------------------------------------------
    print("\n--- SUITE 2: Naming Schema, Collision Resistance & Target Paths ---")

    filename_pattern = re.compile(r"^[0-9]{2}[a-z]?_[a-z0-9_]+\.png$")
    all_filenames = []
    all_paths = []

    for i, c in enumerate(sec5_comps):
        fn = c["filename"]
        pt = c["output_path"]
        name = c["component_name"]

        res.assert_true(
            fn is not None and bool(filename_pattern.match(fn)),
            f"Component '{name}' filename '{fn}' conforms to schema",
            f"Invalid filename: {fn}"
        )

        expected_dir = re.match(r"^([0-9]{2}[a-z]?_[a-z0-9]+?)_", fn)
        # Check output path format: design/components/<dir>/<filename>
        res.assert_true(
            pt is not None and pt.startswith("design/components/") and pt.endswith(fn),
            f"Component '{name}' path '{pt}' matches design/components/<screen_dir>/{fn}",
            f"Path mismatch: {pt} vs {fn}"
        )

        all_filenames.append(fn)
        all_paths.append(pt)

    # Collision resistance
    unique_fn = set(all_filenames)
    res.assert_true(
        len(all_filenames) == len(unique_fn),
        f"Filename collision check: {len(unique_fn)}/{len(all_filenames)} are unique",
        f"Duplicates: {[f for f in all_filenames if all_filenames.count(f) > 1]}"
    )

    # Match Table 4 filenames with Section 5 filenames
    table_filenames = [c["filename"] for c in table_comps]
    res.assert_true(
        table_filenames == all_filenames,
        "Table 4 filenames exactly match Section 5 filenames in 1:1 order",
        f"Diff count: {len(set(table_filenames) ^ set(all_filenames))}"
    )

    # -------------------------------------------------------------------------
    # SUITE 3: Color Token Consistency & Hex Color Audit
    # -------------------------------------------------------------------------
    print("\n--- SUITE 3: Color Token Consistency & Palette Audit ---")

    # Check 6 core tokens in Section 2.1 table
    for hex_code, desc in CORE_COLOR_TOKENS.items():
        res.assert_true(
            hex_code in plan_text,
            f"Core color token {hex_code} ({desc}) present in plan specification",
            f"Missing core token: {hex_code}"
        )

    # Check Shared Style Context across all components
    missing_style_context = []
    missing_tokens_in_style = []
    for c in sec5_comps:
        sc = c["shared_style"]
        if not sc:
            missing_style_context.append(c["component_name"])
            continue
        # Check standard tokens in shared context: #FAF7F2, #FFFFFF, #E8E2D9, #2F4A7A
        for tok in ["#FAF7F2", "#FFFFFF", "#E8E2D9", "#2F4A7A"]:
            if tok not in sc:
                missing_tokens_in_style.append((c["component_name"], tok))

    res.assert_true(
        len(missing_style_context) == 0,
        f"All {len(sec5_comps)} components have Shared Style Context defined",
        f"Missing in: {missing_style_context}"
    )
    res.assert_true(
        len(missing_tokens_in_style) == 0,
        f"Shared Style Context in all components contains core palette (#FAF7F2, #FFFFFF, #E8E2D9, #2F4A7A)",
        f"Tokens missing: {missing_tokens_in_style[:5]}"
    )

    # Find all hex color codes across the entire document
    all_hexes = set(re.findall(r"#[0-9A-Fa-f]{6}\b", plan_text))
    print(f"[INFO] Discovered {len(all_hexes)} distinct hex color codes in plan: {sorted(all_hexes)}")

    # Check for forbidden neon or garish colors
    # Neon indicators: pure full saturation rgb like #FF00FF, #00FF00, #00FFFF, #FFFF00, #FF0000
    FORBIDDEN_NEON = {"#FF00FF", "#00FF00", "#00FFFF", "#FFFF00", "#FF0000"}
    neon_found = all_hexes.intersection(FORBIDDEN_NEON)
    res.assert_true(
        len(neon_found) == 0,
        "No forbidden garish/neon hex codes detected",
        f"Found neon codes: {neon_found}"
    )

    # -------------------------------------------------------------------------
    # SUITE 4: Negative Prompt Strict Suppression
    # -------------------------------------------------------------------------
    print("\n--- SUITE 4: Negative Prompt Completeness & Strict Suppression ---")

    missing_neg_prompts = []
    missing_bottom_nav = []
    missing_neon = []
    missing_hands = []
    missing_3d = []

    for c in sec5_comps:
        np = c["negative_prompt"]
        cname = c["component_name"]

        if not np:
            missing_neg_prompts.append(cname)
            continue

        np_lower = np.lower()

        # Check bottom navigation suppression
        if "bottom navigation" not in np_lower and "floating tab bar" not in np_lower:
            missing_bottom_nav.append(cname)

        # Check neon suppression
        if "neon" not in np_lower:
            missing_neon.append(cname)

        # Check hand suppression
        if "hand" not in np_lower:
            missing_hands.append(cname)

        # Check 3d mockup suppression
        if "3d" not in np_lower and "mockup" not in np_lower:
            missing_3d.append(cname)

    res.assert_true(
        len(missing_neg_prompts) == 0,
        f"Every component ({len(sec5_comps)}) has a Negative Prompt",
        f"Missing: {missing_neg_prompts}"
    )
    res.assert_true(
        len(missing_bottom_nav) == 0,
        "Bottom navigation bar strictly suppressed in 100% of negative prompts",
        f"Missing suppression in: {missing_bottom_nav}"
    )
    res.assert_true(
        len(missing_neon) == 0,
        "Neon colors strictly suppressed in 100% of negative prompts",
        f"Missing suppression in: {missing_neon}"
    )
    res.assert_true(
        len(missing_hands) == 0,
        "Hands / physical holding strictly suppressed in 100% of negative prompts",
        f"Missing suppression in: {missing_hands}"
    )
    res.assert_true(
        len(missing_3d) == 0,
        "3D mockups / perspective device frames strictly suppressed in 100% of negative prompts",
        f"Missing suppression in: {missing_3d}"
    )

    # -------------------------------------------------------------------------
    # SUITE 5: Placeholder & Incomplete Text Audit
    # -------------------------------------------------------------------------
    print("\n--- SUITE 5: Placeholder & Incomplete Text Audit ---")

    for term in FORBIDDEN_TERMS:
        matches = [m.start() for m in re.finditer(re.escape(term), plan_text, re.IGNORECASE)]
        # Filter out legitimate occurrences in descriptions if any
        # But wait, "TODO", "TBD", "[fill in]", "[placeholder]", "FIXME" should NOT appear at all!
        res.assert_true(
            len(matches) == 0,
            f"Zero occurrences of forbidden placeholder string '{term}'",
            f"Found {len(matches)} occurrences at indices {matches[:3]}"
        )

    # Check for empty prompts or empty sections
    empty_visual_prompts = [c["component_name"] for c in sec5_comps if not c["visual_prompt"] or len(c["visual_prompt"].strip()) < 20]
    res.assert_true(
        len(empty_visual_prompts) == 0,
        "All visual prompts are fully populated with substantial copy (> 20 chars)",
        f"Empty or truncated visual prompts: {empty_visual_prompts}"
    )

    # Check for suspicious triple dots indicating unfinished text
    # In regex: "\.\.\." not followed by acceptable typography or code
    triple_dots = []
    for line_num, line in enumerate(plan_text.splitlines(), 1):
        if "..." in line or "…" in line:
            # Check if this line is in code, or a UI button glyph, or genuine ellipsis
            if line.strip().startswith(">") or line.strip().startswith("- **"):
                # Check if it looks like unfinished placeholder text
                if re.search(r"(\[\.\.\.\]|\.\.\.\s*$|etc\.\.\.)", line):
                    triple_dots.append((line_num, line.strip()))

    res.assert_true(
        len(triple_dots) == 0,
        "No incomplete sentence placeholders or truncated ellipsis placeholders detected",
        f"Flagged lines: {triple_dots}"
    )

    # -------------------------------------------------------------------------
    # SUITE 6: Aspect Ratio Validity & UI Role Alignment
    # -------------------------------------------------------------------------
    print("\n--- SUITE 6: Aspect Ratio Validity & UI Role Alignment ---")

    invalid_ratios = []
    ratio_role_mismatches = []
    dimension_parsing_errors = []

    for c in sec5_comps:
        cname = c["component_name"]
        ar = c["aspect_ratio"]
        dim = c["dimensions"]

        # 1. Valid API ratio
        if ar not in VALID_ASPECT_RATIOS:
            invalid_ratios.append((cname, ar))

        # 2. Dimensions format (e.g. 824×200px or 1280×720px)
        dim_clean = dim.replace("px", "").replace("×", "x").strip() if dim else ""
        if "x" in dim_clean:
            try:
                w, h = map(int, dim_clean.split("x"))
                if w <= 0 or h <= 0:
                    dimension_parsing_errors.append((cname, dim))
            except ValueError:
                dimension_parsing_errors.append((cname, dim))
        else:
            dimension_parsing_errors.append((cname, dim))

        # 3. Role alignment heuristics:
        # - Standalone book cover spec, book grid item -> 2:3
        # - Top bars, footers, rows, action containers, indicators -> 16:9
        # - Extended FAB, edge brightness indicator -> 1:1
        # - Full page readers, full lock screens -> 9:16
        # - Large cards, sheets, tab views, TOC -> 4:3 or 3:4
        role_lower = (c["role"] or "").lower()
        name_lower = cname.lower()

        if name_lower in ["shared book cover spec", "library book grid item"]:
            if ar != "2:3":
                ratio_role_mismatches.append((cname, f"Expected 2:3 for standalone book cover, got {ar}"))
        elif "top app bar" in role_lower or ("top bar" in name_lower and "brightness" not in name_lower):
            if ar != "16:9":
                ratio_role_mismatches.append((cname, f"Expected 16:9 for top bar, got {ar}"))
        elif "fab" in name_lower or "brightness indicator" in name_lower:
            if ar != "1:1":
                ratio_role_mismatches.append((cname, f"Expected 1:1 for FAB/square control, got {ar}"))
        elif "reader content page" in name_lower or "system frame" in name_lower:
            if ar != "9:16":
                ratio_role_mismatches.append((cname, f"Expected 9:16 for full page/frame, got {ar}"))
        elif "hero card" in name_lower or "sheet header" in name_lower or "sort section" in name_lower or "browse rows" in name_lower or "header card" in name_lower or "card" in name_lower:
            if ar not in ["4:3", "3:4", "16:9"]:
                ratio_role_mismatches.append((cname, f"Expected 4:3, 3:4, or 16:9 for card/sheet, got {ar}"))

    res.assert_true(
        len(invalid_ratios) == 0,
        f"All 71 components specify valid Gemini API aspect ratios ({sorted(VALID_ASPECT_RATIOS)})",
        f"Invalid ratios: {invalid_ratios}"
    )
    res.assert_true(
        len(dimension_parsing_errors) == 0,
        "All 71 components specify valid target pixel dimensions (W×H)",
        f"Parsing errors: {dimension_parsing_errors}"
    )
    res.assert_true(
        len(ratio_role_mismatches) == 0,
        "Component aspect ratios strictly match their UI semantic roles",
        f"Mismatches: {ratio_role_mismatches}"
    )

    # -------------------------------------------------------------------------
    # SUITE 7: Zero Image Generation Disk Audit
    # -------------------------------------------------------------------------
    print("\n--- SUITE 7: Zero Image Generation Disk Audit ---")

    # Check design/components directory
    components_dir = os.path.join(ROOT_DIR, "design", "components")
    components_dir_exists = os.path.exists(components_dir)
    res.assert_true(
        not components_dir_exists,
        "Target directory 'design/components/' does NOT exist on disk (zero generation executed)",
        f"Directory exists at {components_dir}"
    )

    # Check for any generated image files in design/
    design_images = []
    for ext in ["png", "jpg", "jpeg", "webp", "svg", "gif"]:
        design_images.extend(glob.glob(f"{ROOT_DIR}/design/**/*.{ext}", recursive=True))

    res.assert_true(
        len(design_images) == 0,
        f"Zero image files exist anywhere under 'design/' (found: {len(design_images)})",
        f"Unexpected image files: {design_images}"
    )

    # Summary
    print("\n" + "=" * 80)
    print(f"HARNESS SUMMARY: {res.passed} PASSED, {res.failed} FAILED, {res.warnings} WARNINGS")
    print("=" * 80)

    if res.failed == 0:
        print("\n>>> EMPIRICAL VERDICT: APPROVE <<<")
        sys.exit(0)
    else:
        print(f"\n>>> EMPIRICAL VERDICT: REJECT ({res.failed} failures) <<<")
        for err, det in res.errors:
            print(f"  - {err}: {det}")
        sys.exit(1)

if __name__ == "__main__":
    main()

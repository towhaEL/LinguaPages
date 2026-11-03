#!/usr/bin/env python3
"""
Verification and empirical stress-test harness for LinguaPages UI Component Generation Plan.
Verifies design/ui_generation_plan.md against requirements in design/design.md and ORIGINAL_REQUEST.md.
"""

import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DOC_PATH = REPO_ROOT / "design" / "ui_generation_plan.md"
DESIGN_SPEC_PATH = REPO_ROOT / "design" / "design.md"

# 15 required screens/variants from design.md & ORIGINAL_REQUEST.md
REQUIRED_SCREENS = [
    ("01", "Onboarding", "onboarding"),
    ("02", "Library", "library"),
    ("02b", "Empty Library", "empty_library"),
    ("02c", "Filter and Sort Sheet", "filter_sort_sheet"),
    ("02d", "Book Details Sheet", "book_details"),
    ("03", "Settings", "settings"),
    ("04", "Reader with chrome and hidden chrome", "reader"),
    ("04b", "Appearance Sheet", "appearance_sheet"),
    ("04c", "Text Selection & Dictionary", "text_selection_dictionary"),
    ("04d", "Contents & Annotations", "contents_annotations"),
    ("04e", "Search in Book", "search_in_book"),
    ("05", "Read Aloud Player Variants", "read_aloud"),
    ("06", "Lock-Screen Controls", "lock_screen"),
    ("07", "Premium Appearance", "premium_paywall"),
    ("08", "All Annotations", "all_annotations"),
]


def test_file_exists():
    print("--- Test 1: File Existence ---")
    assert DOC_PATH.exists(), f"File {DOC_PATH} does not exist!"
    size = DOC_PATH.stat().st_size
    print(f"PASS: {DOC_PATH} exists ({size:,} bytes).")


def test_filesystem_no_images_generated():
    print("\n--- Test 2: Filesystem Zero Image Generation Check ---")
    components_dir = REPO_ROOT / "design" / "components"
    if components_dir.exists():
        images = list(components_dir.glob("**/*.png")) + \
                 list(components_dir.glob("**/*.jpg")) + \
                 list(components_dir.glob("**/*.jpeg")) + \
                 list(components_dir.glob("**/*.webp"))
        assert len(images) == 0, f"FAIL: Found {len(images)} generated images in {components_dir}: {images}"
        print(f"PASS: {components_dir} exists but contains 0 image files.")
    else:
        print(f"PASS: {components_dir} does not exist. 0 image files generated.")

    # Also check git status for untracked image files in design/
    design_dir = REPO_ROOT / "design"
    design_images = [f for f in design_dir.glob("**/*") if f.suffix.lower() in [".png", ".jpg", ".jpeg", ".webp"] and f.is_file()]
    assert len(design_images) == 0, f"FAIL: Found images in design/: {design_images}"
    print(f"PASS: No images found anywhere in design/ directory.")


def parse_ui_generation_plan():
    with open(DOC_PATH, "r", encoding="utf-8") as f:
        text = f.read()

    # Split into sections
    return text


def test_all_15_screens_present(content):
    print("\n--- Test 3: Screen Coverage (15 Screens/Variants + Shared) ---")
    # Search for screen headers in section 5
    # Headers format: ### 5.X Screen YY: Name (`dir_name`) or ### 5.0 Shared ...
    screen_header_pattern = re.compile(
        r"###\s+5\.(\d+)\s+(?:Screen\s+([0-9a-z]+):\s+([^\n`]+)|([^\n`]+))\s*\(`([^`]+)`\)",
        re.IGNORECASE
    )

    found_sections = screen_header_pattern.findall(content)
    print(f"Total section 5 subsections found: {len(found_sections)}")
    found_screen_keys = {}
    for idx, screen_num, screen_title_1, screen_title_2, dir_name in found_sections:
        s_num = screen_num.lower() if screen_num else "00"
        s_title = (screen_title_1 or screen_title_2).strip()
        found_screen_keys[s_num] = {
            "index": idx,
            "title": s_title,
            "dir_name": dir_name.strip()
        }
        print(f"  - [{s_num}] {s_title} -> dir: `{dir_name}`")

    # Assert all 15 required screens are present
    missing = []
    for num, name, expected_dir in REQUIRED_SCREENS:
        norm_num = num.lower()
        if norm_num not in found_screen_keys:
            missing.append(f"Screen {num} ({name})")
        else:
            dir_found = found_screen_keys[norm_num]["dir_name"]
            if expected_dir not in dir_found:
                print(f"  WARNING: Screen {num} expected dir '{expected_dir}' vs found '{dir_found}'")

    assert not missing, f"FAIL: Missing required screens: {missing}"
    print(f"PASS: All {len(REQUIRED_SCREENS)} screens and variants are present and accounted for.")


def test_components_specifications(content):
    print("\n--- Test 4: Component Specifications & Parsing ---")

    # Parse components from Section 5
    # Components start with #### Component: `Component Name`
    comp_pattern = re.compile(
        r"####\s+Component:\s*`([^`]+)`\s*\n(.*?)(?=\n####|\n###|\n##|\Z)",
        re.DOTALL
    )

    matches = comp_pattern.findall(content)
    print(f"Total components found in Section 5: {len(matches)}")
    assert len(matches) > 0, "No components found in Section 5!"

    # Also parse Section 4 table rows
    table_pattern = re.compile(
        r"\|\s*\*\*([^*]+)\*\*\s*\|\s*([^|]+)\|\s*`([^`]+)`\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)\|"
    )
    table_rows = table_pattern.findall(content)
    print(f"Total rows in Section 4 Global Inventory table: {len(table_rows)}")

    table_filenames = [row[2].strip() for row in table_rows]

    # Check uniqueness of Section 4 table filenames
    table_filename_counts = {}
    for fn in table_filenames:
        table_filename_counts[fn] = table_filename_counts.get(fn, 0) + 1
    table_duplicates = {fn: c for fn, c in table_filename_counts.items() if c > 1}
    assert not table_duplicates, f"FAIL: Duplicate filenames in Section 4 table: {table_duplicates}"
    print(f"PASS: Section 4 inventory table has {len(table_filenames)} distinct component filenames (0 duplicates).")

    detailed_components = []
    detailed_filenames = []

    # Filename format: <screen_number>_<screen_name>_<component_name>.png
    filename_regex = re.compile(r"^([0-9a-z]+)_([a-z0-9_]+)\.png$")

    valid_aspect_ratios = {"1:1", "2:3", "3:2", "3:4", "4:3", "9:16", "16:9"}

    errors = []

    for comp_name, comp_body in matches:
        # Extract Filename
        fn_match = re.search(r"-\s+\*\*Filename\*\*:\s*`([^`]+)`", comp_body)
        if not fn_match:
            errors.append(f"Component '{comp_name}' missing Filename field")
            continue
        filename = fn_match.group(1).strip()
        detailed_filenames.append(filename)

        # Extract Output Path
        path_match = re.search(r"-\s+\*\*Output Path\*\*:\s*`([^`]+)`", comp_body)
        if not path_match:
            errors.append(f"Component '{comp_name}' missing Output Path field")
            out_path = ""
        else:
            out_path = path_match.group(1).strip()

        # Extract Component Role
        role_match = re.search(r"-\s+\*\*Component Role\*\*:\s*([^\n]+)", comp_body)
        role = role_match.group(1).strip() if role_match else ""

        # Extract Aspect Ratio
        ar_match = re.search(r"-\s+\*\*Aspect Ratio\*\*:\s*`?([0-9]+:[0-9]+)`?", comp_body)
        ar = ar_match.group(1).strip() if ar_match else ""

        # Extract Target Dimensions
        dim_match = re.search(r"-\s+\*\*Target Dimensions\*\*:\s*`?([0-9]+[×x][0-9]+(?:px)?)`?", comp_body)
        dim = dim_match.group(1).strip() if dim_match else ""

        # Extract Visual Prompt
        vp_match = re.search(r"\*\*Visual Prompt\*\*:\s*\n>\s*([^\n]+(?:\n>[^\n]+)*)", comp_body)
        vp = vp_match.group(1).strip() if vp_match else ""

        # Extract Negative Prompt
        np_match = re.search(r"\*\*Negative Prompt\*\*:\s*\n>\s*([^\n]+(?:\n>[^\n]+)*)", comp_body)
        np = np_match.group(1).strip() if np_match else ""

        # Extract Shared Style Context
        sc_match = re.search(r"\*\*Shared Style Context\*\*:\s*\n>\s*([^\n]+(?:\n>[^\n]+)*)", comp_body)
        sc = sc_match.group(1).strip() if sc_match else ""

        comp_dict = {
            "name": comp_name,
            "filename": filename,
            "path": out_path,
            "role": role,
            "aspect_ratio": ar,
            "dimensions": dim,
            "visual_prompt": vp,
            "negative_prompt": np,
            "style_context": sc,
            "body": comp_body
        }
        detailed_components.append(comp_dict)

        # Check filename regex
        if not filename.endswith(".png"):
            errors.append(f"Component '{comp_name}': filename '{filename}' does not end with .png")
        if not filename_regex.match(filename):
            errors.append(f"Component '{comp_name}': filename '{filename}' does not follow <screen_number>_<screen_name>_<component_name>.png format")

        # Check output path: must start with design/components/<screen_dir>/<filename>
        expected_path_prefix = "design/components/"
        if not out_path.startswith(expected_path_prefix):
            errors.append(f"Component '{comp_name}': output path '{out_path}' does not start with '{expected_path_prefix}'")
        elif not out_path.endswith(filename):
            errors.append(f"Component '{comp_name}': output path '{out_path}' filename does not match '{filename}'")
        else:
            rel_parts = out_path[len(expected_path_prefix):].split("/")
            if len(rel_parts) != 2:
                errors.append(f"Component '{comp_name}': output path '{out_path}' must be in subfolder design/components/<screen_dir>/<filename>")

        # Check aspect ratio validity
        if ar not in valid_aspect_ratios:
            errors.append(f"Component '{comp_name}': invalid aspect ratio '{ar}'. Expected one of {valid_aspect_ratios}")

        # Check target dimensions and orientation consistency with aspect ratio
        if not dim:
            errors.append(f"Component '{comp_name}': missing target dimensions")
        else:
            dim_nums = re.findall(r"\d+", dim)
            if len(dim_nums) == 2:
                w, h = int(dim_nums[0]), int(dim_nums[1])
                ar_w, ar_h = [int(x) for x in ar.split(":")]
                if ar_w > ar_h and w <= h:
                    errors.append(f"Component '{comp_name}': aspect ratio {ar} implies landscape, but dimensions are {w}x{h}")
                elif ar_w < ar_h and w >= h:
                    errors.append(f"Component '{comp_name}': aspect ratio {ar} implies portrait, but dimensions are {w}x{h}")
                elif ar_w == ar_h and w != h:
                    errors.append(f"Component '{comp_name}': aspect ratio {ar} implies square, but dimensions are {w}x{h}")

        # Check role
        if not role:
            errors.append(f"Component '{comp_name}': missing component role")

        # Check visual prompt
        if not vp or len(vp) < 20:
            errors.append(f"Component '{comp_name}': visual prompt is missing or too short ({len(vp)} chars)")

        # Check negative prompt
        if not np or len(np) < 10:
            errors.append(f"Component '{comp_name}': negative prompt is missing or too short ({len(np)} chars)")

    assert not errors, f"FAIL: Component specification validation errors:\n" + "\n".join(errors[:20])
    print(f"PASS: All {len(detailed_components)} detailed component specifications have valid filenames, paths, roles, aspect ratios, dimensions, visual prompts, and negative prompts.")

    # Check duplicates across Section 5
    detailed_filename_counts = {}
    for fn in detailed_filenames:
        detailed_filename_counts[fn] = detailed_filename_counts.get(fn, 0) + 1
    detailed_duplicates = {fn: c for fn, c in detailed_filename_counts.items() if c > 1}
    assert not detailed_duplicates, f"FAIL: Duplicate filenames in Section 5: {detailed_duplicates}"
    print(f"PASS: 0 filename collisions across Section 5 ({len(detailed_filenames)} unique filenames).")

    # Cross-check Section 4 vs Section 5
    table_set = set(table_filenames)
    detailed_set = set(detailed_filenames)

    in_table_not_detailed = table_set - detailed_set
    in_detailed_not_table = detailed_set - table_set

    assert not in_table_not_detailed, f"FAIL: Components in Section 4 table but not in Section 5 details: {in_table_not_detailed}"
    assert not in_detailed_not_table, f"FAIL: Components in Section 5 details but not in Section 4 table: {in_detailed_not_table}"

    print(f"PASS: Section 4 inventory ({len(table_set)} items) and Section 5 detailed specs ({len(detailed_set)} items) match 100% identically!")

    return detailed_components


def test_adversarial_stress_testing(content, components):
    print("\n--- Test 5: Adversarial Stress Testing & Prompt Conformance ---")

    # 1. Check for placeholder tokens
    placeholder_tokens = ["TODO", "TBD", "FIXME", "XXX", "PLACEHOLDER", "undefined", "null"]
    found_placeholders = []
    for token in placeholder_tokens:
        matches = re.findall(rf"\b{token}\b", content)
        if matches:
            found_placeholders.append((token, len(matches)))

    # In our BRIEFING we might have TBD, but ui_generation_plan.md should not have unresolved placeholders
    assert not found_placeholders, f"FAIL: Found unresolved placeholder tokens in plan: {found_placeholders}"
    print(f"PASS: Zero placeholder tokens (TODO, TBD, FIXME, etc.) found in document.")

    # 2. Check design tokens adherence across prompts
    # Primary Ink #1C1B1A, Secondary Slate #6B655D, Accent #2F4A7A, Canvas #FAF7F2, Surfaces #FFFFFF
    # Every visual prompt should incorporate the design aesthetic
    non_conforming_prompts = []
    for c in components:
        vp = c["visual_prompt"]
        # Ensure prompts mention key palette or editorial cues
        has_palette_cues = any(tok in vp for tok in ["#FAF7F2", "#FFFFFF", "#1C1B1A", "#2F4A7A", "#6B655D", "ivory", "ink", "editorial", "serif"])
        if not has_palette_cues:
            non_conforming_prompts.append(c["name"])

    if non_conforming_prompts:
        print(f"WARNING: The following {len(non_conforming_prompts)} prompts might lack palette cues: {non_conforming_prompts[:5]}")
    else:
        print(f"PASS: 100% of {len(components)} component visual prompts incorporate design palette and aesthetic cues.")

    # 3. Check for bottom navigation bar prohibition
    # The negative prompts should ban bottom navigation bars, or prompt should not request one
    bottom_nav_violations = []
    for c in components:
        vp = c["visual_prompt"].lower()
        if "bottom navigation bar" in vp and "no bottom navigation bar" not in vp:
            bottom_nav_violations.append(c["name"])
    assert not bottom_nav_violations, f"FAIL: Violations of bottom nav bar constraint: {bottom_nav_violations}"
    print("PASS: No bottom navigation bar violations found in component prompts.")

    # 4. Check component decomposition per screen
    screen_counts = {}
    for c in components:
        prefix = c["filename"].split("_")[0]
        screen_counts[prefix] = screen_counts.get(prefix, 0) + 1

    print("Component counts per screen prefix:")
    monolithic_screens = []
    for prefix, count in sorted(screen_counts.items()):
        print(f"  Prefix '{prefix}': {count} components")
        if count < 2:
            monolithic_screens.append((prefix, count))

    assert not monolithic_screens, f"FAIL: Screens with < 2 components (possible monolithic generation): {monolithic_screens}"
    print(f"PASS: All screens are decomposed into multiple discrete components (min components per screen: {min(screen_counts.values())}).")


def main():
    print("=================================================================")
    print("LINGUAPAGES UI GENERATION PLAN - EMPIRICAL VERIFICATION HARNESS")
    print("=================================================================")

    test_file_exists()
    test_filesystem_no_images_generated()

    content = parse_ui_generation_plan()
    test_all_15_screens_present(content)
    components = test_components_specifications(content)
    test_adversarial_stress_testing(content, components)

    print("\n=================================================================")
    print(f"ALL TESTS PASSED EMPIRICALLY! ({len(components)} components verified)")
    print("VERDICT: APPROVE")
    print("=================================================================")
    return 0


if __name__ == "__main__":
    sys.exit(main())

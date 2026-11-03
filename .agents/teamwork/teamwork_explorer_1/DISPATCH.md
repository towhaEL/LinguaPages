# Task Assignment for teamwork_explorer_1

## 2026-11-03T10:13:19Z
**Identity**: teamwork_explorer
**Working Directory**: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/
**Parent Orchestrator**: orchestrator (Conversation ID: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df)

## Mission
Survey the entire specification in `design/design.md` and `ORIGINAL_REQUEST.md` to design an architectural component decomposition strategy, a standardized image naming schema, and component prompt structure for LinguaPages.

## Target Scope
Inspect `/Users/uswer/StudioProjects/linguaPages/design/design.md` and `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`:
1. Design a consistent screen-wise and component-wise image naming convention (e.g. `<screen_number>_<screen_name>_<component_name>.png`) ensuring zero collision and complete clarity across all 8 screens and variants.
2. Define the exact directory layout under `design/components/` (or screen subfolders if appropriate).
3. Formulate the standardized prompt template for generating modular UI components, incorporating the Shared Style Block (M3 surface tokens, primary/secondary palettes, typography scales, corner radiuses, elevation levels).
4. Outline the complete Feature Inventory of screens and variants (Screens 1, 2, 2b, 2c, 2d, 3, 4, 4b, 4c, 4d, 4e, 5, 6, 7, 8) with their respective discrete component decompositions.

## Output Deliverables
Produce a structured investigation report at `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/handoff.md` detailing:
- The naming convention rules and complete mapping for every screen and component
- The component prompt generation framework (how prompt, negative prompt, aspect ratio, style parameters must be constructed)
- Global feature and component inventory
- Verification criteria for the UI generation plan

Send a completion message back when finished.

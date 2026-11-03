# Task Assignment for teamwork_worker_1

**Identity**: teamwork_worker
**Working Directory**: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_worker_1/
**Parent Orchestrator**: orchestrator (Conversation ID: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df)
**Exclusively Owned Output File**: `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md`

## Mission
Author the complete, production-grade UI Generation Plan for LinguaPages at `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md` based strictly on `/Users/uswer/StudioProjects/linguaPages/design/design.md`, the survey handoffs, and `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`.

## Mandatory Integrity Warning
> DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## Input Reference Files
1. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`
2. `/Users/uswer/StudioProjects/linguaPages/design/design.md`
3. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/orchestrator/PROJECT.md`
4. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_spec_miner_1/handoff.md` (Screens 1, 2, 2b, 2c, 2d, 3 specs)
5. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_spec_miner_2/handoff.md` (Screens 4, 4b, 4c, 4d, 4e, 5, 6, 7, 8 specs)
6. `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_explorer_1/handoff.md` (Naming convention, directory structure, prompt template)

## Core Deliverable Requirements
In `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md`:
1. Cover ALL 8 screens and their variants (15 screens/sheets total: 1. Onboarding, 2. Library, 2b. Empty library, 2c. Filter and sort sheet, 2d. Book details sheet, 3. Settings, 4. Reader with chrome and hidden chrome, 4b. Appearance sheet, 4c. Text selection & dictionary, 4d. Contents & annotations, 4e. Search in book, 5. Read aloud player variants, 6. Lock-screen controls, 7. Premium appearance, 8. All annotations).
2. Decompose EVERY screen into discrete visual components (typically 3 to 7 modular components per screen; NO single full-screen generations).
3. Specify exact screen-wise image filenames adhering to `<screen_number>_<screen_name>_<component_name>.png`.
4. Specify target output file path located within `design/components/<screen_number>_<screen_name>/`.
5. For EVERY component, provide:
   - Component Name & Role / Layout description
   - Exact Target File Path
   - Aspect Ratio and Target Dimensions
   - Visual Prompt incorporating the Shared Style Block (warm ivory #FAF7F2, pure white #FFFFFF surfaces, hairline dividers #E8E2D9, ink #1C1B1A, secondary slate #6B655D, deep ink blue #2F4A7A accent, Newsreader/Fraunces serif display, Inter sans UI labels, 16px card radius, 24px sheet radius, pill chips, 1.5px outlined icons, no bottom nav bar)
   - Negative Prompt suppressing 3D phone mockups, hands, perspective tilt, bottom navigation bars, and saturated neon colors.
6. Absolutely NO image generation in this phase (do not generate `.png` files).
7. Verify completeness and validate file formatting after authoring.

Send a completion message with your handoff report when finished.

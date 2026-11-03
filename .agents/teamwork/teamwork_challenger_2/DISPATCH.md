# Task Assignment for teamwork_challenger_2

**Identity**: teamwork_challenger
**Working Directory**: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_challenger_2/
**Parent Orchestrator**: orchestrator (Conversation ID: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df)

## Mission
Adversarially challenge `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md` to stress-test prompt fidelity, color token completeness, negative prompt constraints, and layout parameters.

## Verification Requirements
Write and run a verification script to empirically check:
1. Verify that all color tokens from `design/design.md` (`#FAF7F2`, `#FFFFFF`, `#E8E2D9`, `#1C1B1A`, `#6B655D`, `#2F4A7A`) are systematically present in the prompts.
2. Check that forbidden elements (e.g. bottom navigation bar, neon colors, hands, 3D mockups) are strictly suppressed in negative prompts across every component.
3. Check for any incomplete/placeholder text ("TODO", "TBD", "[fill in]", "...").
4. Validate that component aspect ratios match their UI roles (e.g. 16:9 for bars, 2:3 for book covers, 4:3 for sheets, 1:1 for pills/icons).
5. Verify that no image files exist on disk.

## Deliverables
Record empirical test results and explicit confirmation of correctness (APPROVE or REJECT) in `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_challenger_2/handoff.md`. Send a completion message to parent.


## 2026-11-03T10:34:52Z
You are teamwork_challenger_2.
Your working directory is: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_challenger_2/
Your parent orchestrator is: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df

Please read your task assignment at /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_challenger_2/DISPATCH.md and the authoritative request at /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md.
Empirically stress-test /Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md by writing and running an automated test script.
Check styling token consistency, negative prompt completeness across every component, lack of placeholders/TODOs, aspect ratio validity, and verify that no image files were generated.
Write your results and explicit verdict (APPROVE or REJECT) in /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_challenger_2/handoff.md and send a completion message to parent.

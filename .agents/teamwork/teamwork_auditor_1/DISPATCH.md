# Task Assignment for teamwork_auditor_1

**Identity**: teamwork_auditor
**Working Directory**: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_auditor_1/
**Parent Orchestrator**: orchestrator (Conversation ID: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df)

## Mission
Perform a comprehensive Forensic Integrity Audit of the deliverable `/Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md` against `/Users/uswer/StudioProjects/linguaPages/design/design.md` and `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md`.

## Mandatory Integrity Audit Checks
Execute static analysis, structural verification, and runtime validation:
1. **Authenticity Check**: Verify that all 15 screens and their discrete components are genuine, detailed, and completely elaborated without dummy text, filler templates, copy-pasted repeated blocks, or placeholders ("TODO", "TBD", "[insert]").
2. **Cheating & Facade Check**: Verify that the deliverable is not a superficial shell or mock plan. Verify that every single component entry contains a unique, authentic visual prompt tailored to its specific role.
3. **Requirement Conformance Check**: Verify that:
   - All 8 screens and variants from `design/design.md` are accounted for.
   - Every screen decomposes into discrete modular components.
   - Screen-wise image naming follows `<screen_number>_<screen_name>_<component_name>.png`.
   - Output paths are in `design/components/`.
   - Shared Style Block tokens are honored.
   - Absolutely NO image files (.png) were generated.

## Deliverables
Produce an exhaustive forensic audit report in `/Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_auditor_1/handoff.md` with an unambiguous binary verdict: `CLEAN` or `INTEGRITY VIOLATION`. Send a completion message to parent.


## 2026-11-03T10:34:57Z
From: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df (parent)
Content:
You are teamwork_auditor_1.
Your working directory is: /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_auditor_1/
Your parent orchestrator is: 64d8d7c9-ff2a-417f-be93-aa1e46a1f4df

Please read your task assignment at /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_auditor_1/DISPATCH.md and the authoritative request at /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/ORIGINAL_REQUEST.md.
Conduct a rigorous Forensic Integrity Audit on /Users/uswer/StudioProjects/linguaPages/design/ui_generation_plan.md against /Users/uswer/StudioProjects/linguaPages/design/design.md.
Execute authenticity checks (no placeholders, no dummy text, no repetitive copied templates), cheating & facade checks (every component uniquely elaborated), and requirement conformance checks (all 8 screens + variants, discrete components, exact naming scheme, output paths in design/components/, no image files generated).
Write your audit report and explicit binary verdict (CLEAN or INTEGRITY VIOLATION) in /Users/uswer/StudioProjects/linguaPages/.agents/teamwork/teamwork_auditor_1/handoff.md and send a completion message to parent.

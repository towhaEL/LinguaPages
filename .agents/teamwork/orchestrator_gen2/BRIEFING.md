# BRIEFING — 2026-11-04T22:30:00Z

## Mission
Complete remaining screen UI and components for LinguaPages as production code integrated into the Flutter app (Settings, Reader widgets/sheets, Paywall, Annotations) matching Stitch canvas designs and Warm Editorial Minimalism.

## 🔒 My Identity
- Archetype: orchestrator
- Roles: orchestrator, user_liaison, human_reporter, successor
- Working directory: /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2
- Original parent: sentinel
- Original parent conversation ID: 3f1b0ecb-3f4d-41c8-84f8-487555246e62

## 🔒 My Workflow
- **Pattern**: Project
- **Scope document**: /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2/PROJECT.md
1. **Decompose**: Decompose remaining requirements (R1: Settings, R2: Reader sheets & widgets, R3: Paywall & Annotations, R4: Integration & QA) into targeted milestones with rigorous verification.
2. **Dispatch & Execute**:
   - Direct iteration loop: 3 Explorers (or spec miner) -> 1 Worker -> 2 Reviewers + 2 Challengers + 1 Auditor -> Gate check.
3. **On failure** (in this order):
   - Retry: nudge stuck agent or re-send task
   - Replace: spawn fresh agent with partial progress
   - Skip: proceed without (only if non-critical, never auditor)
   - Redistribute: split stuck agent's remaining work
   - Redesign: re-partition decomposition
   - Escalate: report to parent (sub-orchestrators only, last resort)
4. **Succession**: At 16 spawns, write handoff.md, spawn successor.
- **Work items**:
  1. Milestone 4: Reader Experience & Overlays (Appearance, Wiktionary & Selection, TOC & Annotations, Search, Read Aloud sheet) [gating]
  2. Milestone 5: Settings Inset Cards, Premium Paywall Sheet, All Annotations Screen [pending]
  3. Milestone 6: Final Verification, QA, 0-Lint & 100% Tests Pass [pending]
- **Current phase**: 2B (Iteration Loop - Milestone 4 Gate Verification)
- **Current focus**: Milestone 4 Gate Check

## 🔒 Key Constraints
- NEVER write, modify, or create source code files directly.
- NEVER run build/test commands yourself — require workers to do so.
- NEVER investigate or explore the problem at the code level — dispatch Explorers for technical investigation.
- File-editing tools ONLY for metadata/state files (.md) in .agents/teamwork/.
- Forensic Auditor INTEGRITY VIOLATION is a BINARY VETO — milestone FAILS UNCONDITIONALLY.
- Strictly NO bottom navigation bar anywhere in the app.
- Warm Editorial Minimalism (ivory #FAF7F2, cards #FFFFFF, borders 1px #E8E2D9, Newsreader serif, Inter sans).
- All Flutter CLI commands must be executed with `fvm flutter <cmd>`.
- Zero flutter analyze errors/warnings, 100% test pass.
- Never reuse a subagent after it has delivered its handoff — always spawn fresh.

## Current Parent
- Conversation ID: 3f1b0ecb-3f4d-41c8-84f8-487555246e62
- Updated: 2026-11-04T22:12:00Z

## Key Decisions Made
- Previous M1 (Theme & Tokens), M2 (Onboarding), M3 (Library & Book Management) are completed/in progress.
- Scope for gen2 is R1 (Settings), R2 (Reader Sheets & Widgets), R3 (Paywall & Annotations), R4 (Integration & QA).
- M4 implementation completed by worker_m4_1 (348 tests passed, 0 analyze errors).
- Dispatched 5 gate agents for M4: reviewer_m4_1, reviewer_m4_2, challenger_m4_1, challenger_m4_2, auditor_m4_1.

## Team Roster
| Agent | Type | Work Item | Status | Conv ID |
|-------|------|-----------|--------|---------|
| spec_miner_m4_1 | teamwork_spec_miner | Reader design spec mining | completed | 7582c163-f0fd-4a06-8b70-8ee58e7157e9 |
| explorer_m4_1 | teamwork_explorer | Reader codebase exploration | completed | 81effb79-ed56-4822-a5c0-e26646d2d74c |
| explorer_m4_2 | teamwork_explorer | Reader test & integration exploration | completed | e46fc3b2-ce3a-45fa-b784-6748dcd76520 |
| worker_m4_1 | teamwork_worker | Reader UI implementation (M4) | completed | c4ed8762-6baa-4ffe-952c-f319a293fecd |
| reviewer_m4_1 | teamwork_reviewer | M4 UI review & test run | in-progress | 5145c4a3-0aea-49af-aec1-13b7cfd8f2ee |
| reviewer_m4_2 | teamwork_reviewer | M4 architecture & E2E review | in-progress | f4a5ef20-9f4c-43eb-9619-d5d0a6a1cd97 |
| challenger_m4_1 | teamwork_challenger | M4 reader stress testing | in-progress | dd963648-f22a-4939-a912-24c81407fa0c |
| challenger_m4_2 | teamwork_challenger | M4 search & audio stress testing | in-progress | 00f39ab5-d865-49fd-8078-91db9982be79 |
| auditor_m4_1 | teamwork_auditor | M4 forensic integrity audit | in-progress | 0c3894f7-01ab-4721-93fe-2e3608381c10 |

## Succession Status
- Succession required: no
- Spawn count: 9 / 16
- Pending subagents: 5145c4a3-0aea-49af-aec1-13b7cfd8f2ee, f4a5ef20-9f4c-43eb-9619-d5d0a6a1cd97, dd963648-f22a-4939-a912-24c81407fa0c, 00f39ab5-d865-49fd-8078-91db9982be79, 0c3894f7-01ab-4721-93fe-2e3608381c10
- Predecessor: orchestrator (f9c472c3-d79e-452d-90d4-f562d9d41ce2)
- Successor: not yet spawned

## Active Timers
- Heartbeat cron: task-38 (every 10m)
- Safety timer: none
- On succession: kill all timers before spawning successor
- On context truncation: handle timers as step 4 of the State Recovery section of your prompt says

## Artifact Index
- /home/tn-99778/Towha/LinguaPages/.agents/teamwork/ORIGINAL_REQUEST.md — Authoritative User Request
- /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2/PROJECT.md — Scope document
- /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2/progress.md — Progress log
- /home/tn-99778/Towha/LinguaPages/.agents/teamwork/orchestrator_gen2/GATE_STATUS.md — Milestone 4 gate status
- /home/tn-99778/Towha/LinguaPages/TEST_READY.md — E2E test suite ready

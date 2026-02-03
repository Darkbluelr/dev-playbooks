# Orchestration bans and routing table (reference)

This file carries the orchestration bans and the `request_kind` routing table for `devbooks-delivery-workflow`, to keep `SKILL.md` compact.

## Absolute bans (mandatory)

1) Main agent orchestrates only
- Do not directly write `proposal.md` / `design.md` / `tasks.md` / `verification.md`
- Do not directly modify `tests/**` or implementation code

2) Do not treat a fixed stage list as “the workflow”
- Do not run a full checklist blindly once `request_kind` is clear (wastes cost without adding certainty).
- Do not skip mandatory gates/evidence required by the chosen loop (e.g., Knife/traceability/reviews).
- Must choose the **minimal sufficient closed loop** by `request_kind`, and automatically upgrade when triggers fire.
- Archiving must pass the matching gates (`change-check.sh <change-id> --mode strict` by Archiver).

3) No fake archive
- Do not archive if `evidence/green-final/` is missing/empty
- Do not archive if `change-check.sh <change-id> --mode strict` fails

4) No “demo/simulate”
- Every stage must produce real artifacts on disk; do not replace execution with assumptions

5) `REVISE REQUIRED` triggers rollback
- If Judge/Test-Review/Code-Review returns `REVISE REQUIRED`: go back, fix, and rerun review until it passes

## P3-3 Action Norms (mandatory)

These rules defend against: end-step amnesia, output not written to disk, multi-change cross-contamination, and “looks done” drift.

1) Pick one real human master perspective; orchestrate only
- At the start, explicitly pick *one* real human master perspective for global coherence (e.g., Fred Brooks / Martin Fowler / Richard Feynman).
- Main agent does **orchestration + verification + adjudication** only; do not do role work (Proposal/Test/Code/Review).

2) Model selection (when available)
- Prefer a coding/tool-execution oriented model for `coder` and `test-owner` (example: `gpt-5.2-codex xhigh`).
- Use a general reasoning model for other roles (example: `gpt-5.2 xhigh`).
- Model names are examples; if the platform cannot pin models, enforce via role isolation + gates + evidence.

3) Sub-agent artifacts: merge-in-place or number in the change package
- If multiple sub-agents touch the same file: merge and write to that file (do not leave changes “in chat”).
- If an output is a standalone report: write it into the change package and number it:
  - `challenge-1.md`, `proposal-judge-1.md`, `test-review-1.md`, `code-review-1.md`, `archiver-report-1.md`, ...

4) Multiple changes in flight: always restate the current change package
- Before each stage, restate the current `change-id` and change package path.
- If starting from scratch: Proposal Author must create the change package skeleton.
- If resuming: inspect existing artifacts first (proposal/design/tasks/verification/evidence) and continue from the latest completed stage.

5) Done means archived (Archiver ran)
- “Tests passed” is not Done. Done means the Archiver stage completed and the change package is archived with evidence.
- Do not pause mid-flow to ask “should I continue”; follow the defined gates and finish the loop.

6) Codex CLI pacing: wait for sub-agents to finish
- In sub-agent-capable tools: wait for sub-agent completion before moving to the next stage (avoid partial outputs and drift).
- If sub-agents are not available: follow the framework’s downgrade strategy (human runs Test Owner and Coder in separate independent sessions; main agent provides steps + checks).

## Routing table (minimal sufficient loop by `request_kind`)

`request_kind` is the primary axis for the single entrypoint (Delivery):
**debug | change | epic | void | bootstrap | governance**.

Delivery’s job is to pick the minimal sufficient loop (cost vs certainty), and to upgrade when required.

### Minimal loops (MUST)

| request_kind | Minimal loop (must-have nodes only) |
|---|---|
| debug | Impact (optional but recommended) → Test Owner (minimal repro / Red) → Coder (Green) → Review → Green Verify → Archive |
| change | Proposal (Author/Challenge/Judge) → Design → Spec (as needed) → Plan → Test Owner → Coder → Review → Green Verify → Archive |
| epic | Knife (plan) → Proposal (Author/Challenge/Judge) → Design → Spec → Plan → Test Owner → Coder → Review → Green Verify → Archive |
| governance | Proposal (Author/Challenge/Judge) → SSOT Maintainer (when SSOT/index/ledger is involved) → Docs Consistency (as needed) → Review → Archive |
| bootstrap | Brownfield Bootstrap → (if needed) Proposal/Design/Spec/Plan → Archive |
| void | Void (questions / Freeze/Thaw / research artifacts) → route back into bootstrap / knife / change / debug |

### Upgrade triggers (WHEN)

- **High risk**: `risk_level=high` → Knife Plan / deterministic anchors / epic alignment gates become mandatory.
- **Epic / governance / higher-scope intervention**: `request_kind=epic|governance` or `intervention_level=team|org` → stricter evidence + handoff quality requirements.
- **External contract changes**: schema/API/event shape changes → must add Spec Contract + contract tests + a backward-compat strategy.
- **Cross-module / architecture boundary**: perform Impact Analysis and write it back (before or after Proposal, but must be present).
- **Docs/templates deliverables**: deliverables include `README/docs/templates` → require docs-consistency evidence.
- **SSOT baseline missing**: missing `<truth-root>/ssot/SSOT.md` or `<truth-root>/ssot/requirements.index.yaml` → route to `request_kind=bootstrap` first (you may scaffold via `ssot-scaffold.sh`).

## Resume (recommended)

- If a change package already exists: resume from the most recent completed stage, do not redo confirmed artifacts.
- After each stage: write evidence under `evidence/` and leave trace in the change package docs.

## Optional helper scripts

Scripts live under `skills/devbooks-delivery-workflow/scripts/`:

- `ssot-scaffold.sh`: scaffold a minimal Project SSOT pack (when no upstream SSOT exists)
- `requirements-ledger-derive.sh`: derive a requirements progress ledger (derived cache)
- SSOT maintenance & index sync: see `skills/devbooks-ssot-maintainer/` (delta → index sync → optional ledger refresh)
- `change-scaffold.sh`: scaffold a change package skeleton
- `change-check.sh`: verify a change package (strict/archive semantics)

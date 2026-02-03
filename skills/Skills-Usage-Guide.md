# DevBooks Skills Quick Reference (Purpose / When to Use / Copy-Paste Prompts)

## Path Conventions

### Project-Internal Paths (Relative Paths)
Default paths (DevBooks project layout):
- `<truth-root>` = `dev-playbooks/specs`
- `<change-root>` = `dev-playbooks/changes`
- `<change-id>` = the change package directory name for this change (verb-first)

If you are not using DevBooks, replace `dev-playbooks/specs` / `dev-playbooks/changes` with the `<truth-root>` / `<change-root>` defined by your project's "signpost" file (e.g. `project.md`, `AGENTS.md`, or your protocol config).

### Skills Shared Resources Paths (Absolute Paths)
Shared resources referenced by Skills (e.g. `_shared/references/`) are located in the global skills installation directory:
- **Claude Code**: `~/.claude/skills/_shared/`
- **Codex CLI**: `~/.codex/skills/_shared/`
- **OpenCode**: `~/.config/opencode/skill/_shared/`

In SKILL.md prompts, the `~/.claude/skills/_shared/` path should be replaced with the corresponding absolute path for your tool.

---

## `devbooks-delivery-workflow` (Delivery / Single entrypoint)

- Purpose: the single entrypoint. Routes by `request_kind` and orchestrates the minimal sufficient closed loop, materializing auditable on-disk artifacts (`RUNBOOK.md`, `inputs/index.md`, proposal metadata, evidence, gate reports).
- Key constraint: if the user did not explicitly specify `deliverable_quality`, Delivery MUST ask and freeze one of `outline|draft|complete|operational`, and write the final value to `completion.contract.yaml#intent.deliverable_quality` (avoid “skeleton mistaken as done”).
- When to use:
  - Always: debug, feature work, refactors, epics, governance changes, bootstrap, high-entropy uncertainty
- Copy-paste prompt:
  ```text
  You are Delivery. Explicitly use `devbooks-delivery-workflow`.
  First read: `dev-playbooks/project.md`.
  Ask the minimal questions to decide:
  - request_kind (debug|change|epic|void|bootstrap|governance)
  - risk_level (low|medium|high)
  - change_type
  - deliverable_quality (outline|draft|complete|operational)
  Then materialize the scaffold (if missing) and write the routing decision into RUNBOOK.
  Finally, orchestrate the minimal sufficient loop and drive it to archive (or explicitly route to Void/Bootstrap when prerequisites are missing).

  My request:
  <one-sentence request + constraints/boundaries>
  ```

---

## `devbooks-knife` (Knife / Epic slicing)

- Purpose: slice an Epic into a topologically-sortable Slice queue, and write a machine-readable Knife Plan (mandatory G3 input for `request_kind=epic` or `risk_level=high`).
- When to use:
  - `risk_level=high` (MUST)
  - `request_kind=epic` (MUST)
  - The request is too large and needs to be split into a queue of change packages (recommended)
- Copy-paste prompt:
  ```text
  You are Knife Planner. Explicitly use `devbooks-knife`.
  First read: `dev-playbooks/project.md`, `dev-playbooks/specs/knife/spec.md`, `dev-playbooks/specs/_meta/epics/README.md`

  My Epic:
  - epic_id: <EPIC-...>
  - goal/scope: <one sentence>
  - request_kind: epic
  - risk_level: <low|medium|high>
  - AC set (or acceptance set): <list or reference>

  Write and output:
  - `dev-playbooks/specs/_meta/epics/<epic_id>/knife-plan.yaml`
  It must include: epic_id, slice_id (if known), slices[] (each slice includes change_id/ac_subset/verification_anchors/depends_on).
  Finally, output the shortest next-step routing + upgrade conditions.
  ```

---

## `devbooks-proposal-author` (Proposal Author)

- Purpose: produce `proposal.md` (Why/What/Impact + Debate Packet) as the entry point for Design/Spec/Plan (no code in proposal stage).
- When to use:
  - New features / behavior changes / refactor proposals / “why change?”
  - You want scope/risks/rollback/acceptance clarified before implementation
- Copy-paste prompt:
  ```text
  You are Proposal Author. Explicitly use `devbooks-proposal-author` and follow the DevBooks proposal stage (no implementation code).
  First read: `dev-playbooks/project.md`
  Generate a verb-first `<change-id>` and repeat it 3 times so I can confirm.
  Then write: `dev-playbooks/changes/<change-id>/proposal.md` (must include a Debate Packet).
  Extra requirement: in Impact, explicitly describe value signals/measurement and value-stream bottleneck hypotheses (use "None" if not applicable).

  My request:
  <one-sentence request + background + constraints>
  ```

---

## `devbooks-impact-analysis` (Impact Analyst)

- Purpose: perform impact analysis (cross-module/cross-file/external contract changes) and write conclusions back to the Impact section of `proposal.md`.
- Two analysis modes:
  - Graph-based (when SCIP is available): use `analyzeImpact`/`findReferences`/`getCallGraph` for high precision
  - Text search (fallback): use `Grep`/`Glob` keyword search
- When to use:
  - You are changing many files / unsure of blast radius / compatibility risk
  - It “looks like a small change” but you worry about cross-module breakage
- Copy-paste prompt:
  ```text
  You are Impact Analyst. Explicitly use `devbooks-impact-analysis` (do not write code).
  First read: `dev-playbooks/project.md`, `dev-playbooks/changes/<change-id>/proposal.md`, and `dev-playbooks/specs/**`.
  Output impact analysis (Scope/Impacts/Risks/Minimal Diff/Open Questions) and backfill it into:
  `dev-playbooks/changes/<change-id>/proposal.md` (Impact section).
  ```

---

## `devbooks-proposal-challenger` (Proposal Challenger)

- Purpose: challenge `proposal.md`. Output a “challenge report” and a conclusion (Approve/Revise/Reject). Do not modify files.
- When to use:
  - High risk, high controversy, many trade-offs
  - You want a hard-gate review to prevent vague proposals from passing
- Copy-paste prompt:
  ```text
  You are Proposal Challenger. Explicitly use `devbooks-proposal-challenger`.
  Read only: `dev-playbooks/changes/<change-id>/proposal.md` (optionally `design.md` / `dev-playbooks/specs/**` if needed).
  Output only a challenge report (must conclude `Approve | Revise | Reject`). Do not modify any files.
  ```

---

## `devbooks-proposal-judge` (Proposal Judge)

- Purpose: judge proposal stage; decide `Approved | Revise | Rejected` and write back to the Decision Log in `proposal.md`.
- When to use:
  - You already have a Challenger report and need final judgment and “required changes / verification requirements”
- Copy-paste prompt:
  ```text
  You are Proposal Judge. Explicitly use `devbooks-proposal-judge`.
  Inputs: `dev-playbooks/changes/<change-id>/proposal.md` + the Challenger report I paste here.
  Decide `Approved | Revise | Rejected`, and write the decision plus required changes/verification requirements into:
  `dev-playbooks/changes/<change-id>/proposal.md` (Decision Log must not be Pending).
  ```

---

## `devbooks-design-doc` (Design Owner / Design Doc)

- Purpose: write `design.md` with What/Constraints + AC-xxx only (no implementation steps). This is the golden truth for tests and planning.
- When to use:
  - Anything beyond a trivial change
  - You need explicit constraints, acceptance rules, boundaries, and invariants
- Copy-paste prompt:
  ```text
  You are Design Owner. Explicitly use `devbooks-design-doc` (no implementation steps).
  First read: `dev-playbooks/project.md`, `dev-playbooks/changes/<change-id>/proposal.md`
  Write: `dev-playbooks/changes/<change-id>/design.md` (What/Constraints + AC-xxx only).
  ```

---

## `devbooks-spec-contract` (Spec & Contract Owner) [New]

> This Skill merges what used to be `devbooks-spec-delta` and `devbooks-contract-data`, reducing selection friction.

- Purpose: define external behavior specs and contracts (Requirements/Scenarios/API/Schema/compatibility strategy), and suggest or generate contract tests.
- When to use:
  - External behavior/contract/data invariants change
  - OpenAPI/Proto/event envelope/schema/config format changes
  - You need a compatibility/deprecation strategy, migrations, and replay
- Copy-paste prompt:
  ```text
  You are Spec & Contract Owner. Explicitly use `devbooks-spec-contract`.
  First read: `dev-playbooks/changes/<change-id>/proposal.md`, `dev-playbooks/changes/<change-id>/design.md` (if present)
  Output in one pass:
  - Spec delta: `dev-playbooks/changes/<change-id>/specs/<capability>/spec.md` (Requirements/Scenarios)
  - Contract plan: write into the Contract section of `design.md` (API changes + compatibility strategy + Contract Test IDs)
  If there is implicit-change risk, run: `implicit-change-detect.sh`
  ```

---

## `devbooks-implementation-plan` (Planner / tasks.md)

- Purpose: derive an implementation plan `tasks.md` from `design.md` (critical path / side quests / checkpoints), tied to verification anchors (must not reference `tests/`).
- When to use:
  - You need task decomposition, parallelization, milestones, and verification anchors
  - A large change needs controlled diffs and testable sub-steps
- Copy-paste prompt:
  ```text
  You are Planner. Explicitly use `devbooks-implementation-plan` (do not write implementation code).
  First read: `dev-playbooks/changes/<change-id>/design.md` (and this change's `specs/**` if present). Do not reference `tests/**`.
  Write: `dev-playbooks/changes/<change-id>/tasks.md` (every task must include a verification anchor).
  Finally run: `devbooks validate <change-id> --strict` and fix all issues.
  ```

---

## `devbooks-test-owner` (Test Owner)

- Purpose: convert design/spec into executable acceptance tests and traceability doc `verification.md`; must be isolated from implementation (Coder) and produce a Red baseline first.
- When to use:
  - TDD / acceptance tests / trace matrix
  - Contract tests / architecture fitness tests
- Output control: if test output exceeds 50 lines, keep only the key failure info; write full logs into `evidence/`.
- Copy-paste prompt (must be a new conversation/instance):
  ```text
  You are Test Owner (must be a separate conversation/instance). Explicitly use `devbooks-test-owner` and follow the DevBooks apply stage.
  Read-only inputs: `dev-playbooks/changes/<change-id>/proposal.md`, `design.md`, and this change's `specs/**` (if any). Do not reference `tasks.md`.
  Produce:
    - `dev-playbooks/changes/<change-id>/verification.md` (includes trace matrix)
    - `tests/**` (following repo conventions)
    - failure evidence written into `dev-playbooks/changes/<change-id>/evidence/`
  Requirements: produce a Red baseline first; finally run `devbooks validate <change-id> --strict`.
  ```

---

## `devbooks-coder` (Coder)

- Purpose: implement strictly according to `tasks.md` and run quality gates; must not modify `tests/**`; completion is defined only by tests/static checks/build.
- When to use:
  - Implementation stage: implement tasks, fix failing tests, make gates green
- Hotspot awareness: before starting, use a hotspot report to identify high-risk files:
  - Critical: top 5 hotspots + core logic changes → refactor first, then modify; must add tests
  - High: top 10 hotspots → increase test coverage; focus review
  - Normal: not a hotspot → standard workflow
- Resume support: after interruption, Coder should detect completed tasks in `tasks.md` and continue from the checkpoint
- Output control: if command output exceeds 50 lines, keep first/last 10 lines + a summary; write full logs to `evidence/`.
- Evidence paths: strict mode must emit gate reports under `evidence/gates/` (e.g., `evidence/gates/G0-<mode>.report.json`, G0–G6) and write risk evidence under `evidence/risks/` (e.g., `dependency-audit.log`, `rollback-plan.md`).
- Copy-paste prompt (must be a new conversation/instance):
  ```text
  You are Coder (must be a separate conversation/instance). Explicitly use `devbooks-coder` and follow the DevBooks apply stage.
  First read: `dev-playbooks/changes/<change-id>/tasks.md`, plus Test Owner’s `verification.md` (if present).
  Implement strictly per `tasks.md`; check off each item with `- [x]` as you complete it.
  Do not modify `tests/**`; if tests must change, hand back to Test Owner.
  Use tests/static checks/build as the only definition of done; write key outputs into `dev-playbooks/changes/<change-id>/evidence/` when needed.
  ```

---

## `devbooks-reviewer` (Reviewer)

- Purpose: review readability/consistency/dependency health/code smells; output actionable suggestions only; do not judge business correctness.
- Hotspot-first review: use a hotspot report before reviewing; prioritize by risk:
  - Top 5 hotspots: deep review (test coverage, cyclomatic complexity delta, dependency delta)
  - Top 10 hotspots: focus
  - Not a hotspot: standard review
- When to use:
  - Before/after PR review to guard maintainability
  - You want to discover coupling/dependency direction/complexity/smells
- Copy-paste prompt:
  ```text
  You are Reviewer. Explicitly use `devbooks-reviewer`.
  Review only readability/consistency/dependency health/code smells; do not discuss business correctness; do not modify `tests/` or design.
  Inputs: code changes + `dev-playbooks/specs/**` (as needed for profile/glossary/anti-patterns).
  Output: severe issues / maintainability risks / consistency suggestions / suggested quality gates to add.
  ```

---

## `devbooks-design-doc` (Design Doc Update / Writeback)

- Archive phase: `devbooks-archiver` performs design writeback automatically.
- If you need writeback before archive: use `devbooks-design-doc` to update `dev-playbooks/changes/<change-id>/design.md` and record reasons + impact.
- After writeback: Planner must rerun tasks; Test Owner may need to add tests / rerun the Red baseline.
- Deprecated name: `devbooks-design-backport`.
- When to use:
  - You discovered “design gap / conflicts with implementation / temporary decision with non-local impact”
  - You need to stop and update design before continuing
- Copy-paste prompt:
  ```text
  You are Design Owner. Explicitly use `devbooks-design-doc`.
  Trigger: implementation discovered a design gap/conflict/temporary decision.
  Write back design-level updates into: `dev-playbooks/changes/<change-id>/design.md` (explain reasons and impact), then stop.
  Explicitly tell me that Planner must rerun tasks, and Test Owner may need to add tests / rerun the Red baseline.
  ```

---

## `devbooks-archiver` (Archiver)

- Purpose: before archiving, prune and maintain `<truth-root>` (dedupe/merge/remove stale/reorganize/fix consistency) to prevent spec sprawl.
- When to use:
  - This change produced spec deltas and is ready to be merged into truth
  - You found duplicate/overlapping/stale entries in `<truth-root>`
- Copy-paste prompt:
  ```text
  You are Archiver. Explicitly use `devbooks-archiver`.
  Inputs: `dev-playbooks/changes/<change-id>/specs/**` + `dev-playbooks/specs/**` + `dev-playbooks/changes/<change-id>/design.md` (if any).
  You may modify only `dev-playbooks/specs/**` to merge/dedupe/categorize/delete stale items; do not modify the change package contents.
  Output in order: operation list (CREATE/UPDATE/MOVE/DELETE) → full content for every CREATE/UPDATE file → merge mapping summary → Open Questions (<=3).
  ```

---

## `devbooks-delivery-workflow` (Delivery Workflow + Scripts)

- Purpose: run a change as a traceable closed loop (Design → Plan → Trace → Verify → Implement → Archive), with deterministic scripts for scaffolding/checks/evidence/codemods.
- Architecture compliance checks: `guardrail-check.sh` options:
  - `--check-layers`: check layering constraint violations
  - `--check-cycles`: check circular dependencies
  - `--check-hotspots`: warn on hotspot file changes
- When to use:
  - You want to script repetitive steps (avoid missing files/fields/verifications)
  - You want “done” anchored to executable checks, not verbal confirmation
- Copy-paste prompt:
  ```text
  Explicitly use `devbooks-delivery-workflow`.
  Goal: prefer the Skill’s `scripts/*` for scaffolding/checking/evidence collection, rather than hand-writing from memory.
  Constraint: do not paste script bodies; run scripts and summarize results; ask me before running each command.

  Project root: $(pwd)
  change-id: <change-id>
  truth-root: dev-playbooks/specs
  change-root: dev-playbooks/changes

  Suggest and execute (after I confirm) in order:
  1) `change-scaffold.sh <change-id> --project-root \"$(pwd)\" --change-root dev-playbooks/changes --truth-root dev-playbooks/specs`
  2) `change-check.sh <change-id> --mode proposal --project-root \"$(pwd)\" --change-root dev-playbooks/changes --truth-root dev-playbooks/specs`
  3) (When evidence is needed) use a script to persist logs into `dev-playbooks/changes/<change-id>/evidence/`
  ```

---

## `devbooks-brownfield-bootstrap` (Brownfield Bootstrapper)

- Purpose: bootstrap an existing project: when `<truth-root>` is empty/missing, generate project profile, glossary, baseline specs, and minimal verification anchors to avoid “editing specs while changing behavior”.
- COD-style outputs (“code map” artifacts):
  - Module dependency map: `<truth-root>/architecture/module-graph.md` (from code-structure analysis)
  - Tech-debt hotspots: `<truth-root>/architecture/hotspots.md` (from change history and complexity indicators)
  - Domain concepts: `<truth-root>/_meta/key-concepts.md` (from code and docs extraction)
  - Project profile template: three layers (syntax/semantics/context)
- When to use:
  - An existing project wants to adopt DevBooks but has no truth/spec baseline
  - You want to describe “what it is today” before making changes
- Copy-paste prompt:
  ```text
  You are Brownfield Bootstrapper. Explicitly use `devbooks-brownfield-bootstrap`.
  Confirm: truth-root = `dev-playbooks/specs`, change-root = `dev-playbooks/changes`.
  Constraint: produce docs and baseline specs only; no refactors, no behavior changes, no implementation plan.
  Produce, in one pass:
    - `dev-playbooks/specs/_meta/project-profile.md`
    - (optional) `dev-playbooks/specs/_meta/glossary.md`
    - a baseline change package: `dev-playbooks/changes/<baseline-id>/*` (proposal/design/specs/verification)
  Finally, tell me how to merge the baseline into `dev-playbooks/specs/` (archive/manual steps).
  ```

---

## `devbooks-entropy-monitor` (Entropy Monitor)

- Purpose: periodically collect entropy metrics (structural/change/test/dependency) and generate a quantitative report; suggest refactors when thresholds are exceeded.
- When to use:
  - You want regular health checks (complexity trends, hotspot files, flaky test ratio)
  - You want quantified evidence before refactoring
  - You want a visualized tech-debt trend
- Copy-paste prompt:
  ```text
  You are Entropy Monitor. Explicitly use `devbooks-entropy-monitor`.
  First read: `dev-playbooks/project.md` (if present)
  Goal: collect current entropy metrics and generate a quantitative report.

  Steps:
  1) Run `entropy-measure.sh --project-root "$(pwd)"` to collect 4 dimensions (structural/change/test/dependency)
  2) Run `entropy-report.sh --output <truth-root>/_meta/entropy/entropy-report-$(date +%Y-%m-%d).md` to generate the report
  3) Compare against thresholds (`thresholds.json`) and list exceeded metrics
  4) If thresholds are exceeded: propose refactoring suggestions (usable as evidence for a future proposal)

  Project root: $(pwd)
  truth-root: dev-playbooks/specs
  ```
- Suggested cadence:
  - Small (< 10K LOC): weekly manual run
  - Medium (10K–100K LOC): scheduled CI daily run
  - Large (> 100K LOC): trigger on PR merge

---

## `devbooks-test-reviewer` (Test Reviewer) [New]

- Purpose: review test quality in `tests/` (coverage, boundary conditions, readability, maintainability); output review comments only; do not modify code.
- When to use:
  - After Test Owner completes tests, an independent quality review is needed
  - You want to find coverage gaps, missing boundary conditions, and maintainability issues
- Copy-paste prompt:
  ```text
  You are Test Reviewer. Explicitly use `devbooks-test-reviewer`.
  Review test quality only (coverage/boundary conditions/readability/maintainability); do not modify code.
  Inputs: `tests/**` + `dev-playbooks/changes/<change-id>/verification.md` (if present)
  Output: coverage gaps / missing boundary conditions / maintainability risks / improvement suggestions.
  ```

---

## `devbooks-convergence-audit` (Convergence Auditor) [New]

- Purpose: evaluate DevBooks workflow convergence using "evidence-first, distrust declarations" principle; detect "Sisyphus anti-pattern" and "false completion". Actively verify rather than trust document assertions.
- Anti-confusion design: never trust any assertion in documents (Status: Done, AC checked, etc.); must confirm through verifiable evidence.
- When to use:
  - You want to evaluate true workflow convergence (not document claims)
  - You suspect a change package is "false completion" or has "stale evidence"
  - You want to detect Sisyphus trap (repeated rework without convergence)
- Copy-paste prompt:
  ```text
  You are Convergence Auditor. Explicitly use `devbooks-convergence-audit`.
  First read: `dev-playbooks/project.md` (if present)
  Goal: perform a convergence audit on a specified change package.

  Execute with anti-confusion principles:
  1) Read all documents under `dev-playbooks/changes/<change-id>/`
  2) Verify each "declaration" (Status=Done, AC checked, etc.) against evidence
  3) Actually run tests for verification (if possible)
  4) Output: declaration vs evidence comparison table + trustworthiness score + confusion detection results

  Change package: <change-id>
  truth-root: dev-playbooks/specs
  change-root: dev-playbooks/changes
  ```
- Trustworthiness scoring:
  - 90-100: ✅ Trustworthy convergence, continue current workflow
  - 70-89: ⚠️ Partially trustworthy, needs additional verification
  - 50-69: 🟠 Questionable, parts need rework
  - < 50: 🔴 Untrustworthy (Sisyphus trap), needs full review

---

## Generating SCIP Index (Manual)

If you need graph-based code understanding (call graph, impact analysis, symbol references), you can generate a SCIP index manually:

```bash
# TypeScript/JavaScript
npm install -g @anthropic-ai/scip-typescript
scip-typescript index --output index.scip

# Python
pip install scip-python
scip-python index . --output index.scip

# Go
go install github.com/sourcegraph/scip-go@latest
scip-go --output index.scip
```

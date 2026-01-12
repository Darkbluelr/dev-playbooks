# Legacy Project: Initialization Workflow (Project Profile + Baseline Specs)

Applicable scenario: You are introducing a "spec-driven context protocol" into an existing project, but `<truth-root>/` is empty or nearly empty.

Goal: One-time completion of "project profile and conventions + baseline specs" so future changes can run as if the protocol had been used from day one.

Core principles:
- **Do not try to document the whole system at once**: start with external-facing surfaces (API/CLI/events/config/Schema), then fill internal core later.
- **Evidence first**: every spec item must point to code/tests/logs/runtime behavior; if unsure, write `TBD` + a verification plan.
- **Stabilize current behavior before refactoring**: the baseline phase should avoid behavioral change; do not "patch specs while changing behavior" and drift the truth source.

---

## Step 0: Define Baseline Scope (Mandatory)

Pick one (only one, avoid scope explosion):
- A) **External contracts first**: API/events/schema/config formats (most recommended)
- B) **Critical flows first**: 1–3 core flows like login/payment/order/compile-release
- C) **Module boundaries first**: dependency direction/layering/no cycles (paired with C4 + fitness tests)

Output (write into `<change-root>/<baseline-id>/proposal.md`):
- In / Out
- Risks and known unknowns (<= 5)
- "What this baseline will not do" (Non-goals)

---

## Step 0.5: One-shot Output (Recommended)

Use a single prompt to generate "project profile + baseline specs + verification draft":
- This Skill's `references/brownfield-bootstrap-prompt.md`

That prompt produces:
- `<truth-root>/_meta/project-profile.md` (tech stack/commands/conventions/gates/contract entry points)
- `<truth-root>/_meta/glossary.md` (optional: unified language)
- `<change-root>/<baseline-id>/...` (proposal/design/specs delta/verification)

---

## Step 1: Capability Inventory

Group the legacy system into 3–8 MECE capabilities (examples):
- `auth`, `billing`, `search`, `sync`, `config`, `observability`

For each capability, provide at least:
- External entry points (API/CLI/events/topics)
- Core data/Schema
- Dependency direction (who calls whom / who is called by whom)

Artifact location (recommended):
- `<change-root>/<baseline-id>/design.md` (optional but strongly recommended as a "current state summary")

---

## Step 2: Write Baseline Spec Deltas (ADDED only)

In `<change-root>/<baseline-id>/specs/<capability>/spec.md`, write **current-state specs**:
- Prefer "ADDED" sections only (exact headings should follow `<truth-root>/_meta/project-profile.md` conventions)
- Each Requirement must have at least 1 Scenario
- Requirements/Scenarios must be observable (inputs/outputs/error semantics/invariants)

Notes:
- If uncertain, write `TBD` and add a verification action to the plan section of `verification.md` (do not guess).
- If you find obvious bugs, do not fix them during baseline; create a separate change for fixes (avoid mixing behavior changes into baseline).

---

## Step 3: Add Minimal Verification Anchors (Recommended)

The goal is not full coverage, but future-proof anchors:
- External contracts: prioritize contract tests (schema shape / backward compatibility)
- Critical flows: minimal smoke/integration tests
- Structural red lines: fitness tests (layering/no cycles/no boundary violations)
- If refactor/migration is expected: add Snapshot/Golden Master for behavioral fingerprints

Artifact locations:
- `<change-root>/<baseline-id>/verification.md` (plan + trace matrix + MANUAL-*)
- `tests/**` (per repo conventions)
- `contracts/**` (if you maintain a contract library)

---

## Step 4: Merge into Current Truth (<truth-root>/)

Merge the baseline change's `<change-root>/<baseline-id>/specs/**` into `<truth-root>/**`:
- If your context protocol has archive/merge commands: use the command
- Otherwise: manual merge is fine, but keep the one-way semantics of "change package -> current truth"

---

## Completion Criteria (DoD)

- `<truth-root>/` includes specs for at least 1–3 core capabilities
- Each spec has 3–10 Requirements (current-state level is enough)
- At least one anchor type is in place (contract or smoke or fitness)
- Uncovered areas explicitly list Non-goals + a plan to complete later

# DevBooks Configuration Guide

> This guide helps you integrate the DevBooks workflow into a project.

---

## Quick Start (let AI configure it for you)

Send the following prompt to an AI assistant and it will apply the configuration automatically:

```text
You are a "DevBooks Context Protocol Adapter Installer". Your goal is to integrate DevBooks' protocol-agnostic conventions (<truth-root>/<change-root> + role isolation + DoD + Skills index) into the target project's context protocol.

Prerequisites (check first; if missing, stop and explain):
- System dependencies are installed (required: jq, ripgrep; recommended: scc, radon)
  Check with: command -v jq rg scc radon
  If missing, run: <devbooks-root>/scripts/install-dependencies.sh
- You can locate the project's "signpost file" (depends on the context protocol; common: CLAUDE.md / AGENTS.md / PROJECT.md / <protocol>/project.md).

Hard constraints (must obey):
1) This installation is only allowed to modify context/signpost documentation. Do NOT modify business code, tests, or add new dependencies.
2) If the target project already has a managed block, put custom content outside the managed block to avoid being overwritten by future auto-updates.
3) The installation MUST explicitly define two directory roots:
   - <truth-root>: the truth root for current specs
   - <change-root>: the change package root

Tasks (in order):
0) Check system dependencies:
   - Run: command -v jq rg scc radon
   - If required deps are missing (jq, rg), tell the user to run: ./scripts/install-dependencies.sh
   - If recommended deps are missing (scc, radon), explain they are optional (used for capabilities like "complexity-weighted hotspots")
1) Detect context protocol type (at least two branches):
   - If DevBooks is detected (dev-playbooks/project.md exists): use DevBooks defaults (<truth-root>=dev-playbooks/specs, <change-root>=dev-playbooks/changes)
   - Otherwise: integrate using the Manual Configuration section below
2) Decide directory roots for the project:
   - If the project already has specs/changes conventions: reuse them as <truth-root>/<change-root>
   - If the project has no conventions: recommend using `specs/` and `changes/` at repo root
3) Merge template content into the signpost file (append/merge; do not overwrite user content):
   - Write: <truth-root>/<change-root>, change package structure, role isolation, DoD, and the devbooks-* Skills index
4) Verify (must print results):
   - Artifact paths are consistent (proposal/design/tasks/verification/specs/evidence)
   - Test Owner/Coder isolation is present, and "Coder must not modify tests/" is present
   - DoD is present and MECE
   - devbooks-* Skills index is present

After completion, output:
- Dependency check results (installed vs missing)
- Which files you modified (list)
- Final <truth-root>/<change-root> values for the project
- A next-step "shortest path" example (2–3 key Skills in plain language)
```

---

## Manual Configuration

If you prefer manual configuration, add the following content into your project's signpost file (`CLAUDE.md`, `AGENTS.md`, or `PROJECT.md`):

### Directory root configuration

```yaml
# DevBooks directory conventions
truth_root: dev-playbooks/specs/    # Truth root for current specs
change_root: dev-playbooks/changes/ # Change package root
```

### Change package structure (per change)

Artifacts for each change are organized as:

| Artifact | Path | Notes |
|------|------|------|
| Proposal | `<change-root>/<change-id>/proposal.md` | Why/What/Impact |
| Design | `<change-root>/<change-id>/design.md` | What/Constraints + AC-xxx |
| Plan | `<change-root>/<change-id>/tasks.md` | Trackable implementation tasks |
| Verification | `<change-root>/<change-id>/verification.md` | Traceability matrix + MANUAL-* checklist |
| Spec deltas | `<change-root>/<change-id>/specs/**` | Spec delta for this change |
| Evidence | `<change-root>/<change-id>/evidence/**` | Red/Green evidence (as needed) |

### Truth root structure

```
<truth-root>/
├── _meta/
│   ├── project-profile.md    # Project profile / constraints / gates
│   └── glossary.md           # Ubiquitous language glossary
├── architecture/
│   └── c4.md                 # C4 architecture map
└── engineering/
    └── pitfalls.md           # High-ROI pitfalls library (optional)
```

### Role isolation (mandatory)

```markdown
## DevBooks role isolation rules

- Test Owner and Coder must work in **separate conversations / separate instances**
- Parallel work is allowed, but shared context that enables "self-proving tests" is prohibited
- Coder **must not modify** `tests/**`
- If tests must change, hand the decision and edits back to Test Owner
```

### DoD (Definition of Done, MECE)

Each change must declare which gates are covered; uncovered gates must include a reason:

| Gate | Type | Examples |
|------|------|----------|
| Behavior | unit/integration/e2e | pytest, jest |
| Contract | OpenAPI/Proto/Schema | contract tests |
| Structure | layering/dependency direction/no cycles | fitness tests |
| Static/Security | lint/typecheck/build | SAST/secret scan |
| Evidence | screenshots/recordings/reports | UI, performance (as needed) |

---

## Skills index

### By role

| Role | Skill | Artifact |
|------|-------|----------|
| Proposal Author | `devbooks-proposal-author` | `proposal.md` |
| Proposal Challenger | `devbooks-proposal-challenger` | Challenge report |
| Proposal Judge | `devbooks-proposal-judge` | Decision log writeback |
| Impact Analyst | `devbooks-impact-analysis` | Impact section |
| Design Owner | `devbooks-design-doc` | `design.md` |
| Spec & Contract | `devbooks-spec-contract` | `specs/**` |
| Planner | `devbooks-implementation-plan` | `tasks.md` |
| Test Owner | `devbooks-test-owner` | `verification.md` + `tests/` |
| Coder | `devbooks-coder` | Implement per tasks (must not modify tests) |
| Reviewer | `devbooks-reviewer` | Review feedback |
| Archiver | `devbooks-archiver` | Archive + C4 merge |

Note: `devbooks-archiver` performs design writeback automatically during archive. If you need writeback before archive, use `devbooks-design-doc`. Deprecated alias: `devbooks-design-backport`.

### By workflow

| Workflow | Skill | Notes |
|--------|-------|------|
| Delivery | `devbooks-delivery-workflow` | Full change closed loop |
| Brownfield Bootstrap | `devbooks-brownfield-bootstrap` | Brownfield project bootstrap |

### Metrics

| Capability | Skill | Notes |
|------|-------|------|
| Entropy Monitor | `devbooks-entropy-monitor` | System entropy metrics |

---

## Advanced options

### Custom directory mapping

Configure in `.devbooks/config.yaml`:

```yaml
# Directory mapping
mapping:
  truth_root: specs/           # Custom truth root
  change_root: changes/        # Custom change root
  agents_doc: AGENTS.md        # Rules doc path

# AI tool selection
ai_tools:
  - claude
  - cursor
```

### CI/CD integration

Copy templates from `templates/ci/` into `.github/workflows/`:

- `devbooks-guardrail.yml`: check complexity/hotspots/layering violations on PRs
- `devbooks-cod-update.yml`: update COD model after pushes

---

## Automatic Skill routing

AI can route to Skills based on intent:

| User intent | Auto routing |
|----------|----------|
| "fix a bug", "locate issue" | `devbooks-impact-analysis` → `devbooks-coder` |
| "refactor", "optimize code" | `devbooks-reviewer` → `devbooks-coder` |
| "new feature", "implement X" | `devbooks-delivery-workflow` → route by `request_kind` and run the minimal sufficient closed loop |
| "write tests", "add tests" | `devbooks-test-owner` |

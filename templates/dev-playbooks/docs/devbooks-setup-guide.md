# DevBooks Setup Guide

> This guide helps you integrate the DevBooks workflow into your project.

---

## Quick Start (Let AI Configure)

Send the following prompt to your AI assistant, and it will automatically complete the configuration:

```text
You are the "DevBooks Context Protocol Adapter Installer." Your goal is to integrate DevBooks' protocol-agnostic conventions (<truth-root>/<change-root> + role isolation + DoD + Skills index) into the target project's context protocol.

Prerequisites (check first; stop and explain if missing):
- System dependencies installed (jq, ripgrep required; scc, radon recommended)
  Check command: command -v jq rg scc radon
  If missing, run: <devbooks-root>/scripts/install-dependencies.sh
- You can locate the project's "context index file" (defined by the context protocol; common: CLAUDE.md / AGENTS.md / PROJECT.md / <protocol>/project.md).

Hard constraints (must follow):
1) This install only changes the "context/document index"; do not change business code, tests, or add dependencies.
2) If the target project already has a context protocol managed block, custom content must be outside the managed block to avoid being overwritten.
3) The install must explicitly state two root directories:
   - <truth-root>: current truth directory root
   - <change-root>: change package directory root

Tasks (execute in order):
0) Check system dependencies:
   - Run: command -v jq rg scc radon
   - If required deps are missing (jq, rg), instruct the user to run: ./scripts/install-dependencies.sh
   - If recommended deps are missing (scc, radon), suggest optional install to enable complexity-weighted hotspots
1) Identify the context protocol type (at least two branches):
   - If DevBooks is detected (dev-playbooks/project.md exists): use DevBooks defaults (<truth-root>=dev-playbooks/specs, <change-root>=dev-playbooks/changes).
   - Otherwise: use the manual configuration section
2) Determine directory roots for the project:
   - If the project already defines "spec/change package" directories: use existing conventions as <truth-root>/<change-root>.
   - If not defined: recommend specs/ and changes/ at the repo root.
3) Merge template content into the project's context index file (append is fine):
   - Write: <truth-root>/<change-root>, change package file structure, role isolation, DoD, devbooks-* Skills index.
4) Validate (must output check results):
   - Whether artifact locations are consistent (proposal/design/tasks/verification/specs/evidence)
   - Whether Test Owner/Coder isolation and "Coder must not modify tests" are included
   - Whether DoD is included (MECE)
   - Whether devbooks-* Skills index is included

After completion, output:
- System dependency check results (what is installed, what is missing)
- Which files you modified (list)
- Final <truth-root>/<change-root> values for the project
- A short "next steps" example for the user (natural language, name 2-3 key skills)
```

---

## Manual Configuration

If you want to configure manually, add the following content to your project's context index file (`CLAUDE.md`, `AGENTS.md`, or `PROJECT.md`):

### Root Directory Configuration

```yaml
# DevBooks directory conventions
truth_root: dev-playbooks/specs/    # Current truth directory root
change_root: dev-playbooks/changes/ # Change package directory root
```

### Single Change Package Structure

Each change's artifacts are organized as follows:

| Artifact | Path | Description |
|----------|------|-------------|
| Proposal | `<change-root>/<change-id>/proposal.md` | Why/What/Impact |
| Design | `<change-root>/<change-id>/design.md` | What/Constraints + AC-xxx |
| Plan | `<change-root>/<change-id>/tasks.md` | Trackable coding tasks |
| Verification | `<change-root>/<change-id>/verification.md` | Trace matrix + MANUAL-* checklists |
| Spec delta | `<change-root>/<change-id>/specs/**` | Spec delta for this change |
| Evidence | `<change-root>/<change-id>/evidence/**` | Red/Green evidence (as needed) |

### Current Truth Directory Structure

```
<truth-root>/
├── _meta/
│   ├── project-profile.md    # Project profile/constraints/gates
│   └── glossary.md           # Unified glossary
├── architecture/
│   └── c4.md                 # C4 architecture map
└── engineering/
    └── pitfalls.md           # High-ROI pitfalls (optional)
```

### Role Isolation (Mandatory)

```markdown
## DevBooks Role Isolation Rules

- Test Owner and Coder must work in **separate conversations/instances**
- Parallel work allowed, but no shared context to avoid "self-testing"
- Coder **must not modify** `tests/**`
- Test changes must be handed back to Test Owner
```

### DoD (Definition of Done, MECE)

Each change must declare which gates are covered; missing items require reasons:

| Gate | Type | Example |
|------|------|---------|
| Behavior | unit/integration/e2e | pytest, jest |
| Contract | OpenAPI/Proto/Schema | contract tests |
| Structure | layering/dependency direction/no cycles | fitness tests |
| Static & Security | lint/typecheck/build | SAST/secret scan |
| Evidence | screenshots/videos/reports | UI, performance (as needed) |

---

## Skills Index

### Role-Based

| Role | Skill | Artifact Location |
|------|-------|-------------------|
| Router | `devbooks-router` | Route and next step suggestions |
| Proposal Author | `devbooks-proposal-author` | `proposal.md` |
| Proposal Challenger | `devbooks-proposal-challenger` | Challenge report |
| Proposal Judge | `devbooks-proposal-judge` | Verdict writeback |
| Impact Analyst | `devbooks-impact-analysis` | Impact section |
| Design Owner | `devbooks-design-doc` | `design.md` |
| Spec & Contract | `devbooks-spec-contract` | `specs/**` |
| Planner | `devbooks-implementation-plan` | `tasks.md` |
| Test Owner | `devbooks-test-owner` | `verification.md` + `tests/` |
| Coder | `devbooks-coder` | Implement per tasks (no tests) |
| Reviewer | `devbooks-code-review` | Review feedback |
| Spec Gardener | `devbooks-spec-gardener` | Archive pruning + C4 merge |
| Design Backport | `devbooks-design-backport` | Backport design gaps |

### Workflow-Based

| Workflow | Skill | Description |
|----------|-------|-------------|
| Proposal Debate | `devbooks-proposal-debate-workflow` | Triangle debate |
| Delivery | `devbooks-delivery-workflow` | Change loop |
| Brownfield Bootstrap | `devbooks-brownfield-bootstrap` | Legacy project init |

### Metrics & Indexing

| Feature | Skill | Description |
|---------|-------|-------------|
| Entropy Monitor | `devbooks-entropy-monitor` | System entropy metrics |
| Index Bootstrap | `devbooks-index-bootstrap` | Generate SCIP index |
| Federation | `devbooks-federation` | Cross-repo analysis |

---

## Advanced Options

### Custom Directory Mapping

Configure in `.devbooks/config.yaml`:

```yaml
# Directory mapping
mapping:
  truth_root: specs/           # Custom truth directory
  change_root: changes/        # Custom change directory
  agents_doc: AGENTS.md        # Rules document path

# AI tools configuration
ai_tools:
  - claude
  - cursor
```

### CI/CD Integration

Copy templates from `templates/ci/` to `.github/workflows/`:

- `devbooks-guardrail.yml`: PR checks for complexity/hotspots/layering violations
- `devbooks-cod-update.yml`: COD model update after push

### Cross-Repo Federation

For multi-repo projects, configure `.devbooks/federation.yaml`:

```bash
cp skills/devbooks-federation/templates/federation.yaml .devbooks/federation.yaml
```

See `skills/devbooks-federation/SKILL.md`

---

## Automatic Skill Routing

The AI can automatically select Skills based on user intent:

| User Intent | Auto Route |
|-------------|------------|
| "Fix bug", "find issue" | `devbooks-impact-analysis` → `devbooks-coder` |
| "Refactor", "optimize code" | `devbooks-code-review` → `devbooks-coder` |
| "New feature", "implement XX" | `devbooks-router` → full loop |
| "Write tests", "add tests" | `devbooks-test-owner` |

---
name: devbooks-router
description: devbooks-router: DevBooks workflow entry guidance. Helps users determine which skill to start with, detects project current status, and provides shortest closed-loop path. Use when user says "what's next/where to start/run DevBooks closed-loop/project status" etc. Note: Routing after skill completion is handled by each skill itself, no need to call router.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Workflow Entry Guide (Router)

## Positioning Statement

> **Important**: Router's responsibility is **entry guidance**, not step-by-step routing.

| Scenario | Use Router? |
|----------|:-----------:|
| "Where should I start?" | ✅ Use |
| "What's the project status?" | ✅ Use |
| "What's next after coder?" | ❌ Don't use (coder outputs it) |
| "What's next after this skill?" | ❌ Don't use (each skill outputs its own) |

**Principle**: Each skill outputs its own next-step recommendation upon completion, following `_shared/references/deviation-detection-routing-protocol.md`.

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
4. If still undetermined → **Stop and ask user**

**Key Constraints**:
- If configuration specifies `agents_doc` (rules document), **you must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Prerequisites: Graph Index Health Check (Automatic)

**Automatically executed before routing**, checks CKB graph index status:

1. Call `mcp__ckb__getStatus` to check SCIP backend
2. If `backends.scip.healthy = false`:
   - Prompt user: "Code graph index not activated detected, impact analysis/call graph and other graph-based capabilities unavailable"
   - Provide the command to manually generate the index (see script above)
   - Continue routing but mark "graph capabilities degraded"

3. If `backends.scip.healthy = true`:
   - Pass silently, continue routing

**Check Script** (for reference):
```bash
# Detect language and generate index
if [ -f "tsconfig.json" ]; then
  scip-typescript index --output index.scip
elif [ -f "pyproject.toml" ]; then
  scip-python index . --output index.scip
elif [ -f "go.mod" ]; then
  scip-go --output index.scip
fi
```

**Degraded Mode Notes**:
- Without index, `devbooks-impact-analysis` degrades to Grep text search (reduced accuracy)
- Without index, `devbooks-code-review` cannot obtain call graph context
- Recommend completing index generation before the Apply phase

## Your Task

Map the user's natural language request to:
1) Current phase (proposal / apply / review / archive)
2) Required artifacts for this change (proposal/design/tasks/verification) and optional artifacts (spec deltas/contract/c4/evidence)
3) Which `devbooks-*` Skill(s) to use next
4) File path for each artifact

## Output Requirements (Mandatory)

1) **Ask 2 minimum key questions first** (skip if context already provides answers):
   - What is the `<change-id>`?
   - What are the final values of `<truth-root>` / `<change-root>` for this project?
2) Provide "next-step routing results" (3-6 items):
   - Each item includes: Skill to use + artifact path + why it's needed
3) Only enter the corresponding Skill's output mode if the user explicitly asks you to "start producing file content directly."

---

## Impact Profile Parsing (AC-003 / AC-012)

When `proposal.md` exists, Router **should automatically parse** the Impact section to generate a more precise execution plan.

### Impact Profile Structure

```yaml
impact_profile:
  external_api: true/false       # External API changes
  architecture_boundary: true/false  # Architecture boundary changes
  data_model: true/false         # Data model changes
  cross_repo: true/false         # Cross-repository impact
  risk_level: high/medium/low    # Risk level
  affected_modules:              # List of affected modules
    - name: <module-path>
      type: add/modify/delete
      files: <count>
```

### Parsing Flow

1. Check if `proposal.md` exists
2. If exists, find `## Impact` section
3. Extract `impact_profile:` YAML block
4. Validate required fields: `external_api`, `risk_level`, `affected_modules`

### Routing Enhancement Based on Impact Profile

| Impact Field | Value | Auto-Append Skill |
|--------------|-------|-------------------|
| `external_api: true` | - | `devbooks-spec-contract` |
| `architecture_boundary: true` | - | `devbooks-design-doc` (ensure Architecture Impact section is complete) |
| `cross_repo: true` | - | Manual cross-repo impact analysis |
| `risk_level: high` | - | `devbooks-proposal-challenger` + `devbooks-proposal-judge` |
| `affected_modules` count > 5 | - | `devbooks-impact-analysis` (deep analysis) |

### Execution Plan Output Format

```markdown
## Execution Plan (Based on Impact Profile)

### Must Execute
1. `devbooks-proposal-author skill` → proposal.md (proposal exists, skip)
2. `devbooks-design-doc skill` → design.md (required)
3. `devbooks-implementation-plan skill` → tasks.md (required)

### Recommended (Based on Impact Analysis)
4. `devbooks-spec-contract skill` → specs/** (detected external_api: true)
5. `devbooks-design-doc skill` → design.md Architecture Impact section (detected architecture_boundary: true)

### Optional
6. `devbooks-impact-analysis skill` → Deep impact analysis (affected_modules > 5)
```

### Parse Failure Handling (AC-012)

**When Impact Profile is missing**:

```
Warning: Impact profile not found in proposal.md.

Missing items:
- Impact section does not exist
- Or impact_profile YAML block is missing

Suggested actions:
1. Run `devbooks-impact-analysis skill` to generate impact analysis
2. Or use the appropriate skill directly

Skill list:
- devbooks-design-doc skill → Design document
- devbooks-implementation-plan skill → Implementation plan
- devbooks-spec-contract skill → Specification definition
```

**When YAML parsing fails**:

```
Warning: Impact profile parsing failed.

Error: <specific error message>

Suggested actions:
1. Check impact_profile YAML format in proposal.md
2. Or use the appropriate skill to bypass Router
```

---

## Routing Rules (Quality-First Default)

### A) Proposal (Proposal Phase)

Trigger signals: User says "proposal/why change/scope/risk/code smell refactoring/should we do this/don't write code yet" etc.

Default routing:
- `devbooks-proposal-author` → `(<change-root>/<change-id>/proposal.md)` (required)
- `devbooks-design-doc` → `(<change-root>/<change-id>/design.md)` (required for non-trivial changes; only write What/Constraints + AC-xxx)
- `devbooks-implementation-plan` → `(<change-root>/<change-id>/tasks.md)` (required; derive only from design)

Append as needed (add only when conditions are met):
- **Cross-module/unclear impact**: `devbooks-impact-analysis` (recommend writing back to proposal Impact)
- **Obvious risks/controversies/trade-offs**: `devbooks-proposal-challenger` + `devbooks-proposal-judge` (Author/Challenger/Judge in separate conversations, write back to Decision Log after debate)
- **External behavior/contract/data invariant changes**: `devbooks-spec-contract` → `(<change-root>/<change-id>/specs/**)` + `design.md` Contract section
  - If you need "deterministic spec delta file creation/avoid path errors": `change-spec-delta-scaffold.sh <change-id> <capability> ...`
- **Module boundary/dependency direction/architecture shape changes**: Ensure `devbooks-design-doc` outputs complete Architecture Impact section → merged to `(<truth-root>/architecture/c4.md)` by `devbooks-spec-gardener` during archiving

Hard constraint reminders:
- Proposal phase prohibits writing implementation code; implementation happens in apply phase with tests/gates as completion criteria.
- If you need "deterministic scaffold creation/avoid missing files": prefer running `devbooks-delivery-workflow` scripts
  - `change-scaffold.sh <change-id> ...`
  - `change-check.sh <change-id> --mode proposal ...`

### B) Apply (Implementation Phase: Test Owner / Coder)

Trigger signals: User says "start implementation/run tests/fix failures/follow tasks/make all gates green" etc.

Default routing (mandatory role separation):
- Test Owner (separate conversation/separate instance): `devbooks-test-owner`
  - Artifacts: `(<change-root>/<change-id>/verification.md)` + `tests/**`
  - First run to produce **Red** baseline, and record evidence (e.g., `(<change-root>/<change-id>/evidence/**)`)
- Coder (separate conversation/separate instance): `devbooks-coder`
  - Input: `tasks.md` + test errors + codebase
  - Prohibited from modifying `tests/**`

Apply phase deterministic checks (recommended):
- Test Owner: `change-check.sh <change-id> --mode apply --role test-owner ...`
- Test Owner (evidence recording): `change-evidence.sh <change-id> --label red-baseline -- <test-command>`
- Coder: `change-check.sh <change-id> --mode apply --role coder ...` (additionally checks that `tests/**` is unmodified in git diff)

LSC (Large-Scale Codemods) recommendations:
- First use `change-codemod-scaffold.sh <change-id> --name <codemod-name> ...` to generate codemod script scaffold, then use script for batch changes and record evidence

### C) Review (Review Phase)

Trigger signals: User says "review/code smells/maintainability/dependency risks/consistency" etc.

Default routing:
- `devbooks-code-review` (output actionable suggestions; do not change business conclusions or tests)
- `devbooks-test-reviewer` (review test quality, coverage, edge cases)

### D) Docs Sync (Documentation Sync)

Trigger signals: User says "update docs/sync docs/README update/API docs" etc.

Default routing:
- `devbooks-docs-sync` (maintain user documentation consistency with code)
  - Incremental mode: In change package context, only update docs related to this change
  - Global mode: With --global parameter, scan all docs and generate difference report

**Trigger conditions** (not required for every change):
- Add/modify/remove public API
- Change user-visible behavior
- Modify configuration options
- Change CLI commands

### E) Archive (Archive Phase)

Trigger signals: User says "archive/merge specs/close out/wrap up" etc.

Default routing:
- If spec deltas were produced this time: `devbooks-spec-gardener` (prune `<truth-root>/**` before archive merge)
- If design decisions need to be written back: `devbooks-design-backport` (as needed)
- If user documentation affected: `devbooks-docs-sync` (ensure docs consistent with code)

Pre-archive deterministic checks (recommended):
- `change-check.sh <change-id> --mode strict ...` (requires: proposal Approved, tasks all checked, trace matrix has no TODOs, structural gate decisions filled in)

### F) Prototype (Prototype Mode)

> Source: "The Mythical Man-Month" Chapter 11 "Plan to Throw One Away" — "The first system built is never suitable for use...plan to throw one away"

Trigger signals: User says "prototype first/quick validation/spike/--prototype/throwaway prototype/Plan to Throw One Away" etc.

**Prototype mode applicable scenarios**:
- Technical approach uncertain, need quick feasibility validation
- First time building this type of feature, expect to rewrite
- Need to explore actual behavior of APIs/libraries/frameworks

**Default routing (prototype track constraints)**:

1. Create prototype scaffold:
   - `change-scaffold.sh <change-id> --prototype ...`
   - Artifacts: `(<change-root>/<change-id>/prototype/)`

2. Test Owner (separate conversation) uses `devbooks-test-owner --prototype`:
   - Artifacts: `(<change-root>/<change-id>/prototype/characterization/)`
   - Generate **characterization tests** (record actual behavior) rather than acceptance tests
   - **No Red baseline required** — characterization tests assert "current state"

3. Coder (separate conversation) uses `devbooks-coder --prototype`:
   - Output path: `(<change-root>/<change-id>/prototype/src/)`
   - Allowed to bypass lint/complexity thresholds
   - **Prohibited from landing directly to repository `src/`**

**Hard constraints (must follow)**:
- Prototype code and production code are **physically isolated** (different directories)
- Test Owner and Coder must still have **separate conversations/instances** (role separation unchanged)
- Promoting prototype to production requires **explicit trigger** `prototype-promote.sh <change-id>`

**Prerequisites for promoting prototype to production**:
1. Create production-grade `design.md` (distill What/Constraints/AC-xxx from prototype learnings)
2. Test Owner produces acceptance tests `verification.md` (replacing characterization tests)
3. Complete the promotion checklist in `prototype/PROTOTYPE.md`
4. Run `prototype-promote.sh <change-id>` and pass all gates

**Prototype discard flow**:
1. Record key insights learned to `proposal.md` Decision Log
2. Delete `prototype/` directory

## DevBooks Skill Adaptation

DevBooks uses `devbooks-proposal-author skill`, `devbooks-test-owner/coder skill`, `devbooks-spec-gardener skill` as entry points.
Route according to A/B/C/D above, artifact paths follow `<truth-root>/<change-root>` mappings in project signposts.

---

## Context Awareness

This Skill automatically detects context before execution, selecting appropriate routing strategy.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if change package exists
2. Detect existing artifacts (proposal/design/tasks/verification)
3. Infer current phase (proposal/apply/archive)
4. Select default routing based on phase

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **New Change** | Change package doesn't exist or is empty | Route to proposal phase, suggest creating proposal.md |
| **In Progress** | Change package exists, has partial artifacts | Recommend next step based on missing artifacts |
| **Ready to Archive** | Gates passed, `evidence/green-final/` exists | Route to archive phase |

### Detection Output Example

```
Detection results:
- Change package status: exists
- Existing artifacts: proposal.md ✓, design.md ✓, tasks.md ✓, verification.md ✗
- Current phase: apply
- Suggested routing: devbooks-test-owner (establish Red baseline first)
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available → Mark "graph capabilities activated" in routing suggestions
3. If timeout or failure → Mark "graph capabilities degraded" in routing suggestions, recommend manually generating SCIP index

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Impact analysis recommendation | Use CKB precise analysis | Use Grep text search |
| Code navigation | Symbol-level navigation available | File-level search |
| Hotspot detection | CKB real-time analysis | Unavailable |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB index not activated, graph capabilities (impact analysis, call graph, etc.) will be degraded.
Recommend manually generating SCIP index for full functionality.
```

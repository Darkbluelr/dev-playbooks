# Archiving Process and Rules

## 🚨 ABSOLUTE RULES (NO EXCEPTIONS)

> These rules have no exceptions. Violations are failures.

### Rule 1: Never Skip Script Validation

```
❌ FORBIDDEN: Archiving without running change-check.sh
❌ FORBIDDEN: Continuing when change-check.sh returns non-zero
❌ FORBIDDEN: Manually skipping or bypassing script checks

✅ REQUIRED: Run change-check.sh --mode strict before archive
✅ REQUIRED: Proceed only when the script returns 0
✅ REQUIRED: Stop and output complete error info when the script fails
```

### Rule 2: Never Archive with Fake Completion

```
❌ FORBIDDEN: Archiving when evidence/green-final/ is missing or empty
❌ FORBIDDEN: Archiving when verification.md AC coverage < 100%
❌ FORBIDDEN: Archiving when tasks.md contains incomplete tasks

✅ REQUIRED: All checks must pass
✅ REQUIRED: Green evidence directory must be non-empty
✅ REQUIRED: AC coverage must be 100%
```

---

## Workflow Position Awareness

> Core principle: Archiver is the single entry point for the archive phase, responsible for closing the loop from code review to change package archival.

### My Position in the Overall Workflow

```
proposal → design → test-owner(P1) → coder → test-owner(P2) → code-review → [Archiver]
                                                                                  ↓
                                               Auto writeback → Spec merge → Doc checks → Archive move
```

### Archiver’s Complete Responsibilities

| Phase | Responsibility | Description |
|------:|----------------|-------------|
| 1 | Design update (writeback) | Detect new constraints/gaps found during implementation and write them back to design.md |
| 2 | Spec merge | Merge change package specs/contracts into truth-root |
| 3 | Architecture merge | Merge design.md “Architecture Impact” into c4.md |
| 4 | Documentation sync check | Check whether design.md “Documentation Impact” has been handled |
| 5 | Change package archive move | Move the change package to `<change-root>/archive/` |

Note: Archiver automatically writes back `design.md` during the archive phase. If you need an earlier writeback, use `devbooks-design-doc` to update `design.md`. Deprecated alias: `devbooks-design-backport`.

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: current truth directory root
- `<change-root>`: change package root

Before execution, you must discover configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if present) → parse and use its mappings
2. `dev-playbooks/project.md` (if present) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if present) → template protocol, use default mappings
4. If still unknown → stop and ask the user

Critical constraints:
- If `agents_doc` (rules document) is specified, you must read it before doing anything.
- Do not guess directory roots.
- Do not skip reading the rules document.

---

## Complete Archive Flow

### Step 0: Run the Mandatory Validation Script (MANDATORY)

> This is the first action of archiving and cannot be skipped.

```bash
change-check.sh <change-id> --mode strict
```

Execution rules:

| Script return | Behavior |
|-------------:|----------|
| `0` (success) | Continue with subsequent steps |
| non-zero (failure) | Stop immediately, output complete error info, and do not perform any archive operations |

What `--mode strict` checks:
- Change package existence
- verification.md status and AC coverage rate
- evidence/green-final/ exists and is non-empty
- tasks.md completion
- all gate checks

Failure output format:

```
❌ Archive Pre-check Failed

Script output:
<complete output from change-check.sh>

Suggested actions:
- Fix issues based on the errors above
- Re-run change-check.sh --mode strict
- Confirm all checks pass before retrying archive
```

### Step 1: Pre-checks (Secondary Confirmation After Script Passes)

```markdown
Pre-check checklist (already validated by script; this is secondary confirmation):
- [ ] Change package exists (<change-root>/<change-id>/)
- [ ] verification.md Status = Ready or Done
- [ ] evidence/green-final/ exists and is non-empty
- [ ] tasks.md all tasks completed ([x])
- [ ] Code review passed (verification.md Status = Done set by Reviewer)
```

If any item fails → stop and list missing items; suggest completing prerequisites first.

### Step 2: Auto Writeback Detection and Handling

> Design decision: the archive phase automatically handles all pending writebacks; users do not need to manually trigger a separate “Design Update” step.

Detection flow:

```
1. Read <change-root>/<change-id>/deviation-log.md
2. Check for pending writeback records ("| ❌")
   → If present: perform auto writeback (steps 3-5)
   → If absent: skip and proceed to merge

3. For each pending record, determine whether it is Design-level content:
   - DESIGN_GAP, CONSTRAINT_CHANGE, API_CHANGE → backportable
   - Pure implementation detail (file/class names, temporary steps) → not backportable; mark as IMPL_ONLY

4. Perform design writeback:
   - Read design.md
   - Update only within the “backportable scope” (see table below)
   - Append a change record to the end of design.md

5. Update deviation-log.md:
   - Mark written-back records as ✅
   - Record writeback time and archive batch
```

Backportable scope (Design Update):

| Backportable | Not backportable |
|--------------|------------------|
| External semantics / user-visible behavior | Specific file paths, class/function names |
| System-level invariants | PR split strategy, task execution order |
| Core data contracts and evolution strategy | Overly detailed algorithm pseudocode |
| Cross-phase governance strategy | Script command lines |
| Key tradeoffs and decisions | Table/field names |

### Step 3: Spec Merge

Merge spec artifacts from the change package into `<truth-root>`:

| Source | Target | Strategy |
|--------|--------|----------|
| `<change-root>/<change-id>/specs/**` | `<truth-root>/specs/**` | incremental merge |
| `<change-root>/<change-id>/contracts/**` | `<truth-root>/contracts/**` | versioned merge |

Spec metadata updates (required during merge):

```yaml
---
last_referenced_by: <change-id>           # Last change package referencing this spec
last_verified: <archive-date>             # Last verification date
health: active                            # active | stale | deprecated
---
```

Metadata update rules:

| Scenario | Update behavior |
|----------|-----------------|
| New spec | Create full metadata header |
| Modify existing spec | Update `last_referenced_by` and `last_verified` |
| Referenced by design but not modified | Update `last_referenced_by` only |
| Marked deprecated | Set `health: deprecated` |

Reference traceability chain:

During archiving, Archiver scans “Affected Specs” declared in design.md and updates `last_referenced_by` for those specs even if they were not directly modified. This creates reverse traceability from specs to change packages.

### Step 4: Architecture Merge

> Design decision: C4 architecture changes are recorded in design.md “Architecture Impact” and merged into truth during archiving.

C4 merge flow:

1. Detect architecture changes: parse “Architecture Impact” in `design.md`
2. Decide whether merge is needed:
   - If “No architecture changes” is checked → skip merge
   - If “Has architecture changes” → perform merge
3. Perform merge:
   - Read `<truth-root>/architecture/c4.md` (create if missing)
   - Update relevant sections based on Architecture Impact
   - Update Container/Component tables
   - Update dependency relationships
   - Update layering constraints (if changed)
4. Record merge log: append a change record to the end of c4.md

### Step 5: Documentation Checks

#### 5.1 Documentation Consistency Check (Non-blocking)

Run a documentation consistency check before archiving:

```
devbooks-docs-consistency --check
skills/devbooks-delivery-workflow/scripts/docs-consistency-check.sh <change-id> \
  --project-root . --change-root dev-playbooks/changes --truth-root dev-playbooks/specs
```

Notes:
- Default: the result is recorded as informational output (helps catch dangling references / missing paths).
- When G6 determines docs consistency is a required scope evidence item (deliverables include `README.md/docs/**/templates/**`, or there is a `severity=must` obligation whose `tags` include both `weak_link` and `docs`):
  - `archive-decider.sh` will attempt to auto-generate `evidence/gates/docs-consistency.report.json` (via `docs-consistency-check.sh`) to reduce “forgot to run it” drift.
  - If it is still missing or `status!=pass`, it will be judged as fail, blocking archiving.
  - It is still recommended to run it once before archiving for faster feedback when doc references change a lot.

#### 5.2 Documentation Sync Check (Based on design.md)

Check the “Documentation Impact” section in design.md:

```markdown
Check items:
- [ ] If documents requiring updates are declared, verify those documents were updated
- [ ] If “No updates needed” is checked, confirm reasonableness
- [ ] Output a documentation sync status report
```

If there are unprocessed documentation updates:
- output a warning listing the documents that still need updates
- do not block archiving, but mark it as “Documentation pending update” in the archive report

### Step 6: Change Package Archive Move

Move the completed change package to the archive directory:

```bash
# Source
<change-root>/<change-id>/

# Target
<change-root>/archive/<change-id>/
```

Move flow:

1. Create archive directory (if missing): `<change-root>/archive/`
2. Set final status: set `Status: Archived` in verification.md
3. Add archive timestamp: append `Archived-At: <timestamp>` to verification.md
4. Move change package: `mv <change-root>/<change-id>/ <change-root>/archive/<change-id>/`
5. Output an archive completion report

verification.md archive metadata example:

```markdown
---
status: Archived
archived-at: 2024-01-16T10:30:00Z
archived-by: devbooks-archiver
---
```

---

## Execution Method

1) First read and follow the shared AI behavior guidelines (verifiability + structural quality gates).
2) Strictly follow the complete prompt: `references/archiver-prompt.md`.

---

## Context Awareness

This Skill detects context before execution and chooses the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Flow

1. Detect `<truth-root>/` directory status
2. If a change-id is provided, detect whether the change package is eligible for archive
3. Detect duplicate/obsolete specs (maintenance mode)

### Modes Supported by This Skill

| Mode | Trigger | Behavior |
|------|---------|----------|
| Archive mode | change-id provided and gates pass | Execute the complete archive flow (steps 0–6) |
| Maintenance mode | no change-id | Deduplicate/cleanup/organize truth-root |
| Check mode | `--dry-run` provided | Output plan only; do not modify/move |

### Archive Mode Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Archive Mode Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  0. Run mandatory validation script (MANDATORY)             │
│     └─ change-check.sh <change-id> --mode strict           │
│              │                                               │
│              ├─ Returns non-zero → ❌ Stop, output error    │
│              │                                               │
│              ▼ Returns 0                                     │
│  1. Pre-checks (secondary confirmation)                     │
│     ├─ Change package exists?                               │
│     ├─ verification.md Status = Ready/Done?                 │
│     ├─ evidence/green-final/ exists?                        │
│     └─ tasks.md all completed?                              │
│              │                                               │
│              ▼                                               │
│  2. Auto writeback                                          │
│     ├─ Read deviation-log.md                                │
│     ├─ Detect pending writebacks                            │
│     └─ Write back → update marks                            │
│              │                                               │
│              ▼                                               │
│  3. Spec merge                                              │
│     ├─ specs/** → truth-root/specs/**                       │
│     └─ contracts/** → truth-root/contracts/**               │
│              │                                               │
│              ▼                                               │
│  4. Architecture merge                                      │
│     └─ Architecture Impact → c4.md                          │
│              │                                               │
│              ▼                                               │
│  5. Documentation checks                                    │
│     └─ Documentation Impact + consistency check             │
│              │                                               │
│              ▼                                               │
│  6. Change package archive move                             │
│     ├─ Set Status: Archived                                 │
│     └─ mv <change-id>/ → archive/<change-id>/               │
│              │                                               │
│              ▼                                               │
│  ✅ Output archive completion report                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

> Optional but recommended: if your project uses the Project SSOT pack (`<truth-root>/ssot/requirements.index.yaml`), refresh the derived progress view (discardable cache) after archiving:
>
> ```bash
> requirements-ledger-derive.sh --project-root <project-root> --change-root <change-root> --truth-root <truth-root>
> ```
>
> Default output: `<truth-root>/ssot/requirements.ledger.yaml`

### Detection Output Example

```
Detection results:
- truth-root: exists, contains 12 spec files
- change package: exists, all gates green
- writeback status: 2 pending records
- running mode: archive mode (complete flow)
```

---

## Archive Report Template

```markdown
## Archive Report

### Change Package Info
- Change ID: <change-id>
- Archive time: <timestamp>

### Execution Summary
| Step | Status | Notes |
|------|--------|-------|
| Pre-checks | ✅ | All passed |
| Auto writeback | ✅ | Wrote back 2 records |
| Spec merge | ✅ | Merged 3 spec files |
| Architecture merge | ⏭️ | No architecture changes |
| Doc checks | ⚠️ | README.md needs update |
| Archive move | ✅ | Moved to archive/ |

### Archive Location
`<change-root>/archive/<change-id>/`

### Follow-up Recommendations
- [ ] Update README.md (doc warning)
```

---

## Maintenance Mode Responsibilities

In maintenance mode (no change-id), perform:

- Detect duplicate spec definitions
- Clean up obsolete/deprecated specs
- Organize directory structure
- Fix consistency issues

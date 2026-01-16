---
name: devbooks-archiver
description: devbooks-archiver: The single entry point for the archive phase, responsible for the complete archive closed-loop (auto-backport → spec merge → doc sync check → change package archive move). Use when user says "archive/finalize/close-loop/merge to truth" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Archiver

## Workflow Position Awareness

> **Core Principle**: Archiver is the **single entry point** for the archive phase, responsible for completing all finalization work from code review to change package archival.

### My Position in the Overall Workflow

```
proposal → design → test-owner(P1) → coder → test-owner(P2) → code-review → [Archiver]
                                                                                  ↓
                                               Auto backport → Spec merge → Doc check → Archive move
```

### Why Renamed to Archiver?

| Old Name | New Name | Reason for Change |
|----------|----------|-------------------|
| `spec-gardener` | `archiver` | Responsibilities expanded beyond just spec merging to complete archive closed-loop |

### Archiver's Complete Responsibilities

| Phase | Responsibility | Description |
|-------|---------------|-------------|
| 1 | Auto backport detection and handling | Detect deviation-log.md, auto-backport to design doc |
| 2 | Spec merge | Merge specs/contracts into truth-root |
| 3 | Architecture merge | Merge design.md's Architecture Impact into c4.md |
| 4 | Documentation sync check | Check if design.md's Documentation Impact has been processed |
| 5 | Change package archive move | Move change package to `<change-root>/archive/` |

---

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
4. If still unable to determine → **Stop and ask the user**

**Critical Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

---

## Complete Archive Flow

### Step 1: Pre-checks

```markdown
Pre-check checklist:
- [ ] Change package exists (<change-root>/<change-id>/)
- [ ] verification.md Status = Ready or Done
- [ ] evidence/green-final/ exists and is non-empty
- [ ] tasks.md all tasks completed ([x])
- [ ] Code review passed (verification.md Status = Done set by Reviewer)
```

If check fails → Stop and output missing items, suggest user complete prerequisite steps first.

### Step 2: Auto Backport Detection and Handling

> **Design Decision**: Archive phase automatically handles all pending backports, users don't need to manually call design-backport.

**Detection Flow**:

```
1. Read <change-root>/<change-id>/deviation-log.md
2. Check if there are "| ❌" pending backport records
   → Yes: Execute auto backport (steps 3-5)
   → No: Skip, proceed directly to merge phase

3. For each pending record, determine if it's Design-level content:
   - DESIGN_GAP, CONSTRAINT_CHANGE, API_CHANGE → Need backport
   - Pure implementation details (filename/classname/temp steps) → Don't backport, mark as IMPL_ONLY

4. Execute design backport:
   - Read design.md
   - Update according to design-backport protocol's "backportable content scope"
   - Add change record at the end of design.md

5. Update deviation-log.md:
   - Mark backported records as ✅
   - Record backport time and archive batch
```

**Auto Backport Content Scope** (inherited from design-backport):

| Backportable | Not Backportable |
|--------------|------------------|
| External semantics/user-visible behavior | Specific file paths, class/function names |
| System-level immutable constraints (Invariants) | PR splits, task execution order |
| Core data contracts and evolution strategies | Overly detailed algorithm pseudocode |
| Cross-phase governance strategies | Script commands |
| Key tradeoffs and decisions | Table/field names |

### Step 3: Spec Merge

Merge change package spec artifacts into `<truth-root>`:

| Source Path | Target Path | Merge Strategy |
|-------------|-------------|----------------|
| `<change-root>/<change-id>/specs/**` | `<truth-root>/specs/**` | Incremental merge |
| `<change-root>/<change-id>/contracts/**` | `<truth-root>/contracts/**` | Versioned merge |

**Spec Metadata Update** (must execute during merge):

When merging specs into truth-root, the following metadata must be updated:

```yaml
# Update in each merged/referenced spec file header
---
last_referenced_by: <change-id>           # Last change package referencing this spec
last_verified: <archive-date>             # Last verification date
health: active                            # Health status: active | stale | deprecated
---
```

**Metadata Update Rules**:

| Scenario | Update Behavior |
|----------|-----------------|
| New Spec | Create complete metadata header |
| Modify existing Spec | Update `last_referenced_by` and `last_verified` |
| Spec referenced by design doc but not modified | Update only `last_referenced_by` |
| Marked as deprecated | Set `health: deprecated` |

**Building Reference Traceability Chain**:

During archiving, archiver automatically scans the "Affected Specs" declared in design.md and updates the `last_referenced_by` field for these Specs, even if they weren't directly modified. This establishes a reverse traceability chain from Specs to change packages.

### Step 4: Architecture Merge

> **Design Decision**: C4 architecture changes are recorded in design.md's Architecture Impact section and merged into truth by Archiver during archiving.

**C4 Merge Flow**:

1. **Detect Architecture Changes**: Parse "Architecture Impact" section in `design.md`
2. **Determine If Merge Needed**:
   - If "No Architecture Changes" is checked → Skip merge
   - If "Has Architecture Changes" → Execute merge
3. **Execute Merge**:
   - Read `<truth-root>/architecture/c4.md` (create if doesn't exist)
   - Update corresponding sections based on Architecture Impact descriptions
   - Update Container/Component tables
   - Update dependency relationships
   - Update layering constraints (if changed)
4. **Record Merge Log**: Append change record at end of c4.md

### Step 5: Documentation Sync Check

Check "Documentation Impact" section in design.md:

```markdown
Check items:
- [ ] If "Documents requiring updates" is declared, verify these documents have been updated
- [ ] If "No updates needed" is checked, confirm reasonableness
- [ ] Output documentation sync status report
```

**If there are unprocessed documentation updates**:
- Output warning, list documents needing updates
- Don't block archive, but mark as "Documentation pending update" in archive report

### Step 6: Change Package Archive Move (New)

Move completed change package to archive directory:

```bash
# Source path
<change-root>/<change-id>/

# Target path
<change-root>/archive/<change-id>/
```

**Move Flow**:

1. **Create archive directory** (if doesn't exist): `<change-root>/archive/`
2. **Set final status**: Set `Status: Archived` in verification.md
3. **Add archive timestamp**: Add `Archived-At: <timestamp>` at end of verification.md
4. **Move change package**: `mv <change-root>/<change-id>/ <change-root>/archive/<change-id>/`
5. **Output archive completion report**

**verification.md Archive Status Update**:

```markdown
---
status: Archived
archived-at: 2024-01-16T10:30:00Z
archived-by: devbooks-archiver
---
```

---

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gates).
2) Strictly execute the complete prompt: `references/archiver-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect `<truth-root>/` directory status
2. If change-id is provided, detect change package archive conditions
3. Detect duplicate/obsolete specs (maintenance mode)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Archive Mode** | change-id provided and gates pass | Execute complete archive flow (6 steps) |
| **Maintenance Mode** | No change-id | Execute truth-root deduplication, cleanup, organization |
| **Check Mode** | With --dry-run parameter | Output plan only, no actual modifications/moves |

### Archive Mode Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Archive Mode Flow                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Pre-checks                                              │
│     ├─ Change package exists?                               │
│     ├─ verification.md Status = Ready/Done?                 │
│     ├─ evidence/green-final/ exists?                        │
│     └─ tasks.md all completed?                              │
│              │                                               │
│              ▼                                               │
│  2. Auto backport                                           │
│     ├─ Read deviation-log.md                                │
│     ├─ Detect pending backport records                      │
│     └─ Execute backport → Update marks                      │
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
│  5. Documentation sync check                                │
│     └─ Check if Documentation Impact processed              │
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

### Detection Output Example

```
Detection Results:
- truth-root: Exists, contains 12 spec files
- Change package: Exists, all gates green
- Backport status: 2 pending backport records
- Running mode: Archive mode (complete flow)
```

---

## Archive Report Template

After archive completion, output the following report:

```markdown
## Archive Report

### Change Package Info
- Change ID: <change-id>
- Archive Time: <timestamp>

### Execution Summary
| Step | Status | Notes |
|------|--------|-------|
| Pre-checks | ✅ | All passed |
| Auto backport | ✅ | Backported 2 records |
| Spec merge | ✅ | Merged 3 spec files |
| Architecture merge | ⏭️ | No architecture changes |
| Doc check | ⚠️ | README.md needs update |
| Archive move | ✅ | Moved to archive/ |

### Archive Location
`<change-root>/archive/<change-id>/`

### Follow-up Recommendations
- [ ] Update README.md (doc check warning)
```

---

## Maintenance Mode Responsibilities

In maintenance mode (no change-id), execute:

- Detect duplicate spec definitions
- Clean up obsolete/deprecated specs
- Organize directory structure
- Fix consistency issues

---

## MCP Enhancement

This Skill does not depend on MCP services; no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

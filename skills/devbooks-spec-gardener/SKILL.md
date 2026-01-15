---
name: devbooks-spec-gardener
description: devbooks-spec-gardener: Prune and maintain <truth-root> before archiving (deduplicate/merge, remove obsolete, organize directories, fix inconsistencies) to prevent specs from accumulating out of control. Use when user says "spec gardener/deduplicate specs/pre-archive cleanup/clean obsolete specs", or during DevBooks archive/pre-archive finalization.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Spec Gardener

## Workflow Position Awareness

> **Core Principle**: Spec Gardener is the endpoint of the archive phase, responsible for merging change package artifacts into truth, **and automatically handling any pending backports**.

### My Position in the Overall Workflow

```
proposal → design → test-owner → coder → test-owner(verify) → code-review → [Spec Gardener/Archive]
                                                                                    ↓
                                                               Auto backport + Merge to truth + Archive
```

### Spec Gardener's Responsibilities

1. **Auto backport detection**: Check if deviation-log.md has pending backport records
2. **Auto execute backport**: If pending records exist, automatically execute design backport
3. **Merge to truth**: Merge specs/contracts/architecture into truth-root
4. **Archive change package**: Set verification.md Status = Archived

### Why Auto Backport in Archive Phase?

**Design Decision**: Users only need to call skills linearly, no need to judge whether backport is needed.

| Scenario | Old Design (Manual judgment) | New Design (Auto handling) |
|----------|------------------------------|---------------------------|
| Coder has deviations | User needs to call design-backport → then archive | Spec Gardener auto-detects and backports |
| Coder has no deviations | Archive directly | Archive directly |

---

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Critical Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

---

## Core Responsibilities

### 0. Auto Backport Detection and Handling (Required Before Archive)

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

**deviation-log.md Update Format**:

```markdown
| Time | Type | Description | Affected Files | Backported | Batch |
|------|------|-------------|----------------|:----------:|-------|
| 2024-01-15 10:30 | DESIGN_GAP | Concurrent scenario | tests/... | ✅ | archive-2024-01-16 |
| 2024-01-15 11:00 | IMPL_ONLY | Variable rename | src/... | ⏭️ | (skipped) |
```

### 1. Spec Merge and Maintenance

During archive phase, merge change package spec artifacts into `<truth-root>`:

| Source Path | Target Path | Merge Strategy |
|-------------|-------------|----------------|
| `<change-root>/<change-id>/specs/**` | `<truth-root>/specs/**` | Incremental merge |
| `<change-root>/<change-id>/contracts/**` | `<truth-root>/contracts/**` | Versioned merge |

### 2. C4 Architecture Map Merge (New)

> **Design Decision**: C4 architecture changes are now recorded in design.md's Architecture Impact section and merged into truth by spec-gardener during archiving.

During archive phase, detect and merge architecture changes:

| Detection Source | Target Path | Merge Logic |
|------------------|-------------|-------------|
| "Architecture Impact" section in `<change-root>/<change-id>/design.md` | `<truth-root>/architecture/c4.md` | Incremental update |

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

**Merge Output Format** (appended to c4.md):

```markdown
## Change History

| Date | Change ID | Impact Summary |
|------|-----------|----------------|
| <date> | <change-id> | <brief description of architecture changes> |
```

### 3. Deduplication and Cleanup

Execute in maintenance mode:

- Detect duplicate spec definitions
- Clean up obsolete/deprecated specs
- Organize directory structure
- Fix consistency issues

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gates).
2) Strictly execute the complete prompt: `references/spec-gardener-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate maintenance mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect `<truth-root>/` directory status
2. If change-id is provided, detect change package archive conditions
3. Detect duplicate/obsolete specs

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Archive Mode** | change-id provided and gates pass | **Auto backport** → Merge to truth-root → Set Status=Archived |
| **Maintenance Mode** | No change-id | Execute deduplication, cleanup, organization operations |
| **Check Mode** | With --dry-run parameter | Output suggestions only, no actual modifications |

### Archive Mode Complete Flow

```
1. Pre-checks:
   - [ ] Change package exists
   - [ ] verification.md Status = Ready or Done
   - [ ] evidence/green-final/ exists
   - [ ] tasks.md all [x]

2. Auto backport (if needed):
   - [ ] Detect deviation-log.md
   - [ ] Backport to design.md
   - [ ] Update deviation-log.md marks

3. Merge to truth:
   - [ ] Merge specs/**
   - [ ] Merge contracts/**
   - [ ] Merge Architecture Impact to c4.md

4. Archive:
   - [ ] Set verification.md Status = Archived
   - [ ] Output archive report
```

### Detection Output Example

```
Detection Results:
- truth-root: Exists, contains 12 spec files
- Change package: Exists, all gates green
- Running mode: Archive mode
```

---

## MCP Enhancement

This Skill does not depend on MCP services; no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`


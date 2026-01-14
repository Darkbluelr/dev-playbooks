---
name: devbooks-docs-sync
description: "devbooks-docs-sync: Maintains consistency between project documentation (README, API docs, and other user-facing docs) and code. Supports incremental mode (for changes) and global mode (consistency check). Use when user says update docs/sync docs/align docs/README update/API docs update."
allowed-tools:
  - Glob
  - Grep
  - Read
  - Edit
  - Write
  - Bash
---

# DevBooks: Docs Sync

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) -> Template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

---

## Role Definition

**docs-sync** is a documentation maintenance role in the DevBooks Apply phase, responsible for ensuring user-facing documentation stays consistent with code.

### Document Classification

| Document Type | Target Audience | Maintained by This Skill | Examples |
|---------------|-----------------|:------------------------:|----------|
| **User Docs** | End users | ✅ | README.md, docs/*.md, API.md |
| **Developer Specs** | AI/Developers | ❌ (maintained by other skills) | dev-playbooks/, AGENTS.md |
| **Code Comments** | Developers | ❌ (maintained by coder) | JSDoc, inline comments |

### Differences from Other Roles

| Dimension | docs-sync | coder | reviewer |
|-----------|:---------:|:-----:|:--------:|
| Maintain user docs | ✅ | ❌ | ❌ |
| Modify code | ❌ | ✅ | ❌ |
| Modify tests | ❌ | ❌ | ❌ |
| Review code quality | ❌ | ❌ | ✅ |

---

## Key Constraints

### CON-DOCS-001: Only Maintain User Documentation
- **Allowed to modify**: README.md, docs/, API.md, CHANGELOG.md, configuration guides, etc.
- **Prohibited from modifying**: dev-playbooks/, AGENTS.md, CLAUDE.md, src/, tests/

### CON-DOCS-002: Do Not Introduce New Features
- Only sync documentation for existing features
- Do not add descriptions for features that don't exist in code
- If missing features are found, suggest rather than add

### CON-DOCS-003: Maintain Style Consistency
- Follow the project's existing documentation style
- Use unified terminology from `<truth-root>/_meta/glossary.md`
- Maintain language consistency (if project has multi-language docs)

---

## Running Modes

### Mode One: Incremental Mode (Change-Scoped)

**Trigger Condition**: Running in change package context

**Behavior**:
1. Analyze public API/features/configuration affected by this change
2. Locate related user documentation
3. Update affected documentation sections
4. Output change summary

**Execution Flow**:
```
1. Read <change-root>/<change-id>/design.md to understand change content
2. Identify impact scope:
   - New/modified public APIs
   - Configuration changes
   - User-visible behavior changes
3. Locate documentation needing updates:
   - Feature descriptions in README.md
   - Interface documentation in API.md
   - Usage guides in docs/
4. Execute updates and record
```

### Mode Two: Global Mode (Global Sync)

**Trigger Condition**: User explicitly requests global sync (e.g., `devbooks-docs-sync --global`)

**Behavior**:
1. Scan all public APIs and features in the project
2. Compare documentation coverage
3. Generate difference report
4. Execute fixes after user confirmation

**Execution Flow**:
```
1. Scan public interfaces in code (exported functions, classes, configurations)
2. Scan feature descriptions in user documentation
3. Generate comparison matrix:
   - Code exists, docs missing: needs addition
   - Code missing, docs exists: outdated docs
   - Code and docs inconsistent: needs sync
4. Output difference report
5. Execute fixes after user confirmation
```

---

## Checklist

### Documentation Coverage Check

- [ ] Does feature list in README.md match actual features
- [ ] Does API documentation cover all public interfaces
- [ ] Does configuration guide match actual config options
- [ ] Can example code run correctly

### Consistency Check

- [ ] Does terminology in docs match glossary.md
- [ ] Does version number match package.json
- [ ] Do CLI examples match actual CLI
- [ ] Are links valid (no dead links)

### Completeness Check

- [ ] Is installation guide complete
- [ ] Is quick start usable
- [ ] Is FAQ updated
- [ ] Does CHANGELOG record important changes

---

## Output Format

### Incremental Mode Output

```markdown
# Docs Sync Report: <change-id>

## Impact Analysis

| Change Type | Affected Item | Related Docs |
|-------------|---------------|--------------|
| New API | `createWidget()` | README.md, API.md |
| Config Change | `timeout` param | docs/config.md |
| Removed Feature | `legacyMode` | README.md |

## Update Summary

### README.md
- [x] Updated feature list, added `createWidget` description
- [x] Removed `legacyMode` related description

### API.md
- [x] Added `createWidget()` interface documentation

## Conclusion

✅ **SYNCED** - Documentation sync completed
```

### Global Mode Output

```markdown
# Global Docs Sync Report

## Coverage Statistics

| Type | Code Count | Doc Count | Coverage |
|------|------------|-----------|----------|
| Public Functions | 25 | 22 | 88% |
| Config Options | 10 | 10 | 100% |
| CLI Commands | 5 | 4 | 80% |

## Difference List

### Missing Docs (code exists, docs missing)
1. `parseConfig()` - src/config.ts:42
2. `validateInput()` - src/utils.ts:15

### Outdated Docs (code missing, docs exists)
1. `oldFunction()` - removed in v2.0

### Inconsistent Items
1. `timeout` param: code default 30s, docs say 60s

## Suggested Actions

1. Add documentation for `parseConfig()`
2. Remove documentation for `oldFunction()`
3. Correct default value description for `timeout`

Execute above fixes? [Y/n]
```

---

## Workflow Integration

### Position in Delivery Workflow

```
Design → Plan → Test → Implement → Review → [Docs Sync] → Archive
```

### Trigger Timing

| Phase | Trigger Condition | Mode |
|-------|-------------------|------|
| After implementation | Change affects public API | Incremental |
| Before archive | User request | Incremental |
| Standalone run | User explicit request | Global |

### Should Every Change Run This?

**No**. Only changes meeting the following conditions need this:

- Add/modify/remove public API
- Change user-visible behavior
- Modify configuration options
- Change CLI commands

**These cases don't need it**:

- Pure refactoring (no public interface changes)
- Bug fixes (no behavior changes)
- Internal implementation optimization
- Test code changes

---

## How to Avoid Missing Updates

### 1. Mark in design.md

Add `[Docs-Required]` marker in design.md:

```markdown
## Change Description

This change adds a new `createWidget()` API. [Docs-Required]
```

### 2. Include Documentation Tasks in tasks.md

```markdown
## Task List

- [ ] Implement createWidget API
- [ ] Add unit tests
- [ ] [Docs] Update API.md
- [ ] [Docs] Update README.md
```

### 3. Check During Review Phase

Check for incomplete documentation tasks during code-review.

---

## Context Awareness

This Skill automatically detects context before execution to select the appropriate running mode.

### Detection Flow

1. Detect if in change package context
2. Detect if `--global` parameter exists
3. Detect if change package affects public API

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Incremental Mode** | In change package context | Only update docs related to this change |
| **Global Mode** | With --global parameter | Scan all docs and generate difference report |
| **Check Mode** | With --check parameter | Check only, no modifications, output report |

### Detection Output Example

```
Detection Results:
- Change package context: Exists (CHG-2024-001)
- Affects public API: Yes (2 new, 1 modified)
- Running mode: Incremental Mode
```

---

## MCP Enhancement

This Skill can optionally use MCP services for enhanced functionality.

### Optional MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__searchSymbols` | Search public APIs | 2s |
| `mcp__ckb__getModuleOverview` | Get module overview | 2s |

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| API Discovery | Automatically identify all exports | File glob search |
| Impact Analysis | Precise call relationships | Infer from file names |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
⚠️ CKB unavailable, using basic mode scan.
Suggestion: Manually specify module paths to check.
```

---

## Metadata

| Field | Value |
|-------|-------|
| Skill Name | devbooks-docs-sync |
| Phase | Apply (after implementation, before archive) |
| Artifact | Updated user documentation |
| Constraints | CON-DOCS-001~003 |

---

*This Skill document follows the devbooks-* specification.*

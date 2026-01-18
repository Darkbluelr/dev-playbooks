# Skills Configuration Discovery Template

> This template defines the configuration discovery flow that all `devbooks-*` Skills must follow before execution.

---

## Prerequisite: Configuration Discovery (Protocol Agnostic)

Before any operation, **must** search for configuration in the following order (stop when found):

### Search Order

1. `.devbooks/config.yaml` (if present) -> parse mappings
2. `dev-playbooks/project.md` (if present) -> use DevBooks default mappings
3. `project.md` (if present) -> use template default mappings
4. If still unknown -> **stop and ask the user**

### Default Mapping Table

| Protocol | truth_root | change_root | agents_doc |
|----------|------------|-------------|------------|
| devbooks | `dev-playbooks/specs/` | `dev-playbooks/changes/` | `dev-playbooks/project.md` |
| template | `specs/` | `changes/` | `project.md` |

### Read from Config

- `truth_root`: truth directory root (final version of system specs)
- `change_root`: change directory root (all artifacts per change)
- `agents_doc`: rules document location (must be read by the AI)
- `project_profile`: project profile location (optional, for fast context)

### Key Constraints

1. **If `agents_doc` exists, you must read it before any operation**
2. Do not guess directory roots
3. Do not skip reading the rules document
4. Do not proceed without confirmed config

### Recommended Approach

Run the config discovery script:

```bash
DEVBOOKS_SCRIPTS="${CODEX_HOME:-$HOME/.codex}/skills/devbooks-delivery-workflow/scripts"
# or
DEVBOOKS_SCRIPTS="${CLAUDE_CODE_HOME:-$HOME/.claude-code}/skills/devbooks-delivery-workflow/scripts"

source <("$DEVBOOKS_SCRIPTS/../config-discovery.sh")
# Now you can use $truth_root, $change_root, $agents_doc, etc.
```

---

## How to Use This Template in SKILL.md

Add the following to the beginning of each SKILL.md:

```markdown
## Prerequisite: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: current truth directory root
- `<change-root>`: change package directory root

Before execution, **must** search for configuration in this order (stop when found):
1. `.devbooks/config.yaml` (if present)
2. `dev-playbooks/project.md` (if present)
3. `project.md` (if present)
4. If still unknown -> **stop and ask the user**

**Key constraint**: If `agents_doc` is specified in config, you must read it before any operation.
```

---

## Example: Updated SKILL.md

### Before (hardcoded)

```markdown
## Prerequisite: Directory Roots (Protocol Agnostic)

- `<truth-root>`: current truth directory root (default `specs/`; DevBooks uses `dev-playbooks/specs/`)
- `<change-root>`: change package directory root (default `changes/`; DevBooks uses `dev-playbooks/changes/`)

Before execution, attempt to read `dev-playbooks/project.md` (if present) to determine `<truth-root>/<change-root>`; do not guess. If still unknown, ask the user.
```

### After (config discovery)

```markdown
## Prerequisite: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: current truth directory root
- `<change-root>`: change package directory root

Before execution, **must** search for configuration in this order (stop when found):
1. `.devbooks/config.yaml` (if present) -> parse mappings
2. `dev-playbooks/project.md` (if present) -> DevBooks protocol defaults
3. `project.md` (if present) -> template protocol defaults
4. If still unknown -> **stop and ask the user**

**Key constraints**:
- If `agents_doc` is specified, read it before any operation
- Do not guess directory roots
- Do not skip reading the rules document
```

---

## Batch Update Script (Reference)

```bash
#!/bin/bash
# Batch update all Skills SKILL.md files

OLD_PATTERN='Before execution, attempt to read `dev-playbooks/project.md`'
NEW_TEXT='Before execution, **must** search for configuration'

for skill_dir in skills/devbooks-*/; do
    skill_md="$skill_dir/SKILL.md"
    if [ -f "$skill_md" ] && grep -q "$OLD_PATTERN" "$skill_md"; then
        echo "Updating: $skill_md"
        # Actual update needs more complex sed
    fi
done
```

# setup/ (DevBooks setup)

## What is DevBooks?

DevBooks is a **change-management workflow** that provides:

- **DevBooks protocol**: proposal → apply → archive (3-stage change management)
- **Role isolation**: Test Owner / Coder / Reviewer operate independently
- **Skills collection**: devbooks-coder, devbooks-test-owner, devbooks-router, etc.
- **Slash commands / prompts**: DevBooks command entry points for supported tools

## Installation

### Option 1: Use the installation prompt (for an AI assistant)

Tell your AI assistant:
```
Please follow `setup/generic/Installation-Prompt.md` to complete DevBooks setup.
```

### Option 2: Install Skills + Codex prompts (from this repo)

```bash
./scripts/install-skills.sh --with-codex-prompts
```

This installs:
- DevBooks Skills (to `~/.claude/skills/` and `~/.codex/skills/`)
- Codex prompts (to `~/.codex/prompts/`, enabled via `--with-codex-prompts`)

### Option 3: Install system dependencies

```bash
./scripts/install-dependencies.sh
```

## Directory layout

```
setup/
└── generic/                        # Protocol-agnostic templates
    ├── DevBooks-Integration-Template.md
    └── Installation-Prompt.md      # Primary AI-driven setup entry point
```

## After setup

- ✅ DevBooks workflow is available (proposal/apply/archive)
- ✅ DevBooks Skills are available (devbooks-coder, devbooks-test-owner, etc.)
- ✅ Codex prompts are available (if installed with `--with-codex-prompts`)
- ✅ Role isolation is enforced by the playbooks
- ✅ Changes are traceable and archivable

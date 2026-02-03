<!-- DEVBOOKS:START -->
# DevBooks Instructions

These instructions apply to Claude Code.

## Language preference

**Default to English**: unless explicitly requested otherwise, all outputs should be in English, including:
- Documentation
- Code comments
- Commit messages
- Specs

## Core Concepts

- **SSOT** (`dev-playbooks/ssot/`): Requirements-level source of truth, defines "what the system must do"
- **Spec** (`dev-playbooks/specs/`): Design-level specifications, defines "how modules work"
- See `docs/SSOT-vs-Spec-Boundary.md` for details

## Workflow

When the request matches any of the following, always open `@/AGENTS.md`:
- Mentions planning or proposals (e.g., proposal/spec/change/plan)
- Introduces new features, breaking changes, architecture changes, or major performance/security work
- Is unclear and requires authoritative specs before coding

Use `@/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so `devbooks update` can refresh these instructions.

<!-- DEVBOOKS:END -->

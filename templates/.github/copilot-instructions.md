# GitHub Copilot Instructions (DevBooks)

## Language

- Default to English (unless the user explicitly requests another language).

## Workflow

- If the request involves proposal/spec/change/plan, introduces new features/breaking changes/architecture changes, or is unclear: read `AGENTS.md` first and follow the DevBooks protocol discovery constraints.

## Constraints

- Do not guess directory roots or protocols. Discover config in order: `.devbooks/config.yaml` → `dev-playbooks/project.md` → `project.md`.
- Enforce role isolation: Test Owner and Coder must be in separate sessions; Coder must not modify `tests/`.


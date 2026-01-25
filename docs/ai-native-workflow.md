# AI-Native Workflow

This guide describes the DevBooks AI-native workflow, role boundaries, and evidence loop.

## Entry

- Default entrypoint: Start (Router outputs the shortest closed-loop path)
- If you already know the target step, you can jump directly to the corresponding Skill

## Roles and boundaries

| Role | Responsibility | Key constraint |
| --- | --- | --- |
| Test Owner | Produce acceptance tests and verification traceability | Separate conversation from Coder |
| Coder | Implement according to `tasks.md` | Must not modify `tests/` |
| Reviewer | Maintainability and consistency review | Must not modify `tests/` |

## Workflow stages

1. Proposal: clarify goals and impact
2. Design: define acceptance criteria (AC-xxx) and constraints
3. Spec: define external contracts and behavior specs
4. Plan: break down tasks and verification anchors
5. Test: produce acceptance tests and traceability matrix
6. Implement: implement and produce Green Evidence
7. Review: structural/maintainability review
8. Archive: sync specs and archive the change package

## Evidence and gates

- Evidence folders: `evidence/red-baseline/`, `evidence/green-final/`, `evidence/gates/`, `evidence/risks/`
- Gate model: G0–G6 covering proposal/apply/risk/archive
- Before archive, Green Evidence logs must exist

## Common commands

- `/devbooks:start`: default entrypoint
- `/devbooks:router`: routing and phase detection
- `/devbooks:proposal`: proposal
- `/devbooks:design`: design
- `/devbooks:spec`: spec
- `/devbooks:plan`: plan
- `/devbooks:test`: tests
- `/devbooks:code`: implementation
- `/devbooks:review`: review
- `/devbooks:archive`: archive

## FAQ

- Not sure where to start: use `/devbooks:start`
- Scope unclear: complete Proposal + Impact first
- Tests failing: Coder fixes, but must not modify `tests/`


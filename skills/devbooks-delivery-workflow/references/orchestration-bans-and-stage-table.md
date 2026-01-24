# Orchestration bans and stage table (reference)

This file carries the orchestration bans and the 12-stage table for `devbooks-delivery-workflow`, to keep `SKILL.md` compact.

## Absolute bans (mandatory)

1) Main agent orchestrates only
- Do not directly write `proposal.md` / `design.md` / `tasks.md` / `verification.md`
- Do not directly modify `tests/**` or implementation code

2) Do not skip mandatory stages
- Must run: Proposal → Challenge → Judge → Design → Spec → Plan → Test → Code → Test Review → Code Review → Green Verify → Archive

3) No fake archive
- Do not archive if `evidence/green-final/` is missing/empty
- Do not archive if `change-check.sh <change-id> --mode strict` fails

4) No “demo/simulate”
- Every stage must produce real artifacts on disk; do not replace execution with assumptions

5) `REVISE REQUIRED` triggers rollback
- If Judge/Test-Review/Code-Review returns `REVISE REQUIRED`: go back, fix, and rerun review until it passes

## 12-stage table (mandatory)

| # | Stage | Sub-agent | Skill | Key artifact(s) |
|---:|---|---|---|---|
| 1 | Propose | Proposal Author | `devbooks-proposal-author` | `proposal.md` |
| 2 | Challenge | Proposal Challenger | `devbooks-proposal-challenger` | `challenge-*.md` |
| 3 | Judge | Proposal Judge | `devbooks-proposal-judge` | writes back Decision Log |
| 4 | Design | Design Owner | `devbooks-design-doc` | `design.md` |
| 5 | Spec | Spec Owner | `devbooks-spec-contract` | `specs/**` |
| 6 | Plan | Planner | `devbooks-implementation-plan` | `tasks.md` |
| 7 | Test-Red | Test Owner | `devbooks-test-owner` | `verification.md` + `tests/**` + Red evidence |
| 8 | Code | Coder | `devbooks-coder` | implementation changes (must not change tests) |
| 9 | Test-Review | Test Reviewer | `devbooks-test-reviewer` | `test-review-*.md` |
| 10 | Code-Review | Reviewer | `devbooks-reviewer` | `code-review-*.md` |
| 11 | Green-Verify | Test Owner | `devbooks-test-owner` | Green evidence |
| 12 | Archive | Archiver | `devbooks-archiver` | moved under `archive/` |

## Resume (recommended)

- If a change package already exists: resume from the most recent completed stage, do not redo confirmed artifacts.
- After each stage: write evidence under `evidence/` and leave trace in the change package docs.


# Subagent Invocation Specification

## Invocation Format

Use Task tool to invoke subagents:

```markdown
## Invoke devbooks-proposal-author Subagent

Please execute the following task:
- Use devbooks-proposal-author skill
- Create change proposal for the following requirement: [requirement description]
- Generate spec-compliant change-id
- Output change-id and proposal.md path upon completion
```

## Invocation Examples by Phase

| Phase | Subagent | Invocation Prompt |
|-------|----------|-------------------|
| 1 | devbooks-proposal-author | "Use devbooks-proposal-author skill to create change proposal for [requirement]" |
| 2 | devbooks-challenger | "Use devbooks-proposal-challenger skill to challenge proposal for change [change-id]" |
| 3 | devbooks-judge | "Use devbooks-proposal-judge skill to judge change [change-id]" |
| 4 | devbooks-designer | "Use devbooks-design-doc skill to create design document for change [change-id]" |
| 5 | devbooks-spec-owner | "Use devbooks-spec-contract skill to define specs for change [change-id]" |
| 6 | devbooks-planner | "Use devbooks-implementation-plan skill to create plan for change [change-id]" |
| 7 | devbooks-test-owner | "Use devbooks-test-owner skill to write tests and establish Red baseline for change [change-id]" |
| 8 | devbooks-coder | "Use devbooks-coder skill to implement functionality for change [change-id]" |
| 9 | devbooks-reviewer | "Use devbooks-test-reviewer skill to review tests for change [change-id]" |
| 10 | devbooks-reviewer | "Use devbooks-code-review skill to review code for change [change-id]" |
| 11 | devbooks-test-owner | "Use devbooks-test-owner skill to run all tests and collect Green evidence for change [change-id]" |
| 12 | devbooks-archiver | "Use devbooks-archiver skill to archive change [change-id]" |

## Role Isolation Constraints

**Key Principle**: Test Owner and Coder must use **independent Agent instances/sessions**.

| Role | Isolation Requirement | Reason |
|------|----------------------|--------|
| Test Owner (Phase 7, 11) | Independent Agent | Prevent Coder from tampering with tests |
| Coder (Phase 8) | Independent Agent | Prevent Coder from seeing test implementation details |
| Reviewer (Phase 9, 10) | Independent Agent (recommended) | Maintain review objectivity |

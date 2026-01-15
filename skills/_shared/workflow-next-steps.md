# DevBooks Workflow Next Steps Reference

This document defines the canonical next step recommendations for each skill. All skills should reference this file to ensure consistent workflow guidance.

## Workflow Order

```
┌─────────────────────────────────────────────────────────────────┐
│                     PROPOSAL STAGE                               │
│  proposal-author → impact-analysis → design-doc → spec-contract │
│                                          ↓                       │
│                                implementation-plan               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      APPLY STAGE                                 │
│      test-owner (Chat A) ←→ coder (Chat B)                      │
│      (must be separate conversations)                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     REVIEW STAGE                                 │
│                      code-review                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     ARCHIVE STAGE                                │
│                     archiver                                │
└─────────────────────────────────────────────────────────────────┘
```

## Next Step Matrix

| Current Skill | Next Step(s) | Condition |
|---------------|--------------|-----------|
| `devbooks-proposal-author` | `devbooks-impact-analysis` | If cross-module impact is unclear |
| `devbooks-proposal-author` | `devbooks-design-doc` | If impact is clear |
| `devbooks-proposal-author` | `devbooks-proposal-challenger` | If high risk (optional) |
| `devbooks-impact-analysis` | `devbooks-design-doc` | Always |
| `devbooks-proposal-challenger` | `devbooks-proposal-judge` | Always |
| `devbooks-proposal-judge` | `devbooks-design-doc` | If Approved/Revise |
| `devbooks-design-doc` | `devbooks-spec-contract` | If external behavior/contract changes |
| `devbooks-design-doc` | `devbooks-implementation-plan` | If no external contract changes |
| `devbooks-spec-contract` | `devbooks-implementation-plan` | Always (NEVER recommend test-owner/coder directly) |
| `devbooks-implementation-plan` | `devbooks-test-owner` | Always (must be separate chat) |
| `devbooks-test-owner` | `devbooks-coder` | After Red baseline (must be separate chat) |
| `devbooks-coder` | `devbooks-code-review` | After all tasks completed |
| `devbooks-code-review` | `devbooks-archiver` | If spec deltas exist |
| `devbooks-code-review` | Archive complete | If no spec deltas |
| `devbooks-test-reviewer` | `devbooks-coder` | If test issues found, hand back |
| `devbooks-design-backport` | `devbooks-implementation-plan` | Rerun plan after design update |
| `devbooks-archiver` | Archive complete | Always |

## Critical Constraints

### Proposal Stage Flow
```
proposal-author → [impact-analysis] → design-doc → [spec-contract] → implementation-plan
```
- `spec-contract` is required if external behavior/contract changes
- `impact-analysis` is recommended for cross-module changes
- **NEVER skip to test-owner/coder from spec-contract or design-doc**

### Apply Stage Flow
```
implementation-plan → test-owner (Chat A) ←→ coder (Chat B)
```
- Test Owner and Coder **must be in separate conversations**
- Test Owner produces Red baseline first
- Coder implements per tasks.md, makes gates Green

### Role Isolation Rules
- Author, Challenger, Judge: separate conversations for debate
- Test Owner, Coder: separate conversations (hard requirement)
- Coder **cannot modify** `tests/**`

## Standard Next Step Output Format

When recommending next steps, use this format:

```markdown
## Recommended Next Steps

Based on current artifacts, the recommended next skill is:

**Next: `devbooks-<skill-name>`**

Reason: <why this skill is next in the workflow>

### How to invoke
```
Run devbooks-<skill-name> skill for change <change-id>
```

### Alternative paths (if applicable)
- If <condition>: use `devbooks-<alternative-skill>` instead
```

## Common Mistakes to Avoid

1. **After spec-contract, recommending test-owner/coder directly**
   - Correct: spec-contract → implementation-plan → test-owner

2. **After design-doc, recommending coder directly**
   - Correct: design-doc → [spec-contract] → implementation-plan → test-owner → coder

3. **Recommending test-owner and coder in the same chat**
   - Correct: Always mention "must be separate conversation"

4. **Skipping implementation-plan**
   - implementation-plan is required before apply stage

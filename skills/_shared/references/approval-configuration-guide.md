# Approval Configuration Guide

> This document explains how to configure the approval mechanism, including default approval, timeout settings, etc.

## Configuration File Location

```
.devbooks/config.yaml
```

## Configuration Example

```yaml
# Approval configuration
approval:
  # Default approval strategy
  # - auto_approve: Auto-approve after timeout (default)
  # - require_explicit: Must explicitly approve
  # - disabled: Disable approval mechanism
  default_strategy: auto_approve

  # Timeout (hours)
  timeout:
    proposal: 48      # Proposal needs 48 hours
    design: 24        # Design needs 24 hours
    tasks: 24         # Tasks needs 24 hours
    verification: 12  # Verification needs 12 hours

  # Whether explicit approval is required
  require_explicit:
    proposal: true    # Proposal must be explicitly approved
    design: false     # Design can be auto-approved
    tasks: false      # Tasks can be auto-approved
    verification: false  # Verification can be auto-approved

  # Approval methods
  approval_methods:
    - cli           # Command-line approval
    - chat          # Chat approval
    - auto          # Auto-approval

  # Notification methods
  notification:
    - terminal      # Terminal notification
    # - desktop     # Desktop notification (optional)
    # - email       # Email notification (optional)
```

## Configuration Details

### 1. Default Approval Strategy

| Strategy | Description | Use Case |
|----------|-------------|----------|
| `auto_approve` | Auto-approve after timeout | Most cases (recommended) |
| `require_explicit` | Must explicitly approve | High-risk projects |
| `disabled` | Disable approval mechanism | Complete trust in AI |

### 2. Timeout Settings

- **Proposal**: 48 hours (needs more time to think)
- **Design**: 24 hours (technical details)
- **Tasks**: 24 hours (task breakdown)
- **Verification**: 12 hours (acceptance results)

**Recommendations**:
- Personal projects: Can shorten timeout (e.g., 12/6/6/3 hours)
- Team projects: Keep default timeout
- High-risk projects: Extend timeout (e.g., 72/48/48/24 hours)

### 3. Explicit Approval Required

- **true**: Must explicitly approve, won't auto-approve
- **false**: Auto-approve after timeout

**Recommendations**:
- Set Proposal to true (important decisions)
- Set other phases to false (reduce burden)

### 4. Approval Methods

#### CLI Approval

```bash
# Approve
devbooks approve <change-id> --stage proposal

# Reject
devbooks reject <change-id> --stage proposal --reason "reason"

# Revise
devbooks revise <change-id> --stage proposal
```

#### Chat Approval

Say directly in chat:
- "agree" / "approve"
- "disagree" / "reject"
- "I want to modify XXX"

#### Auto-approval

Auto-approve after timeout (based on configuration)

### 5. Notification Methods

- **terminal**: Terminal notification (default)
- **desktop**: Desktop notification (requires additional configuration)
- **email**: Email notification (requires additional configuration)

## Approval Process

### 1. Creation Phase

After AI creates a document, it adds an approval block at the end:

```markdown
## ✅ Approval Process

**Current status**:
- 📝 Status: Pending approval
- ⏰ Created at: 2026-01-19 10:00
- ⏰ Timeout at: 2026-01-20 10:00 (after 24 hours)

**If you agree**:
- [ ] ✅ Approve, start next phase

**If you disagree**:
- [ ] ❌ Reject, explain reason

**Default choice**: ✅ Approve (auto-approved after 24 hours)
```

### 2. Notification Phase

System reminds users through configured notification methods:

```
⏰ Reminder: Proposal pending approval
- Change: 20260119-1000-add-feature-x
- Phase: Proposal
- Timeout at: 2026-01-20 10:00 (23 hours remaining)
- Action: devbooks approve 20260119-1000-add-feature-x --stage proposal
```

### 3. Approval Phase

Users can approve through:

- **CLI**: `devbooks approve <change-id> --stage proposal`
- **Chat**: Say "agree" directly
- **Auto**: Do nothing, wait for timeout

### 4. Timeout Phase

If timeout and configured as `auto_approve`, system auto-approves:

```
✅ Auto-approved: Proposal
- Change: 20260119-1000-add-feature-x
- Phase: Proposal
- Reason: Auto-approved after timeout (24 hours)
```

### 5. Recording Phase

All approval actions are recorded in approval history:

```markdown
## Approval History

| Time | Phase | Action | Actor | Reason |
|------|-------|--------|-------|--------|
| 2026-01-19 10:00 | Proposal | Created | AI | - |
| 2026-01-20 10:00 | Proposal | Auto-approved | System | 24-hour timeout |
```

## FAQ

### Q1: How to disable auto-approval?

Modify configuration file:

```yaml
approval:
  default_strategy: require_explicit
  require_explicit:
    proposal: true
    design: true
    tasks: true
    verification: true
```

### Q2: How to shorten timeout?

Modify configuration file:

```yaml
approval:
  timeout:
    proposal: 12
    design: 6
    tasks: 6
    verification: 3
```

### Q3: How to view pending approvals?

```bash
devbooks status
```

Output:

```
Pending approvals:
- 20260119-1000-add-feature-x (Proposal, 23 hours remaining)
- 20260119-1100-fix-bug-y (Design, 5 hours remaining)
```

### Q4: How to batch approve?

```bash
devbooks approve --all
```

### Q5: How to revoke approval?

```bash
devbooks revoke <change-id> --stage proposal
```

## Best Practices

### 1. Personal Projects

```yaml
approval:
  default_strategy: auto_approve
  timeout:
    proposal: 12
    design: 6
    tasks: 6
    verification: 3
  require_explicit:
    proposal: false
    design: false
    tasks: false
    verification: false
```

### 2. Team Projects

```yaml
approval:
  default_strategy: auto_approve
  timeout:
    proposal: 48
    design: 24
    tasks: 24
    verification: 12
  require_explicit:
    proposal: true
    design: false
    tasks: false
    verification: false
```

### 3. High-risk Projects

```yaml
approval:
  default_strategy: require_explicit
  timeout:
    proposal: 72
    design: 48
    tasks: 48
    verification: 24
  require_explicit:
    proposal: true
    design: true
    tasks: true
    verification: true
```

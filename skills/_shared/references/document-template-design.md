# Design Document Template

> This template defines the standard structure for design.md to ensure designs are clear, implementable, and verifiable.

## File Location

```
<change-root>/<change-id>/design.md
```

## Standard Structure

```markdown
# <Change Title> - Design Document

## 🎯 Bottom Line Up Front (30-second read)

**This design will result in**:
- ✅ [Change 1 that will happen]
- ✅ [Change 2 that will happen]
- ✅ [Change 3 that will happen]

**This design will NOT result in**:
- ❌ [What won't happen 1]
- ❌ [What won't happen 2]

**Difference from Proposal**:
- 📝 Proposal said "[Proposal content]"
- 🎨 Design says "[Specific implementation approach]"

---

## 🤔 Requirements Alignment Check (2-minute read)

> Purpose: Confirm the design meets your needs

### Quick Check

**In the Proposal phase you chose**:
- Role: [Role name]
- Solution: [Solution name]

**Changes in the Design phase**:
- ⚠️ [New issues or constraints discovered]
- ✅ [Suggested adjustments]
- ⚠️ Trade-offs: [Explain trade-offs]

**Need your confirmation**:
- [ ] ✅ Agree with adjustments ([reason])
- [ ] ❌ Disagree, continue with original plan ([reason])
- [ ] 🤔 I need more information

**Default choice**: ✅ Agree with adjustments (auto-approved after 24 hours)

---

## ✅ Approval Process (1 minute)

**Current status**:
- 📝 Status: Pending approval
- ⏰ Created at: [time]
- ⏰ Timeout at: [time] (after 24 hours)

**If you agree**:
- [ ] ✅ Approve design, start implementation

**If you disagree**:
- [ ] ❌ Reject design, reason: [reason]

**Default choice**: ✅ Approve design (auto-approved after 24 hours)

---

## 📋 Detailed Design (AI reading)

### What (What to do)

#### Objective

[Describe the design objective]

#### Scope

[Explain the design scope]

---

### Constraints

#### Technical Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| [Constraint1] | [Description] | [Impact] |

#### Business Constraints

| Constraint | Description | Impact |
|------------|-------------|--------|
| [Constraint1] | [Description] | [Impact] |

---

### Architecture

#### Component Diagram

```
[Use Mermaid or text to describe component relationships]
```

#### Data Flow

```
[Describe data flow]
```

#### Interface Design

| Interface | Input | Output | Description |
|-----------|-------|--------|-------------|
| [Interface1] | [Input] | [Output] | [Description] |

---

### Acceptance Criteria

#### AC-001: [Acceptance Criteria Title]

**Description**: [One-sentence description]

**Acceptance conditions**:
- [ ] [Condition 1]
- [ ] [Condition 2]

**Testing approach**: [Explain how to test]

---

### Documentation Impact

#### Documents to Update

| Document | Update Reason | Priority |
|----------|---------------|----------|
| [Document1] | [Reason] | P0 |

#### Documents Not Requiring Updates

- [ ] This change is an internal refactoring and doesn't affect user-visible functionality
- [ ] This change only fixes bugs and doesn't introduce new features

---

### Architecture Impact

#### New Dependencies

| Dependency | Version | Purpose | Risk |
|------------|---------|---------|------|
| [Dependency1] | [Version] | [Purpose] | [Risk] |

#### Modified Modules

| Module | Modification Type | Impact Scope |
|--------|-------------------|--------------|
| [Module1] | [Add/Modify/Delete] | [Impact scope] |

---

## Approval History

| Time | Phase | Action | Actor | Reason |
|------|-------|--------|-------|--------|
| [Time] | Design | Created | AI | - |
| [Time] | Design | Approved | User | [Reason] |
```

## Usage Guide

### 1. Purpose of Bottom Line Up Front

- **30-second quick understanding**: Let users immediately know the core content of the design
- **Comparison with Proposal**: Clearly explain the difference between design and proposal
- **Reduce cognitive load**: Use plain language, avoid technical jargon

### 2. Purpose of Requirements Alignment Check

- **Lightweight alignment**: Only requires user confirmation when new issues or constraints are discovered
- **Quick decision**: In most cases, users only need to confirm "agree" or "disagree"
- **Retain control**: Users can reject adjustments at any time

### 3. Purpose of Detailed Design

- **AI reading**: Provides complete technical details for AI reference
- **Humans can skip**: Humans only need to read "Bottom Line Up Front" and "Requirements Alignment Check" sections

### 4. Purpose of Acceptance Criteria

- **Testable**: Each acceptance criterion should be testable
- **Traceable**: Acceptance criteria should correspond to Proposal objectives
- **Verifiable**: Acceptance criteria should clearly explain how to verify

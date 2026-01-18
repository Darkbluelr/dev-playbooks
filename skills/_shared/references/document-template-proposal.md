# Proposal Document Template

> This template defines the standard structure for proposal.md to ensure proposals are clear, reviewable, and actionable.

## File Location

```
<change-root>/<change-id>/proposal.md
```

## Standard Structure

```markdown
# <Change Title>

## 🎯 Executive Summary (30-second read)

**This proposal will result in**:
- ✅ [Change 1 in plain language]
- ✅ [Change 2 in plain language]
- ✅ [Change 3 in plain language]

**This proposal will NOT result in**:
- ❌ [What won't change 1]
- ❌ [What won't change 2]

**One-sentence summary**: [Explain this change in plain language]

---

## 🤔 Alignment Check (5-minute read)

> Purpose: Ensure direction is correct and uncover hidden requirements

### Who are you? (Role identification)

Please select the description that best fits you:

- [ ] **Quick Starter**: Just want to implement features quickly, no hassle
  - Core needs: Simple, fast, good enough
  - Tech preference: Out-of-the-box, no complex configuration

- [ ] **Platform Builder**: Want to develop it into a platform serving more users
  - Core needs: Scalable, high quality, multi-scenario
  - Tech preference: Architecture first, quality first

- [ ] **Rapid Validator**: Want to quickly validate ideas, uncertain if useful
  - Core needs: See results fastest, can optimize later
  - Tech preference: Prototype first, rapid iteration

**If you're unsure**: Default to "Quick Starter", can upgrade later.

---

### What do you want? (Core requirements)

**Basic requirements** (all roles need):
- [x] [Requirement 1]
- [x] [Requirement 2]

**Advanced requirements** (select based on role):
- [ ] [Advanced requirement 1]
- [ ] [Advanced requirement 2]

**If you're unsure**: Only check basic requirements, advanced can be added later.

---

### What might you have missed? (Hidden requirements)

> Purpose: Help you discover potentially overlooked requirements

#### Hidden Requirement 1: [Requirement name]

**Question**: [Guide user thinking with a question]

**Why it matters**: [Explain why this requirement is important]

**Please select**:
- [ ] [Option A]
- [ ] [Option B]

**Default selection**: [Option A]

---

### 🎯 Based on your selection, recommended approach

**If you selected "Quick Starter"**:
Recommended approach: Simple and sufficient version
- [Approach description]
- Trade-off: [Explain trade-off]

**If you selected "Platform Builder"**:
Recommended approach: Complete platform version
- [Approach description]
- Trade-off: [Explain trade-off]

**If you made no selection**:
Default approach: Quick Starter version

---

## ✅ Approval Process (1 minute)

### Quick Approval (Recommended)

**If you agree with the recommended approach**:
- [ ] ✅ I agree with the recommended approach, start immediately

**If you want to customize**:
- [ ] 🔧 I want to customize the approach (need to fill in the table below)

**If you're unsure**:
- [ ] 🤔 I need more information

**Default selection**: ✅ I agree with the recommended approach (auto-approve after 24 hours)

---

## 📋 Detailed Proposal (AI reading)

### Why (Why change)

#### Problem Description

[Describe the current problem]

#### Impact

[Explain the scope and severity of the problem]

---

### What (What to change)

#### Objectives

[Describe the objectives of the change]

#### Scope

[Explain the scope of the change]

---

### Impact (Impact Analysis)

#### Affected Modules

| Module | Impact Type | Impact Level |
|--------|-------------|--------------|
| [Module1] | [Add/Modify/Delete] | [High/Medium/Low] |

#### Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [Risk1] | [High/Medium/Low] | [High/Medium/Low] | [Mitigation] |

---

### Alternatives (Alternative Approaches)

#### Approach A: [Approach name]

**Advantages**:
- [Advantage1]

**Disadvantages**:
- [Disadvantage1]

**Suitable for**: [What scenarios]

#### Approach B: [Approach name]

**Advantages**:
- [Advantage1]

**Disadvantages**:
- [Disadvantage1]

**Suitable for**: [What scenarios]

---

### Decision

**Selected approach**: [Approach name]

**Rationale**: [Explain selection rationale]

---

## Approval History

| Time | Stage | Action | Actor | Reason |
|------|-------|--------|-------|--------|
| [Time] | Proposal | Created | AI | - |
| [Time] | Proposal | Approved | User | [Reason] |
```

## Usage Guide

### 1. Purpose of Executive Summary

- **30-second quick understanding**: Let users immediately know "what will result, what won't result"
- **Reduce cognitive load**: Use plain language, avoid technical jargon
- **Set expectations**: Clearly state scope of changes

### 2. Purpose of Alignment Check

- **Role identification**: Help users clarify their role and requirements
- **Uncover hidden requirements**: Guide users to think about potentially overlooked requirements through questions
- **Multi-perspective recommendations**: Provide different recommendations based on different roles

### 3. Purpose of Approval Process

- **Default approval**: User silence = agreement (auto-approve after 24 hours)
- **Reduce decision burden**: Most cases don't require manual approval
- **Retain control**: Users can reject or customize at any time

### 4. Purpose of Detailed Proposal

- **AI reading**: Provide complete technical details for AI reference
- **Humans can skip**: Humans only need to read "Executive Summary" and "Alignment Check" sections

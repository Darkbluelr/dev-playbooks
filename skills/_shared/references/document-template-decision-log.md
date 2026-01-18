# Decision Log Document Template

> This template defines the standard structure for decision-log.md, used to record all important decisions for easy retrospection and learning.

## File Location

```
<truth-root>/specs/_meta/decision-log.md
```

## Standard Structure

```markdown
# Decision Log: <Project Name>

> **Purpose**: Record all important decisions for easy retrospection and learning

## Decision #001: [Decision Title]

**Decision time**: YYYY-MM-DD
**Decision phase**: Proposal / Design / Tasks / Verification
**Decision maker**: User / AI recommendation / Default

**Background**:
[Why this decision needs to be made]

**Options**:
- Option A: [Description]
  - Advantages: [Advantages]
  - Disadvantages: [Disadvantages]
  - Suitable for: [What scenarios]

- Option B: [Description]
  - Advantages: [Advantages]
  - Disadvantages: [Disadvantages]
  - Suitable for: [What scenarios]

**Decision**:
Choose option [X]

**Reason**:
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Impact**:
- ✅ [Positive impact]
- ⚠️ [Negative impact]
- ⚠️ [Risk]

**Subsequent evolution**:
- YYYY-MM-DD: [Evolution record]

---

## Decision #002: [Decision Title]

...

---

## Decision Template

**Decision #XXX: [Decision Title]**

**Decision time**: YYYY-MM-DD
**Decision phase**: Proposal / Design / Tasks / Verification
**Decision maker**: User / AI recommendation / Default

**Background**:
[Why this decision needs to be made]

**Options**:
- Option A: [Description]
- Option B: [Description]
- Option C: [Description]

**Decision**:
Choose option X

**Reason**:
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Impact**:
- ✅ [Positive impact]
- ⚠️ [Negative impact]
- ⚠️ [Risk]

**Subsequent evolution**:
- YYYY-MM-DD: [Evolution record]
```

## Usage Guide

### 1. Who writes Decision Log?

- **proposal-author**: Records decisions from Proposal phase
- **design-doc**: Records decisions from Design phase
- **implementation-plan**: Records decisions from Tasks phase
- **archiver**: Organizes decision log during archiving

### 2. Who reads Decision Log?

| Skill | Reading Purpose |
|-------|-----------------|
| proposal-author | Understand historical decisions, avoid repeated discussions |
| design-doc | Understand historical reasons for technology selection |
| impact-analysis | Assess long-term impact of decisions |
| archiver | Organize decision log, build knowledge base |

### 3. Purpose of Decision Log

- **Knowledge retention**: Record background, reasons, and impact of decisions
- **Avoid repetition**: Avoid repeated discussions of the same issues
- **Learning and improvement**: Review subsequent evolution of decisions, learn lessons
- **Team collaboration**: Help new members quickly understand project's decision history

### 4. Decision Log Update Frequency

- **Real-time updates**: Record immediately when important decisions are made
- **Regular review**: Review monthly, update "Subsequent evolution" section
- **Archiving organization**: Organize decision log during each archiving, remove outdated decisions

### 5. What decisions need to be recorded?

**Decisions to record**:
- Technology selection (choosing A over B)
- Architecture design (choosing solution A over solution B)
- Important trade-offs (sacrificing X for Y)
- Boundary conditions (explicitly not doing something)

**Decisions not to record**:
- Obvious decisions (like using Git for version control)
- Temporary decisions (like variable naming)
- Reversible decisions (like code formatting)

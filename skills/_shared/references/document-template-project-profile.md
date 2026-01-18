# Project Profile Document Template

> This template defines the standard structure for project-profile.md, used to record user profiles, core requirements, and decision preferences.

## File Location

```
<truth-root>/specs/_meta/project-profile.md
```

## Standard Structure

```markdown
# Project Profile: <Project Name>

## 👤 Who are you? (Role positioning)

**Current role**: [Quick starter / Platform builder / Fast validator / Other]

**Role characteristics**:
- Core needs: [Simple, fast, good enough / Scalable, high quality / Fastest to see results]
- Technical preference: [Out-of-the-box / Architecture-first / Prototype-first]
- Time budget: [1-2 days / 1-2 weeks / Unlimited]
- Technical level: [Beginner / Intermediate / Advanced]

**Role evolution**:
- [Date]: [Role] (Initial)
- [Date]: [Role] (Upgraded) ← If upgraded

---

## 🎯 What do you want? (Core requirements)

### Explicit Requirements (What you clearly stated)

**Functional requirements**:
- ✅ [Requirement 1]
- ✅ [Requirement 2]
- ❌ Don't need [Requirement 3]

**Non-functional requirements**:
- ✅ Accuracy >[X]%
- ✅ Performance <[X] seconds
- ✅ Memory <[X]MB

---

### Hidden Requirements (What you need but didn't say)

**Team collaboration**:
- Team size: [X] people
- Need shared cache: [Yes / No]
- Decision reason: [Reason]

**CI/CD integration**:
- Have CI: [Yes / No]
- Need integration: [Yes / No]
- Decision reason: [Reason]

**Offline usage**:
- Need offline: [Yes / No]
- Decision reason: [Reason]

**Multi-project support**:
- Multi-project: [Yes / No]
- Decision reason: [Reason]

**Historical version analysis**:
- Need it: [Yes / No]
- Decision reason: [Reason]

---

## 🚫 What don't you want? (Boundaries)

**Explicitly not doing**:
- ❌ [Thing not to do 1]
- ❌ [Thing not to do 2]

**Technical constraints**:
- ✅ Can install new tools
- ❌ Can't use cloud services
- ✅ Can use space (<[X]MB)

**Time constraints**:
- ⏰ Must complete within [X] weeks
- ⏰ Each milestone <[X] days

---

## 🧭 Your North Star (Long-term goals)

**Long-term vision**:
[Describe long-term vision]

**Core values**:
- [Value 1] > [Value 2]
- [Value 3] > [Value 4]

**What not to do**:
- Don't do [Thing 1] (Reason: [Reason])
- Don't do [Thing 2] (Reason: [Reason])

---

## 📊 Decision Preferences (Historical decisions)

**Technology selection preference**:
- Tendency: [Mature and stable / Cutting edge]
- Example: [Example]

**Architecture preference**:
- Tendency: [Simple and direct / Complex and flexible]
- Example: [Example]

**Quality preference**:
- Tendency: [Accuracy / Performance]
- Example: [Example]

---

## 🔄 Profile Update Log

| Date | Change | Reason |
|------|--------|--------|
| [Date] | Created profile | Project initialization |
| [Date] | Role upgrade: [Old role] → [New role] | [Reason] |
| [Date] | New requirement: [Requirement] | [Reason] |
```

## Usage Guide

### 1. Who writes Project Profile?

- **Initialization**: brownfield-bootstrap skill creates it during project initialization
- **Updates**: proposal-author skill updates it with each proposal
- **Maintenance**: archiver skill syncs updates during archiving

### 2. Who reads Project Profile?

| Skill | Reading Purpose |
|-------|-----------------|
| proposal-author | Understand user profile, recommend suitable solutions |
| design-doc | Understand technical preferences, choose suitable architecture |
| implementation-plan | Understand time constraints, create reasonable plans |
| archiver | Update profile, record decision evolution |

### 3. Purpose of Profile

- **Personalized recommendations**: Recommend suitable solutions based on user profile
- **Decision consistency**: Ensure all decisions align with user's long-term goals
- **Knowledge retention**: Record user's decision preferences, avoid repeated questions

### 4. Profile Update Frequency

- **Initialization**: When project is created
- **Role upgrade**: When user requirements undergo major changes
- **New requirements**: When new hidden requirements are discovered
- **Regular review**: Review quarterly to ensure profile accuracy

# Tasks Document Template

> This template defines the standard structure for tasks.md to ensure tasks are clear, executable, and trackable.

## File Location

```
<change-root>/<change-id>/tasks.md
```

## Standard Structure

```markdown
# <Change Title> - Task Plan

## 🎯 Bottom Line Up Front (30-second read)

**This task will result in**:
- ✅ [Feature 1 to be implemented]
- ✅ [Feature 2 to be implemented]
- ✅ Development time: [X-Y days]

**This task will NOT result in**:
- ❌ [What won't be modified 1]
- ❌ [What won't be affected 2]

**Difference from Design**:
- 📝 Design said "[Design content]"
- 🔨 Tasks says "Implement in [X] milestones"

---

## ⚡ Quick Approval (30 seconds)

**Task breakdown**:
- MP1: [Milestone 1] ([X-Y days])
- MP2: [Milestone 2] ([X-Y days])
- MP3: [Milestone 3] ([X-Y days])

**If you agree**:
- [ ] ✅ Agree with task breakdown, start implementation

**If you want to adjust**:
- [ ] 🔧 I want to adjust priorities (please explain)
- [ ] 🔧 I want to adjust timeline (please explain)

**Default choice**: ✅ Agree with task breakdown (auto-approved after 24 hours)

---

## ✅ Approval Process (1 minute)

**Current status**:
- 📝 Status: Pending approval
- ⏰ Created at: [time]
- ⏰ Timeout at: [time] (after 24 hours)

**If you agree**:
- [ ] ✅ Approve task plan, start implementation

**If you disagree**:
- [ ] ❌ Reject task plan, reason: [reason]

**Default choice**: ✅ Approve task plan (auto-approved after 24 hours)

---

## 📋 Detailed Tasks (AI reading)

### Main Plan

#### MP1: [Milestone 1 Title]

**Objective**: [Describe milestone objective]

**Task list**:
- [ ] Task 1.1: [Task description]
  - Estimated time: [X hours]
  - Dependencies: None
  - Acceptance criteria: [Acceptance criteria]

- [ ] Task 1.2: [Task description]
  - Estimated time: [X hours]
  - Dependencies: Task 1.1
  - Acceptance criteria: [Acceptance criteria]

**Milestone acceptance**:
- [ ] [Acceptance condition 1]
- [ ] [Acceptance condition 2]

---

#### MP2: [Milestone 2 Title]

**Objective**: [Describe milestone objective]

**Task list**:
- [ ] Task 2.1: [Task description]
  - Estimated time: [X hours]
  - Dependencies: MP1
  - Acceptance criteria: [Acceptance criteria]

**Milestone acceptance**:
- [ ] [Acceptance condition 1]
- [ ] [Acceptance condition 2]

---

### Temp Plan

> Temporary tasks discovered during implementation

- [ ] Temp 1: [Temporary task description]
  - Discovered at: [time]
  - Reason: [Why this task is needed]
  - Estimated time: [X hours]

---

### Checkpoint

> Record key decisions and issues during implementation

#### Checkpoint 1: [time]

**Issue**: [Issue encountered]

**Decision**: [Decision made]

**Impact**: [Impact on task plan]

---

### Progress Tracking

| Milestone | Status | Completed at | Notes |
|-----------|--------|--------------|-------|
| MP1 | ✅ Completed | [time] | - |
| MP2 | 🔄 In progress | - | - |
| MP3 | ⏳ Pending | - | - |

---

## Approval History

| Time | Phase | Action | Actor | Reason |
|------|-------|--------|-------|--------|
| [Time] | Tasks | Created | AI | - |
| [Time] | Tasks | Approved | User | [Reason] |
```

## Usage Guide

### 1. Purpose of Bottom Line Up Front

- **30-second quick understanding**: Let users immediately know the core content of the task
- **Time estimation**: Clearly state development time
- **Reduce cognitive load**: Use plain language, avoid technical jargon

### 2. Purpose of Quick Approval

- **Task breakdown**: Break large tasks into manageable milestones
- **Quick decision**: Users only need to confirm "agree" or "adjust"
- **Default approval**: Auto-approved after 24 hours

### 3. Purpose of Main Plan

- **Structured**: Organize tasks by milestones
- **Trackable**: Each task has clear acceptance criteria
- **Parallelizable**: Clearly define dependencies between tasks

### 4. Purpose of Temp Plan

- **Flexibility**: Record temporary tasks discovered during implementation
- **Traceable**: Explain why this task is needed

### 5. Purpose of Checkpoint

- **Decision recording**: Record key decisions during implementation
- **Issue tracking**: Record issues encountered and solutions
- **Knowledge retention**: Provide reference for similar future tasks

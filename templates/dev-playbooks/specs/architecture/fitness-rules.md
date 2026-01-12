# Fitness Rules

> This document defines the project's Architecture Fitness Functions.
> These rules are used to automatically verify compliance with architectural constraints.

---

## What are Fitness Functions?

Fitness functions are executable architectural constraint checks. They help teams:
- Automate validation of architectural decisions
- Continuously check architectural health in CI/CD
- Prevent architectural erosion

---

## Rule Definition Format

```markdown
### FT-XXX: Rule Name

> Source: <Rule source, such as design document or architectural decision>

**Rule**: <Rule description>

**Check Command**:
\`\`\`bash
<check command>
\`\`\`

**Severity**: Critical | High | Medium | Low
```

---

## Rule List

### FT-001: Layered Dependency Direction

> Source: Architectural Design

**Rule**: Upper layers may depend on lower layers; lower layers must not depend on upper layers.

**Check Command**:
```bash
# Example: Check if domain layer depends on ui layer
grep -r "import.*from.*ui" src/domain/ && echo "FAIL" || echo "OK"
```

**Severity**: Critical

---

### FT-002: Circular Dependencies Prohibited

> Source: Architectural Design

**Rule**: Circular dependencies between modules are prohibited.

**Check Command**:
```bash
# Use madge or similar tool to check
npx madge --circular src/
```

**Severity**: High

---

### FT-003: Test Coverage

> Source: Quality Requirements

**Rule**: Unit test coverage must not be lower than 80%.

**Check Command**:
```bash
npm run test:coverage -- --coverage-threshold='{"global":{"lines":80}}'
```

**Severity**: High

---

## Process for Adding New Rules

1. Propose the new rule in the change package's `design.md`
2. Go through Challenger review and Judge decision
3. Add the rule to this document during archival
4. Add the corresponding check script in CI

---

**Rule Set Version**: v1.0.0
**Last Updated**: {{DATE}}

# Pull Request Template and Guidelines

Inspired by VS Code’s `.github/pull_request_template.md`, this document defines a standard PR workflow.

---

## 1) PR template

```markdown
## Summary

<!-- Describe what this PR does in 1–3 sentences -->

## Related Issues

<!-- Link issues using Fixes #123 or Relates to #456 -->

## Changes

<!-- List the key changes -->

- [ ] Change 1
- [ ] Change 2
- [ ] Change 3

## Type of Change

<!-- Select one -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)

## Test Plan

<!-- Describe how to test this change -->

1. Step 1
2. Step 2
3. Expected result

## Checklist

<!-- Confirm the following -->

- [ ] Code follows project conventions
- [ ] Relevant tests added/updated
- [ ] All tests pass (`npm test`)
- [ ] Relevant docs updated
- [ ] Commit messages follow Conventional Commits
- [ ] Self-reviewed; no debug statements left behind

## Screenshots (if applicable)

<!-- If this includes UI changes, attach screenshots -->
```

---

## 2) PR types and size

### Type definitions

| Type | Prefix | Description |
|------|--------|-------------|
| Bug fix | `fix:` | Fixes issues in existing functionality |
| Feature | `feat:` | Adds new functionality |
| Refactor | `refactor:` | Code improvements without behavioral changes |
| Docs | `docs:` | Documentation-only changes |
| Test | `test:` | Adds or modifies tests |
| Build | `build:` | Build system or dependency changes |
| Performance | `perf:` | Performance optimizations |

### Size guidance

| Size | Lines changed | Review time | Recommendation |
|------|--------------:|------------|----------------|
| XS | < 50 | ~15 minutes | Quick merge |
| S | 50–200 | ~30 minutes | Standard review |
| M | 200–500 | ~1 hour | Careful review |
| L | 500–1000 | 2+ hours | Consider splitting |
| XL | > 1000 | half day+ | **Must split** |

Principle: one PR does one thing; keep it atomic.

---

## 3) Commit conventions

### Conventional Commits format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Examples

```
feat(auth): add OAuth2 login support

- Add OAuth2 provider configuration
- Implement token refresh mechanism
- Add logout cleanup logic

Closes #123
```

```
fix(api): handle null response from external service

The external API sometimes returns null instead of an empty array.
Added defensive check to prevent runtime errors.

Fixes #456
```

### Common types

| Type | Meaning | Example |
|------|---------|---------|
| `feat` | Feature | `feat(user): add profile edit` |
| `fix` | Bug fix | `fix(auth): correct token expiry` |
| `docs` | Docs | `docs(readme): update install guide` |
| `style` | Formatting | `style: fix indentation` |
| `refactor` | Refactor | `refactor(api): extract common logic` |
| `test` | Tests | `test(user): add unit tests` |
| `chore` | Misc | `chore(deps): update lodash` |

---

## 4) Review checklist

### Author self-check

Before opening the PR, confirm:

```bash
# 1) Lint/type checks
npm run lint
npm run compile

# 2) Tests
npm test

# 3) No debug code
rg 'console\\.(log|debug)|debugger' src/ --type ts

# 4) No accidental focused tests
rg '\\.only\\s*\\(' tests/ --type ts

# 5) No secrets
rg '(password|secret|token|key)\\s*[:=]' --type ts -i
```

### Reviewer checklist

When reviewing, focus on:

**Correctness**
- [ ] Does the code implement what the PR describes?
- [ ] Are edge cases handled?
- [ ] Are error cases handled?

**Code quality**
- [ ] Are names clear?
- [ ] Are functions too long?
- [ ] Is there duplicated code?
- [ ] Any obvious performance issues?

**Security**
- [ ] SQL injection risk?
- [ ] XSS risk?
- [ ] Sensitive data protected?

**Tests**
- [ ] Are there relevant tests?
- [ ] Do tests cover major paths?
- [ ] Are tests isolated and repeatable?

**Docs**
- [ ] Public API documented?
- [ ] README needs updates?
- [ ] Changelog needs updates?

---

## 5) PR workflow

### Standard flow

```
1. Create a branch
   git checkout -b feat/feature-name

2. Develop and commit
   git add .
   git commit -m "feat(scope): description"

3. Push branch
   git push -u origin feat/feature-name

4. Open PR
   - Fill the PR template
   - Link issues
   - Request review

5. Address review feedback
   - Reply to comments
   - Push fixes
   - Re-request review

6. Merge
   - Squash and merge (recommended)
   - Delete source branch
```

### Branch naming

| Type | Format | Example |
|------|--------|---------|
| Feature | `feat/<name>` | `feat/user-auth` |
| Fix | `fix/<issue-id>` | `fix/123-login-error` |
| Docs | `docs/<name>` | `docs/api-guide` |
| Refactor | `refactor/<name>` | `refactor/auth-service` |
| Hotfix | `hotfix/<name>` | `hotfix/security-patch` |

---

## 6) Review etiquette

### Authors

- Provide sufficient context
- Respond to feedback promptly
- Respect reviewers’ time
- Avoid overly large PRs

### Reviewers

- Review in a timely manner (within 24–48 hours)
- Provide constructive suggestions
- Explain “why”, not only “what”
- Differentiate “must fix” vs “nice to have”

### Comment format

```markdown
# Must fix
🔴 **Must**: there is a security issue here; add input validation.

# Suggestion
🟡 **Suggestion**: consider using `Array.from()` instead of spread.

# Question
🔵 **Question**: what is the rationale for this timeout value?

# Praise
🟢 **Praise**: nice abstraction!
```

---

## 7) Automation checks

### CI workflow example

```yaml
# .github/workflows/pr-check.yml
name: PR Check

on:
  pull_request:
    branches: [main, develop]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type Check
        run: npm run compile

      - name: Test
        run: npm test

      - name: Check for debug statements
        run: |
          if rg 'console\\.(log|debug)|debugger' src/ --type ts; then
            echo "::error::Found debug statements"
            exit 1
          fi
```

### Required checks

| Check | Description |
|-------|-------------|
| Lint | ESLint rules pass |
| TypeScript | Type check passes |
| Tests | All tests pass |
| Coverage | Coverage not below baseline |
| Build | Build succeeds |

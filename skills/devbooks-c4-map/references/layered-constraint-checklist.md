# Layering Constraints Checklist

Inspired by VS Code’s `code-layering.ts` and `layersChecker.ts`, this document defines practical checks for a layered architecture.

---

## 1) Layer Dependency Checks

### 1.1 Unidirectional Dependency Violations

**How to check**: scan `import`/`require` statements and validate dependency direction.

```typescript
// Violation: base layer importing platform layer
// src/base/utils.ts
import { ConfigService } from '../platform/config';  // ❌ violation

// Correct: platform layer importing base layer
// src/platform/config.ts
import { deepClone } from '../base/utils';  // ✅ allowed
```

**Example commands** (grep/rg):

```bash
# Check whether base illegally imports platform
rg "from ['\"].*platform" src/base/ --type ts

# Check whether common illegally imports browser/node
rg "from ['\"].*(browser|node)" src/common/ --type ts
```

### 1.2 Environment Isolation Violations

| Environment | Forbidden APIs | Detection regex |
|------|-----------|---------|
| common | DOM API | `document\.|window\.|navigator\.` |
| common | Node API | `require\(['"]fs['"]\)|process\.|__dirname` |
| browser | Node API | `require\(['"]fs['"]\)|child_process` |
| node | DOM API | `document\.|window\.|DOM\.` |

### 1.3 contrib Reverse-Dependency Checks

```bash
# Check whether core illegally imports contrib
rg "from ['\"].*contrib" src/core/ --type ts
rg "from ['\"].*contrib" src/workbench/services/ --type ts
```

---

## 2) Layering Constraints Template

Add this to `<truth-root>/architecture/c4.md`:

```markdown
## Architecture Guardrails

### Layering Constraints

This project uses an N-layer architecture with dependency direction: `base ← platform ← domain ← application ← ui`

| Layer | Directory | Responsibility | Allowed deps | Forbidden deps |
|------|------|------|--------|----------|
| base | src/base/ | Utilities, cross-platform abstractions | (none) | all other layers |
| platform | src/platform/ | Platform services, dependency injection | base | domain, app, ui |
| domain | src/domain/ | Business logic, domain model | base, platform | app, ui |
| application | src/app/ | App services, use-case orchestration | base, platform, domain | ui |
| ui | src/ui/ | User interface, interaction logic | all layers | (none) |

### Environment Constraints

| Environment directory | Allowed | Forbidden |
|----------|--------|----------|
| */common/ | platform-agnostic libs | */browser/*, */node/* |
| */browser/ | */common/* | */node/* |
| */node/ | */common/* | */browser/* |

### Validation Commands

```bash
# Layering violations check
npm run valid-layers-check

# Or check manually
rg "from ['\"].*platform" src/base/ --type ts && echo "FAIL: base→platform" || echo "OK"
```
```

---

## 3) Severity Levels for Layering Violations

| Violation type | Severity | Handling |
|----------|----------|----------|
| Lower layer depends on upper layer | **Critical** | must fix immediately; block merge |
| common depends on browser/node | **Critical** | must fix immediately |
| Cross-layer deep import of Internal modules | **High** | use public APIs instead |
| core depends on contrib | **High** | violates extension-point design |
| Cyclic dependencies | **High** | requires refactoring/decoupling |

---

## 4) Integrating Layer Checks

### 4.1 Configure in ESLint (recommended)

```javascript
// eslint.config.js
module.exports = {
  rules: {
    'import/no-restricted-paths': ['error', {
      zones: [
        // base must not import platform
        { target: './src/base', from: './src/platform', message: 'base cannot import platform' },
        // platform must not import domain
        { target: './src/platform', from: './src/domain', message: 'platform cannot import domain' },
        // common must not import browser/node
        { target: './src/**/common', from: './src/**/browser', message: 'common cannot import browser' },
        { target: './src/**/common', from: './src/**/node', message: 'common cannot import node' },
      ]
    }]
  }
};
```

### 4.2 Configure in TypeScript

Create a separate `tsconfig` for each layer:

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "paths": {
      // base layer can only see itself
    }
  },
  "include": ["src/base/**/*"],
  "exclude": ["src/platform/**/*", "src/domain/**/*"]
}
```

### 4.3 Configure in CI

```yaml
# .github/workflows/pr.yml
- name: Check layer constraints
  run: |
    # Check for layering violations
    ./scripts/valid-layers-check.sh || exit 1
```

---

## 5) Layering Refactoring Guide

When a layering violation is found:

1. **Identify the reason**
   - Is the dependency actually legitimate? (You may need to adjust the layering definition.)
   - Can you decouple via interface abstractions?
   - Should the code be moved to the correct layer?

2. **Decoupling strategies**
   - **Dependency injection**: upper layers inject interfaces; lower layers do not depend on implementations
   - **Events**: lower layers publish events; upper layers subscribe
   - **Callbacks**: lower layers accept callback functions and avoid knowing callers

3. **Code movement**
   - If the code belongs in a lower layer, move it to the correct location
   - Update all import paths
   - Run layer checks to confirm the fix

---

## 6) Review Checklist

During code review, check:

- [ ] Do new imports follow layer constraints?
- [ ] Are there deep imports into Internal modules?
- [ ] Does code under `common/` use platform-specific APIs?
- [ ] Does `core` import `contrib`?
- [ ] Are there cyclic dependencies?

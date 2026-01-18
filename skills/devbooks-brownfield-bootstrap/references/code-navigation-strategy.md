# Code Navigation Strategy (Four-Step Method)

This document defines a standard process to quickly locate code in legacy projects.

---

## Core Principle

> **Understand before you change**: You must understand existing structure and intent before modifying any code.

---

## Four-Step Navigation

### Step 1: Semantic Search

**Goal**: Narrow scope quickly based on intent.

**Methods**:
```bash
# Fuzzy search
rg -i "user.*auth" --type ts
rg -i "login|signin|authenticate" --type ts

# Or use IDE semantic search
# VS Code: Cmd+Shift+F -> enter keywords
```

**Tips**:
- Use business terms instead of technical terms
- Try synonyms (login/signin/authenticate)
- Search comments and docstrings

### Step 2: Exact Grep

**Goal**: Find specific function/class/variable definitions.

**Methods**:
```bash
# Function definitions
rg "function\\s+createUser" --type ts
rg "const\\s+createUser\\s*=" --type ts

# Class definitions
rg "class\\s+UserService" --type ts

# Interface definitions
rg "interface\\s+User\\b" --type ts

# Exports
rg "export\\s+(default\\s+)?(function|class|const|interface)\\s+\\w*User" --type ts
```

**Tips**:
- Use `\\b` to ensure word boundaries
- Search exports to find public APIs
- Combine with path filters: `rg "pattern" src/user/`

### Step 3: Trace Imports

**Goal**: Understand dependencies and call chains.

**Methods**:
```bash
# Who imports this module
rg "from ['\"].*userService['\"]" --type ts
rg "import.*UserService" --type ts

# What this module imports
rg "^import" src/services/userService.ts

# Use IDE "Find References"
# VS Code: Right click -> Find All References (Shift+F12)
```

**Tips**:
- Trace from entry points (main.ts, index.ts)
- Watch relative vs absolute imports
- Check re-exports (`export * from` in index.ts)

### Step 4: Review Tests

**Goal**: Understand expected behavior and edge cases.

**Methods**:
```bash
# Find related test files
rg -l "UserService" tests/ src/**/test/

# Inspect test descriptions
rg "describe\\(|it\\(|test\\(" tests/user.service.test.ts

# Inspect mocks and fixtures
rg "mock|stub|fixture" tests/user.service.test.ts
```

**Tips**:
- Tests are the best documentation
- Check `beforeEach` for setup
- Check `expect` for behavior
- Edge-case tests reveal hidden constraints

---

## Strategy Selection

| Scenario | Recommended Strategy | Why |
|---------|----------------------|-----|
| You don't know where a feature lives | Semantic search -> Exact search | Broad to narrow |
| You know the function name | Exact search -> Trace imports | Direct locate |
| You need call relationships | Trace imports -> Review tests | Context |
| You need expected behavior | Review tests | Tests as docs |
| Validate impact before changes | Trace imports | Impact analysis |

---

## Project Structure Recognition

### Common Directory Patterns

**Layered architecture**:
```
src/
├── controllers/   # Entry layer
├── services/      # Business logic
├── repositories/  # Data access
├── models/        # Data models
└── utils/         # Utilities
```

**Feature-sliced architecture**:
```
src/
├── user/
│   ├── user.controller.ts
│   ├── user.service.ts
│   └── user.repository.ts
├── order/
│   ├── order.controller.ts
│   └── ...
```

**VS Code architecture**:
```
src/vs/
├── base/          # Core utilities
├── platform/      # Platform services
├── editor/        # Editor
└── workbench/     # Workbench
    ├── browser/   # UI
    ├── services/  # Services
    └── contrib/   # Contributions
```

### Quick Entry-Point Identification

```bash
# Find main files
rg -l "main|bootstrap|app" --type ts -g "*.ts" | head -10

# Find route definitions
rg "app\\.(get|post|put|delete)|router\\." --type ts

# Find service registration
rg "register|provide|bind" --type ts | head -20
```

---

## Tool Recommendations

### CLI Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `rg` (ripgrep) | Fast text search | `brew install ripgrep` |
| `fd` | Fast file search | `brew install fd` |
| `tree` | Directory tree | `brew install tree` |
| `bat` | Syntax-highlighted view | `brew install bat` |

### IDE Features

| Feature | VS Code Shortcut | Purpose |
|---------|------------------|---------|
| Global search | Cmd+Shift+F | Semantic search |
| Go to definition | F12 | Exact location |
| Find references | Shift+F12 | Trace imports |
| Symbol search | Cmd+T | Quick jump |
| File search | Cmd+P | Quick open |

---

## Checklist

Before modifying code, confirm:

- [ ] Use semantic search to find relevant areas
- [ ] Use exact search to locate definitions
- [ ] Trace imports to understand dependencies
- [ ] Review tests for expected behavior
- [ ] Identify the project structure pattern
- [ ] Confirm entry points and call chains
- [ ] Evaluate impact scope

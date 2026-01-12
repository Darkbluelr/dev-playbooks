# Project Profile

> This document describes the project's technical profile, enabling AI assistants to quickly understand the project context.

---

## Tech Stack

| Category | Technology | Version |
|----------|------------|---------|
| Language | <!-- TypeScript/Python/Go --> | <!-- Version --> |
| Framework | <!-- React/Django/Gin --> | <!-- Version --> |
| Database | <!-- PostgreSQL/MongoDB --> | <!-- Version --> |
| Test Framework | <!-- Jest/pytest/go test --> | <!-- Version --> |
| Build Tool | <!-- webpack/vite/make --> | <!-- Version --> |

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run test` | Run tests |
| `npm run lint` | Run linter |

---

## Project Conventions

### Naming Conventions

- **File names**: kebab-case (e.g., `user-service.ts`)
- **Component names**: PascalCase (e.g., `UserProfile`)
- **Function names**: camelCase (e.g., `getUserById`)
- **Constant names**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### Directory Structure Conventions

```
src/
├── components/     # UI components
├── services/       # Business logic
├── models/         # Data models
├── utils/          # Utility functions
└── tests/          # Test files
```

---

## Quality Gates

| Gate | Threshold | Command |
|------|-----------|---------|
| Unit test coverage | >= 80% | `npm run test:coverage` |
| Type checking | 0 errors | `npm run typecheck` |
| Lint checking | 0 errors | `npm run lint` |
| Build | Success | `npm run build` |

---

## External Services

| Service | Purpose | Environment Variable |
|---------|---------|---------------------|
| <!-- e.g., PostgreSQL --> | <!-- Data storage --> | `DATABASE_URL` |
| <!-- e.g., Redis --> | <!-- Caching --> | `REDIS_URL` |

---

## Special Constraints

<!-- Project-specific constraints or rules -->

---

**Profile Version**: v1.0.0
**Last Updated**: {{DATE}}

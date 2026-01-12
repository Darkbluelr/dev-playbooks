# Coding Style Guidelines

Inspired by VS Code's `guidelines/CODING_GUIDELINES.md`, this document defines concrete code style rules.

---

## 1) Naming Conventions

### TypeScript/JavaScript

| Type | Convention | Examples |
|------|------------|----------|
| Class names | PascalCase | `UserService`, `HttpClient` |
| Interface names | PascalCase (no I prefix) | `User`, `Config` |
| Function names | camelCase | `getUserById`, `parseConfig` |
| Variable names | camelCase | `userName`, `isActive` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_URL` |
| Private members | leading underscore | `_cache`, `_disposed` |
| Boolean vars | is/has/can/should prefix | `isValid`, `hasPermission` |

### File Naming

| Type | Convention | Examples |
|------|------------|----------|
| Component files | PascalCase | `UserProfile.tsx` |
| Utility files | camelCase | `stringUtils.ts` |
| Test files | source name + `.test` | `userService.test.ts` |
| Type files | source name + `.types` | `api.types.ts` |

---

## 2) Code Organization

### Import Order

```typescript
// 1. Node.js built-in modules
import * as fs from 'fs';
import * as path from 'path';

// 2. Third-party libraries (alphabetical)
import { Observable } from 'rxjs';
import * as vscode from 'vscode';

// 3. Internal modules (by layer: base -> platform -> domain)
import { Disposable } from '@/base/common/lifecycle';
import { IConfigService } from '@/platform/config/common/config';

// 4. Relative imports (by distance: far -> near)
import { UserModel } from '../models/user';
import { formatDate } from './utils';

// 5. Type-only imports (separate group)
import type { User, Config } from '../types';
```

### Export Order

```typescript
// 1. Type exports
export type { User, Config };
export interface IService { ... }

// 2. Constant exports
export const DEFAULT_CONFIG = { ... };

// 3. Function exports
export function createUser() { ... }

// 4. Class exports
export class UserService { ... }

// 5. Default export (only for module entry points)
export default UserService;
```

---

## 3) Function Guidelines

### Function Length

- **Recommended**: <= 30 lines
- **Warning**: 30–50 lines
- **Forbidden**: > 50 lines (must split)

### Parameter Count

- **Recommended**: <= 3 parameters
- **Warning**: 4–5 parameters
- **Forbidden**: > 5 parameters (use an options object)

```typescript
// Bad: too many parameters
function createUser(name: string, email: string, age: number,
                    role: string, department: string, manager: string) { ... }

// Good: use an options object
interface CreateUserOptions {
  name: string;
  email: string;
  age: number;
  role: string;
  department: string;
  manager: string;
}

function createUser(options: CreateUserOptions) { ... }
```

### Return Flow

```typescript
// Bad: multiple early returns, hard to trace
function process(data: Data): Result {
  if (!data) return null;
  if (data.type === 'A') return processA(data);
  if (data.type === 'B') return processB(data);
  return processDefault(data);
}

// Good: single exit, clear control flow
function process(data: Data): Result {
  let result: Result;

  if (!data) {
    result = null;
  } else if (data.type === 'A') {
    result = processA(data);
  } else if (data.type === 'B') {
    result = processB(data);
  } else {
    result = processDefault(data);
  }

  return result;
}
```

---

## 4) Type Safety

### Forbidden Patterns

```typescript
// Forbidden: any
function process(data: any) { ... }  // ❌

// Good: use unknown or specific types
function process(data: unknown) { ... }  // ✓
function process(data: Record<string, unknown>) { ... }  // ✓

// Forbidden: type assertion to bypass checks
const user = {} as User;  // ❌

// Good: construct a complete object
const user: User = {
  id: '1',
  name: 'John',
  email: 'john@example.com'
};  // ✓

// Forbidden: non-null assertion
const name = user!.name;  // ❌

// Good: explicit check
const name = user?.name ?? 'default';  // ✓
```

### Recommended Patterns

```typescript
// Use type guards
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

// Use satisfies (TypeScript 4.9+)
const config = {
  host: 'localhost',
  port: 3000
} satisfies Config;

// Use const assertions
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number];
```

---

## 5) Error Handling

### Exception Guidelines

```typescript
// Forbidden: swallow errors
try {
  await riskyOperation();
} catch (e) {
  // do nothing ❌
}

// Good: log and rethrow or handle
try {
  await riskyOperation();
} catch (e) {
  logger.error('Operation failed', e);
  throw new OperationError('Failed to complete operation', { cause: e });
}

// Good: explicit handling
try {
  await riskyOperation();
} catch (e) {
  if (e instanceof NetworkError) {
    return fallbackValue;
  }
  throw e;
}
```

### Error Class Definitions

```typescript
// Create custom error classes
class ApplicationError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends ApplicationError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(message, 'VALIDATION_ERROR', details);
  }
}
```

---

## 6) Comment Guidelines

### When to Add Comments

| Scenario | Comment Needed |
|---------|----------------|
| "What" the code does | ❌ self-explanatory |
| "Why" the code exists | ✓ add comments |
| Complex algorithms | ✓ add comments |
| Temporary workaround | ✓ comment + TODO |
| Public API | ✓ add JSDoc |

### JSDoc Format

```typescript
/**
 * Fetch user info by user ID.
 *
 * @param id - Unique user identifier
 * @returns User object or undefined if not found
 * @throws {ValidationError} When id format is invalid
 *
 * @example
 * ```typescript
 * const user = await getUserById('123');
 * if (user) {
 *   console.log(user.name);
 * }
 * ```
 */
async function getUserById(id: string): Promise<User | undefined> {
  // ...
}
```

### TODO Format

```typescript
// TODO(#123): Optimize query performance; current implementation is slow for large datasets
// FIXME(#456): Fix edge-case handling
// HACK: Temporary workaround; remove after upstream fix
// NOTE: Uses a non-standard API; requires Node 18+
```

---

## 7) Async Code

### Promise vs async/await

```typescript
// Recommended: use async/await
async function fetchUserData(id: string): Promise<UserData> {
  const user = await getUser(id);
  const profile = await getProfile(user.profileId);
  return { user, profile };
}

// Parallel execution
async function fetchAllData(ids: string[]): Promise<UserData[]> {
  return Promise.all(ids.map(id => fetchUserData(id)));
}

// Avoid: mixing then and await
async function badExample() {
  const user = await getUser(id);
  return getProfile(user.profileId).then(p => ({ user, profile: p })); // ❌
}
```

### Cancellation Support

```typescript
// Use AbortController
async function fetchWithTimeout(
  url: string,
  timeoutMs: number
): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(timeoutId);
  }
}
```

---

## 8) Checklist

Before committing code, confirm:

- [ ] Naming follows conventions (PascalCase/camelCase)
- [ ] Import order is correct
- [ ] Function length <= 30 lines
- [ ] Parameter count <= 3
- [ ] No `any` usage
- [ ] No `@ts-ignore`
- [ ] Errors handled correctly
- [ ] Complex logic is commented
- [ ] Public API has JSDoc
- [ ] TODOs reference issue IDs

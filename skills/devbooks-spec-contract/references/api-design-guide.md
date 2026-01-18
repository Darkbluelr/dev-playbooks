# API Design Guide

This document summarizes practical API design best practices.

---

## 1) Core principles

### 1.1 Principle of least surprise

API behavior should match users’ intuitive expectations.

```typescript
// Bad: method name suggests a query, but it mutates state
function getUser(id: string): User {
  this.lastAccessedUser = id;  // side effect!
  return this.users[id];
}

// Good: query methods are side-effect free
function getUser(id: string): User {
  return this.users[id];
}
```

### 1.2 Consistency

Similar operations should have similar APIs.

```typescript
// Bad: inconsistent naming
interface UserService {
  getUser(id: string): User;
  fetchOrder(id: string): Order;   // should be getOrder
  loadProduct(id: string): Product; // should be getProduct
}

// Good: consistent naming pattern
interface UserService {
  getUser(id: string): User;
  getOrder(id: string): Order;
  getProduct(id: string): Product;
}
```

### 1.3 Explicit is better than implicit

Avoid “magic”. Make effects and options visible.

```typescript
// Bad: implicit behavior
function saveUser(user: User): void {
  // implicitly send a notification
  this.notificationService.send('User saved');
  // implicitly update cache
  this.cache.update(user);
}

// Good: explicit control via options
interface SaveOptions {
  sendNotification?: boolean;
  updateCache?: boolean;
}

function saveUser(user: User, options?: SaveOptions): void {
  // apply behavior explicitly based on options
}
```

---

## 2) Naming conventions

### 2.1 Method naming

| Operation type | Prefix | Examples |
|---------------|--------|----------|
| Get one | `get` | `getUser()`, `getConfig()` |
| Get a list | `list` / `getAll` | `listUsers()`, `getAllConfigs()` |
| Find/search | `find` / `search` | `findByEmail()`, `searchUsers()` |
| Create | `create` | `createUser()`, `createOrder()` |
| Update | `update` | `updateUser()`, `updateConfig()` |
| Delete | `delete` / `remove` | `deleteUser()`, `removeItem()` |
| Existence | `has` / `exists` | `hasUser()`, `exists()` |
| State/capability | `is` / `can` | `isActive()`, `canEdit()` |
| Transform | `to` | `toJSON()`, `toString()` |
| Build from | `from` | `fromJSON()`, `fromString()` |

### 2.2 Parameter naming

```typescript
// Boolean params: use positive form
function setVisible(visible: boolean): void;  // ok
function setHidden(hidden: boolean): void;    // avoid: double negative at call sites

// Callback params: describe the trigger
function onUserCreated(callback: Function): void;  // ok
function userCallback(callback: Function): void;   // avoid: unclear

// ID params: make the type explicit
function getUser(userId: string): User;  // preferred
function getUser(id: string): User;      // acceptable, but less clear
```

---

## 3) Parameter design

### 3.1 Control parameter count

```typescript
// Bad: too many params
function createUser(
  name: string,
  email: string,
  age: number,
  role: string,
  department: string,
  manager: string,
  startDate: Date
): User;

// Good: use an options object
interface CreateUserOptions {
  name: string;
  email: string;
  age?: number;
  role?: string;
  department?: string;
  manager?: string;
  startDate?: Date;
}

function createUser(options: CreateUserOptions): User;
```

### 3.2 Optional parameters

```typescript
// Use defaults
function paginate<T>(
  items: T[],
  page: number = 1,
  pageSize: number = 20
): T[];

// Use an options object when params > 3
interface PaginationOptions {
  page?: number;
  pageSize?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

function paginate<T>(items: T[], options?: PaginationOptions): T[];
```

### 3.3 Avoid boolean traps

```typescript
// Bad: unclear meaning of true/false at call sites
user.save(true);  // what does true mean?

// Good: named options (or an enum)
user.save({ validate: true });
// or
user.save({ mode: SaveMode.Validated });
```

---

## 4) Return value design

### 4.1 Null handling

```typescript
// Option 1: return null/undefined
function findUser(id: string): User | null;

// Option 2: Optional (requires a library)
function findUser(id: string): Optional<User>;

// Option 3: throw (only for true error cases)
function getUser(id: string): User;  // throws NotFoundError when missing
```

**Selection guide:**

| Scenario | Recommendation |
|----------|----------------|
| Records that may not exist | Return `null` |
| Records that must exist | Throw |
| Fluent/chaining use cases | Return `Optional` |

### 4.2 Collection returns

```typescript
// Always return an array, never null
function listUsers(): User[];  // return [] when empty

// Paged result with metadata
interface PagedResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

function listUsers(options: PaginationOptions): PagedResult<User>;
```

### 4.3 Async returns

```typescript
// Always use Promise
async function getUser(id: string): Promise<User>;

// Cancellable async operations
function fetchData(
  url: string,
  signal?: AbortSignal
): Promise<Response>;
```

---

## 5) Error handling

### 5.1 Error types

```typescript
// Define explicit error types
class ApiError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number,
    public readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

class NotFoundError extends ApiError {
  constructor(resource: string, id: string) {
    super(
      `${resource} with id ${id} not found`,
      'NOT_FOUND',
      404,
      { resource, id }
    );
  }
}

class ValidationError extends ApiError {
  constructor(field: string, message: string) {
    super(
      message,
      'VALIDATION_ERROR',
      400,
      { field }
    );
  }
}
```

### 5.2 Error documentation

```typescript
/**
 * Get user details.
 *
 * @param id - User ID.
 * @returns The user object.
 * @throws {NotFoundError} When the user does not exist.
 * @throws {ValidationError} When the ID format is invalid.
 */
async function getUser(id: string): Promise<User>;
```

---

## 6) Version evolution

### 6.1 Backward compatibility

```typescript
// Add optional parameters (compatible)
// old
function search(query: string): Result[];
// new
function search(query: string, options?: SearchOptions): Result[];

// Add new methods (compatible)
interface UserService {
  getUser(id: string): User;
  // new
  getUserWithDetails(id: string): UserWithDetails;
}
```

### 6.2 Deprecation policy

```typescript
/**
 * @deprecated Use `getUserById` instead. Will be removed in v3.0.
 */
function getUser(id: string): User {
  console.warn('getUser is deprecated, use getUserById instead');
  return getUserById(id);
}

function getUserById(id: string): User {
  // new implementation
}
```

### 6.3 Breaking changes

When you must make a breaking change:

1. Clearly mark it in CHANGELOG
2. Provide a migration guide
3. Consider shipping a codemod

```typescript
// v2 -> v3 migration example
// old API
userService.save(user, true);  // true = validate

// new API
userService.save(user, { validate: true });
```

---

## 7) API review checklist

When designing a new API, confirm:

- [ ] Are names clear and consistent?
- [ ] Are parameters <= 3? (Otherwise use an options object.)
- [ ] Are return types explicit? (Avoid `any`.)
- [ ] Are error cases handled?
- [ ] Is there JSDoc documentation?
- [ ] Is it backward compatible?
- [ ] Does it follow the principle of least surprise?

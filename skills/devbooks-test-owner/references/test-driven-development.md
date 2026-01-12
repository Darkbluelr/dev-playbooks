# Automated Architecture Governance and AI-Driven Refactoring: Verification Strategy and Enterprise Best Practices for All-AI Coding

## Abstract

As large language models (LLMs) improve, software development is shifting from “humans write code” to “AI generates, humans review” and, in some settings, “All-AI Coding”. However, All-AI Coding becomes unreliable for architecture-level refactoring. The most visible failure mode is the **Recursive Repair Loop**: AI proposes a fix, AI reviews it and flags issues, AI applies another fix, the next review finds more issues, and quality oscillates instead of converging. This exposes a core limitation of probabilistic “AI review” when it lacks **deterministic ground truth**.

This report analyzes the root cause and proposes an enterprise-grade solution for environments where human code review is unavailable. The approach combines **Architecture-as-Code** and **Test-Driven Refactoring**: encode architecture constraints as executable fitness functions (ArchUnit, NetArchTest, dependency-graph rules) and validate changes via black-box contract tests. Finally, it outlines an unattended governance pipeline using tools such as Cursor, Aider, and SonarQube to create a deterministic “red → green” loop that replaces “AI review”.

---

## 1. Pathology of the recursive repair loop: why AI can’t reliably review AI

In an All-AI Coding workflow, the main pain is an endless “fix → review → fix” loop. Solving it requires understanding the underlying cognitive and statistical dynamics. This is not merely a prompt-engineering issue; it is a systemic failure of a probabilistic model operating inside a closed loop without external feedback.

### 1.1 Probabilistic validation and hallucination amplification

Human code review relies on a mental model grounded in logic, domain knowledge, and deterministic runtime behavior. In contrast, LLM “review” is fundamentally **next-token prediction** 1.

When asked to “review” code, an LLM often does not build an AST or simulate execution paths. Instead, it imitates the *language patterns* of reviewers. Since real-world review corpora (e.g., GitHub PRs) contain critique and suggestions, models exhibit a statistical **critique bias**: they tend to find problems even when code is correct. This can produce **hallucinated bugs**, such as claiming an imported symbol is undefined or treating style preferences as logic defects 3.

In a recursive loop, hallucinated issues from round one become “requirements” for the fix agent in round two, leading it to change correct code. Those changes introduce real regressions that round three review correctly detects. The cycle increases code entropy rather than reducing it.

### 1.2 Sycophancy and context collapse

Research shows LLMs can display **sycophancy**: a tendency to align with the user’s implicit assumptions or the conversation’s premises 4.

- **Regressive sycophancy:** when a user or a previous agent asserts “there is a bug here”, the model may accept that premise and “fix” correct code. This compliance with a false premise is a key reason the loop fails to converge 4.
- **Context collapse:** architecture refactoring depends on global consistency, but LLMs are constrained by context windows and local file focus. While “fixing file A”, the model may forget it broke a contract in “file B”. The review agent then flags B, leading to changes that re-break A. This oscillation between local optima is common in large refactors 3.

### 1.3 Limits of intrinsic self-correction

Although “self-reflection” is popular, empirical evidence shows that without external tools (compiler, interpreter, test results), LLM **intrinsic self-correction** is limited and may even degrade performance 7.

| Feature | Human review | AI review (LLM) |
|---|---|---|
| Validation mechanism | Logical reasoning + experience | Pattern matching + probabilistic prediction |
| Error identification | Causal reasoning | Textual/statistical cues |
| Context awareness | Global/system-level | Local/window-limited |
| Response to criticism | Dialectical evaluation | Tendency to comply (sycophancy) |
| Outcome stability | High | Low (stochastic) |

**Conclusion:** using probabilistic AI to validate probabilistic AI output does not reliably converge. You must introduce **deterministic anchors**—compiler errors, failing tests, static analysis reports—to break the loop.

### 1.4 Input isolation: avoid the “same-source fallacy”

In multi-agent All-AI workflows, the most dangerous closed loop is: “generate tests from the implementation plan, then generate code from the same plan”. If tests and code share the same input document, validation collapses into self-confirmation.

System prompts should enforce isolation of “sources of truth”:

- **Verifier input (tests):** only architecture/design docs or requirement specs. The test agent must not read detailed plans/tasks, to remain an independent “acceptance” viewpoint.
- **Coder input (implementation):** only the implementation plan/tasks, current test failures, and the codebase itself.
- **Conflict resolution:** when implementation and tests disagree, treat tests derived from design/specs as the **golden truth**. The implementation must move toward the design intent, not adjust tests to fit the implementation.

This isolation enables orthogonal verification without requiring human code review.

---

## 2. Dual anchors: architecture and behavior

For the question: **“Can a comprehensive test suite verify whether a refactoring plan is complete?”**

Yes—but the critical suite is not traditional unit tests; it is **architectural fitness functions** plus black-box contract tests. Together they validate both structure and externally observable behavior.

### 2.1 Structural anchor: architectural fitness functions (ArchUnit)

Architectural fitness functions come from **Evolutionary Architecture**: executable constraints that measure whether a system adheres to its intended structure 9. In All-AI Coding they act as an “automated architect”: they validate not only behavior but structure.

Common tools:

- **ArchUnit (Java):** validates package dependencies, inheritance, annotation usage via bytecode analysis; robust to formatting and text-level noise 11.
- **NetArchTest (.NET):** fluent APIs for enforcing layering and dependency rules 14.
- **Dependency-Cruiser / TsArch (JS/TS):** validates module dependency graphs via AST parsing 17.
- **ArchUnitNET:** a .NET port of ArchUnit-style rules 18.

**Multi-tenant SaaS upgrades:** structural anchors should additionally enforce tenant isolation: RLS policy presence, tenant-aware annotations (e.g., `@TenantAware`), and forbidden cross-domain schema references. Example rules include “all repositories accessing `tenant_data` must be `@TenantAware`” and “shared services must not import tenant-specific schema modules”.

### 2.2 Behavioral anchor: black-box contract tests

Correct structure does not guarantee correct external behavior. To broaden deterministic anchors, the test agent should translate API definitions, data flows, and side effects from design/spec into contract-level integration tests.

- **Test the contract, not the implementation:** tests rely only on architecture/requirements documents, not plan details such as class names.
- **Drive through HTTP/messages:** assert status codes, response bodies, and durable state changes (e.g., records in `audit_logs`, emitted events in `tenant_events`).
- **Assert observable side effects:** audit logs, event bus messages, security policies (e.g., RLS) should be asserted explicitly.
- **Example:** `POST /impersonate` must insert an `IMPERSONATE_START` record regardless of internal service decomposition.

Only when both anchors pass can you claim “externally correct behavior + internally correct structure”.

### 2.3 Turning a refactoring plan into executable acceptance criteria

In traditional development, an architecture fix plan is a document (“decouple order service from inventory DB”). In All-AI Coding, that document must become **test code**.

Process:

1. **Plan analysis:** the architecture agent identifies the defect (cycles, layering violations).
2. **Rule generation:** write rules describing the desired target state.
   - Defect: “UI depends directly on data layer.”
   - Rule: `noClasses().that().resideIn("..ui..").should().dependOnClassesThat().resideIn("..data..")`
3. **Red/green loop:** run rules before refactoring; they should **fail (red)**, proving they capture the current defect.
4. **Completion criteria:** the plan is structurally complete only when the rules **pass (green)**.

### 2.4 Verifying “completeness”

Architecture tests can define “done” more strictly than manual review:

- **Full scan:** rules scan all compiled artifacts. If a refactor misses a hidden class/file, the test fails immediately. Humans routinely miss such cases when reviewing hundreds of files 19.
- **Regression prevention:** once fixed, keep the rules in CI. If a future change reintroduces the defect, CI fails. This is an **architectural ratchet** 9.

**Example: layering validation (Java / ArchUnit)**

```java
@ArchTest
public static final ArchRule layered_architecture_must_be_respected =
    layeredArchitecture()
       .consideringOnlyDependenciesInAnyPackage("com.myapp..")
       .layer("Controller").definedBy("..controller..")
       .layer("Service").definedBy("..service..")
       .layer("Persistence").definedBy("..persistence..")

       .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
       .whereLayer("Service").mayOnlyBeAccessedByLayers("Controller")
       .whereLayer("Persistence").mayOnlyBeAccessedByLayers("Service");
```

This encodes strict one-way dependencies. If generated code makes `Service` call `Controller`, or `Controller` skip `Service` and call `Persistence`, the test fails. It yields an unambiguous binary definition of “plan complete”.

---

## 3. Enterprise best practices: unattended governance pipelines

For the question: **“What are enterprise best practices when humans cannot review code?”**

The core shift is from **trust by observation** to **trust by constraint**. Build a pipeline where AI changes are merged only after passing strict mechanical checks.

Four pillars:

1. Test-driven refactoring
2. Snapshot testing for legacy systems
3. Static-analysis gates
4. Agent role separation

### 3.1 Core workflow: inverted TDD for AI refactoring

Classic TDD is “tests first”. In AI refactoring, it becomes non-negotiable because it answers “when do we stop?” 20.

Steps:

1. **Define tests (red):** before changing business code, write tests that capture the architecture defect or required behavior.
   - Example instruction: “Write an ArchUnit test that asserts all `OrderService` dependencies come from `OrderDomain`. Run it and confirm it fails.”
2. **Implement (green):** instruct AI to modify code until the tests pass.
   - Constraint: AI must not modify the tests unless explicitly authorized.
   - Benefit: compiler/test failures provide deterministic feedback, avoiding hallucination-heavy “self review” 21.
3. **Refactor:** once green, allow structural cleanup under the protection of tests.

### 3.2 Legacy safety net: snapshot (golden master) testing

For legacy projects, fine-grained unit tests can be costly. Snapshot testing (golden master testing) is standard for large refactors 24.

- **Idea:** don’t interpret internals; capture black-box input/output fingerprints.
- **AI advantage:** models are good at generating repetitive harness code 27.
- **Verification:** during refactoring (moving classes, splitting packages), snapshots should remain 100% passing if behavior is unchanged. Failures indicate accidental behavior drift 24.

### 3.3 Agent role separation: architect vs craftsperson

Avoid doing everything in one chat session. Mirror team roles to prevent context contamination 29.

| Agent role | Permissions & responsibilities | Input constraints (critical) |
|---|---|---|
| Verifier / QA | Read-only. Translate design/spec into architecture rules, contract tests, and snapshot baselines. Run tests and interpret results. | May read design/spec docs only. Must not read implementation plans or source code. |
| Planner | Read-only. Translate design into actionable steps (Plan.md) and list impacted modules. | May read design and codebase. Must not read verifier-generated tests to avoid “seeing the answers”. |
| Coder | Read/write. Implement according to Plan; iterate until verifier tests are green; may edit source/config. | May read Plan, test failures, and codebase. Must not read design docs verbatim to reduce same-source coupling. |

This separation keeps tests and implementation independently anchored.

### 3.4 Static analysis as a hard gate

Without human review, static analysis must be stricter than humans: **SAST** and lint gates become the “cold police” 32.

- **Tools:** SonarQube (quality gates), Codacy, Qodo, ESLint/Pylint with strict rules.
- **Policy:** zero tolerance. Any new code smell/bug/vulnerability fails CI.
- **Closed loop:** feed structured reports (e.g., SonarQube JSON) to the AI agent. Models are more successful with line-numbered, typed findings than with vague natural-language feedback 34.

---

## 4. Practical implementation: building a “no-code-review” environment

For All-AI Coding, here is a concrete toolchain and workflow that replaces “AI review” with deterministic validation.

### 4.1 Tool selection

1. **IDE / agent:** Cursor (Composer) or Windsurf (multi-file editing and context).
2. **CLI automation:** Aider (strong red/green loop; runs tests and iterates on failures) 35.
3. **Architecture guard:** ArchUnit (Java) / NetArchTest (.NET) / dependency graph tools.
4. **Quality gate:** SonarQube Cloud (or local ESLint/Pylint with strict configs).

### 4.2 Configure Cursor rules (`.cursor/rules`)

Create `.cursor/rules` at repo root and inject architecture constraints into every AI interaction. This is effectively a “hard guardrail” for the agent 36.

Example file:

```text
## description: Architecture refactoring and quality guardrails
## globs: **/*.java, **/*.cs, **/*.ts
## alwaysApply: true

# Core principles

1. Test first:
   - Before changing any business code, run ./gradlew test (or equivalent).
   - If tests are failing, fix tests first (do not delete tests).

2. Architecture constraints:
   - Controllers must not call repositories directly.
   - No cyclic dependencies.
   - Any architecture change must pass ArchitectureTest.java.

3. Prohibited actions:
   - Do not delete existing tests to make the build pass.
   - Do not use System.out.println for debugging; use a logger.

4. Definition of done:
   - The task is done only when unit tests + architecture tests + lint all pass.
```

### 4.3 Aider automatic repair loop

For large refactors, use Aider to run an unattended fix loop.

Example:

```bash
aider --model sonnet --architect --test-cmd "mvn test && mvn verify"
```

How it works:

1. `--architect`: encourages planning before editing, reducing blind trial-and-error 31.
2. `--test-cmd`: after each edit, Aider runs tests automatically.
   - On failure, it captures the error logs.
   - It iterates without human intervention until tests pass or retries are exhausted.
3. Effect: replaces “AI fix → AI review” with “AI fix → deterministic test verification” 38.

---

## 5. Limitations and risks

Even with the above, watch for:

1. **Test correctness:** if AI generates bogus tests (e.g., always-true assertions), the whole system fails.
   - Mitigation: mutation testing (e.g., Pitest). If mutated code still passes tests, the suite is weak. Feed mutation reports back to the agent to harden tests.
2. **Requirement drift:** architecture tests ensure “structure”, not “business correctness”.
   - Mitigation: keep high-level acceptance tests or E2E tests reviewed by a human, or at minimum have a human validate the alignment between the requirement document and test descriptions.

---

## 6. Conclusion

The recursive repair loop is not an accident; it is the expected outcome of All-AI Coding without deterministic feedback. The solution is not “better prompts for AI review”, but tool-based verification that the model cannot talk its way around.

Recommendations:

1. Stop using AI for “code review” as the primary acceptance gate. Invest in **architecture tests** and **snapshot tests**.
2. Enforce a strict **red/green loop**: AI must see failing tests before changing code.
3. Automate governance: use `.cursor/rules` and Aider `--test-cmd` to turn “review” into “test execution”.

Architecture-as-Code + Test-Driven Refactoring allows even non-coders to control AI changes by controlling rules and tests—an inevitable role shift in AI-era engineering.

---

### Table 1: verification strategy comparison

| Dimension | Traditional human review | AI review (current trap) | Architecture-as-Code (recommended) |
|---|---|---|---|
| Baseline | Expertise and intuition | Probabilistic token prediction | **Deterministic rules (bytecode/AST)** |
| Feedback | Advisory, fuzzy | Hallucination-prone, sycophantic, unstable | **Binary (pass/fail), precise** |
| Coverage | Sampling (fatigue) | Window-limited (misses) | **Full scan (100% of codebase)** |
| Convergence | High | **Non-convergent (infinite loop)** | **High (red → green → refactor)** |
| Best for | Core logic, complex algorithms | Simple syntax/style hints | **Layering, dependency governance, rule enforcement** |

---

## 7. Legacy Code Change Algorithm

> Source: *Working Effectively with Legacy Code* — Michael Feathers

When changing legacy code, the Test Owner should follow this 5-step algorithm to ensure “test anchors first, then change”:

### 7.1 Five-step flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. Find change point -> 2. Find test point -> 3. Break deps -> 4. Test -> 5. Change │
│    (Change Point)        (Test Point)          (Break Deps)    (Write Tests) (Change) │
└─────────────────────────────────────────────────────────────────────────┘
```

| Step | Action | Output | Fallback if it fails |
|------|--------|--------|----------------------|
| **1. Find change point** | Locate the code you must modify | File:line list | - |
| **2. Find test point** | Identify a Pinch Point as the best test entry | PP-xxx list | If none, go to step 3 |
| **3. Break dependencies** | Apply decoupling techniques to enable testing | seams / mock points | See “Decoupling Techniques Cheat Sheet” |
| **4. Write tests** | Write characterization tests that capture current behavior | tests/xxx_test.py | Must be red before green |
| **5. Change** | Modify code under test protection | code change | Roll back if tests fail |

### 7.2 Pinch Point priority

**Definition:** a Pinch Point is a node where multiple call paths converge. Testing there yields maximum coverage per test.

**How to identify:**
1. Trace outward from the change point along the call chain
2. Find convergence points used by 2+ callers (many-in, one-out)
3. Prefer writing tests at the Pinch Point instead of per-caller tests

**Example:**

```
Call-chain analysis:
  ControllerA.handleRequest() ----+
  ControllerB.handleBatch()  -----+--> OrderService.processOrder() --> Repository.save()
  EventHandler.onOrderEvent() ----+                 ^
                                               [Pinch Point]

Testing strategy:
  Bad: write 1 test each for ControllerA/ControllerB/EventHandler (3 total)
  Good: write 1 test at OrderService.processOrder() (covers all 3 paths)
```

### 7.3 Test Owner checklist

Before writing tests for legacy code, answer:

- [ ] Where is the change point? (file:line)
- [ ] Where is the Pinch Point? (if unknown, break dependencies first)
- [ ] Is the code testable? (if not, which decoupling technique is required?)
- [ ] Do characterization tests capture current behavior? (prove by red → green)
- [ ] Does the number of tests match the number of Pinch Points (not call paths)?

### 7.4 Sensing and separation

When code feels “untestable”, it usually lacks **sensing** or **separation**:

| Problem | Symptom | Solution |
|--------|---------|----------|
| **Lack of sensing** | You can’t observe outcomes (private methods, no return value, side effects in external systems) | Extract interfaces, add test hooks, dependency injection |
| **Lack of separation** | You can’t isolate dependencies (hard-coded deps, global state, static calls) | Parameterize constructors, extract interfaces, Subclass and Override |

**Core idea:**
- Sensing = tests can “see” what happened
- Separation = tests can “control” what dependencies are used

Further reading: `decoupling-techniques-cheatsheet.md`

---
name: devbooks-federation
description: devbooks-federation: Cross-repository federation analysis and contract synchronization. Use when changes involve external APIs/contracts or when analyzing cross-repository impact. Use when the user says "cross-repo impact/federation analysis/contract sync/upstream-downstream dependencies/multi-repo", etc.
tools:
  - Glob
  - Read
  - Bash
  - mcp__ckb__analyzeImpact
  - mcp__ckb__findReferences
  - mcp__github__search_code
  - mcp__github__create_issue
---

# DevBooks: Cross-Repository Federation Analysis

## Trigger Conditions

Automatically executed when any of the following conditions are met:
1. User says "cross-repo impact/federation analysis/contract sync/upstream-downstream dependencies/multi-repo"
2. `devbooks-impact-analysis` detects that changes involve contract files defined in `federation.yaml`
3. User has marked `Impact: Cross-Repo` in `proposal.md`

## Prerequisites

- `.devbooks/federation.yaml` or `dev-playbooks/federation.yaml` exists in the project root
- GitHub MCP must be configured for cross-repository searches

## Execution Flow

### Step 1: Load Federation Configuration

```bash
# Detect federation configuration file
if [ -f ".devbooks/federation.yaml" ]; then
  FEDERATION_CONFIG=".devbooks/federation.yaml"
elif [ -f "dev-playbooks/federation.yaml" ]; then
  FEDERATION_CONFIG="dev-playbooks/federation.yaml"
else
  echo "Federation configuration not found, please create federation.yaml first"
  exit 1
fi
```

After reading the configuration, extract:
- Upstream dependency list (who I depend on)
- Downstream consumer list (who depends on me)
- Contract file list

### Step 2: Identify Contract Changes

Check whether the current changes involve contract files:

```
Changed Files ∩ Contract Files = Contract Change Set
```

Contract change classification:
- **Breaking**: Delete/rename exports, modify required parameters, change return types
- **Deprecation**: Add `@deprecated` annotation
- **Enhancement**: Add optional parameters, add exports
- **Patch**: Internal implementation changes, does not affect signature

### Step 3: Cross-Repository Impact Analysis

For changes involving contracts:

1. **Local Analysis** (using CKB)
   ```
   mcp__ckb__findReferences(symbolId=<contract symbol>)
   mcp__ckb__analyzeImpact(symbolId=<contract symbol>)
   ```

2. **Remote Search** (using GitHub MCP)
   ```
   mcp__github__search_code(query="<contract name> org:<org>")
   ```

3. **Consolidate Results**
   - References within this repository
   - Downstream repository references (from GitHub search)
   - Estimated potential impact scope

### Step 4: Generate Federation Impact Report

Output format:

```markdown
# Cross-Repository Impact Analysis Report

## Change Summary

| Contract File | Change Type | Impact Level |
|---------------|-------------|--------------|
| `src/api/v1/user.ts` | Breaking | Critical |
| `src/types/order.ts` | Enhancement | Safe |

## Impact Within This Repository

- Internal reference count: 15
- Affected modules: `services/`, `handlers/`

## Cross-Repository Impact

### Downstream Consumers

| Repository | Reference Count | Status |
|------------|-----------------|--------|
| org/web-app | 8 | Needs sync |
| org/mobile-app | 3 | Needs sync |

### Recommended Actions

1. [ ] Create adaptation Issue in org/web-app
2. [ ] Create adaptation Issue in org/mobile-app
3. [ ] Update CHANGELOG
4. [ ] Send Slack notification

## Compatibility Strategy

- [ ] Keep old API available (dual-write period)
- [ ] Add `@deprecated` annotation
- [ ] Set removal date: YYYY-MM-DD
```

### Step 5: Automatic Notification (Optional)

If `notify_on_change: true` is configured:

1. Create Issue in downstream repositories (using GitHub MCP)
2. Send Slack notification (requires webhook configuration)

Issue template:
```markdown
## Upstream Contract Change Notification

**Source Repository**: org/my-service
**Change Type**: Breaking Change
**Expected Removal Date**: YYYY-MM-DD

### Affected Contracts

- `UserService.getUser()` - Parameter signature changed

### Recommended Actions

Please complete the following adaptations before [deadline]:
1. Update call sites to adapt to the new signature
2. Run tests to ensure compatibility

### Related Links

- Change PR: org/my-service#123
- Migration Guide: [link]
```

## Script Support

### Federation Check Script

```bash
# Check federation constraints
bash skills/devbooks-federation/scripts/federation-check.sh \
  --project-root "$(pwd)" \
  --change-files "src/api/v1/user.ts,src/types/order.ts"
```

### Contract Sync Script

```bash
# Generate downstream notifications
bash skills/devbooks-federation/scripts/federation-notify.sh \
  --project-root "$(pwd)" \
  --change-type breaking \
  --dry-run
```

## Collaboration with Other Skills

- `devbooks-impact-analysis`: Automatically invokes this Skill when cross-repository impact is detected
- `devbooks-spec-contract`: Triggered synchronously when contract definitions change (merged from original spec-delta + contract-data)
- `devbooks-proposal-author`: Automatically marks Cross-Repo Impact in proposal.md

## Important Notes

1. Cross-repository search depends on GitHub MCP and requires appropriate access permissions
2. Searches in large organizations may take longer; consider narrowing the search scope
3. Federation configuration should be synchronized with the team to ensure accurate upstream/downstream information
4. Breaking changes should use Semantic Versioning (SemVer)

## References

- [API Versioning Best Practices](https://swagger.io/resources/articles/best-practices-in-api-versioning/)

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate analysis scope.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether `federation.yaml` exists
2. Detect whether current changes involve contract files
3. Detect whether there is a cross-repository impact marker

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Local Analysis** | Contract change but no cross-repo configuration | Only analyze references within this repository |
| **Federation Analysis** | federation.yaml exists | Analyze upstream/downstream repository impact |
| **Notification Mode** | notify_on_change=true configured | Automatically create downstream Issues |

### Detection Output Example

```
Detection Results:
- federation.yaml: Exists
- Contract changes: 2 files
- Cross-repo marker: Yes
- Execution mode: Federation Analysis
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__analyzeImpact` | Symbol-level impact analysis | 2s |
| `mcp__ckb__findReferences` | Find references within this repository | 2s |
| `mcp__github__search_code` | Cross-repository code search | 5s |
| `mcp__github__create_issue` | Create downstream notification Issues | 5s |

### Detection Flow

1. Call `mcp__ckb__findReferences` to detect references within this repository (2s timeout)
2. If cross-repo analysis is needed, call `mcp__github__search_code` (5s timeout)
3. If GitHub MCP is unavailable, skip cross-repo search and only output local repository analysis

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Local repository references | CKB precise analysis | Grep text search |
| Cross-repository search | GitHub API search | Unavailable |
| Automatic notification | Create downstream Issues | Manual notification |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
Warning: GitHub MCP is unavailable, cross-repository search cannot be performed.
Only references within this repository can be analyzed; cross-repository impact requires manual confirmation.
```

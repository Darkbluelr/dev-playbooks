---
name: devbooks-index-bootstrap
description: devbooks-index-bootstrap: Automatically detects project language stack and generates SCIP index, activating graph-based code understanding capabilities. Triggered automatically when entering a large project for the first time, or when CKB reports missing index.
tools:
  - Glob
  - Read
  - Bash
  - mcp__ckb__getStatus
---

# DevBooks: Index Bootstrap

## Trigger Conditions

Automatically executes when any of the following conditions are met:
1. User says "initialize index/build code graph/activate graph analysis"
2. `mcp__ckb__getStatus` returns SCIP backend `healthy: false`
3. Entering a new project and `index.scip` does not exist

## Execution Flow

### Step 1: Detect Project Language Stack

```bash
# Detect primary language
if [ -f "package.json" ] || [ -f "tsconfig.json" ]; then
  echo "LANG=typescript"
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  echo "LANG=python"
elif [ -f "go.mod" ]; then
  echo "LANG=go"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  echo "LANG=java"
elif [ -f "Cargo.toml" ]; then
  echo "LANG=rust"
else
  echo "LANG=unknown"
fi
```

### Step 2: Check if Indexer is Installed

| Language | Check Command | Install Command |
|----------|---------------|-----------------|
| TypeScript/JS | `which scip-typescript` | `npm install -g @sourcegraph/scip-typescript` |
| Python | `which scip-python` | `pip install scip-python` |
| Go | `which scip-go` | `go install github.com/sourcegraph/scip-go@latest` |
| Java | Check gradle/maven plugin | See scip-java documentation |
| Rust | `which rust-analyzer` | `rustup component add rust-analyzer` |

### Step 3: Generate Index

```bash
# TypeScript/JavaScript
scip-typescript index --output index.scip

# Python
scip-python index . --output index.scip

# Go
scip-go --output index.scip

# Rust (via rust-analyzer)
rust-analyzer scip . > index.scip
```

### Step 4: Verify Index

After generation, call `mcp__ckb__getStatus` to confirm SCIP backend becomes `healthy: true`.

## Output

On success:
```
✓ TypeScript project detected
✓ scip-typescript installed
✓ index.scip generated (2.3 MB, 15,234 symbols)
✓ CKB SCIP backend activated

Graph-based capabilities ready:
- mcp__ckb__searchSymbols
- mcp__ckb__findReferences
- mcp__ckb__getCallGraph
- mcp__ckb__analyzeImpact
```

## Index Maintenance Recommendations

After generating the index, it is recommended to configure automatic updates to keep the index current:

### Option 1: Git Hook (Recommended)

```bash
# Create post-commit hook
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash
if command -v scip-typescript &> /dev/null; then
  scip-typescript index --output index.scip &
fi
EOF
chmod +x .git/hooks/post-commit
```

### Option 2: CI Pipeline (Team Collaboration)

```yaml
# .github/workflows/index.yml
on:
  push:
    paths: ['src/**', 'lib/**']
jobs:
  index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g @anthropic-ai/scip-typescript
      - run: scip-typescript index --output index.scip
      - uses: actions/upload-artifact@v4
        with:
          name: scip-index
          path: index.scip
```

## Notes

- Initial indexing for large projects may take 1-5 minutes
- Index files should be added to `.gitignore` (or shared as CI artifacts)
- Outdated index does not affect functionality, but graph data may be incomplete

## CKB Index Detection Paths

DevBooks automatically detects the following paths to determine if an index is available:

| Path | Description |
|------|-------------|
| `$CWD/index.scip` | SCIP index file (recommended) |
| `$CWD/.git/ckb/` | CKB local cache directory |
| `$CWD/.devbooks/embeddings/index.tsv` | DevBooks Embedding index |

If any path exists, the index is considered available, and hook output will show `Index available`.

## FAQ

### Q: Why does it say "CKB can be enabled to accelerate code analysis"?

A: This indicates the current project has no available code index. After running this Skill to generate an index, the following advanced features become available:
- `mcp__ckb__searchSymbols` - Symbol search
- `mcp__ckb__findReferences` - Reference finding
- `mcp__ckb__getCallGraph` - Call graph analysis
- `mcp__ckb__analyzeImpact` - Impact analysis

### Q: What if grep doesn't support `-P` option on macOS?

A: Install GNU grep:
```bash
brew install grep
# Use ggrep instead of grep
```

### Q: What if the index file is too large?

A: It is recommended to add `index.scip` to `.gitignore` and generate it in CI as a shared artifact:
```bash
echo "index.scip" >> .gitignore
```

### Q: How to verify if the index is working?

A: Use the CKB status check tool:
```
# In Claude Code
mcp__ckb__getStatus
```
Should return `scip: { healthy: true }`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate indexing strategy.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Check if `index.scip` exists
2. Call `mcp__ckb__getStatus` to check SCIP backend status
3. Detect project language stack

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **First-time Index** | index.scip does not exist | Detect language stack and generate index |
| **Update Index** | index.scip exists but outdated | Regenerate index |
| **Verify Mode** | With --check parameter | Only verify index status, no generation |

### Detection Output Example

```
Detection results:
- index.scip: Does not exist
- CKB SCIP backend: Unavailable
- Language stack: TypeScript
- Run mode: First-time index
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement for detecting index status.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect SCIP backend status | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. Check if SCIP backend is healthy
3. If unavailable -> Trigger index generation flow

### MCP Capabilities Activated After Index Generation

| Feature | MCP Tool |
|---------|----------|
| Symbol search | `mcp__ckb__searchSymbols` |
| Reference finding | `mcp__ckb__findReferences` |
| Call graph analysis | `mcp__ckb__getCallGraph` |
| Impact analysis | `mcp__ckb__analyzeImpact` |

### Degradation Notes

This Skill does not require degradation, as its purpose is to generate the index to enable MCP enhancement capabilities for other Skills.


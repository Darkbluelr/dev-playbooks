# Recommended MCP Servers (Configured)

> Recommended MCP servers for this project: configuration and usage notes
>
> Date: 2026-01-18  
> Scope: User scope (available to all projects)

---

## Table of Contents

1. [Overview](#overview)
2. [CKB (Code Knowledge Backend)](#ckb-code-knowledge-backend)
3. [Context7](#context7)
4. [GitHub MCP Server](#github-mcp-server)
5. [Playwright MCP](#playwright-mcp)
6. [Config locations](#config-locations)
7. [Use cases](#use-cases)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### Currently configured MCP servers

| Server | Type | Scope | Primary capabilities |
|--------|------|-------|----------------------|
| **ckb** | Code analysis | User scope | Symbol search, reference tracing, impact analysis |
| **context7** | Library docs | User scope | Fetch up-to-date library docs + code examples |
| **github** | GitHub integration | User scope | Repos, issues, PRs, automation |
| **playwright** | Browser automation | User scope | Web automation testing, scraping, interaction |

**Config file**: `~/.claude.json` (top-level `mcpServers` field)

**Availability**: ✅ all projects

---

## CKB (Code Knowledge Backend)

### Basics

- **Version**: 7.5.0
- **Type**: language-agnostic code understanding layer
- **Install path**: `/usr/local/bin/ckb`
- **GitHub**: [simplyliz/codemcp](https://github.com/simplyliz/codemcp)

### Capabilities

- ✅ **Symbol search**: quickly find functions/classes/variables
- ✅ **Find references**: locate all usages of a symbol
- ✅ **Impact analysis**: estimate change blast radius
- ✅ **Architecture view**: project structure and dependencies
- ✅ **Git integration**: blame and history tracing

### Backend support

- **LSP** (Language Server Protocol): Python, TypeScript, Go, etc.
- **SCIP**: precomputed index (Go/Java/TypeScript)
- **Git**: repo history and blame

### Configuration

```json
{
  "mcpServers": {
    "ckb": {
      "command": "/usr/local/bin/ckb",
      "args": ["mcp"]
    }
  }
}
```

### Installation

#### 1) Install the CKB binary

```bash
# Clone the repo
cd ~/Projects/mcps
git clone https://github.com/simplyliz/codemcp.git
cd codemcp

# Set Go proxy (optional; useful in restricted networks)
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=sum.golang.google.cn

# Build
go build -o ckb ./cmd/ckb

# Install to system path
sudo cp ckb /usr/local/bin/ckb
sudo chmod +x /usr/local/bin/ckb

# Verify
ckb --version
```

#### 2) Install Python LSP support

```bash
pip3 install python-lsp-server

# Verify
python3 -m pylsp --version
```

#### 3) Initialize CKB for a project

```bash
cd /path/to/your/project
ckb init
```

This creates `.ckb/config.json`.

### Project config file

Location: `project/.ckb/config.json`

```json
{
  "backends": {
    "lsp": {
      "enabled": true,
      "servers": {
        "python": {
          "command": "python3",
          "args": ["-m", "pylsp"]
        }
      }
    },
    "git": {
      "enabled": true
    }
  }
}
```

### Usage examples

**Search symbols**:
```
Use CKB to search for FastAPI symbols in this project
```

**Find references**:
```
Use CKB to find all references to get_user
```

**Impact analysis**:
```
Use CKB to analyze the impact of modifying the User class
```

### Common commands

```bash
# Status
ckb status

# Search symbols
ckb search <symbol>

# Find references
ckb refs <symbol>

# Architecture overview
ckb arch

# Diagnostics
ckb doctor
```

### Supported languages

- ✅ Python (via LSP)
- ✅ TypeScript/JavaScript (via LSP)
- ✅ Go (via SCIP + LSP)
- ✅ Java (via SCIP)
- ✅ Any repo with Git history

### Notes

⚠️ **Each project must be initialized**: even though the CKB MCP server is configured at user scope, each project should run `ckb init` to create project-specific configuration.

---

## Context7

### Basics

- **npm package**: `@upstash/context7-mcp`
- **Version**: 2.0.0+
- **Type**: real-time library documentation service
- **Install**: via npx (auto-download)
- **Website**: [context7.com](https://context7.com)
- **GitHub**: [upstash/context7](https://github.com/upstash/context7)

### Capabilities

- ✅ **Real-time docs**: fetch up-to-date, version-aware docs
- ✅ **Code examples**: retrieve current examples and API usage
- ✅ **Library matching**: identify and match libraries used in the project
- ✅ **Seamless integration**: no tab-switching to read docs
- ✅ **Anti-hallucination**: avoid outdated suggestions and non-existent APIs
- ✅ **Broad coverage**: supports mainstream libraries and frameworks

### Configuration

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**With API key** (optional, higher rate limits and private access):

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {
        "CONTEXT7_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Environment variables

| Variable | Required | Notes |
|------|------|------|
| `CONTEXT7_API_KEY` | ❌ | Optional; higher rate limits and private access |

**Get an API key**: create an account at [context7.com/dashboard](https://context7.com/dashboard).

### Available tools

Context7 provides these tools:

1. **resolve-library-id**: resolve a library name into a Context7 library ID
   - `query` (required): the user's task/question
   - `libraryName` (required): library name to search

2. **query-docs**: fetch docs via library ID
   - `libraryId` (required): library ID (e.g., `/mongodb/docs`)
   - `query` (required): question/task to retrieve relevant docs

### Usage examples

#### Basic usage (recommended: add rules)

Add rules in `CLAUDE.md` (or your tool settings) to auto-trigger Context7:

```markdown
Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.
```

Then you can ask directly:

```
Create a Next.js middleware that validates a JWT from cookies,
and redirects unauthenticated users to /login
```

#### Manual trigger

If no rules are set, append `use context7` in your prompt:

```
Configure a Cloudflare Worker to cache JSON API responses for 5 minutes. use context7
```

#### Specify library ID (advanced)

If you already know the library ID:

```
Implement basic auth with Supabase.
use library /supabase/supabase for API and docs.
```

### Supported libraries

Context7 supports thousands of libraries, including:

**Web frameworks**:
- Next.js, React, Vue, Angular, Svelte
- Express, Fastify, Koa, NestJS

**Cloud services**:
- AWS SDK, Google Cloud, Azure
- Cloudflare Workers, Vercel, Netlify

**Databases**:
- MongoDB, PostgreSQL, MySQL
- Supabase, Firebase, PlanetScale

**Tooling**:
- Lodash, Axios, Prisma
- TailwindCSS, shadcn/ui

### Characteristics

- ✅ **Zero config**: auto-installs on first use
- ✅ **Auto updates**: npx uses the latest version
- ✅ **Version-aware**: retrieves version-specific docs
- ✅ **Community-driven**: libraries are contributed and maintained by the community
- ✅ **Lightweight**: no local index build required

### Proxy configuration

Context7 supports standard HTTPS proxy env vars:

```bash
export https_proxy=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### Troubleshooting

#### Context7 connection failures

Common causes:
- network issues
- proxy misconfiguration
- rate limiting (without API key)

```bash
# Test connectivity
curl -I https://api.context7.com

# Check proxy
echo $https_proxy

# Consider using an API key for higher rate limits
```

#### Library not found

1. Check spelling
2. Search on [context7.com](https://context7.com)
3. Submit an add request if missing

#### Slow first run

Cause: npx downloads packages on first run (expected).

---

## GitHub MCP Server

### Basics

- **Docker image**: `ghcr.io/github/github-mcp-server`
- **Version**: 0.26.3+
- **Type**: GitHub platform integration
- **Install**: Docker (recommended) or build from source
- **Repo**: [github/github-mcp-server](https://github.com/github/github-mcp-server)
- **Maintainer**: GitHub

### Capabilities

- ✅ **Repo management**: browse code, search files, analyze commits, understand structure
- ✅ **Issue & PR automation**: create/update/manage issues and PRs
- ✅ **CI/CD**: monitor Actions, analyze failures, manage releases
- ✅ **Code security**: review findings, dependabot alerts, pattern analysis
- ✅ **Collaboration**: discussions, notifications, activity analysis
- ✅ **Broad toolset**: gists, labels, projects, stargazers, etc.

### Configuration

#### Basic config (Docker)

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE"
      }
    }
  }
}
```

#### Config with toolsets

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e",
        "GITHUB_TOOLSETS",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE",
        "GITHUB_TOOLSETS": "repos,issues,pull_requests,actions"
      }
    }
  }
}
```

#### GitHub Enterprise configuration

For GitHub Enterprise Server or Enterprise Cloud with data residency (ghe.com):

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e",
        "GITHUB_HOST",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE",
        "GITHUB_HOST": "https://your-ghes-domain.com"
      }
    }
  }
}
```

### Getting a GitHub Personal Access Token (PAT)

1) Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)  
2) Generate a new token (classic)  
3) Set description and expiry (recommended: 90 days)  
4) Select scopes  
5) Copy and store the token securely (you cannot view it again)

### Recommended scopes

**Read-only**:
- ✅ `repo`
- ✅ `read:org`
- ✅ `read:user`

**Full functionality (read/write)**:
- ✅ `repo`
- ✅ `workflow`
- ✅ `admin:org` (if needed)
- ✅ `gist`
- ✅ `notifications`
- ✅ `user`
- ✅ `read:discussion`
- ✅ `write:discussion`

### Configure in Claude Code

Add your token to `~/.claude.json`:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### Environment variables

| Variable | Required | Notes |
|------|------|------|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | ✅ | GitHub PAT |
| `GITHUB_TOOLSETS` | ❌ | Enabled toolsets (comma-separated) |
| `GITHUB_TOOLS` | ❌ | Enabled tools (comma-separated) |
| `GITHUB_HOST` | ❌ | GitHub Enterprise host |
| `GITHUB_READ_ONLY` | ❌ | Read-only mode (`1` to enable) |
| `GITHUB_LOCKDOWN_MODE` | ❌ | Lockdown mode (`1` to enable) |
| `GITHUB_DYNAMIC_TOOLSETS` | ❌ | Dynamic toolset discovery (`1` to enable) |

### Toolsets

Default toolsets:
- `context`, `repos`, `issues`, `pull_requests`, `users`

All toolsets:

| Toolset | Description |
|--------|------------|
| `context` | 🔰 Current user and GitHub context (highly recommended) |
| `actions` | ⚙️ Actions / CI/CD |
| `code_security` | 🔐 Code security scanning |
| `dependabot` | 🤖 Dependabot |
| `discussions` | 💬 Discussions |
| `gists` | 📝 Gists |
| `git` | 🌳 Low-level Git API |
| `issues` | 🐛 Issues |
| `labels` | 🏷️ Labels |
| `notifications` | 🔔 Notifications |
| `orgs` | 🏢 Orgs |
| `projects` | 📊 Projects |
| `pull_requests` | 🔀 Pull requests |
| `repos` | 📦 Repos |
| `secret_protection` | 🔒 Secret scanning |
| `security_advisories` | 🛡️ Security advisories |
| `stargazers` | ⭐ Stargazers |
| `users` | 👥 Users |

Special toolsets:
- `all` (enable all toolsets)
- `default` (context, repos, issues, pull_requests, users)

### Usage examples

Repo:
```
Use GitHub MCP to list all my repositories
```

Issues:
```
Create a new issue in owner/repo: title "Fix login bug", description "Users cannot log in"
```

PRs:
```
Create a PR in owner/repo: from feature-branch to main
```

CI:
```
Show the status of recent GitHub Actions runs in owner/repo
```

### Config examples

Read-only mode:

```json
{
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx",
    "GITHUB_READ_ONLY": "1"
  }
}
```

Enable all toolsets:

```json
{
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx",
    "GITHUB_TOOLSETS": "all"
  }
}
```

Dynamic toolset discovery:

```json
{
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx",
    "GITHUB_DYNAMIC_TOOLSETS": "1"
  }
}
```

### Prerequisites

Docker:

```bash
docker --version
docker ps
```

First run can auto-pull the image, or you can pre-pull:

```bash
docker pull ghcr.io/github/github-mcp-server
```

### Security best practices

- Never commit PATs
- Rotate regularly (e.g., every 90 days)
- Grant least privilege
- Revoke tokens when no longer needed

---

## Playwright MCP

### Basics

- **npm package**: `@playwright/mcp@latest`
- **Version**: 0.0.54+
- **Type**: browser automation
- **Install**: via npx (auto-download)
- **Repo**: [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)
- **Website**: [playwright.dev](https://playwright.dev)
- **Maintainer**: Microsoft

### Capabilities

- ✅ Browser automation (Playwright)
- ✅ No vision required (uses Accessibility Tree; fast and lightweight)
- ✅ Deterministic tools (avoid screenshot fuzziness)
- ✅ Multi-browser: Chrome, Firefox, WebKit (Safari), Edge
- ✅ Page interaction: click, type, navigate, submit forms
- ✅ Content extraction
- ✅ Optional testing assertions
- ✅ Optional PDF export
- ✅ Optional coordinate click (`--caps=vision`)

### Configuration

Basic (recommended):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    }
  }
}
```

With args:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser=chrome",
        "--viewport-size=1280x720",
        "--timeout-action=10000"
      ]
    }
  }
}
```

Headless:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--headless"
      ]
    }
  }
}
```

### Common flags

| Flag | Meaning | Default | Example |
|------|---------|---------|---------|
| `--browser` | browser type | chrome | chrome, firefox, webkit, msedge |
| `--headless` | run headless | false | --headless |
| `--viewport-size` | viewport size | default | --viewport-size=1280x720 |
| `--device` | device emulation | none | --device="iPhone 15" |
| `--timeout-action` | action timeout (ms) | 5000 | --timeout-action=10000 |
| `--timeout-navigation` | navigation timeout (ms) | 60000 | --timeout-navigation=30000 |
| `--user-agent` | override UA | default | --user-agent="Custom UA" |
| `--ignore-https-errors` | ignore HTTPS errors | false | --ignore-https-errors |
| `--caps` | extra capabilities | none | --caps=vision,pdf,testing |

### Persistent profile location

macOS:
```
~/Library/Caches/ms-playwright/mcp-{channel}-profile
```

Linux:
```
~/.cache/ms-playwright/mcp-{channel}-profile
```

Windows:
```
%USERPROFILE%\\AppData\\Local\\ms-playwright\\mcp-{channel}-profile
```

### Optional capabilities

Vision:
```bash
--caps=vision
```

PDF:
```bash
--caps=pdf
```

Testing:
```bash
--caps=testing
```

Tracing:
```bash
--caps=tracing
```

### Use cases

Suitable for:
- UI/E2E automation
- scraping dynamic sites
- form automation
- screenshots / PDFs
- web monitoring
- SPA interactions

Not suitable for:
- high-frequency large-scale crawling
- resource-constrained "always-on" monitoring
- simple API calls (use an HTTP client instead)

### Requirements

Node.js:
```bash
node --version
```

Install browsers (optional; auto-download on first run):
```bash
npx playwright install
```

### Standalone server mode (advanced)

```bash
# Start server
npx @playwright/mcp@latest --port 8931

# In MCP client config
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/mcp"
    }
  }
}
```

---

## Config locations

### User scope (Claude Code)

**File**: `~/.claude.json`

```json
{
  "mcpServers": {
    "context7": { ... },
    "github": { ... },
    "playwright": { ... }
  },
  "projects": {
    ...
  }
}
```

### Codex CLI config (sync with Claude Code)

If you use Codex CLI and want to reuse the same MCP setup:

- **Codex config**: `~/.codex/config.toml`
- **Field**: `mcp_servers`
- **Note**: some versions require `features.rmcp_client = true` to enable MCP tools
- **Sync**: DevBooks does not ship a Claude→Codex MCP sync script; copy `mcpServers` from `~/.claude.json` into `mcp_servers` in `~/.codex/config.toml` manually.

---

## Use cases

### Context7

- query latest library docs and APIs
- fetch up-to-date code examples
- avoid outdated suggestions

### GitHub MCP Server

- browse/search repos
- create/manage issues
- create/review PRs
- monitor CI/CD
- security scanning and dependabot

### Playwright MCP

- web automation testing and E2E
- scrape dynamic pages
- automate form flows
- screenshots/PDFs

---

## Troubleshooting

- Context7: see [Context7](#context7)
- GitHub MCP: see [GitHub MCP Server](#github-mcp-server)
- Playwright MCP: see [Playwright MCP](#playwright-mcp)

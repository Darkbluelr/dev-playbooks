# Recommended MCP Servers

> Detailed configuration and usage guide for MCP servers recommended by this repo.
>
> Date: 2025-12-30
> Scope: User scope (available to all projects)

---

## Table of contents

1. [Overview](#overview)
2. [TaskMaster AI](#taskmaster-ai)
3. [CKB (Code Knowledge Backend)](#ckb-code-knowledge-backend)
4. [tree-sitter-mcp](#tree-sitter-mcp)
5. [Context7](#context7)
6. [GitHub MCP Server](#github-mcp-server)
7. [Playwright MCP](#playwright-mcp)
8. [Configuration locations](#configuration-locations)
9. [Common use cases](#common-use-cases)
10. [Troubleshooting](#troubleshooting)
11. [Maintenance and updates](#maintenance-and-updates)
12. [References](#references)

---

## Overview

### Currently configured MCP servers

| Server | Type | Scope | Primary capability |
|---|---|---|---|
| **task-master** | Task management | User scope | AI-driven task management |
| **ckb** | Code analysis | User scope | Symbol search, references, impact analysis |
| **tree-sitter-mcp** | Code search | User scope | Semantic code search and analysis |
| **context7** | Docs | User scope | Fetch up-to-date library docs and examples |
| **github** | GitHub integration | User scope | Repos, issues, PRs, actions automation |
| **playwright** | Browser automation | User scope | Web automation, scraping, and interaction |

**Config file**: `~/.claude.json` (top-level `mcpServers` field)

**Scope**: all projects

---

## TaskMaster AI

### Basics

- **npm package**: `task-master-ai`
- **Type**: AI-driven task management system
- **Install**: `npx` (auto-download)
- **Docs**: https://docs.task-master.dev
- **GitHub**: https://github.com/eyaltoledano/claude-task-master

### Capabilities

- Task management: create/update/delete/search
- Priority management: high/medium/low
- Status tracking: todo/in-progress/done
- AI suggestions and analysis
- Natural-language interaction
- Multi-model support (Claude/GPT/etc.)

### Configuration

```json
{
  "mcpServers": {
    "task-master": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "sk-...",
        "ANTHROPIC_BASE_URL": "https://anyrouter.top",
        "OPENAI_API_KEY": "sk-...",
        "OPENAI_BASE_URL": "https://anyrouter.top/v1",
        "TASK_MASTER_TOOLS": "core"
      }
    }
  }
}
```

### Environment variables

| Variable | Required | Description |
|---|:---:|---|
| `ANTHROPIC_API_KEY` | yes | API key for Claude models |
| `ANTHROPIC_BASE_URL` | no | Custom Anthropic API endpoint |
| `OPENAI_API_KEY` | no | API key for OpenAI models |
| `OPENAI_BASE_URL` | no | Custom OpenAI API endpoint |
| `TASK_MASTER_TOOLS` | no | Enabled toolset: `core`/`standard`/`all`/comma-separated list |

### Toolset selection (`TASK_MASTER_TOOLS`)

Note: `task-master-ai` reads `TASK_MASTER_TOOLS` (not `TASK_MASTER_TOOL_MODE`).

Common values:
- `core`: minimal toolset (default/recommended)
- `standard`: standard toolset
- `all`: enable everything
- `tool_a,tool_b,...`: custom allowlist (comma-separated)

### Usage examples

Create a task:
```
Use task-master to create a task: finish MCP configuration docs
```

List tasks:
```
Use task-master to list all open tasks
```

Update task status:
```
Use task-master to mark the task as completed
```

Search tasks:
```
Use task-master to search tasks about "docs"
```

### Model configuration (optional)

```bash
# interactive setup
npx task-master-ai models --setup

# or set explicitly
npx task-master-ai models --set-main=gpt-4o
npx task-master-ai models --set-research=claude-3-5-sonnet-20241022
npx task-master-ai models --set-fallback=gpt-3.5-turbo
```

Config file location: `~/.taskmaster/config.json`

### Supported API providers

- Anthropic (Claude)
- OpenAI (GPT-4, GPT-3.5)
- Perplexity
- Google (Gemini)
- Mistral
- Groq
- OpenRouter
- xAI (Grok)
- Azure OpenAI
- Ollama (local)

---

## CKB (Code Knowledge Backend)

### Basics

- **Version**: 7.5.0
- **Type**: language-agnostic code understanding layer
- **Install path**: `/usr/local/bin/ckb`
- **GitHub**: https://github.com/simplyliz/codemcp

### Capabilities

- Symbol search: functions/classes/variables
- Find references: all usages
- Impact analysis: estimate blast radius
- Architecture view: structure and dependencies
- Git integration: blame + history

### Backend support

- **LSP** (Language Server Protocol): Python, TypeScript, Go, etc.
- **SCIP**: precomputed index (Go/Java/TypeScript, etc.)
- **Git**: repository history and blame

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

### Installation steps

#### 1) Install the CKB binary

```bash
# clone
cd ~/Projects/mcps
git clone https://github.com/simplyliz/codemcp.git
cd codemcp

# Go proxy settings (useful in some regions)
export GOPROXY=https://goproxy.cn,direct
export GOSUMDB=sum.golang.google.cn

# build
go build -o ckb ./cmd/ckb

# install
sudo cp ckb /usr/local/bin/ckb
sudo chmod +x /usr/local/bin/ckb

# verify
ckb --version
```

#### 2) Install Python LSP support

```bash
pip3 install python-lsp-server

# verify
python3 -m pylsp --version
```

#### 3) Initialize CKB for a project

```bash
cd /path/to/your/project
ckb init
```

This creates `.ckb/config.json`.

### Project config file

Location: `<project>/.ckb/config.json`

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

Symbol search:
```
Use CKB to search for FastAPI symbols in this project
```

Find references:
```
Use CKB to find all references to the get_user function
```

Impact analysis:
```
Use CKB to analyze the impact of modifying the User class
```

### Common commands

```bash
# system status
ckb status

# search symbols
ckb search <symbol>

# find references
ckb refs <symbol>

# architecture overview
ckb arch

# diagnostics
ckb doctor
```

### Supported languages

- Python (via LSP)
- TypeScript/JavaScript (via LSP)
- Go (via SCIP + LSP)
- Java (via SCIP)
- Any project with a Git history

### Notes

Each project must be initialized separately: even though the CKB MCP server is configured at user scope, you still need to run `ckb init` per project to create project-specific configuration.

---

## tree-sitter-mcp

### Basics

- **npm package**: `@nendo/tree-sitter-mcp`
- **Type**: semantic code search
- **Install**: `npx` (auto-download)
- **GitHub**: https://github.com/nendo/tree-sitter-mcp

### Capabilities

- Real-time parsing (no prebuilt index required)
- Structural search (code-aware search)
- AST-level queries
- Multi-language support
- Lightweight (minimal configuration)

### Configuration

```json
{
  "mcpServers": {
    "tree-sitter-mcp": {
      "command": "npx",
      "args": ["-y", "@nendo/tree-sitter-mcp", "--mcp"]
    }
  }
}
```

### Highlights

- Auto-installs on first use
- Auto-updates to latest via npx
- No local installation maintenance
- Works for any project (no init required)
- Zero-config

### Usage examples

Analyze file structure:
```
Use tree-sitter to analyze the structure of backend/main.py
```

Find function definitions:
```
Use tree-sitter to find all async function definitions
```

Pattern search:
```
Use tree-sitter to find all try-except blocks
```

### Supported languages

- Python
- JavaScript/TypeScript
- Go
- Rust
- C/C++
- Java
- Ruby
- and more

### Comparison

| Feature | tree-sitter-mcp | CKB |
|---|---|---|
| Installation complexity | easy (auto) | medium (build) |
| Project initialization | not required | required |
| Semantic understanding | medium | high |
| Find references | basic | full |
| Best for | fast search | deep analysis |

---

## Context7

### Basics

- **npm package**: `@upstash/context7-mcp`
- **Version**: 2.0.0+
- **Type**: real-time library documentation service
- **Install**: `npx` (auto-download)
- **Website**: https://context7.com
- **GitHub**: https://github.com/upstash/context7

### Capabilities

- Real-time docs: latest, version-specific library docs
- Code examples: up-to-date examples and API usage
- Library matching: detect and match libraries used in the project
- Seamless workflow: no context switching to browser tabs
- Reduces hallucinations: avoids outdated or non-existent APIs
- Broad support: popular libraries and frameworks

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

Configuration with API key (optional; for higher rate limits and private repos):

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

| Variable | Required | Description |
|---|:---:|---|
| `CONTEXT7_API_KEY` | no | Optional API key for higher rate limits and private repo access |

Get an API key: https://context7.com/dashboard

### Available tools

Context7 provides tools for LLMs:

1. `resolve-library-id`: resolve a library name into a Context7 library ID
2. `query-docs`: fetch docs for a library ID

### Usage examples

Recommended rule (add to `CLAUDE.md` or tool settings):

```markdown
Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.
```

After adding the rule, ask normally:

```
Create a Next.js middleware that checks for a valid JWT in cookies and redirects unauthenticated users to /login.
```

Manual trigger (if you do not have an auto rule):

```
Configure a Cloudflare Worker script to cache JSON API responses for 5 minutes. use context7
```

Known library ID (advanced):

```
Implement basic auth using Supabase.
use library /supabase/supabase for API and docs.
```

### Supported libraries and frameworks

Context7 supports thousands of libraries, including (not limited to):

Web frameworks:
- Next.js, React, Vue, Angular, Svelte
- Express, Fastify, Koa, NestJS

Cloud services:
- AWS SDK, Google Cloud, Azure
- Cloudflare Workers, Vercel, Netlify

Databases:
- MongoDB, PostgreSQL, MySQL
- Supabase, Firebase, PlanetScale

Utilities:
- Lodash, Axios, Prisma
- TailwindCSS, shadcn/ui

Search for more: https://context7.com

### Proxy configuration

Context7 supports standard HTTPS proxy environment variables:

```bash
export https_proxy=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### Comparison

| Feature | Context7 | CKB | tree-sitter-mcp |
|---|---|---|---|
| Installation complexity | easy (auto) | medium (build) | easy (auto) |
| Documentation source | online/latest | local code | local code |
| Version-aware docs | yes | no | no |
| Up-to-date examples | yes | no | no |
| Offline | no | yes | yes |
| Best for | library docs | local deep analysis | local fast search |

### Troubleshooting

Context7 connection failures:
- network issues
- proxy misconfiguration
- rate limiting (no API key)

```bash
# test connectivity
curl -I https://api.context7.com

# check proxy settings
echo "$https_proxy"
```

Invalid API key:
1. Confirm the key is correct and not expired
2. Regenerate the key
3. Update your config

Library resolution failures:
1. Use a more specific library name
2. Check spelling
3. Search on https://context7.com

Library not found:
1. Check spelling
2. Search on https://context7.com
3. Submit a request to add the library if needed

Slow first run:
- `npx` needs to download the package (expected)
- wait for completion; subsequent runs are fast

---

## GitHub MCP Server

### Basics

- **Docker image**: `ghcr.io/github/github-mcp-server`
- **Version**: 0.26.3+
- **Type**: GitHub platform integration
- **Install**: Docker (recommended) or build from source
- **Repo**: https://github.com/github/github-mcp-server
- **Maintained by**: GitHub

### Capabilities

- Repo management: browse/search code, commits, project structure
- Issue & PR automation: create/update/manage
- CI/CD: monitor GitHub Actions, analyze failures, manage releases
- Code security: security findings, Dependabot alerts, pattern analysis
- Collaboration: discussions, notifications, activity analysis
- Toolsets: gists, labels, projects, stargazers, and more

### Configuration

Basic Docker config:

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

With toolsets enabled:

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

GitHub Enterprise (GHES / ghe.com) config:

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

1. Visit https://github.com/settings/tokens
2. Generate a new token (classic)
3. Add a description (e.g. "Claude Code MCP")
4. Choose expiration (recommended: 90 days)
5. Select scopes

Recommended scopes:

Read-only:
- `repo`
- `read:org`
- `read:user`

Full functionality (read/write):
- `repo`
- `workflow`
- `admin:org` (if needed)
- `gist`
- `notifications`
- `user`
- `read:discussion`
- `write:discussion`

Important: copy and store the token securely; you cannot view it again after leaving the page.

Example `~/.claude.json` snippet:

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

| Variable | Required | Description |
|---|:---:|---|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | yes | GitHub PAT |
| `GITHUB_TOOLSETS` | no | Enabled toolsets (comma-separated) |
| `GITHUB_TOOLS` | no | Enabled specific tools (comma-separated) |
| `GITHUB_HOST` | no | GitHub Enterprise host URL |
| `GITHUB_READ_ONLY` | no | Read-only mode (`1` to enable) |
| `GITHUB_LOCKDOWN_MODE` | no | Lockdown mode (`1` to enable) |
| `GITHUB_DYNAMIC_TOOLSETS` | no | Dynamic toolset discovery (`1` to enable) |

### Toolsets

Default toolsets (when unset):
- `context`: current user + GitHub context (recommended)
- `repos`: repository management
- `issues`: issue management
- `pull_requests`: PR management
- `users`: user info

All toolsets:
| Toolset | Description |
|---|---|
| `context` | current user + context |
| `actions` | GitHub Actions / CI-CD |
| `code_security` | code security scanning |
| `dependabot` | Dependabot |
| `discussions` | Discussions |
| `gists` | Gists |
| `git` | low-level Git API |
| `issues` | Issues |
| `labels` | Labels |
| `notifications` | Notifications |
| `orgs` | Orgs |
| `projects` | Projects |
| `pull_requests` | Pull requests |
| `repos` | Repositories |
| `secret_protection` | secret scanning |
| `security_advisories` | security advisories |
| `stargazers` | stargazers |
| `users` | users |

Special values:
- `all`: enable all toolsets
- `default`: default set (`context,repos,issues,pull_requests,users`)

### Usage examples

Repo management:
```
Use GitHub MCP to list all my repositories
```

```
Fetch file contents from owner/repo: src/main.py
```

```
Search owner/repo for files containing "authentication"
```

Issue management:
```
Create a new issue in owner/repo: title "Fix login bug", description "Users cannot log in"
```

```
List all open issues in owner/repo
```

```
Add a comment to issue #123: "Fixed; please verify"
```

PR management:
```
Create a PR in owner/repo: from feature-branch to main
```

```
List PRs in owner/repo pending review
```

```
Fetch review comments for PR #456
```

CI/CD monitoring:
```
Check recent GitHub Actions runs for owner/repo
```

```
Fetch logs for workflow run ID 123456
```

### Toolset config examples

Read-only mode (recommended while exploring):

```json
{
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx",
    "GITHUB_READ_ONLY": "1"
  }
}
```

Specific toolsets:

```json
{
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx",
    "GITHUB_TOOLSETS": "repos,issues,pull_requests,actions"
  }
}
```

Enable all:

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

Docker must be installed and running:

```bash
docker --version
docker ps
```

Optional pre-pull:

```bash
docker pull ghcr.io/github/github-mcp-server
```

### Troubleshooting

Docker pull failures:

```bash
docker logout ghcr.io
docker pull ghcr.io/github/github-mcp-server
```

Docker not running:

```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

PAT permissions:
1. Review token scopes under https://github.com/settings/tokens
2. Add missing scopes
3. Regenerate token if needed

API rate limits:
- unauthenticated: 60/hour
- authenticated: 5000/hour

Connectivity:
```bash
curl -I https://api.github.com
```

GitHub Enterprise:
- GHES: `https://your-ghes.com`
- ghe.com: `https://yourorg.ghe.com`

Tool visibility:
```bash
cat ~/.claude.json | grep -A 20 '\"github\"'
```

### Security best practices

- Never commit PATs to git
- Rotate tokens regularly (e.g. every 90 days)
- Use least privilege
- Revoke tokens immediately when no longer needed
- Prefer read-only mode (`GITHUB_READ_ONLY=1`) for exploration
- Use lockdown mode (`GITHUB_LOCKDOWN_MODE=1`) for production contexts
- Audit periodically: https://github.com/settings/security-log

---

## Playwright MCP

### Basics

- **npm package**: `@playwright/mcp@latest`
- **Version**: 0.0.54+
- **Type**: browser automation
- **Install**: `npx` (auto-download)
- **Repo**: https://github.com/microsoft/playwright-mcp
- **Website**: https://playwright.dev
- **Maintained by**: Microsoft

### Capabilities

- Browser automation via Playwright
- No vision model required: uses Accessibility Tree instead of screenshots
- More deterministic than screenshot-based approaches
- Multi-browser: Chrome, Firefox, WebKit (Safari), Edge
- Page interaction: click/type/navigate/form submit
- Content extraction: text and element data
- Optional features: testing, PDF export, vision-based coordinate click

### Configuration

Basic config (recommended):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

With parameters:

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
      "args": ["@playwright/mcp@latest", "--headless"]
    }
  }
}
```

### Common parameters

| Flag | Description | Default | Example |
|---|---|---|---|
| `--browser` | browser | chrome | chrome, firefox, webkit, msedge |
| `--headless` | headless mode | false | `--headless` |
| `--viewport-size` | window size | default | `--viewport-size=1280x720` |
| `--device` | emulate device | none | `--device="iPhone 15"` |
| `--timeout-action` | action timeout (ms) | 5000 | `--timeout-action=10000` |
| `--timeout-navigation` | nav timeout (ms) | 60000 | `--timeout-navigation=30000` |
| `--user-agent` | custom UA | default | `--user-agent="Custom UA"` |
| `--ignore-https-errors` | ignore HTTPS errors | false | `--ignore-https-errors` |
| `--caps` | extra capabilities | none | `--caps=vision,pdf,testing` |

### Advanced options

Proxy:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--proxy-server=http://myproxy:3128",
        "--proxy-bypass=.com,chromium.org"
      ]
    }
  }
}
```

Persistent user data:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--user-data-dir=/path/to/profile"]
    }
  }
}
```

Isolated sessions:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--isolated",
        "--storage-state=/path/to/state.json"
      ]
    }
  }
}
```

Enable extra capabilities:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--caps=vision,pdf,testing"]
    }
  }
}
```

### Default persistent profile locations

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

You can override with `--user-data-dir`.

### Optional capabilities via `--caps`

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

### Usage examples

Basic browsing:
```
Use Playwright to open a browser and visit https://example.com
```

Fill a form:
```
Use Playwright:
1. Visit https://forms.example.com
2. Type "testuser" into #username
3. Type "password123" into #password
4. Click #submit
```

Extract content:
```
Use Playwright to visit https://news.example.com and extract all article titles
```

Web test:
```
Use Playwright to test login:
1. Visit the login page
2. Enter credentials
3. Submit the form
4. Verify redirect to dashboard
```

Screenshot:
```
Use Playwright to visit https://example.com and save a screenshot
```

### When it fits / does not fit

Fits:
- UI automation and E2E testing
- scraping data from dynamic pages
- form automation
- screenshots and PDF export
- monitoring page changes
- interacting with SPAs (React/Vue/etc.)

Does not fit:
- high-frequency large-scale scraping (resource heavy)
- real-time monitoring where browser cost is unacceptable
- simple API calls (an HTTP client is more efficient)

### Extension mode (advanced)

Connect to an existing browser session via a Chrome extension:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--extension"]
    }
  }
}
```

Prereqs:
1. Install "Playwright MCP Bridge" Chrome extension
2. Only Edge/Chrome supported
3. Can reuse an already logged-in browser session

### Access restrictions and security notes

Allowed origins:
```bash
--allowed-origins="https://example.com;https://trusted.com"
```

Blocked origins:
```bash
--blocked-origins="https://malicious.com"
```

Note: this is not a security boundary; it is a guardrail only.

Block service workers:
```bash
--block-service-workers
```

Sandbox:
```bash
--no-sandbox
```

Warning: disabling sandbox reduces security; use only when required (e.g. some Docker contexts).

### Troubleshooting

Browsers missing:
```bash
npx playwright install
npx playwright install chromium
```

Slow first run:
- downloads the package and browsers via `npx` (expected)

Headless debugging:
1. remove `--headless` to watch the browser
2. enable tracing: `--caps=tracing`
3. save screenshots

Timeouts:
```bash
--timeout-action=30000
--timeout-navigation=90000
```

Permission issues:
```bash
--grant-permissions=geolocation,clipboard-read,clipboard-write
```

Docker environments:
```dockerfile
FROM mcr.microsoft.com/playwright:v1.48.0-noble
WORKDIR /app
RUN npm install -g playwright
CMD ["npx", "@playwright/mcp@latest", "--headless", "--no-sandbox"]
```

### Standalone server mode (advanced)

```bash
# start server
npx @playwright/mcp@latest --port 8931
```

Client config example:
```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/mcp"
    }
  }
}
```

Characteristics:
- HTTP transport
- suitable for remote access
- works on headless systems

### Config file

```json
// playwright-mcp-config.json
{
  "browser": "chrome",
  "headless": true,
  "viewport": { "width": 1280, "height": 720 },
  "ignoreHTTPSErrors": true,
  "timeout": {
    "action": 10000,
    "navigation": 60000
  },
  "proxy": {
    "server": "http://myproxy:3128",
    "bypass": ".com,chromium.org"
  }
}
```

Use the config file:
```bash
--config=/path/to/config.json
```

### Best practices

Choose the right mode:
```bash
# local debugging: show browser
--browser=chrome

# production: headless
--headless

# CI: headless + no sandbox (if required)
--headless --no-sandbox
```

Performance:
```bash
--timeout-action=3000
--user-data-dir=~/.playwright-profile
--shared-browser-context
```

Debug artifacts:
```bash
--save-session
--save-trace
--save-video=1280x720
```

Permissions:
```bash
--grant-permissions=geolocation,notifications
--allowed-origins="https://trusted.com"
```

Updating Playwright MCP:
```bash
# npx uses the latest version automatically
npx clear-npx-cache
npx playwright install
```

---

## Configuration locations

### User scope configuration

**File**: `~/.claude.json`

```json
{
  "mcpServers": {
    "task-master": { },
    "ckb": { },
    "tree-sitter-mcp": { },
    "context7": { },
    "github": { },
    "playwright": { }
  },
  "projects": {
  }
}
```

### Codex CLI configuration (sync with Claude Code)

If you use Codex CLI and want to reuse the same MCP set:

- **Codex config file**: `~/.codex/config.toml`
- **Field**: `mcp_servers`
- **Note**: some versions require enabling `features.rmcp_client = true` to load MCP tools in Codex
- **Recommended**: use the repo script to sync from Claude config to Codex: `scripts/sync_mcp_from_claude_to_codex.py`
- **Guide**: `mcp_codex.md`

### Project-specific configuration

- **CKB**: `<project>/.ckb/config.json`
- **TaskMaster**: `~/.taskmaster/config.json` (optional)

---

## Common use cases

TaskMaster AI is a good fit for:
- task tracking and project planning
- todos and progress reporting
- refactor planning
- bug tracking

CKB is a good fit for:
- architecture understanding in large codebases
- symbol reference lookups
- impact analysis before changes
- git blame/history analysis
- dependency tracking

tree-sitter-mcp is a good fit for:
- fast code search
- structural/semantic analysis
- new or temporary projects (no init required)
- lightweight code understanding
- pattern matching

Context7 is a good fit for:
- querying the latest library docs and APIs
- getting up-to-date code examples
- learning new libraries/frameworks
- avoiding outdated code suggestions

GitHub MCP Server is a good fit for:
- browsing/searching GitHub repos
- creating/managing issues
- creating/reviewing PRs
- CI/CD monitoring
- collaboration and project management
- security scanning and Dependabot management

Playwright MCP is a good fit for:
- web automation testing and E2E
- scraping dynamic pages
- form automation
- screenshots and PDFs
- monitoring page changes
- interacting with SPAs
- e-commerce flow automation tests

---

## Troubleshooting

TaskMaster fails to start:
- missing API key
- API endpoint not reachable
- npx download issues

```bash
# print env keys from config
cat ~/.claude.json | python3 -c "
import sys, json
data = json.load(sys.stdin)
env = data['mcpServers']['task-master']['env']
print('env keys:', list(env.keys()))
"

# test API reachability
curl -I https://anyrouter.top
```

CKB shows `LSP not ready`:
```bash
python3 -m pylsp --version
cat .ckb/config.json
ckb init
```

tree-sitter-mcp first run is slow:
- `npx` needs to download packages (expected)

Context7/GitHub/Playwright:
- see their respective sections for specific troubleshooting steps

---

## Maintenance and updates

Update TaskMaster:
```bash
# npx uses latest automatically; nothing to do
```

Update CKB:
```bash
cd ~/Projects/mcps/codemcp
git pull
go build -o ckb ./cmd/ckb
sudo cp ckb /usr/local/bin/ckb
```

Update tree-sitter-mcp:
```bash
# npx -y downloads latest automatically; nothing to do
```

Update Context7:
```bash
# npx -y downloads latest automatically; nothing to do
```

Update GitHub MCP Server:
```bash
docker pull ghcr.io/github/github-mcp-server
```

Update Playwright MCP:
```bash
npx clear-npx-cache
npx playwright install
```

---

## References

TaskMaster AI:
- https://docs.task-master.dev
- https://github.com/eyaltoledano/claude-task-master
- https://www.npmjs.com/package/task-master-ai

CKB:
- https://github.com/simplyliz/codemcp
- https://mcp.lobehub.com/

tree-sitter-mcp:
- https://github.com/nendo/tree-sitter-mcp
- https://www.npmjs.com/package/@nendo/tree-sitter-mcp

Context7:
- https://context7.com
- https://github.com/upstash/context7
- https://www.npmjs.com/package/@upstash/context7-mcp
- https://context7.com/dashboard
- https://github.com/upstash/context7#-adding-projects

GitHub MCP Server:
- https://github.com/github/github-mcp-server
- https://github.com/github/github-mcp-server/pkgs/container/github-mcp-server
- https://github.com/github/github-mcp-server#readme
- https://github.com/github/github-mcp-server/tree/main/docs
- https://github.com/settings/tokens

Playwright MCP:
- https://github.com/microsoft/playwright-mcp
- https://playwright.dev
- https://www.npmjs.com/package/@playwright/mcp
- https://github.com/microsoft/playwright-mcp/tree/main/extension
- https://github.com/microsoft/playwright-mcp#docker

General:
- https://modelcontextprotocol.io/
- https://docs.claude.com/en/docs/claude-code/mcp
- https://mcp.lobehub.com/

---

**Document updated**: 2025-12-30
**Author**: Claude Code
**Maintenance**: update configs and usage notes periodically

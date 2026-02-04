# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.6] - 2026-02-04

### Fixed

- **Windows compatibility**: Changed npm bin entry from bash wrapper to direct `.mjs` file to fix "Unexpected identifier 'pipefail'" error on Windows

## [4.0.0] - 2026-02-03

### Added

- **Completion Contract**: Compiles user intent into machine-readable contracts, locking “obligation → check → evidence” chains to prevent silent weakening
- **7 Gates (G0-G6)**: End-to-end judgeable checkpoints from input readiness to archive decision — any failure blocks
- **Upstream SSOT Support**: Auto-indexes existing requirement docs into judgeable constraints; scaffolds a minimal SSOT pack when missing
- **Knife Slicing Protocol**: Large requirements must be sliced with a complexity budget per slice — over budget means slice again
- **Void Research Protocol**: Research before decisions for high-entropy problems, producing traceable ADRs
- **Evidence Freshness Check**: Evidence must be newer than the deliverables it claims to cover
- **Weak-Link Obligations**: Docs/configs/release notes and other “non-code contracts” are compiled into judgeable obligations

### Fixed

- **Ignore rules**: Added `.ci-index/` (local index DB directory) to ignore lists to prevent accidental commit/publish
- **Docs consistency**: Aligned install-time command examples to `dev-playbooks`

## [3.1.0] - 2026-01-31

> Important: `3.0.0` was a mis-published release (version/narrative drift vs the actual capability set). Prefer `3.1.0` for an auditable release boundary and CN↔EN alignment.

### Added

- Added release-boundary evidence anchors:
  - Treat `npm pack --dry-run` as the final, auditable packlist boundary (what is included/excluded).
  - Keep CLI entrypoint self-check anchors (bin mapping + entry executability).

### Changed

- Aligned CN/EN release-layer versions to `3.1.0` and aligned release notes narrative (language differs, key points match).

### Fixed

- Improved release and sync auditability:
  - Turn “publish boundary” and “cross-repo sync boundary” into evidence-driven checks (packlist + parity reports), reducing silent drift risk.

---

## [3.0.3] - 2026-01-29

### Added

- Added protocol v1.1 coverage mapping and enforced coverage reports (mapping + evidence driven; requires `uncovered=0`).
- Added Gate Report evidence conventions and risk evidence paths (`evidence/gates/`, `evidence/risks/`).
- Added formatted dependency audit output (minimal fields + raw audit JSON).

### Changed

- Hardened `change-check.sh`: metadata contract, state machine, change-type matrix, and Knife/Bootstrap gate validations.
- Aligned docs and templates with Gate Report, coverage reports, and dependency audit conventions.

---

## [3.0.2] - 2026-01-28

### Added

- Added protocol-level CN↔EN sync tooling for `dev-playbooks/**` with auditable reports and rollback anchor (`scripts/english-sync-protocol.sh`).
- Added protocol v1.1 coverage report generator for strict/archive gating (`scripts/generate-protocol-v1.1-coverage-report.sh`).

### Changed

- Hardened strict/archive gates to require protocol sync reports, parity report, and v1.1 coverage report (`skills/devbooks-delivery-workflow/scripts/change-check.sh`).
- Hardened high-risk approvals: strict now requires human approval records for `risk_level=high` (gate-enforced).

---

## [3.0.1] - 2026-01-27

### Added

- Added `devbooks-start` Skill: materializes the Start entrypoint (RUNBOOK/inputs index + evidence directory scaffold).
- Added verification entrypoints for legacy cleanup, slash commands, npm packaging, and summary validation.
- Added tool scripts: `tools/devbooks-embedding.sh`, `tools/devbooks-complexity.sh`, `tools/devbooks-entropy-viz.sh`.

### Changed

- Completed `change-check.sh` strict gates: G0–G6 reports, risk/trace/handoff blocking, and registry consistency checks.
- Hardened `scripts/english-sync.sh`: added release spec reporting and strengthened the `dev-playbooks/**` deny boundary.
- Unified CLI entry script: `bin/devbooks.mjs`.

---

## [3.0.0] - 2026-01-26

### Added

- AI-native workflow and protocol upgrade:
  - Completed Start/Router entrypoints and phase routing conventions.
  - Added change package templates and protocol contracts (RUNBOOK, verification/compliance/rollback, Knife Plan, contract schemas).
  - Completed quality gates and evidence structure (G0–G6, risk and audit requirements).
  - Added dependency audit and release validation entrypoints.
  - Updated architecture/filesystem views and workflow diagram templates.

### Changed

- Completed CLI entrypoints:
  - Added `start` and `router` commands for entry routing (no AI execution).
  - Updated help output to point to templates and workflow docs.

---

## [2.6.0] - 2026-01-25

### Added

- MCP additions:
  - Added MCP detection script `scripts/detect-mcp.sh`.
  - Added MCP-related specs and guidance.
- Long-term guidance and references:
  - Added shared reference docs under `skills/_shared/references/`.
  - Added archiver and workflow reference docs under `skills/**/references/`.
- Specs:
  - Added `dev-playbooks/specs/README.md` as a specs index.

### Changed

- Documentation cleanup and reorganization.
- Archived change package `20260124-0636-enhance-devbooks-longterm-guidance`.

---

## [2.5.4] - 2026-01-23

### Fixed

- Corrected ignore rules:
  - Removed `.ckb/` (external tool cache; not part of DevBooks).
  - Updated `dev-playbooks/changes/*/evidence/` ignores to ignore the entire `dev-playbooks/` working area where appropriate.

### Changed

- More precise ignore scope:
  - `dev-playbooks/` - DevBooks working directory (runtime-generated content)
  - `.devbooks/` - local DevBooks config
  - `evidence/` - test evidence
  - `*.tmp`, `*.bak` - temp/backup files

---

## [2.5.3] - 2026-01-23

### Added

- Smarter ignore generation:
  - Ignore runtime temporary files from DevBooks workflows.
  - Add `evidence/`, `dev-playbooks/changes/*/evidence/`, `*.tmp`, `*.bak`, and `.ckb/` patterns.
  - Auto-detect project-level Skills directories (e.g., `.factory/`, `.cursor/`).

### Changed

- Improved ignore generation logic:
  - Add tool-specific directories based on selected AI tools.
  - Support relative `skillsDir` paths (e.g., `.factory/skills`).
  - Update both `.gitignore` and `.npmignore`.

---

## [2.5.2] - 2026-01-23

### Fixed

- `init` supports Factory and Cursor:
  - Added Factory as a full-Skills supported tool.
  - Upgraded Cursor from a Rules system to full Skills support.
  - `dev-playbooks init` can now target Factory and Cursor.
  - Skills install correctly to `.factory/skills/` and `.cursor/skills/`.

- More general Skills installation:
  - Removed hard-coded tool-id checks.
  - Support any tool definition with `skillsDir`.
  - Support relative `skillsDir` (e.g., `.factory/skills`).

---

## [2.5.1] - 2026-01-23

### Fixed

- Fixed changelog display for `dev-playbooks update`:
  - Added complete 2.5.0 release notes.
  - Ensured users can see detailed changes for the latest version.

---

## [2.5.0] - 2026-01-23

### Added

- Factory native Skills support: add `.factory/skills/` for Factory Droid
  - Use symlinks to keep `skills/` as a single source of truth.
  - All 18 DevBooks Skills are available natively.
  - Conform to Factory Skills standard (YAML front matter + Markdown).

- Cursor native Skills support: add `.cursor/skills/` for Cursor Agent
  - Use symlinks to keep `skills/` as a single source of truth.
  - All 18 DevBooks Skills are available natively.
  - Conform to Cursor Agent Skills standard.

### Changed

- README improvements:
  - Simplified structure and updated supported AI tools table.
  - Clarified Skills directory locations.

- `package.json`:
  - Added `.factory/` and `.cursor/` to npm published files.

### Technical details

- Symlinks (instead of file copies) ensure:
  - Single source of truth
  - Automatic updates
  - Lower maintenance cost
  - Avoid drift

---

## [2.3.0] - 2026-01-23

### Added

- Added `devbooks-docs-consistency`: documentation consistency checks (keeps legacy alias and prints a deprecation warning)
  - Custom rules engine (persistent rules + one-off tasks)
  - Incremental scanning via git diff
  - Completeness checks (prerequisites, security, troubleshooting, configuration docs, API docs)
  - Document classification (living/historical/conceptual)
  - Style checks with persisted config
- Added shared reference docs:
  - `skills/_shared/references/completeness-thinking-framework.md`
  - `skills/_shared/references/expert-list.md`
- Added tool scripts:
  - `scripts/benchmark-scan.sh`
  - `scripts/detect-fancy-words.sh`

### Changed

- Kept legacy alias for `devbooks-docs-consistency` with a 6-month deprecation window.
- Updated AI behavior guidelines in all Skills with an expert-role declaration protocol.
- Improved `devbooks-archiver`: integrate docs consistency checks.
- Improved `devbooks-brownfield-bootstrap`: generate docs maintenance metadata.
- Improved `devbooks-proposal-author`: add Challenger review section.

### Removed

- Removed MCP enhancement sections from all Skills.
- Removed `CSDN_ARTICLE.md`.

---

## [2.2.1] - 2025-01-20

### Fixed

- Fixed changelog display in `update`:
  - Added complete version history.
  - Added `CHANGELOG.md` to npm published files.
- Improved update performance:
  - Added version-check cache (10-minute TTL).
  - Avoid repeated network requests.

---

## [2.2.0] - 2025-01-20

### Added

- Added Every Code (`@just-every/code`) support:
  - Full Skills support
  - Skills install directory: `~/.code/skills/` or project-level `.code/skills/`
  - Uses `AGENTS.md`
- Added install script options: `--code-only` and `--with-code`.
- Added version-check cache (10-minute TTL) for repeated `update`.

### Changed

- Updated README supported-tools table.

---

## [2.1.1] - 2025-01-19

### Fixed

- Terminology cleanup.

---

## [2.1.0] - 2025-01-19

### Added

- Version changelog display: when running `dev-playbooks update`, the CLI displays a formatted changelog summary between the current and the latest versions.
  - Automatic fetch from GitHub
  - Smart parsing (extract only relevant sections)
  - Colorized output
  - Graceful fallback
  - Content limit (first 10 lines per version)

### Improved

- Users can make informed decisions about updates by reviewing what’s new.

---

## [2.0.0] - 2026-01-19

### Added

#### Human-friendly document templates

- Bottom Line Up Front: every document (proposal, design, tasks, verification) has a short executive summary at the top.
- Alignment check: proposal phase includes guided questions to uncover hidden requirements.
- Default approval mechanism: reduce decision fatigue with configurable timeouts.
- Project-level documents: user profile and decision log templates.

#### New document templates

- `skills/_shared/references/document-template-proposal.md`
- `skills/_shared/references/document-template-design.md`
- `skills/_shared/references/document-template-tasks.md`
- `skills/_shared/references/document-template-verification.md`
- `skills/_shared/references/document-template-project-profile.md`
- `skills/_shared/references/document-template-decision-log.md`
- `skills/_shared/references/approval-configuration-guide.md`

### Changed

- proposal-author: updated prompts to use the new templates and alignment checks.

### Breaking changes

- Document structure changes:
  - older `proposal.md` files may not match the new structure; migration may be needed.
  - backward compatibility is maintained for reading old formats.
- Approval mechanism changes:
  - default strategy is `auto_approve`, configurable via `.devbooks/config.yaml`.

### Upgrade guide

1. Update npm package:
   ```bash
   npm install -g dev-playbooks@2.0.0
   ```

2. (Optional) Configure approval mechanism via `.devbooks/config.yaml`.
3. (Optional) Create project-level documents (profile / decision log).

---

## [1.7.4] - 2026-01-18

### Changed

- Various bug fixes and improvements.

---

## [1.7.0] - 2026-01-15

### Added

- Initial release with 18 Skills
- Support for Claude Code, Codex CLI, and other AI tools
- Quality gates and role isolation
- MCP integration support

---

[3.0.2]: https://github.com/Darkbluelr/dev-playbooks/compare/v3.0.1...v3.0.2
[3.0.1]: https://github.com/Darkbluelr/dev-playbooks/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.6.0...v3.0.0
[2.6.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.5.4...v2.6.0
[2.5.4]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.5.3...v2.5.4
[2.5.3]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.5.2...v2.5.3
[2.5.2]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.5.1...v2.5.2
[2.5.1]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.5.0...v2.5.1
[2.5.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.3.0...v2.5.0
[2.3.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/Darkbluelr/dev-playbooks/compare/v1.7.4...v2.0.0
[1.7.4]: https://github.com/Darkbluelr/dev-playbooks/compare/v1.7.0...v1.7.4
[1.7.0]: https://github.com/Darkbluelr/dev-playbooks/releases/tag/v1.7.0

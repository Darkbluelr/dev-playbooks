---
name: devbooks-ssot-maintainer
description: devbooks-ssot-maintainer: maintains an addressable SSOT index and a derived progress view. Use it to "edit/sync SSOT (upstream or in-project) → write an auditable delta → sync requirements.index.yaml → (optional) refresh requirements.ledger.yaml". Usually called by `/devbooks:delivery` under `request_kind=governance`.
recommended_experts: ["Technical Writer", "System Architect"]
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: SSOT Maintainer (Index/Ledger Maintenance Loop)

## Progressive Disclosure
### Basic (must-read)
Goal: upgrade “SSOT edits” from chat memory to a **machine-readable, auditable, judgeable** loop: `ssot.delta.yaml → requirements.index.yaml → (optional) requirements.ledger.yaml`.  
Input: change package path, upstream/in-project SSOT anchor refs, and the delta for this change.  
Output:
- `<change-root>/<change-id>/inputs/ssot.delta.yaml` (minimal machine-readable input for this change)
- `<truth-root>/ssot/requirements.index.yaml` (truth: stable id → anchor → statement)
- `<truth-root>/ssot/requirements.ledger.yaml` (derived cache: progress view; disposable/rebuildable)
Boundaries:
- Do not read/copy the whole upstream SSOT library; only maintain the index and anchor refs.
- Do not change the contract semantics of `upstream_claims`.
Evidence: script logs, updated index file, and (optional) ledger refresh logs.

### Advanced (optional)
Use this when you need constraints/best practices for “upstream SSOT library (external directory) + minimal in-truth Project SSOT pack”.

### Extended (optional)
Use this when you want to bind SSOT maintenance into Knife/Epic slicing (e.g., `slices[].ssot_ids`) or stricter governance gates.

## Prereq: Config discovery (protocol-agnostic)

Before running, discover configuration in this order (stop at the first match):
1. `.devbooks/config.yaml` (if present) → parse mappings (especially `truth_mapping.ssot_root`)
2. `dev-playbooks/project.md` (if present) → Dev-Playbooks protocol
3. `project.md` (if present) → template protocol
4. If still unclear → stop and ask the user

## Minimal Sufficient Loop

### 1) Decide SSOT source (index only; no copying)

- If you have an upstream SSOT library: configure project `.devbooks/config.yaml`:
  - `truth_mapping: { ssot_root: "SSOT docs/" }`
- If you do not have an upstream SSOT: ensure `<truth-root>/ssot/SSOT.md` and `<truth-root>/ssot/requirements.index.yaml` exist (you can scaffold a skeleton via `skills/devbooks-delivery-workflow/scripts/ssot-scaffold.sh`).

### 2) Edit SSOT (content) and write a delta (machine-readable)

You can brainstorm “what to change” with AI, but you MUST write the final change as a delta file (do not leave it only in chat):

- Recommended location: `<change-root>/<change-id>/inputs/ssot.delta.yaml`
- Constraint: `statement` must be a single-line string (the script will refuse multi-line values)
- Each requirement must have a stable id. If upstream has no ids, generate one in the delta (or leave blank and let the script auto-assign `R-###`).

### 3) Sync the index (truth)

Run:
- `skills/devbooks-ssot-maintainer/scripts/ssot-index-sync.sh --delta <path> --apply`

The script will:
- validate the delta and the existing index (schema_version, uniqueness, allowed ops)
- apply add/update/remove to `requirements.index.yaml`
- fail non-destructively (it will not corrupt the existing index)

### 4) (Optional) Refresh the progress ledger (derived cache)

If you need “done/not done” visibility (dashboard/audit), refresh it via:
- `skills/devbooks-delivery-workflow/scripts/requirements-ledger-derive.sh ...`

Note: the ledger is a derived cache. It can be deleted/rebuilt and MUST NOT be treated as SSOT.

## Recommended usage (via Delivery single entry)

If your ask is “edit SSOT / sync index / update ledger”, make it explicit in your `/devbooks:delivery` input:

- `request_kind=governance`
- Change type: SSOT maintenance
- Impacted `ssot_ids` (if known)
- Upstream SSOT anchor refs (if any)

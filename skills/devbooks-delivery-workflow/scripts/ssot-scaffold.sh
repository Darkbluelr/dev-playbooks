#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: ssot-scaffold.sh [options]

Scaffold a minimal Project SSOT pack under truth_root when upstream SSOT is absent.

Creates (default):
  <truth-root>/ssot/SSOT.md
  <truth-root>/ssot/requirements.index.yaml

Options:
  --project-root <dir>    Project root directory (default: pwd)
  --truth-root <dir>      Truth root directory (default: specs)
  --ssot-dir <dir>        SSOT dir under truth_root (default: ssot)
  --set-id <id>           requirements.index set_id (default: derived from project dir)
  --source-ref <ref>      requirements.index source_ref (default: truth://<ssot-dir>/SSOT.md)
  --force                 Overwrite existing files
  -h, --help              Show this help message

Notes:
- This script is intentionally deterministic and does not "discover" external SSOT.
  Use it when your project does not have an upstream SSOT, or you want an internal pointer file.
- requirements.index.yaml schema_version is fixed to 1.0.0 (required by upstream_claims checks).
EOF
}

die_usage() {
  echo "error: $*" >&2
  usage
  exit 2
}

project_root="${DEVBOOKS_PROJECT_ROOT:-$(pwd)}"
truth_root="${DEVBOOKS_TRUTH_ROOT:-specs}"
ssot_dir="ssot"
set_id=""
source_ref=""
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --project-root)
      project_root="${2:-}"
      shift 2
      ;;
    --truth-root)
      truth_root="${2:-}"
      shift 2
      ;;
    --ssot-dir)
      ssot_dir="${2:-}"
      shift 2
      ;;
    --set-id)
      set_id="${2:-}"
      shift 2
      ;;
    --source-ref)
      source_ref="${2:-}"
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    *)
      die_usage "unknown option: $1"
      ;;
  esac
done

project_root="${project_root%/}"
truth_root="${truth_root%/}"
ssot_dir="${ssot_dir%/}"

if [[ -z "$project_root" || -z "$truth_root" || -z "$ssot_dir" ]]; then
  die_usage "missing required paths"
fi

if [[ "$truth_root" = /* ]]; then
  truth_dir="$truth_root"
else
  truth_dir="${project_root}/${truth_root}"
fi

ssot_pack_dir="${truth_dir}/${ssot_dir}"

if [[ -z "$set_id" ]]; then
  base="$(basename "$project_root")"
  base_safe="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+|-+$//g')"
  if [[ -z "$base_safe" ]]; then
    base_safe="project"
  fi
  set_id="REQSET-${base_safe}"
fi

if [[ -z "$source_ref" ]]; then
  source_ref="truth://${ssot_dir}/SSOT.md"
fi

write_file() {
  local path="$1"
  shift || true

  if [[ -f "$path" && "$force" != true ]]; then
    echo "skip: $path" >&2
    cat >/dev/null
    return 0
  fi

  mkdir -p "$(dirname "$path")"
  cat >"$path"
  echo "wrote: $path" >&2
}

mkdir -p "$ssot_pack_dir"

ssot_md="${ssot_pack_dir}/SSOT.md"
req_index="${ssot_pack_dir}/requirements.index.yaml"

cat <<'EOF' | write_file "$ssot_md"
# SSOT (Project Source of Truth)

> Goal: make requirements/constraints/contracts/progress addressable, auditable, and traceable.  
> Rule: record only judgeable truths; do not paste long materials—use references/links instead.

## 0) Conventions

- **Stable IDs**: recommend `PROJ-P0-001` / `PROJ-P1-001` / `PROJ-P2-001` (or any stable scheme). Never reuse IDs once published.
- **Truth vs Cache**:
  - Truth: this file + `requirements.index.yaml` (machine-readable index)
  - Cache: any derived views (e.g. `requirements.ledger.yaml`), safe to delete and regenerate

## 1) System Goals (include non-functional)

- Target users:
- Success criteria:
- Out of scope:

## 2) Functional Requirements

> Each requirement must have a stable ID and a testable acceptance definition.

### <ID>: <Title>
- Statement (MUST/SHOULD):
- Acceptance (AC / Given-When-Then):
- Dependencies / prerequisites:
- Risks / rollback:

## 3) UI/UX (if applicable)

- Target devices / breakpoints:
- Top user flows (<= 3):
- Screens / components:
- Visual/interaction constraints (links or sketch paths):

## 4) Data & Contracts (API/Schema/Event)

- Public API:
- Data model (key fields / constraints / migration strategy):
- Compatibility strategy (versioning, migration, rollback):

## 5) Ops & Quality (NFR)

- Performance / capacity:
- Security & compliance:
- Observability (logs/metrics/alerts):
- Release & rollback:

## 6) Open Questions (<= 10)

1.
2.
3.
EOF

cat <<EOF | write_file "$req_index"
schema_version: 1.0.0
set_id: ${set_id}
source_ref: ${source_ref}

requirements:
  - id: R-001
    severity: must
    anchor: ""
    statement: "Example: persist a minimal SSOT pack and assign stable IDs to requirements covered by this project."
EOF

echo "ok: scaffolded ssot pack under: ${ssot_pack_dir}" >&2


#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# knife-parallel-schedule.sh
# =============================================================================
# Generate a parallel execution schedule from a Knife Plan
#
# Features:
#   1. Parse the slices[] dependency graph from Knife Plan
#   2. Calculate maximum parallelism (DAG width)
#   3. Generate layered execution schedule (Layer 0, 1, 2, ...)
#   4. Identify critical path
#   5. Output human-readable parallel execution guide
#
# Use case:
#   After Epic slicing, users can use this schedule to launch multiple
#   independent Agents in parallel to complete change packages
# =============================================================================

usage() {
  cat <<'EOF' >&2
usage: knife-parallel-schedule.sh <epic-id> [options]

Generate a parallel execution schedule from a Knife Plan.

Options:
  --project-root <dir>    Project root directory (default: pwd)
  --truth-root <dir>      Truth root directory (default: specs)
  --out <path>            Output file path (default: stdout)
  --format <md|json>      Output format (default: md)
  -h, --help              Show help

Output contents:
  - Maximum parallelism
  - Layered execution schedule (which Slices can start simultaneously)
  - Critical path
  - Launch command templates for each Slice
  - Traceability information

Exit codes:
  0 - success
  1 - Knife Plan not found or parse error
  2 - usage error
EOF
}

errorf() {
  printf 'ERROR: %s\n' "$*" >&2
}

infof() {
  printf 'INFO: %s\n' "$*" >&2
}

# =============================================================================
# Argument parsing
# =============================================================================

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

epic_id="$1"
shift

project_root="${DEVBOOKS_PROJECT_ROOT:-$(pwd)}"
truth_root="${DEVBOOKS_TRUTH_ROOT:-specs}"
out_path=""
format="md"

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
    --out)
      out_path="${2:-}"
      shift 2
      ;;
    --format)
      format="${2:-}"
      shift 2
      ;;
    *)
      errorf "unknown option: $1"
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$epic_id" || "$epic_id" == "-"* ]]; then
  errorf "invalid epic-id: '$epic_id'"
  exit 2
fi

case "$format" in
  md|json) ;;
  *)
    errorf "invalid --format: $format (must be md or json)"
    exit 2
    ;;
esac

project_root="${project_root%/}"
truth_root="${truth_root%/}"

if [[ "$truth_root" = /* ]]; then
  truth_dir="$truth_root"
else
  truth_dir="${project_root}/${truth_root}"
fi

# =============================================================================
# Find Knife Plan
# =============================================================================

knife_plan_dir="${truth_dir}/_meta/epics/${epic_id}"
knife_plan_file=""

if [[ -f "${knife_plan_dir}/knife-plan.yaml" ]]; then
  knife_plan_file="${knife_plan_dir}/knife-plan.yaml"
elif [[ -f "${knife_plan_dir}/knife-plan.json" ]]; then
  knife_plan_file="${knife_plan_dir}/knife-plan.json"
else
  errorf "Knife Plan not found at: ${knife_plan_dir}/knife-plan.(yaml|json)"
  exit 1
fi

infof "Found Knife Plan: $knife_plan_file"

# =============================================================================
# Parse Knife Plan (using yq or jq)
# =============================================================================

# Check tool availability
if command -v yq &>/dev/null; then
  YAML_TOOL="yq"
elif command -v python3 &>/dev/null; then
  YAML_TOOL="python"
else
  errorf "Requires yq or python3 to parse YAML"
  exit 1
fi

# Extract slices data
extract_slices() {
  local file="$1"

  if [[ "$file" == *.json ]]; then
    jq -r '.slices // []' "$file"
  elif [[ "$YAML_TOOL" == "yq" ]]; then
    yq -o=json '.slices // []' "$file"
  else
    python3 -c "
import yaml
import json
import sys

with open('$file', 'r') as f:
    data = yaml.safe_load(f)
    slices = data.get('slices', [])
    print(json.dumps(slices))
"
  fi
}

# Extract metadata
extract_metadata() {
  local file="$1"

  if [[ "$file" == *.json ]]; then
    jq -r '{epic_id, plan_id, plan_revision, risk_level, change_type, ac_ids}' "$file"
  elif [[ "$YAML_TOOL" == "yq" ]]; then
    yq -o=json '{epic_id: .epic_id, plan_id: .plan_id, plan_revision: .plan_revision, risk_level: .risk_level, change_type: .change_type, ac_ids: .ac_ids}' "$file"
  else
    python3 -c "
import yaml
import json
import sys

with open('$file', 'r') as f:
    data = yaml.safe_load(f)
    meta = {
        'epic_id': data.get('epic_id'),
        'plan_id': data.get('plan_id'),
        'plan_revision': data.get('plan_revision'),
        'risk_level': data.get('risk_level'),
        'change_type': data.get('change_type'),
        'ac_ids': data.get('ac_ids', [])
    }
    print(json.dumps(meta))
"
  fi
}

slices_json=$(extract_slices "$knife_plan_file")
metadata_json=$(extract_metadata "$knife_plan_file")

# Validate slices not empty
slice_count=$(echo "$slices_json" | jq 'length')
if [[ "$slice_count" -eq 0 ]]; then
  errorf "No slices defined in Knife Plan"
  exit 1
fi

infof "Found $slice_count slices"

# =============================================================================
# Topological sort and layer calculation
# =============================================================================

# Use jq for topological sort and layer calculation
schedule_json=$(echo "$slices_json" | jq '
# Build slice_id -> index mapping
. as $slices |
reduce range(length) as $i ({}; . + {($slices[$i].slice_id): $i}) as $id_to_idx |

# Calculate in-degree for each node
reduce .[] as $slice (
  (reduce .[] as $s ({}; . + {($s.slice_id): 0}));
  reduce ($slice.depends_on // [])[] as $dep (.; .[$slice.slice_id] = (.[$slice.slice_id] // 0) + 1)
) as $in_degree |

# Kahn algorithm for topological sort with layering
{
  layers: [],
  remaining: [.[] | .slice_id],
  in_degree: $in_degree,
  slices: $slices
} |
until((.remaining | length) == 0;
  # Find nodes with in-degree 0
  .remaining as $rem |
  .in_degree as $deg |
  [$rem[] | select($deg[.] == 0)] as $current_layer |

  if ($current_layer | length) == 0 then
    # Cycle detected, cannot continue
    .remaining = []
  else
    # Update in-degrees
    reduce ($slices[] | select([.slice_id] | inside($current_layer) | not)) as $s (
      .in_degree;
      reduce ($s.depends_on // [])[] as $dep (
        .;
        if ($current_layer | index($dep)) then
          .[$s.slice_id] = (.[$s.slice_id] - 1)
        else . end
      )
    ) as $new_deg |

    .layers += [$current_layer] |
    .remaining = [.remaining[] | select(. as $id | $current_layer | index($id) | not)] |
    .in_degree = $new_deg
  end
) |

# Calculate critical path (longest path)
.layers as $layers |
($layers | length) as $depth |

# Build slice details
{
  max_parallelism: ($layers | map(length) | max),
  total_layers: ($layers | length),
  layers: [range($layers | length) as $i | {
    layer: $i,
    can_start_immediately: ($i == 0),
    depends_on_layer: (if $i > 0 then $i - 1 else null end),
    slices: $layers[$i]
  }],
  critical_path_length: ($layers | length),
  slices_detail: [.slices[] | {
    slice_id: .slice_id,
    change_id: .change_id,
    ac_subset: .ac_subset,
    depends_on: (.depends_on // []),
    budgets: .budgets,
    verification_anchors: .verification_anchors
  }]
}
')

# =============================================================================
# Output generation
# =============================================================================

generate_markdown() {
  local meta="$1"
  local schedule="$2"
  local knife_file="$3"

  local epic_id plan_id plan_revision risk_level change_type
  epic_id=$(echo "$meta" | jq -r '.epic_id // "N/A"')
  plan_id=$(echo "$meta" | jq -r '.plan_id // "N/A"')
  plan_revision=$(echo "$meta" | jq -r '.plan_revision // "N/A"')
  risk_level=$(echo "$meta" | jq -r '.risk_level // "N/A"')
  change_type=$(echo "$meta" | jq -r '.change_type // "N/A"')

  local max_parallelism total_layers
  max_parallelism=$(echo "$schedule" | jq -r '.max_parallelism')
  total_layers=$(echo "$schedule" | jq -r '.total_layers')

  cat <<EOF
# Parallel Execution Schedule

> Auto-generated by \`knife-parallel-schedule.sh\`
> Generated at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Traceability

| Field | Value |
|-------|-------|
| Epic ID | \`$epic_id\` |
| Plan ID | \`$plan_id\` |
| Plan Revision | \`$plan_revision\` |
| Risk Level | \`$risk_level\` |
| Change Type | \`$change_type\` |
| Knife Plan Path | \`$knife_file\` |

## Parallelism Summary

- **Maximum Parallelism**: $max_parallelism (max number of Agents that can start simultaneously)
- **Total Layers**: $total_layers (serial dependency depth)
- **Critical Path Length**: $total_layers layers

## Execution Layers

EOF

  # Output each layer
  echo "$schedule" | jq -r '.layers[] | "### Layer \(.layer)\(if .can_start_immediately then " (Can Start Immediately)" else " (Depends on Layer \(.depends_on_layer))" end)\n\n| Slice ID | Change ID |\n|----------|-----------|" + (.slices | map("\n| `\(.)` | - |") | join(""))'

  cat <<EOF

## Slice Details

EOF

  # Output each slice's details
  echo "$schedule" | jq -r '.slices_detail[] | "### \(.slice_id)\n\n- **Change ID**: `\(.change_id // "TBD")`\n- **Dependencies**: \(if (.depends_on | length) == 0 then "None (can execute independently)" else (.depends_on | map("`\(.)`") | join(", ")) end)\n- **AC Subset**: \(.ac_subset | map("`\(.)`") | join(", "))\n- **Token Budget**: \(.budgets.tokens // "Not specified")\n- **Verification Anchors**: \(if (.verification_anchors | length) == 0 then "None" else (.verification_anchors | map("`\(.)`") | join(", ")) end)\n"'

  cat <<EOF

## Launch Command Templates

Each Slice corresponds to an independent change package that can be executed in a separate Agent session:

\`\`\`bash
# Layer 0 Slices can be launched in parallel immediately
EOF

  echo "$schedule" | jq -r '.layers[0].slices[] as $sid | .slices_detail[] | select(.slice_id == $sid) | "# Agent for \(.slice_id)\ndevbooks apply --change-id \(.change_id // "<TBD>") --epic-id '"$epic_id"' --slice-id \(.slice_id)"'

  cat <<EOF
\`\`\`

## Execution Guidelines

1. **Parallel Launch**: All Slices within the same Layer can launch independent Agents simultaneously
2. **Dependency Wait**: Slices in the next Layer must wait for all previous Layer Slices to complete
3. **Traceability Verification**: After each change package completes, use \`devbooks archive\` to archive and update the ledger
4. **Progress Tracking**: Use \`progress-dashboard.sh\` to view overall progress

## Post-Completion Writeback

After all Slices complete, run the following to update the ledger:

\`\`\`bash
# Derive requirements ledger
requirements-ledger-derive.sh --project-root .

# Verify Epic completeness
epic-alignment-check.sh $epic_id --mode strict
\`\`\`

---

*This schedule was generated by DevBooks Knife Parallel Schedule*
*Reference: dev-playbooks/specs/knife/spec.md*
EOF
}

generate_json() {
  local meta="$1"
  local schedule="$2"
  local knife_file="$3"

  jq -n \
    --argjson meta "$meta" \
    --argjson schedule "$schedule" \
    --arg knife_file "$knife_file" \
    --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{
      schema_version: "1.0.0",
      generated_at: $generated_at,
      source: {
        knife_plan_path: $knife_file,
        epic_id: $meta.epic_id,
        plan_id: $meta.plan_id,
        plan_revision: $meta.plan_revision,
        risk_level: $meta.risk_level,
        change_type: $meta.change_type
      },
      summary: {
        max_parallelism: $schedule.max_parallelism,
        total_layers: $schedule.total_layers,
        critical_path_length: $schedule.critical_path_length,
        total_slices: ($schedule.slices_detail | length)
      },
      layers: $schedule.layers,
      slices: $schedule.slices_detail
    }'
}

# =============================================================================
# Output
# =============================================================================

output=""
if [[ "$format" == "md" ]]; then
  output=$(generate_markdown "$metadata_json" "$schedule_json" "$knife_plan_file")
else
  output=$(generate_json "$metadata_json" "$schedule_json" "$knife_plan_file")
fi

if [[ -n "$out_path" ]]; then
  if [[ "$out_path" = /* ]]; then
    out_file="$out_path"
  else
    out_file="${project_root}/${out_path}"
  fi
  mkdir -p "$(dirname "$out_file")"
  echo "$output" > "$out_file"
  infof "Output written to: $out_file"
else
  echo "$output"
fi

infof "Parallel schedule generated successfully"
infof "Max parallelism: $(echo "$schedule_json" | jq -r '.max_parallelism')"
infof "Total layers: $(echo "$schedule_json" | jq -r '.total_layers')"

# Proposal Debate Workflow

Goal: in the proposal phase, use a “proposal → challenge → judgment” three-role debate to avoid diluted consensus and proxy-metric-driven decisions.

Directory conventions (protocol-agnostic):
- Change package: `<change-root>/<change-id>/`
- Proposal: `<change-root>/<change-id>/proposal.md`

Hard rules:
- Proposal Author / Challenger / Judge must run in separate conversations/instances.
- The Challenger can only challenge based on the persisted `proposal.md` and available design materials; no “private co-authoring”.
- The Judge must provide a clear decision; no vague compromises.

Process:
1) **Proposal Author**: use the `devbooks-proposal-author` skill to produce `proposal.md` (including the Debate Packet).
2) **Proposal Challenger**: use the `devbooks-proposal-challenger` skill to produce a challenge report.
3) **Proposal Judge**: use the `devbooks-proposal-judge` skill to produce a judgment report.
4) **Write back to proposal**: write the judgment conclusion into `proposal.md` under the Decision Log.
5) **Proceed to downstream artifacts**: Design/Spec/Plan starts only after a decision of Approved or Revise.

Acceptance criteria:
- `proposal.md` must include a `Decision Log` with decision state `Approved | Revise | Rejected`.
- If `Revise`, it must list “required changes” and be judged again after completion.
- Optional automated check: `proposal-debate-check.sh <change-id>` (script: `scripts/proposal-debate-check.sh`)

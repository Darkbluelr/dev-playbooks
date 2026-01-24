# Human Advice Calibration Prompt

> This template is used to calibrate human advice for high-impact or uncertain decisions.
> It defines only trigger conditions, boundaries, and output format; it does not include implementation steps.

## Triggers (meet at least one)

- Cross-module or external contract changes
- Multiple-option trade-offs (two or more viable directions)
- Long-term maintenance risk (shared specs, templates, or guardrail rules)
- Security or compliance risk

## Boundaries

- Does not replace decision records in proposal/design/spec
- Not used for pure execution changes or low-impact formatting tweaks
- Do not output implementation steps, commands, or code details

## Minimal prompt template

```markdown
[Human Advice Calibration]

Intuitive value:
Deviations from best practice/immaturity points:
Recommended approach:
```

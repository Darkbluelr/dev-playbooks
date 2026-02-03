---
skill: devbooks-archiver
---

# DevBooks: Archive

Use devbooks-archiver to complete the archive loop for a change package.

## Usage

/devbooks:archive [args]

## Args

$ARGUMENTS

## Description

Runs the full archive closed loop:
- Auto write back the design doc
- Merge specs into the truth root
- Doc sync checks
- Move the change package into archive

If you only need docs consistency checks (without archiving), use `/devbooks:gardener` (`devbooks-docs-consistency`).

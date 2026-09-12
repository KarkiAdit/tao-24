---
description: Review the current diff against the project's rules
---

Run `git diff` (and `git diff --staged` if there's staged work) and review the
changes against the iOS-specific rules in `CLAUDE.md` and the general
engineering conventions in your personal `~/.claude/CLAUDE.md`. For each issue
found, report:

- File and rough line location
- What's wrong
- Which convention it violates
- A suggested fix

Then give an overall verdict: ready to commit, needs small fixes, or needs
rework. Don't make the fixes yourself unless asked to.

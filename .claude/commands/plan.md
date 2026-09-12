---
description: Delegate to the planner subagent to scope and stage a task before any implementation
---

Delegate this to the `planner` subagent rather than planning inline: $ARGUMENTS

The planner will load `.claude/PLAN.md` (creating it from the template if
missing), run Problem Identification and Task Development, identify/scaffold
tooling, and save the result back to `.claude/PLAN.md`.

Do not begin implementation yourself until the planner returns its summary
and I've reviewed it. The planner may skip a stage that genuinely doesn't
apply, but it should say explicitly which stage it skipped and why rather
than silently dropping it.

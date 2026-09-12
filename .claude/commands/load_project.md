---
description: Load the project plan and current state before starting work
---

Read `.claude/PLAN.md`.

- If it exists: summarize the problem statement, which stages apply, what's
  done, what's in progress, what's blocked, and the next step. Use this as
  your starting context instead of re-deriving it from the codebase.
- If it doesn't exist or is still the untouched template: say so plainly and
  suggest running `/plan <task>` to initiate it — don't invent a plan that
  was never actually made.

Don't edit `.claude/PLAN.md` as part of this command — it's read-only here.
Use `/save_project` to write to it.

---
description: Load the project plan and current state before starting work
---

Read `.claude/PLAN.md`.

Report, in this order:

1. **Where we are in the roadmap** — the active phase, which milestones in it
   are ticked, and how many remain across all phases.
2. **The active milestone** — from the `Active Milestone` section. If it's
   empty, say so and ask which milestone to start; don't pick one.
3. **The current milestone's plan** — problem statement, which stages apply,
   what's done, in progress, blocked, and the concrete next step. Use this as
   your starting context instead of re-deriving it from the codebase.

If `.claude/PLAN.md` doesn't exist, or the roadmap is seeded but no milestone
has ever been planned, say so plainly and suggest setting `Active Milestone`
then running `/plan` — don't invent a plan that was never actually made.

Don't edit `.claude/PLAN.md` as part of this command — it's read-only here.
Use `/save_project` to write to it.

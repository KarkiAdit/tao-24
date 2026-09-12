---
description: Stage relevant changes and write a commit message
---

Review `git status` and `git diff`. Stage only the files relevant to the
current task (don't sweep up unrelated stray changes). Write the commit
message in imperative mood ("Add retry logic", not "Added"), first line
≤ 72 chars, with a body explaining *why* if that isn't obvious from the diff.
One logical change per commit — if the diff contains two, say so and propose
splitting it.

Show the proposed commit message before committing and wait for confirmation,
unless explicitly told to just commit.

---
description: Diagnose and fix a bug, with a regression test
---

Investigate and fix this bug: $ARGUMENTS

1. Reproduce the issue first (write a failing test if one doesn't exist).
2. Find the root cause — don't just patch the symptom.
3. Fix it with the smallest reasonable diff.
4. Confirm the new/updated test passes, then run the full suite to check for
   regressions.
5. Summarize the root cause and the fix in a couple of sentences at the end.

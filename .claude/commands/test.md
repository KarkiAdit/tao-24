---
description: Run the test suite and summarize failures
---

Run the project's test suite (check CLAUDE.md or package manifest for the
exact command). Then:

1. Report pass/fail counts.
2. For each failure, show the assertion and the likely cause.
3. Group failures that look related (same root cause) instead of listing
   them as unrelated items.
4. Don't attempt fixes unless asked — just diagnose, unless $ARGUMENTS says
   otherwise.

$ARGUMENTS

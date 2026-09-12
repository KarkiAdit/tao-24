# Working preferences

These apply to every project. Project-level `CLAUDE.md` files cover what's
specific to that codebase and take precedence where they conflict.

## Code

- Match the style already in the surrounding file before applying a personal
  preference — consistency within a file beats an abstract "best" style.
- No unused imports, no commented-out code left behind, no debug print/log
  statements in committed code.
- Functions should do one thing. If a diff adds a function doing three
  unrelated things, split it.
- Prefer explicit names over clever abbreviations. `userCount`, not `uc`.
- Add a comment only when the *why* isn't obvious from the code itself. Don't
  narrate what the code already says.
- Use the language's type system where it has one. Don't reach for an escape
  hatch to silence a type error.
- Keep diffs minimal and scoped to the task. Don't reformat unrelated code in
  the same commit.
- Don't invent dependencies — check the package manifest before assuming a
  library is available.
- Prefer editing existing files over creating new ones unless the task clearly
  needs a new module.

## Git

- Never commit directly to `main`/`master`. Work on a feature branch named
  `type/short-description` (e.g. `fix/login-redirect`).
- Commit messages in imperative mood: "Add retry logic", not "Added". First
  line ≤ 72 chars, body explains *why* if it isn't obvious.
- One logical change per commit. Don't bundle an unrelated refactor into a
  feature commit.
- Before opening a PR: rebase on latest `main`, make sure tests pass, and
  self-review the diff for stray debug code or TODOs.
- Never force-push a shared branch without saying so explicitly. Don't amend
  or rewrite history that's already been pushed and reviewed.

## Tests

- Every bug fix gets a regression test that fails before the fix and passes
  after it.
- New features need at least happy-path + one edge case covered.
- Don't weaken a test to make it pass (loosening an assertion, adding a skip).
  Fix the underlying issue, or say plainly that the test may be wrong.
- Keep tests fast and isolated — no reliance on network access, real
  timestamps, or execution order unless that's what's under test.
- Run the full suite before marking a task complete, not just the tests you
  added.

## Secrets and input

- Never commit secrets, API keys, or credentials. Keep them in a gitignored
  env file or the platform keystore, with a checked-in example file listing
  the required keys.
- Never log sensitive data (passwords, tokens, PII), even at debug level.
- Validate and sanitize external input before it reaches a query, a shell
  command, or a file path.
- Use parameterized queries — never string-concatenate user input into SQL.
- Prefer well-maintained dependencies, and check a new one isn't a
  near-duplicate of something already in use.
- Flag anything that needs a security review (auth changes, new external
  endpoints, filesystem access driven by user input) instead of quietly
  proceeding.

## How I want you to work

- When a task is ambiguous, state your assumption and proceed rather than
  stopping to ask — unless the ambiguity could send the whole task sideways.
- Run tests and lint before declaring a task done, not after being asked.
- Surface anything you skipped or couldn't verify at the end of a task
  instead of staying silent about it.

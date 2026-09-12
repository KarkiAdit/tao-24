# tao-24

## What this project is

A habit tracker iOS app, built as a prototype to validate the idea quickly
rather than to ship as a finished product.

The concrete product thinking — what a habit is here, what the daily loop
looks like, what makes this different from every other tracker — hasn't been
written down yet. It lands in `docs/` and in `.claude/PLAN.md` (via `/plan`)
before feature work starts. Until then, treat the app idea as unspecified and
ask rather than assuming.

## Stack

- Language: Swift
- Framework: SwiftUI
- Project format: Xcode project (`tao-24.xcodeproj`), single app target
- Package manager: Swift Package Manager (SPM), via Xcode package dependencies
- Test runner: XCTest — **no test target exists yet**; one has to be added in
  Xcode (File > New > Target > Unit Testing Bundle) before `/test` does
  anything real
- Lint/format: swift-format (bundled with the toolchain, invoked via `xcrun`)

## How to run things

```bash
# install — SPM resolves dependencies on build, no separate step

# build (headless check, no need to open Xcode)
xcodebuild -scheme tao-24 -destination 'platform=iOS Simulator,name=iPhone 16' build

# tests (once a test target exists)
xcodebuild test -scheme tao-24 -destination 'platform=iOS Simulator,name=iPhone 16'

# list the simulators actually installed, if the destination above isn't one
xcrun simctl list devices available

# run in simulator / SwiftUI previews — open Xcode for this specifically
open tao-24.xcodeproj

# lint / format
xcrun swift-format lint -r .
xcrun swift-format format -i -r .
```

`xcodebuild` and `simctl` need the full Xcode toolchain selected. If they
report "requires Xcode, but active developer directory is a command line
tools instance", run:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Repo layout

```
tao-24/              # application code (app target sources, Assets.xcassets)
tao-24.xcodeproj/    # Xcode project
docs/                # design docs, ADRs, product notes
.claude/             # Claude Code config
```

There is no SPM `Sources/`/`Tests/` layout — this is a plain Xcode app
project. A new file only compiles once it's a member of the `tao-24` target,
so files added outside Xcode need to be added to the target there.

## Rules

General engineering conventions (code style, git, testing, secrets) live in
`~/.claude/CLAUDE.md` and are already in context — don't restate them here.
This section is only for what's specific to an iOS prototype:

- Store tokens and credentials in the Keychain, never `UserDefaults`, a
  plist, or `@AppStorage`.
- No secrets in `Info.plist` or a checked-in `.xcconfig`.
- Check the project's package dependencies before assuming a library is
  available.
- Keep view bodies thin — push logic into a model type so it stays testable
  without a UI host.

## Planning

Planning is automatic, not opt-in. Before starting any non-trivial task,
delegate to the `planner` subagent (`.claude/agents/planner.md`) without
waiting for an explicit `/plan` — treat the task request itself as an
implicit trigger.

**Skip the planner (go straight to work) only when the task is:**
- A single, unambiguous change — typo, copy edit, config value, comment,
  one-line fix with an obvious location
- Read-only — answering a question, explaining code, running existing tests
- Already fully scoped by the person asking, in a way that already covers
  what the plan would produce

**Delegate to the planner for anything else**, including new features however
small they sound, any schema/API/contract change, changes touching more than
one file where the files interact, bug fixes needing root-cause
investigation, and anything where you don't yet know how many files it'll
touch. If genuinely unsure which bucket a task falls in, delegate.

The planner owns `.claude/PLAN.md` end to end (load → plan → save). Run
`/load_project` at the start of a session on existing work, and let
`/save_project` keep state current as you go.

## Pointers

- Commands: `.claude/commands/` (`/plan`, `/load_project`, `/save_project`,
  `/review`, `/test`, `/fix`, `/commit`)
- Subagents: `.claude/agents/` (`planner`)
- Hooks: `.claude/settings.json` + `.claude/hooks/`
  (`bash .claude/hooks/hooks-smoke-test.sh` checks the bash guard still works)
- GitHub work goes through the `gh` CLI — there is no MCP server configured.

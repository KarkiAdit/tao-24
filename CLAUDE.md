# tao-24

## What this project is

A habit tracker iOS app — a **goal-aligned habit development engine** that
connects daily actions to long-term objectives. Its differentiator is what it
refuses to do: no streak coercion, no guilt-driven notifications, no
engagement-farming. Habits are organized across three **Dimensions of Joy** —
Health, Career, Fun — to keep growth balanced rather than lopsided.

**Target user:** people trying to build discipline and consistency — students,
young professionals, teens, broadly anyone.

Currently a prototype validating the architecture, onboarding framework, and
ethical-engagement model. Not a shipping product.

Full product specs live in `docs/product/` and are the source of truth:

| Doc | Covers |
|---|---|
| `proof-of-concept.md` | Philosophy, MVP screens, onboarding questionnaire, personality mapping, 3-phase roadmap |
| `information-flow-and-wireframes.md` | Per-screen UI specs and component breakdown |
| `tech-stack-and-project-architecture.md` | Stack choices, MVCS layer contracts, reference implementations |
| `blackbox-architecture-and-scalability.md` | Local-first design, indexing, sync, privacy boundaries |

Read the relevant doc before building a feature — don't infer product
behavior from existing code alone, the code is a thin prototype and the docs
are ahead of it.

## Stack

- Language: Swift 5 language mode (`SWIFT_VERSION = 5.0`), with
  `SWIFT_APPROACHABLE_CONCURRENCY` on
- UI: SwiftUI, declarative; Swift Charts + Canvas for the balance wheel and
  consistency graphs
- Persistence: SwiftData (`@Model`), SQLite-backed, on device
- Architecture: Feature-Oriented MVCS (Model–View–Controller–Service)
- System integration: WidgetKit, UserNotifications
- Target: iOS 26.5 (`IPHONEOS_DEPLOYMENT_TARGET = 26.5`)
- Test runner: XCTest, target `tao-24Tests` at the repo root (never under
  `tao-24/`, where the synchronized group would bundle tests into the app)
- Lint/format: swift-format, invoked via `xcrun`

No third-party dependencies. That's deliberate — see Rules.

## How to run things

```bash
# install — SPM resolves dependencies on build, no separate step

# build (headless check, no need to open Xcode)
xcodebuild -scheme tao-24 -destination 'platform=iOS Simulator,name=iPhone 17' build

# tests (once a test target exists)
xcodebuild test -scheme tao-24 -destination 'platform=iOS Simulator,name=iPhone 17'

# list the simulators actually installed, if the destination above isn't one
xcrun simctl list devices available

# run in simulator / SwiftUI previews — open Xcode for this specifically
open tao-24.xcodeproj

# run one test class
xcodebuild test -scheme tao-24 -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:tao-24Tests/HabitFrequencyTests

# lint / format
xcrun swift-format lint -r .
xcrun swift-format format -i -r .
```

`xcodebuild` and `simctl` need the full Xcode toolchain. This machine's
`xcode-select` points at the Command Line Tools, so they fail with "requires
Xcode, but active developer directory is a command line tools instance".

Prefer the per-command override — no `sudo`, no global change:

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

To change it machine-wide instead:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Repo layout

```
tao-24/              # application code
tao-24.xcodeproj/    # Xcode project
docs/product/        # product & architecture specs (source of truth)
docs/                # ADRs and working notes
.claude/             # Claude Code config
```

`tao-24/` is a filesystem-synchronized group (Xcode 16+), so a new `.swift`
file created there is added to the target and compiled automatically — no
Xcode step needed. The flip side: **anything** placed in that folder is
picked up, and non-source files get copied into the built `.app` as bundle
resources. Keep notes, configs and scratch files out of `tao-24/`.

`App/` exists and holds the entry point. The rest of the structure below is
the **target** layout from the tech-stack doc — build into it as features
land, don't create the folders ahead of time. Git can't track an empty
directory anyway, and a `.gitkeep` placed under `tao-24/` risks being copied
into the built `.app` as a bundle resource by the synchronized group.

```
tao-24/
  App/               # @main entry point and root view          [exists]
  Features/
    Onboarding/      # 5-step questionnaire, starter-plan output
    StarterHub/      # daily execution checklist, quick-add
    PlannerHub/      # dimension portals, blueprints, micro-resources
    ProgressHub/     # balance wheel, consistency trends, milestones
  Models/            # SwiftData entities
  Services/          # stateless domain engines
  DesignSystem/      # shared components, domain theming
```

Each feature folder holds its own `Views/` and `Controller`.

## Rules

General engineering conventions (code style, git, testing, secrets) live in
`~/.claude/CLAUDE.md` and are already in context — don't restate them here.
This section is only what's specific to tao-24:

### Design tokens

Deep-dark and **dark-only**: a black ground with grey
surfaces stepping up by luminance (`#000000` → `#121212` → `#181818` →
`#282828`), high-contrast type, and saturated colour spent only where it
carries meaning. There are no light values, so the app locks
`preferredColorScheme(.dark)` — adding light mode means adding a second value
to every colour token, not flipping a switch.

`docs/design-tokens.json` is the specification; `tao-24/DesignSystem/` mirrors
it (`ColorTokens`, `TypographyTokens`, `LayoutTokens`). Change a value in both
or they drift — the JSON records the measured contrast ratio justifying each.

Domain accents are fixed: **Health → Green `#30D158`, Career → Blue `#0A84FF`,
Fun → Orange `#FF5500`**. Never introduce a fourth domain colour; the
three-way split is the product's core metaphor. Colour is never the *only*
signal either — these are hard to distinguish with deuteranopia, so pair every
accent with `domain.symbolName` and a text label.

Components live in `tao-24/DesignSystem/Components/`: `TaoCard`,
`DomainPill`, `CompletionRing`, and the `GlowEffect` modifiers
(`.softGlow`, `.strongGlow`).

**Naming:** describe what a component *is*, never what it was modelled on — no
third-party product names in type names, filenames or comments. Swift has
module namespacing, so skip prefixes by default; the one exception is a name
too generic to read at a call site or liable to collide with a future SwiftUI
type, which is why `TaoCard` carries the prefix and the rest do not.

Rules:

- Never write a literal `Color` or a fixed font size in a view — add a token.
- Reach for `DimensionDomain.accent`, not `ColorTokens.healthAccent`, so the
  domain-to-colour mapping stays in one place.
- Text on a filled accent uses `domain.onAccent`, which is **black** for all
  three. Every accent is bright enough on dark that white text fails AA.
- Type styles build on system text styles so everything scales with Dynamic
  Type. Prefer the `.displayStyle()` / `.bodyStyle()` view modifiers, which
  carry the matching text colour so the pairing cannot drift.
- One spring for the whole system: `LayoutTokens.Motion.spring`. Every
  animated component checks `accessibilityReduceMotion` and every glow checks
  `accessibilityReduceTransparency`.
- **Glow is decoration, never state.** It is invisible to anyone who cannot
  separate the hue from black, so an element's state must also be carried by
  fill, symbol, or label.
- **There is no error colour for habit completion.** An incomplete ring is
  neutral grey, never red, and un-completing animates exactly like completing.
  Missing a day is not a failure state.
- Contrast is enforced by `ContrastTests`, not by eye or by comment: every
  text token against **all four** surfaces at 4.5:1, every accent at 3:1 as UI
  and 4.5:1 as text, every `onAccent` against its own fill, and every control
  outline at 3:1 on all four surfaces. Add a token to the arrays in
  `ColorTokens.Hex` and it is checked automatically.
- Anything a user can *touch* uses `controlOutline`, never `borderStrong`.
  `borderStrong` is decorative and sits at 1.66:1 on a card — it was used for
  the unchecked completion ring and made the checklist's primary affordance
  nearly invisible until the first real run caught it.
- Checking only the default surface is how a bug ships: `textMuted` passed at
  5.43:1 on `#121212` while failing at 4.27:1 on `#282828`, which is exactly
  where muted text sits inside a pill. It is `#909090` now — do not darken it.

### MVCS layer boundaries

The layer contract is the architecture, so treat a violation as a bug:

- **Model** — SwiftData entities (`Habit`, `HabitExecutionLog`, `LifeGoal`,
  `UserValueProfile`). Pure data. No business logic, no formatting.
- **View** — SwiftUI. Renders and forwards gestures. **Zero data mutation.**
  A View that writes to a `ModelContext` is in the wrong layer.
- **Controller** — `@Observable` classes holding one screen's presentation
  state. Owns UI side effects, delegates real work to a Service.
- **Service** — stateless/singleton engines: completion validation, radar
  math, questionnaire mapping, notification scheduling. No SwiftUI imports.

Services take their dependencies by injection with a default
(`init(executionService: HabitExecutionService = .shared)`) so tests can
substitute a fake without a UI host.

### Product rules that are not negotiable

These come from the PoC's ethical-engagement section. They constrain
implementation, so check a feature against them before building it:

- **No punitive streaks.** Never reset progress to zero on a missed day.
  Progress is expressed as trend and consistency rate over 7/30/90 days, not
  an unbroken chain. If a spec seems to ask for a streak counter, flag the
  conflict rather than quietly implementing one.
- **Notifications are conversational check-ins, not commands.** No urgency
  pressure, no shame framing, no manufactured loss aversion.
- **Every habit links to a goal.** The goal anchor is core to the product,
  not decoration.
- **Balance over volume.** Features should surface distribution across
  Health/Career/Fun, not maximize total completions.

### Local-first & privacy

- All reads/writes hit the on-device SwiftData store **synchronously**. UI
  never waits on the network. No feature may degrade when offline.
- Questionnaire analysis, value scoring, and habit mapping run **on device**.
  Personality and values data does not leave the phone.
- **No third-party analytics, telemetry, tracking or ad SDKs.** This is a
  product guarantee, not a preference. A new dependency of any kind needs an
  explicit decision — check the project's package dependencies before
  assuming a library is available.
- Cloud sync (CloudKit) is background-only and additive; conflicts resolve
  last-write-wins on ISO-8601 UTC timestamps.
- Store tokens and credentials in the Keychain, never `UserDefaults`, a
  plist, or `@AppStorage`. No secrets in `Info.plist` or a checked-in
  `.xcconfig`.
- The local store's data protection level is **deferred to Milestone 3.3**
  and no entitlement is set before then. Complete File Protection makes the
  store unreadable while the device is locked, which breaks WidgetKit timeline
  refresh — so the level is chosen alongside the widget, when its actual needs
  are known. See `.claude/PLAN.md` > Status.

### Performance

- Two compound indexes carry the hot paths:
  `HabitExecutionLog[habitID, completedDayStart]` and
  `Habit[domainRawValue, isArchived]`. Query through those paths — a predicate
  that forces a full table scan on the daily checklist is a defect.
  Two notes on the log index, decided in `.claude/PLAN.md` (Phase 01), which
  is why it differs from the `[habit_id, completedAt]` in the architecture doc:
  `habitID` is a denormalized `UUID` column because `#Index` cannot traverse a
  relationship, and `completedDayStart` is a day-normalized companion to
  `completedAt` because `Calendar` calls are not expressible in `#Predicate`.
  `completedAt` remains the precise timestamp for display and ordering.
- Controllers cache the current day's active habits in memory rather than
  re-reading from disk per view update.

## Open decisions

**Resolved (Sep 12, 2026): `project.pbxproj` is the source of truth for build
settings.** Deployment target **iOS 26.5**, **Swift 5** language mode — Xcode's
defaults at project creation, kept as-is. No build-setting change is planned;
where the spec docs say iOS 17.0+, the project wins and the docs carry a note.

Two consequences worth knowing:

- SwiftData's `#Index` macro is iOS 18.0+, so at a 26.5 floor it is available.
  The two compound indexes can be declared outright — this was previously a
  blocker and no longer is.
- Swift 6 strict concurrency is **not** enabled. Data-race safety is not
  compiler-enforced, so `@MainActor` isolation on Controllers and `Sendable`
  on anything crossing an actor boundary have to be applied by hand rather
  than caught at build time. Revisit if that starts to bite.

Still open — resolve before the affected work; they change generated code.

1. **Streak API.** The tech-stack doc's reference `HabitExecutionService`
   includes `calculateCurrentStreak(for:)`, which contradicts the PoC's
   no-punitive-streaks stance. Decide whether streaks exist as a neutral
   read-only stat or not at all.
4. **Missing spec.** The "Project Roadmap: implementation, testing &
   iteration" link duplicates the architecture doc, so testing strategy and
   iteration cadence are unspecified.
5. **Missing diagrams.** Three figures were images and didn't survive the
   text export: the IA/navigation flow, the modular Xcode structure, and the
   high-level architecture diagram. The layout above is inferred from the
   MVCS description.

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

`.claude/PLAN.md` carries the phase/milestone roadmap (mirrored from Notion)
above the per-milestone plan. The roadmap is hand-maintained — the planner
reads it to pick up the active milestone but never rewrites it. One milestone
= one planner run; one Task Breakdown item = one commit.

## Pointers

- Product specs: `docs/product/` (read before building a feature)
- Commands: `.claude/commands/` (`/plan`, `/load_project`, `/save_project`,
  `/review`, `/test`, `/fix`, `/commit`)
- Subagents: `.claude/agents/` (`planner`)
- Hooks: `.claude/settings.json` + `.claude/hooks/`
  (`bash .claude/hooks/hooks-smoke-test.sh` checks the bash guard still works)
- GitHub work goes through the `gh` CLI — there is no MCP server configured.

<!--
  This file is the project's planning state. Two kinds of content live here and
  they have different owners:

    * Roadmap + Active Milestone  — HAND-MAINTAINED, mirrored from Notion:
      https://app.notion.com/p/tao-24-34a71fe447a681e182c0e4ed174ca6e7
      The planner subagent READS these to know what to work on. It must not
      rewrite or reorder them; it may only tick a checkbox when the work is
      genuinely complete.

    * Problem / Task Breakdown / Tooling / Status — OWNED BY THE PLANNER
      (.claude/agents/planner.md, via /plan and /save_project). These describe
      the ONE active milestone, not the whole project. They get replaced each
      time a new milestone starts.

  Keep the section headers intact. Freeform notes are fine inside a section.
-->

# Project Plan

_Last updated: Sep 27, 2026 — Phase 01 complete; app launches and renders seeded data._

## Roadmap

Tasks below are verbatim from the Notion roadmap. One milestone = one planner
run; the planner turns each task into one or more discrete commits under
**Task Breakdown**.

### Phase 01 — Core Foundation & Data Persistence

- [x] **Milestone 1.1 — Project Scaffold & Design System Tokens**  _(complete, `3d992ce`)_
  - [x] Task 0: Define the agentic setup for the project.
  - [x] Task 1: Set up Xcode project structure following the feature-oriented
        MVCS pattern (Core, Features, StarterHub, Planner, Progress,
        Onboarding).
  - [x] Task 2: Define core design tokens: domain accent colors (Health →
        Green, Career → Blue, Fun → Orange), system typography styles, and
        reusable custom card containers.
        <!-- Fully done, including the "reusable custom card containers"
             clause: TaoCard, DomainPill, CompletionRing and
             GlowEffect all shipped with the tokens. -->
- [x] **Milestone 1.2 — SwiftData Engine & Schema Definition**  _(complete)_
  - [x] Task 1: Implement `@Model` definitions for `Habit`,
        `HabitExecutionLog`, `LifeGoal`, and `UserValueProfile`.
  - [x] Task 2: Set up the `DatabaseService` singleton to configure
        `ModelContainer` with schema migrations and seed initial default
        templates.

### Phase 02 — Feature-by-Feature Core Implementation

- [ ] **Milestone 2.1 — Starter Hub (Daily Checklist & Log Execution)**
  - [ ] Task 1: Build `StarterHubView` and `StarterHubController` with
        reactive SwiftData `@Query` binding for today's habits.
  - [ ] Task 2: Implement `HabitRowCard` with interactive checkmarks that
        trigger instant local logging via `HabitExecutionService`.
  - [ ] Task 3: Create `QuickAddHabitSheet` modal to allow manual creation of
        custom habits tied to specific domains.
- [ ] **Milestone 2.2 — Habit Planner Screen (Discovery & Blueprint System)**
  - [ ] Task 1: Construct `PlannerHubView` displaying the 3 main "Dimensions
        of Joy" hero cards.
  - [ ] Task 2: Implement horizontal micro-resource feed showcasing 1-minute
        educational insight cards.
  - [ ] Task 3: Develop `BlueprintDetailSheet` modal and implement the "Adopt
        Plan" action to automatically batch-insert 3 pre-packaged habits into
        SwiftData.
- [ ] **Milestone 2.3 — Progress Hub (Data Visualization)**
  - [ ] Task 1: Build `ProgressHubView` with a time-frame segmented selector
        (7 Days, 30 Days, 90 Days).
  - [ ] Task 2: Implement `DimensionBalanceWheel` custom Canvas view to render
        the 3-axis radar chart calculating weekly effort distribution across
        Health, Career, and Fun.
  - [ ] Task 3: Implement `ConsistencyBarChart` using Swift Charts to display
        daily completion ratios over time.
- [ ] **Milestone 2.4 — Onboarding Questionnaire & Personalization Engine**
  - [ ] Task 1: Build `OnboardingContainerView` featuring a 5-step
        step-by-step questionnaire flow.
  - [ ] Task 2: Implement `PersonalityMappingEngine` service to map
        questionnaire responses to calculated initial starter habit
        recommendations.
  - [ ] Task 3: Connect the onboarding completion output screen directly to
        initial app launches via `AppState`.

### Phase 03 — System Integration & Refinement Iterations

- [ ] **Milestone 3.1 — State Coordination & Navigation Polish**
  - [ ] Task 1: Wire up tab bar navigation across Starter Hub, Planner Hub,
        and Progress Hub.
  - [ ] Task 2: Ensure seamless deep linking from onboarding completion
        directly into the populated Starter Hub.
- [ ] **Milestone 3.2 — Native Haptics & Visual Feedback**
  - [ ] Task 1: Integrate `UIImpactFeedbackGenerator` for haptic feedback upon
        checking off habit items.
  - [ ] Task 2: Add spring animations for modal presentations and progress
        ring updates.
- [ ] **Milestone 3.3 — WidgetKit Integration**
  - [ ] Task 1: Implement a simple Home Screen Widget using WidgetKit that
        displays today's checklist completion state directly on the iOS home
        screen.

### Post Phase 03 — The Launch Sequence

- [ ] **TestFlight Beta** (end of Phase 3.2) — Share a TestFlight build with a
      small group of friends or colleagues to catch any critical UI crashes or
      layout glitches on different iPhone screen sizes.
- [ ] **App Store Submission** (Milestone 3.3 complete) — Submit the build to
      Apple for App Store review once the WidgetKit implementation is finished.
- [ ] **LinkedIn Launch Announcement** (day of App Store approval) — Publish
      the launch post highlighting the product story, native SwiftUI build, and
      the "Dimensions of Joy" philosophy once the App Store link goes live.

### Future tasks (not part of the initial MVP)

Deferred past the MVP; raised so they are not mistaken for oversights.

- **The PoC's Phase 3 (Ethical Engagement) has no milestone anywhere in this
  roadmap** — weekly self-reflection prompts, compassionate pausing
  (vacation/sick mode), and intentional context-aware reminders are unplanned.
  These are the product's stated differentiator.
- **Customizable Domain Weights** (PoC Phase 2) has no milestone.
- ~~No milestone covers adding a unit test target~~ — resolved: landed in
  `2989277`. A `verify.sh` wrapping build + test + lint is still unwritten.

## Active Milestone

- **Phase:** 01 — Core Foundation & Data Persistence
- **Milestone:** 1.2 — SwiftData Engine & Schema Definition
- **Planned commits:** 3 remaining of 8; Milestone 1.1 is complete

Milestone 1.1 is complete and pushed: agentic setup, MVCS folder structure,
and the design system. The test target that Phase 01 scoping had added to
M1.1 was deferred rather than built, so the milestone closed without it.
Remaining: M1.2 Task 1 (`@Model` entities), M1.2 Task 2 (`DatabaseService`).

**Decided Sep 12, 2026:** `project.pbxproj` is the source of truth for build
settings — deployment target **iOS 26.5**, **Swift 5** language mode, kept as
Xcode created them. M1.1 Task 1 therefore ships no build-setting change; see
`CLAUDE.md` > Open decisions.

---

<!-- Everything below describes the ACTIVE MILESTONE ONLY. -->

## Problem

<!-- Problem Identification stage output: restated problem, assumptions
     challenged, edge cases, non-goals. -->

Context and constraints are in `CLAUDE.md` — not restated here. Only the two
schema decisions that `CLAUDE.md` does not already settle:

- **`targetFrequency` is a type, not a `String`.** The reference `String`
  ("Daily"/"3x/week"/"Custom") can't say *which* days "Custom" means, and the
  consistency rate needs a numeric denominator. Store decomposed
  (`frequencyKindRawValue`, `weeklyTargetCount`, `customWeekdayMask`) with a
  computed `HabitFrequency` façade — same pattern as `domain`/`domainRawValue`.
  Not a single `Codable` enum: SwiftData stores that as a blob that can't be
  used in `#Predicate` or indexed.
- **The log's compound index needs a denormalized `habitID: UUID`.** `#Index`
  can't traverse a relationship, so `\.habit.id` is illegal — without a stored
  column there is no index. Also index `completedDayStart` (a day-normalized
  companion to `completedAt`) rather than `completedAt`, because `Calendar`
  calls aren't expressible in `#Predicate` at all. Gives
  `#Index<HabitExecutionLog>([\.habitID, \.completedDayStart])` and
  `#Index<Habit>([\.domainRawValue, \.isArchived])`.
  `#Index` is iOS 18.0+ and the project's floor is 26.5, so it is available —
  not a blocker.

## Task Breakdown

<!-- Task Development stage output. One checklist per stage; leave a stage
     empty if it doesn't apply. Each checklist item should be one commit. -->

8 commits — 4 per milestone. Stage 4 folds into the commits it verifies
(previews and tests ship with their code) and Stage 5 into commit 8; neither
has standalone work in this phase.

### Stage 1 — Data & Contracts

- [x] `[M1.1] Set up the MVCS folder layout` — done in `b907584`; entry point and root view moved to `tao-24/App/`, `@main` struct renamed `Tao24Universe`. No build-setting change: `project.pbxproj` is the source of truth and keeps iOS 26.5 / Swift 5. Follow-ups `f528190` (swift-format config, 4-space) and `a9b6fd5` (capitalize struct) landed with it
- [x] `[M1.1] Add tao-24Tests unit test target` — deferred on Sep 27, 2026, then un-deferred the same day and landed in `2989277` ahead of `DatabaseService`, whose claims are behavioural. Rooted at `tao-24Tests/` with a checked-in shared scheme. No `verify.sh` yet — `xcodebuild test` plus `swift-format lint --strict` cover it for now
- [x] `[M1.1] Add DimensionDomain and the core design tokens` — deep-dark system, **dark-only** (app locks `.preferredColorScheme(.dark)`). `docs/design-tokens.json` is the spec; `ColorTokens`/`TypographyTokens`/`LayoutTokens` mirror it, cross-checked in CI-able form. Absorbs the Stage 3 component commit: `TaoCard`, `DomainPill`, `CompletionRing`, `GlowEffect`
- [x] `[M1.2] Add the four @Model entities with typed frequency storage` `[!]` — split as flagged, into three commits that each build: `8c6a9ce` (`HabitFrequency` + `Weekday`), `546f55d` (`Habit`, `HabitExecutionLog`, `LifeGoal` — mutually referential, so together), `9bb5b50` (`UserValueProfile` + onboarding enums)
- [x] `[M1.2] Add SchemaV1, compound indexes, and fetch descriptors` — both `#Index` declarations, `SchemaV1`, and `HabitQuery`/`ExecutionLogQuery`/`LifeGoalQuery`/`UserValueProfileQuery` descriptor factories. `#Unique` on `[habitID, completedDayStart]` deliberately **not** added: its interaction with the existing unique `id` is upsert behaviour that cannot be verified without running the app. Revisit when a test target exists

### Stage 2 — Core Logic

- [x] `[M1.2] Implement DatabaseService with migration plan and seeding` `[!]` — `58602c6`. Idempotent by construction (inserts only what is absent, so it self-repairs a partial seed), `nonisolated` in-memory factory, `isEphemeral` surfaced when the on-disk store fails. 13 tests against a live container

### Stage 3 — Integration

- [x] ~~`[M1.1] Add CardContainer and DomainTagPill with previews`~~ — superseded: shipped as `TaoCard` and `DomainPill` in the design-tokens commit, alongside `CompletionRing` and `GlowEffect`. The pill still pairs colour with icon and label so colour is never the sole domain signal
- [x] `[M1.2] Attach the ModelContainer and replace the template ContentView` — `1c8b12f`. `RootView` reads seeded goals through `@Query`; `ContentView` deleted. Followed by `07cde24`, which fixed a `textMuted` contrast failure the first real launch exposed and made the palette rule executable

### Stage 4 — Verification

Folded into the commits above — previews ship with their components, tests with
the service. No telemetry work, by product guarantee.

### Stage 5 — Cleanup

Folded into commit 8. No dead code or temporary scaffolding accumulates in a
phase this short.

## Tooling

<!-- Tool Building stage output. -->

- **Test fakes & mocks:** `DatabaseService.makeContainer(inMemory: true)` is the
  test seam — a real SwiftData stack, no disk, no UI host. `DatabaseServicing`
  protocol exists for Phase 02 controllers; a fake is premature until one has a
  consumer.
- **Reproduction scripts:** `scripts/verify.sh` (build + test + lint), added in
  commit 2. No bug to reproduce.
- **Custom skills:** none. Revisit in Phase 02 — a feature-module scaffolder
  would pay off across four hub milestones once the pattern is exercised.
- **Background automations:** the `format-on-write` hook already covers Swift
  formatting. No analytics or usage automation, by product guarantee.

## Status

- Current stage: **Phase 01 complete** on branch `feat/m1-2-swiftdata-schema`,
  pushed, not yet merged to `main`
- Done: **Milestone 1.1**, all three Notion tasks — agentic setup, MVCS
  folder layout (`b907584`, `f528190`, `a9b6fd5`, `90bab25`), design system
  (`3d992ce`). Merged to `main` and pushed.
- In progress: nothing — Phase 02 (Starter Hub) is next
- Blocked on: nothing. `project.pbxproj` is the source of truth for build
  settings (iOS 26.5 / Swift 5), so no build-setting work remains and `#Index`
  is available at that floor.
- Verified: clean build, **29 tests passing**, and the app **launched in the
  simulator** rendering its seeded goals. Prefix commands with
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`; no `sudo`
  needed.
- **Deployment target warning:** at 26.5 the app will not install on the iOS
  26.4 simulator — one patch behind is already excluded, and installation
  fails outright rather than degrading. Worth revisiting before TestFlight.
  `project.pbxproj` remains the source of truth, so lowering it is a
  deliberate decision, not a default.
- Still unverified: no UI interaction is exercised. Tests cover value types
  and the store; nothing taps a `CompletionRing` or scrolls a list.
- Deferred to M3.3: the store's data protection level. `CLAUDE.md` requires
  Complete File Protection, which makes the store unreadable while the device
  is locked and so breaks WidgetKit timeline refresh. It is an entitlement, not
  a schema change, so it costs the same to add in M3.3 as now — and M3.3 is
  where the widget's actual needs are known. Phase 01 sets no data protection
  entitlement.
- Also raised: the roadmap's folder names (Core, Planner, Progress) disagree
  with `CLAUDE.md`'s layout; plan follows `CLAUDE.md`. M1.2 Task 2's "default
  templates" are seeded as three per-domain `LifeGoal`s plus the singleton
  profile — blueprints stay a static code catalog, not rows.
- Next step: merge to `main`, then Phase 02 Milestone 2.1 — the Starter Hub

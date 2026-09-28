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

_Last updated: Sep 27, 2026 — Milestone 2.3 complete; all three hubs run._

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

- [x] **Milestone 2.1 — Starter Hub (Daily Checklist & Log Execution)**  _(complete)_
  - [x] Task 1: Build `StarterHubView` and `StarterHubController` with
        reactive SwiftData `@Query` binding for today's habits.
  - [x] Task 2: Implement `HabitRowCard` with interactive checkmarks that
        trigger instant local logging via `HabitExecutionService`.
  - [x] Task 3: Create `QuickAddHabitSheet` modal to allow manual creation of
        custom habits tied to specific domains.
- [x] **Milestone 2.2 — Habit Planner Screen (Discovery & Blueprint System)**  _(complete)_
  - [x] Task 1: Construct `PlannerHubView` displaying the 3 main "Dimensions
        of Joy" hero cards.
  - [x] Task 2: Implement horizontal micro-resource feed showcasing 1-minute
        educational insight cards.
  - [x] Task 3: Develop `BlueprintDetailSheet` modal and implement the "Adopt
        Plan" action to automatically batch-insert 3 pre-packaged habits into
        SwiftData.
- [x] **Milestone 2.3 — Progress Hub (Data Visualization)**  _(complete)_
  - [x] Task 1: Build `ProgressHubView` with a time-frame segmented selector
        (7 Days, 30 Days, 90 Days).
  - [x] Task 2: Implement `DimensionBalanceWheel` custom Canvas view to render
        the 3-axis radar chart calculating weekly effort distribution across
        Health, Career, and Fun.
  - [x] Task 3: Implement `ConsistencyBarChart` using Swift Charts to display
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

- **Phase:** 02 — Feature-by-Feature Core Implementation
- **Milestone:** 2.3 — Progress Hub _(complete)_; 2.4 Onboarding is next
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

Milestone 2.3 is where the no-streak stance had to become arithmetic rather
than a principle. Three decisions carried the work:

- **The denominator is per-day and historical.** A habit counts on a day only
  if it was due then and already existed, so adding a habit today cannot
  retroactively ruin last month, and a 3x-a-week habit is not marked down for
  the four days it was never meant to happen.
- **A rest day is not a missed day.** `DailyCompletion.hasSchedule` is
  separate from `ratio`, the chart draws rest days as a faint baseline, and
  the average excludes them.
- **Balance is a ratio, not a tolerance.** Settled by running the screen — see
  Verification.

## Task Breakdown

2 commits, both building green.

### Stage 2 — Core Logic

- [x] `[M2.3] Add ProgressService: trends, distribution, and consistency` —
      `60e3d46`. Also threaded `Calendar` through `HabitExecutionService`,
      which had hard-coded `.current` and so could not agree with any caller
      bucketing days differently

### Stage 3 — Integration

- [x] `[M2.3] Build the Progress Hub: balance wheel and consistency chart` —
      `ProgressHubController`, `ProgressHubView`, the Canvas radar, the Swift
      Charts bar chart, and the Progress tab

### Stage 4 — Verification

Folded in: 19 new tests, plus the screen exercised in the simulator — which is
what caught the balance-threshold bug. The badge claimed "spread evenly" above
a 40/40/20 breakdown because the old ±15-point tolerance allowed a 2.6x gap.
Now a max/min ratio capped at 1.5, with a regression test.

### Stage 5 — Cleanup

Both temporary scaffolds — the demo history and the tab reorder used for
screenshots — were reverted before commit.

## Tooling

- Test fakes & mocks: none — in-memory containers throughout
- Reproduction scripts: none
- Custom skills: none
- Background automations: none

## Status

- Current stage: **Milestone 2.3 complete** on `feat/m2-3-progress-hub`
- Done: Phase 01 in full; M2.1 Starter Hub; M2.2 Habit Planner; M2.3 Progress
  Hub
- In progress: nothing — M2.4 (Onboarding questionnaire) is next, and it is
  the last milestone in Phase 02
- Blocked on: nothing
- Verified: 98 tests passing, clean build, all three hubs exercised in the
  simulator
- Partly pulled forward: **M3.1 Task 1** (tab navigation) is now effectively
  done — all three tabs exist. M3.1 still owns the onboarding deep link.
- Not in M2.3's task list, but in the PoC's Progress screen: the **Milestone
  Log** and the **weekly Reflection CTA**. The reflection prompt belongs to the
  unplanned Ethical Engagement phase; the milestone log has no home yet.
- Still unverified: no automated UI interaction anywhere.
- Carried forward: iOS 26.5 still refuses to install on the 26.4 simulator;
  `#Unique` on `[habitID, completedDayStart]` still unadded.
- Next step: Milestone 2.4 — Onboarding questionnaire and personalization
  engine

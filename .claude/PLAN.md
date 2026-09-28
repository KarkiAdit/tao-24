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

_Last updated: Sep 27, 2026 — Milestone 2.1 complete; the Starter Hub runs._

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

- **Phase:** 02 — Feature-by-Feature Core Implementation
- **Milestone:** 2.1 — Starter Hub _(complete)_; 2.2 Habit Planner is next
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

Milestone 2.1 turns the store into a usable screen. The risk was not the
SwiftUI — it was keeping the MVCS boundary while wiring `@Query`, a Service
and a Controller together, since that is the seam where a view starts writing
to a `ModelContext` "just this once".

Two things settled during the work:

- **Filtering is presentation state, not a predicate.** The view holds one
  `@Query` for active habits; the controller narrows it. Switching a chip is
  free, and the filter logic is testable against a plain array.
- **No streak API, in any form.** `HabitExecutionService` deliberately omits
  the reference `calculateCurrentStreak`. Progress is a count today and a
  trend in M2.3.

## Task Breakdown

4 commits, all landed and each building green.

### Stage 1 — Data & Contracts

- [x] `[M2.1] Add HabitExecutionService for completion logging` — `a031228`.
      Completion state, log, undo, toggle, and habit creation that enforces
      the goal anchor. No streak API

### Stage 2 — Core Logic

- [x] `[M2.1] Add StarterHubController for the daily checklist` — `abd12df`.
      Filter, quick-add draft, derived visible list and completion count

### Stage 3 — Integration

- [x] `[M2.1] Build the Starter Hub: daily checklist, rows, and quick-add` —
      `c11c902`. `StarterHubView`, `HabitRowCard`, `QuickAddHabitSheet`, and
      `RootView` switched over from the placeholder

### Stage 4 — Verification

- [x] `[M2.1] Add controlOutline so the completion ring is actually visible` —
      `2c8c85f`. Found by running the screen, not by a test

### Stage 5 — Cleanup

Nothing accumulated. The temporary demo-seed used to screenshot the populated
list was reverted before commit.

## Tooling

- Test fakes & mocks: none needed — `DatabaseService.makeContainer(inMemory:)`
  gives every test a real, isolated store
- Reproduction scripts: none
- Custom skills: none
- Background automations: none

## Status

- Current stage: **Milestone 2.1 complete** on `feat/m2-1-starter-hub`
- Done: Phase 01 in full, plus M2.1's three Notion tasks
- In progress: nothing — M2.2 (Habit Planner) is next
- Blocked on: nothing
- Verified: 58 tests passing, clean build, and the hub **exercised in the
  simulator** in both empty and populated states
- Still unverified: no automated UI interaction. Nothing taps a ring or opens
  the quick-add sheet in a test — the flows are covered at the controller
  level, not through the view. A UI test target would close it.
- Carried forward: the iOS 26.5 deployment target still refuses to install on
  the 26.4 simulator; `#Unique` on `[habitID, completedDayStart]` is still
  unadded, and now cheap to verify since a test target exists.
- Next step: Milestone 2.2 — Habit Planner (dimension portals, blueprints,
  micro-resources)

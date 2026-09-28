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

_Last updated: Sep 27, 2026 — Milestone 2.2 complete; both hubs run._

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
- **Milestone:** 2.2 — Habit Planner _(complete)_; 2.3 Progress Hub is next
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

Milestone 2.2 is the half of the product that explains rather than tracks. The
decisions that mattered were about content ownership and about what "adopted"
means, not about layout.

- **Blueprints and reads are code, not rows.** Read-only app content as
  SwiftData rows would turn every copy edit into a migration and sync three
  identical copies of fixed text to every device. The user's adopted habits
  are rows; the template is not.
- **Adopted-ness is derived, never stored.** A blueprint is a template, not a
  subscription. Once adopted the habits belong to the user, who may rename or
  archive them, so an "adopted" flag would start lying immediately. Matching
  title and domain against active habits makes partial adoption the normal
  path rather than an edge case.

## Task Breakdown

4 commits, each building green.

### Stage 1 — Data & Contracts

- [x] `[M2.2] Add the blueprint and micro-resource catalog` — `3424e2f`.
      Three sets, four reads, as a static `Sendable` catalog. A test enforces
      that every set spans all three dimensions

### Stage 2 — Core Logic

- [x] `[M2.2] Add BlueprintService for adopting a set` — `9271628`. Derived
      adopted-ness, case-insensitive but domain-sensitive matching, partial
      adoption, and archived habits not blocking re-adoption

### Stage 3 — Integration

- [x] `[M2.2] Build the Habit Planner: portals, reads, and blueprint
      adoption` — `PlannerHubController`, `PlannerHubView`,
      `BlueprintDetailSheet`, plus the two-tab bar that makes the screen
      reachable

### Stage 4 — Verification

Folded in: 21 new tests across the service and controller, and the screen was
exercised in the simulator.

### Stage 5 — Cleanup

The temporary tab reorder used to screenshot the Planner was reverted before
commit.

## Tooling

- Test fakes & mocks: none — `DatabaseService.makeContainer(inMemory:)` gives
  each test a real isolated store
- Reproduction scripts: none
- Custom skills: none
- Background automations: none

## Status

- Current stage: **Milestone 2.2 complete** on `feat/m2-2-habit-planner`
- Done: Phase 01 in full; M2.1 Starter Hub; M2.2 Habit Planner
- In progress: nothing — M2.3 (Progress Hub) is next
- Blocked on: nothing
- Verified: 79 tests passing, clean build, both hubs exercised in the simulator
- Partly pulled forward: **M3.1 Task 1** (tab navigation) is half done. The
  bar exists with Today and Plan; M3.1 still owns the Progress tab and the
  onboarding deep link.
- Still unverified: no automated UI interaction anywhere. Adoption, the
  accordion and the quick-add sheet are covered at controller level and by
  hand, not through the view.
- Carried forward: iOS 26.5 still refuses to install on the 26.4 simulator;
  `#Unique` on `[habitID, completedDayStart]` still unadded.
- Next step: Milestone 2.3 — Progress Hub (balance wheel, consistency chart,
  milestones)

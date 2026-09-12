<!--
  Reformatted from a Google Docs text export on 2026-09-12. Structure (headings,
  bullets, code fences) was rebuilt for navigability; wording and code are
  unchanged.
  Source: https://docs.google.com/document/d/1WIuwc4NnYkmdyCnRDDpUfG4fXx1e6y9IR0-qnV0F1H0/edit
  MISSING FIGURE: section 3 (scalable modular Xcode project structure) is an
  image in the original and did not survive the text export.
-->

# Native iOS Tech Stack & Project Architecture

> **Version** 1.0 · **Status** Draft · **Last updated** Sep 11, 2026
> **Target platform** iOS 18.0+ (Native Swift; raised from 17.0 — see `CLAUDE.md`) ·
> **Architecture style** Feature-Oriented Modular MVCS (Model-View-Controller-Service)

**In this doc:** [Tech Stack](#1-tech-stack-selection) ·
[MVCS Pattern](#2-architectural-pattern-feature-oriented-mvcs) ·
[Project Structure](#3-scalable-modular-xcode-project-structure) ·
[Model Layer](#41-model-layer-swiftdata-entity) ·
[Service Layer](#42-service-layer-business-engine) ·
[Controller Layer](#43-controller-layer-presentation-state)

---

## 1. Tech Stack Selection

| Component | Technology Choice | Strategic Rationale |
|---|---|---|
| **Language** | Swift 6 | Strict concurrency safety, maximum hardware performance, and direct OS integration. |
| **UI Framework** | SwiftUI | Declarative layout engine for reactive state binding, fluid sheets, and smooth animations. |
| **Persistence Engine** | SwiftData | Modern Apple persistence layer featuring declarative `@Model` macros and automated schema migration. |
| **Architecture** | Feature-Oriented MVCS | Decouples UI (Views), State/Logic (Controllers), Business Services (Services), and Data (Models). |
| **Data Visualization** | Swift Charts + Canvas | Native rendering for the Dimension Balance Wheel (Radar Chart) and Consistency Bar Graphs. |
| **System Integrations** | WidgetKit & UserNotifications | Home screen widgets, lock screen progress tracking, and contextual check-in notifications. |

---

## 2. Architectural Pattern: Feature-Oriented MVCS

To ensure high scalability, testability, and clear separation of concerns, the
project utilizes MVCS (Model-View-Controller-Service) structured by functional
feature modules:

- **Model (Data & Entities)** — SwiftData entities representing persistent
  state (e.g. `Habit`, `HabitExecutionLog`, `LifeGoal`, `UserValueProfile`).
  Pure data structures with no business logic.
- **View (UI & Presentation)** — Declarative SwiftUI views responsible strictly
  for rendering UI and forwarding user gestures to the Controller. Views
  contain zero data-mutation logic.
- **Controller (Feature State & User Flow)** — `@Observable` classes that hold
  presentation state for a specific screen or flow, manage UI side-effects, and
  delegate business execution to Services.
- **Service (Core Business Logic)** — Stateless or singleton engines executing
  pure domain logic (e.g. habit completion validation, radar chart math,
  personality questionnaire mapping algorithm, notification scheduling).

---

## 3. Scalable Modular Xcode Project Structure

> **Missing figure.** This section is a diagram in the source document and did
> not survive the text export. See the *Repo layout* section of the project's
> `CLAUDE.md` for the structure currently inferred from the MVCS description
> above — replace it once the original diagram is available.

---

## 4. Swift Core Implementations (MVCS)

### 4.1 Model Layer (SwiftData Entity)

> **Superseded in part (Phase 01).** `targetFrequency: String` is not the
> shipped shape: the string cannot express *which* days "Custom" means, and the
> consistency rate needs a numeric denominator. It is stored decomposed
> (`frequencyKindRawValue`, `weeklyTargetCount`, `customWeekdayMask`) behind a
> computed `HabitFrequency` façade — the same pattern as `domain` below.
> `HabitExecutionLog` also gains a denormalized `habitID` and a
> `completedDayStart`. See `.claude/PLAN.md` > Problem.

```swift
import Foundation
import SwiftData

enum DimensionDomain: String, Codable, CaseIterable {
    case health = "Health"
    case career = "Career"
    case fun = "Fun"
}

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var title: String
    var domainRawValue: String
    var targetFrequency: String
    var createdAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade, inverse: \HabitExecutionLog.habit)
    var executionLogs: [HabitExecutionLog] = []

    var domain: DimensionDomain {
        get { DimensionDomain(rawValue: domainRawValue) ?? .health }
        set { domainRawValue = newValue.rawValue }
    }

    init(title: String, domain: DimensionDomain, targetFrequency: String = "Daily") {
        self.id = UUID()
        self.title = title
        self.domainRawValue = domain.rawValue
        self.targetFrequency = targetFrequency
        self.createdAt = Date()
        self.isArchived = false
    }
}
```

### 4.2 Service Layer (Business Engine)

> **Open question — see `CLAUDE.md` > Open decisions.** `calculateCurrentStreak(for:)`
> sits in tension with the PoC's *Streak Forgiveness* guideline. Additionally,
> the loop below returns `0` for a streak that ended yesterday rather than
> today, because `checkDate` starts at today and only advances on a match.
> Resolve both before adapting this reference implementation.

```swift
import Foundation

final class HabitExecutionService {
    static let shared = HabitExecutionService()
    private init() {}

    func canLogCompletion(for habit: Habit, on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return !habit.executionLogs.contains { log in
            calendar.isDate(log.completedAt, inSameDayAs: date)
        }
    }

    func calculateCurrentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let sortedLogs = habit.executionLogs.map { $0.completedAt }.sorted(by: >)
        guard let mostRecent = sortedLogs.first else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for logDate in sortedLogs {
            if calendar.isDate(logDate, inSameDayAs: checkDate) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
        }
        return streak
    }
}
```

### 4.3 Controller Layer (Presentation State)

```swift
import Foundation
import Observation
import SwiftData

@Observable
final class StarterHubController {
    var selectedDomainFilter: DimensionDomain? = nil
    var isShowingQuickAddSheet: Bool = false

    private let executionService: HabitExecutionService

    init(executionService: HabitExecutionService = .shared) {
        self.executionService = executionService
    }

    func toggleHabitCompletion(_ habit: Habit, context: ModelContext) {
        if executionService.canLogCompletion(for: habit) {
            let log = HabitExecutionLog(completedAt: Date(), habit: habit)
            context.insert(log)
        }
        try? context.save()
    }
}
```

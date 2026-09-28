//
//  Queries.swift
//  tao-24
//

import Foundation
import SwiftData

/// Canonical fetch descriptors.
///
/// These exist so no caller hand-rolls a predicate. Both hot paths depend on
/// hitting a compound index, and the ways to miss one are quiet: filtering on
/// `habit.id` instead of `habitID` traverses a relationship, and asking
/// `Calendar` whether a date is today is not expressible in a `#Predicate` at
/// all. Every query below is shaped to the index that serves it.
///
/// Contracts, not logic — these only build descriptors. Anything that decides
/// *what* to do with the results belongs in a Service.

/// Queries over `Habit`, served by `#Index<Habit>([domainRawValue, isArchived])`.
enum HabitQuery {

    /// Every active habit, oldest first.
    static func active() -> FetchDescriptor<Habit> {
        var descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.goal]
        return descriptor
    }

    /// Active habits in one dimension — the domain portal's query.
    ///
    /// Compares `domainRawValue` rather than the computed `domain`, which is
    /// invisible to the store.
    static func active(in domain: DimensionDomain) -> FetchDescriptor<Habit> {
        let raw = domain.rawValue
        var descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived && $0.domainRawValue == raw },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.goal]
        return descriptor
    }

    /// Archived habits, most recently created first. History is never deleted,
    /// only archived, so this is how it is reached.
    static func archived() -> FetchDescriptor<Habit> {
        FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
    }
}

/// Queries over `HabitExecutionLog`, served by
/// `#Index<HabitExecutionLog>([habitID, completedDayStart])`.
enum ExecutionLogQuery {

    /// Every completion on one day — what the Starter Hub checklist loads.
    static func onDay(_ date: Date, calendar: Calendar = .current) -> FetchDescriptor<
        HabitExecutionLog
    > {
        let dayStart = calendar.startOfDay(for: date)
        return FetchDescriptor<HabitExecutionLog>(
            predicate: #Predicate { $0.completedDayStart == dayStart },
            sortBy: [SortDescriptor(\.completedAt, order: .forward)]
        )
    }

    /// Whether one habit is already logged on one day.
    ///
    /// `fetchLimit` of 1 because the question is existence, not the row.
    static func forHabit(
        _ habitID: UUID,
        on date: Date,
        calendar: Calendar = .current
    ) -> FetchDescriptor<HabitExecutionLog> {
        let dayStart = calendar.startOfDay(for: date)
        var descriptor = FetchDescriptor<HabitExecutionLog>(
            predicate: #Predicate { $0.habitID == habitID && $0.completedDayStart == dayStart }
        )
        descriptor.fetchLimit = 1
        return descriptor
    }

    /// One habit's completions within a date range — the consistency trend.
    ///
    /// Half-open on the upper bound so a range ending today includes today
    /// exactly once, whatever the caller passes as a time component.
    static func forHabit(
        _ habitID: UUID,
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> FetchDescriptor<HabitExecutionLog> {
        let lower = calendar.startOfDay(for: startDate)
        let upper = calendar.startOfDay(for: endDate)
        return FetchDescriptor<HabitExecutionLog>(
            predicate: #Predicate {
                $0.habitID == habitID
                    && $0.completedDayStart >= lower
                    && $0.completedDayStart <= upper
            },
            sortBy: [SortDescriptor(\.completedDayStart, order: .forward)]
        )
    }

    /// Every completion in a date range, across all habits — the Progress
    /// Hub's balance wheel and consistency chart.
    static func inRange(
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar = .current
    ) -> FetchDescriptor<HabitExecutionLog> {
        let lower = calendar.startOfDay(for: startDate)
        let upper = calendar.startOfDay(for: endDate)
        var descriptor = FetchDescriptor<HabitExecutionLog>(
            predicate: #Predicate {
                $0.completedDayStart >= lower && $0.completedDayStart <= upper
            },
            sortBy: [SortDescriptor(\.completedDayStart, order: .forward)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.habit]
        return descriptor
    }
}

/// Queries over `LifeGoal`.
enum LifeGoalQuery {

    /// Active goals, for the quick-add goal picker.
    static func active() -> FetchDescriptor<LifeGoal> {
        FetchDescriptor<LifeGoal>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
    }
}

/// Queries over `UserValueProfile`.
enum UserValueProfileQuery {

    /// The single profile row, if one exists.
    ///
    /// `fetchLimit` of 1 guards the invariant at the read side: if seeding
    /// ever produced a duplicate, callers still see one profile rather than
    /// behaving unpredictably.
    static func singleton() -> FetchDescriptor<UserValueProfile> {
        var descriptor = FetchDescriptor<UserValueProfile>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }
}

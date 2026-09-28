//
//  HabitExecutionService.swift
//  tao-24
//

import Foundation
import SwiftData

/// Completion logging and habit creation.
///
/// Stateless domain logic with no SwiftUI imports, so it is testable without a
/// UI host. The `ModelContext` arrives per call rather than being held,
/// because contexts belong to the view tree that owns them.
///
/// Two product rules are enforced here rather than left to callers:
/// un-completing is exactly as available as completing, and a new habit always
/// gets a goal anchor.
///
/// Note what is deliberately absent: there is **no streak API**. The reference
/// implementation in the tech-stack doc has `calculateCurrentStreak`, which
/// contradicts the PoC's no-punitive-streaks stance. Progress is expressed as
/// trend and consistency rate over a window — that lands with the Progress Hub
/// in M2.3, not here.
final class HabitExecutionService {

    static let shared = HabitExecutionService()

    init() {}

    /// Whether this habit already has a completion recorded for the day.
    func isComplete(
        _ habit: Habit,
        on date: Date = Date(),
        in context: ModelContext
    ) throws -> Bool {
        try !context.fetch(ExecutionLogQuery.forHabit(habit.id, on: date)).isEmpty
    }

    /// Records a completion unless the day already has one.
    ///
    /// - Returns: `true` if a log was inserted, `false` if one already existed.
    @discardableResult
    func logCompletion(
        for habit: Habit,
        on date: Date = Date(),
        in context: ModelContext
    ) throws -> Bool {
        guard try !isComplete(habit, on: date, in: context) else { return false }
        context.insert(HabitExecutionLog(habit: habit, completedAt: date))
        try context.save()
        return true
    }

    /// Removes the day's completion if there is one.
    ///
    /// Undo is a first-class operation, not a hidden one — a mis-tap should
    /// cost exactly one tap to correct.
    ///
    /// - Returns: `true` if a log was removed.
    @discardableResult
    func removeCompletion(
        for habit: Habit,
        on date: Date = Date(),
        in context: ModelContext
    ) throws -> Bool {
        let existing = try context.fetch(ExecutionLogQuery.forHabit(habit.id, on: date))
        guard !existing.isEmpty else { return false }
        for log in existing {
            context.delete(log)
        }
        try context.save()
        return true
    }

    /// Flips the day's completion state.
    ///
    /// - Returns: the state *after* toggling.
    @discardableResult
    func toggleCompletion(
        for habit: Habit,
        on date: Date = Date(),
        in context: ModelContext
    ) throws -> Bool {
        if try isComplete(habit, on: date, in: context) {
            try removeCompletion(for: habit, on: date, in: context)
            return false
        }
        try logCompletion(for: habit, on: date, in: context)
        return true
    }

    /// Creates a habit, guaranteeing the goal anchor.
    ///
    /// `Habit.goal` is optional at storage only because CloudKit rejects
    /// non-optional relationships — the product rule is that every habit links
    /// to a goal. This is the boundary that enforces it: an explicit goal wins,
    /// otherwise the seeded goal for the habit's own domain is used.
    ///
    /// - Throws: `HabitCreationError.noGoalAvailable` when the store has no
    ///   goal for the domain, which means seeding did not run.
    @discardableResult
    func createHabit(
        title: String,
        domain: DimensionDomain,
        frequency: HabitFrequency = .daily,
        goal: LifeGoal? = nil,
        in context: ModelContext
    ) throws -> Habit {
        let anchor: LifeGoal
        if let goal {
            anchor = goal
        } else {
            let candidates = try context.fetch(LifeGoalQuery.active())
            guard let fallback = candidates.first(where: { $0.domain == domain }) else {
                throw HabitCreationError.noGoalAvailable(domain: domain)
            }
            anchor = fallback
        }

        let habit = Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            domain: domain,
            frequency: frequency,
            goal: anchor
        )
        context.insert(habit)
        try context.save()
        return habit
    }
}

enum HabitCreationError: Error, Equatable {
    /// No goal exists for the domain, so the goal-anchor rule cannot hold.
    case noGoalAvailable(domain: DimensionDomain)
}

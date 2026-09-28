//
//  HabitExecutionLog.swift
//  tao-24
//

import Foundation
import SwiftData

/// One completion of a habit.
///
/// Carries two columns that look redundant and are not. `habitID` duplicates
/// `habit.id` because `#Index` cannot traverse a relationship — without a
/// stored column there is no compound index on the checklist's hot path. And
/// `completedDayStart` duplicates `completedAt` normalised to midnight,
/// because `Calendar` calls are not expressible in a `#Predicate`: asking
/// "was this completed today?" has to be an equality test against a stored
/// value, not a date computation.
@Model
final class HabitExecutionLog {

    /// Carries the Starter Hub's hot path: "what did this habit do today?"
    /// Both columns exist specifically to make this declarable — see the type
    /// documentation above.
    #Index<HabitExecutionLog>([\.habitID, \.completedDayStart])

    @Attribute(.unique) var id: UUID

    /// The precise moment, for display and ordering.
    var completedAt: Date

    /// `completedAt` normalised to the start of its day. Indexed with
    /// `habitID`; this is what day-scoped queries compare against.
    var completedDayStart: Date

    /// Denormalised copy of `habit.id`, so the compound index has a column to
    /// sort on. Set at init and never mutated — a log does not move between
    /// habits.
    var habitID: UUID

    /// Inverse is declared on `Habit.executionLogs`.
    var habit: Habit?

    init(
        habit: Habit,
        completedAt: Date = Date(),
        calendar: Calendar = .current
    ) {
        self.id = UUID()
        self.completedAt = completedAt
        self.completedDayStart = calendar.startOfDay(for: completedAt)
        self.habitID = habit.id
        self.habit = habit
    }
}

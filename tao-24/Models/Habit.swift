//
//  Habit.swift
//  tao-24
//

import Foundation
import SwiftData

/// A recurring action the user is trying to establish, anchored to a goal.
///
/// Storage follows one rule throughout: anything a `#Predicate` or an index
/// needs to reach is a plain stored column, with richer types exposed as
/// computed façades over it. SwiftData cannot query into an encoded enum, so
/// `domain` and `frequency` are decomposed rather than stored directly.
@Model
final class Habit {

    /// Stable identity across devices.
    ///
    /// `.unique` is a local-store constraint that CloudKit mirroring does not
    /// support — enabling sync later means dropping it and de-duplicating in a
    /// Service instead. Fine while the app is local-only; recorded so it is
    /// not discovered during the sync work.
    @Attribute(.unique) var id: UUID

    var title: String

    /// Backing column for `domain`. Indexed with `isArchived`.
    var domainRawValue: String

    /// Backing columns for `frequency`. See `HabitFrequency`.
    var frequencyKindRawValue: String
    var weeklyTargetCount: Int
    var customWeekdayMask: Int

    var createdAt: Date

    /// Archived habits stay in the store so their history survives. Nothing is
    /// ever deleted to punish a lapse.
    var isArchived: Bool

    @Relationship(deleteRule: .cascade, inverse: \HabitExecutionLog.habit)
    var executionLogs: [HabitExecutionLog] = []

    /// The long-term objective this habit serves.
    ///
    /// The product rule is that every habit links to a goal, but this is
    /// optional at storage because CloudKit rejects non-optional
    /// relationships. Non-nil is enforced at the Service boundary instead,
    /// and quick-add always has a seeded per-domain goal to fall back on.
    var goal: LifeGoal?

    /// Which Dimension of Joy this belongs to.
    var domain: DimensionDomain {
        get { DimensionDomain(rawValue: domainRawValue) ?? .health }
        set { domainRawValue = newValue.rawValue }
    }

    /// How often the habit is meant to happen.
    var frequency: HabitFrequency {
        get {
            HabitFrequency(
                kindRawValue: frequencyKindRawValue,
                weeklyTargetCount: weeklyTargetCount,
                customWeekdayMask: customWeekdayMask
            )
        }
        set {
            frequencyKindRawValue = newValue.kind.rawValue
            weeklyTargetCount = newValue.weeklyTargetCount
            customWeekdayMask = newValue.customWeekdayMask
        }
    }

    init(
        title: String,
        domain: DimensionDomain,
        frequency: HabitFrequency = .daily,
        goal: LifeGoal? = nil,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.domainRawValue = domain.rawValue
        self.frequencyKindRawValue = frequency.kind.rawValue
        self.weeklyTargetCount = frequency.weeklyTargetCount
        self.customWeekdayMask = frequency.customWeekdayMask
        self.goal = goal
        self.createdAt = createdAt
        self.isArchived = false
    }
}

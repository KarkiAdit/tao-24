//
//  HabitFrequency.swift
//  tao-24
//

import Foundation

/// A set of weekdays, stored as a bitmask.
///
/// `rawValue` is persisted directly on `Habit`, so the bit positions are part
/// of the schema — append new cases, never renumber existing ones.
struct Weekday: OptionSet, Codable, Hashable, Sendable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let sunday = Weekday(rawValue: 1 << 0)
    static let monday = Weekday(rawValue: 1 << 1)
    static let tuesday = Weekday(rawValue: 1 << 2)
    static let wednesday = Weekday(rawValue: 1 << 3)
    static let thursday = Weekday(rawValue: 1 << 4)
    static let friday = Weekday(rawValue: 1 << 5)
    static let saturday = Weekday(rawValue: 1 << 6)

    static let everyDay: Weekday = [
        .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday,
    ]
    static let weekdays: Weekday = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekends: Weekday = [.saturday, .sunday]

    /// Builds from `Calendar`'s 1-based weekday, where 1 is Sunday.
    ///
    /// Returns an empty set for anything outside 1...7 rather than trapping —
    /// this sits on a read path that renders a checklist, and a malformed
    /// value should show nothing due rather than crash the screen.
    init(calendarWeekday: Int) {
        guard (1...7).contains(calendarWeekday) else {
            self = []
            return
        }
        self = Weekday(rawValue: 1 << (calendarWeekday - 1))
    }

    /// How many days this set covers. The denominator for a weekly target.
    var count: Int { rawValue.nonzeroBitCount }
}

/// How often a habit is meant to happen.
///
/// Replaces the `targetFrequency: String` in the architecture doc, which could
/// not answer the only question the daily checklist actually asks — *is this
/// due today?* — because "Custom" carried no payload. It also gives the
/// consistency rate a numeric denominator instead of a string to parse.
///
/// Persisted decomposed into three stored columns on `Habit` rather than as a
/// single `Codable` value: SwiftData stores an encoded enum as an opaque blob,
/// which cannot appear in a `#Predicate` or be indexed.
enum HabitFrequency: Equatable, Hashable, Sendable {

    /// Every day.
    case daily

    /// A target number of days per week, with no fixed schedule.
    case timesPerWeek(Int)

    /// Only on the given weekdays.
    case specificDays(Weekday)

    /// Expected completions in a week. The denominator for a consistency rate.
    var expectedCompletionsPerWeek: Int {
        switch self {
        case .daily: 7
        case .timesPerWeek(let count): max(1, min(7, count))
        case .specificDays(let days): max(1, days.count)
        }
    }

    /// Whether the habit is scheduled for the given date.
    ///
    /// A `timesPerWeek` habit is due every day, since any day can count toward
    /// the target — progress against that target is a separate question.
    func isDue(on date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .daily, .timesPerWeek:
            true
        case .specificDays(let days):
            days.contains(Weekday(calendarWeekday: calendar.component(.weekday, from: date)))
        }
    }
}

// MARK: - Storage decomposition

extension HabitFrequency {

    /// Discriminator persisted in `Habit.frequencyKindRawValue`.
    ///
    /// Raw values are schema. Renaming one is a data migration.
    enum Kind: String, Codable, CaseIterable, Sendable {
        case daily = "Daily"
        case timesPerWeek = "TimesPerWeek"
        case specificDays = "SpecificDays"
    }

    var kind: Kind {
        switch self {
        case .daily: .daily
        case .timesPerWeek: .timesPerWeek
        case .specificDays: .specificDays
        }
    }

    /// Target count column. Meaningful only for `.timesPerWeek`.
    var weeklyTargetCount: Int {
        switch self {
        case .timesPerWeek(let count): count
        default: 0
        }
    }

    /// Weekday bitmask column. Meaningful only for `.specificDays`.
    var customWeekdayMask: Int {
        switch self {
        case .specificDays(let days): days.rawValue
        default: 0
        }
    }

    /// Rebuilds from the three stored columns.
    ///
    /// Falls back to `.daily` on an unrecognised discriminator so that a row
    /// written by a future schema version degrades to a sane default instead
    /// of failing to load.
    init(kindRawValue: String, weeklyTargetCount: Int, customWeekdayMask: Int) {
        switch Kind(rawValue: kindRawValue) {
        case .timesPerWeek:
            self = .timesPerWeek(weeklyTargetCount)
        case .specificDays:
            self = .specificDays(Weekday(rawValue: customWeekdayMask))
        case .daily, nil:
            self = .daily
        }
    }
}

//
//  ProgressService.swift
//  tao-24
//

import Foundation
import SwiftData

/// Turns execution logs into the trend figures the Progress Hub shows.
///
/// This is the replacement for the streak API the architecture doc proposed.
/// Nothing here can reach zero because of one missed day: a trend over a
/// window absorbs a miss, which is precisely why the product asks for it
/// instead of a chain.
final class ProgressService {

    static let shared = ProgressService()

    init() {}

    /// Completion per day across the window, oldest first.
    ///
    /// The denominator is per-day and historical: a habit counts on a given
    /// day only if it was due that day and already existed. Counting today's
    /// habits against last month would make every new habit retroactively
    /// ruin the chart.
    func dailyCompletions(
        from startDate: Date,
        to endDate: Date,
        in context: ModelContext,
        calendar: Calendar = .current
    ) throws -> [DailyCompletion] {
        let habits = try context.fetch(HabitQuery.active())
        let logs = try context.fetch(
            ExecutionLogQuery.inRange(from: startDate, to: endDate, calendar: calendar)
        )

        var completionsByDay: [Date: Set<UUID>] = [:]
        for log in logs {
            completionsByDay[log.completedDayStart, default: []].insert(log.habitID)
        }

        return eachDay(from: startDate, to: endDate, calendar: calendar).map { day in
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let scheduled = habits.filter { habit in
                habit.createdAt < dayEnd && habit.frequency.isDue(on: day, calendar: calendar)
            }
            let scheduledIDs = Set(scheduled.map(\.id))
            let done = completionsByDay[day, default: []].intersection(scheduledIDs)

            return DailyCompletion(day: day, completed: done.count, scheduled: scheduled.count)
        }
    }

    /// Share of completions per dimension over the window.
    ///
    /// This is literally "where the effort went", which is what the balance
    /// wheel claims to show. Worth knowing the limitation: a dimension holding
    /// more scheduled habits will read larger even when every dimension is
    /// kept up perfectly. The wheel reports distribution; it does not grade
    /// it, and the insight copy is written accordingly.
    func domainEffort(
        from startDate: Date,
        to endDate: Date,
        in context: ModelContext,
        calendar: Calendar = .current
    ) throws -> [DomainEffort] {
        let logs = try context.fetch(
            ExecutionLogQuery.inRange(from: startDate, to: endDate, calendar: calendar)
        )

        var counts: [DimensionDomain: Int] = [:]
        for log in logs {
            guard let domain = log.habit?.domain else { continue }
            counts[domain, default: 0] += 1
        }

        let total = counts.values.reduce(0, +)
        return DimensionDomain.allCases.map { domain in
            let count = counts[domain] ?? 0
            return DomainEffort(
                domain: domain,
                completions: count,
                share: total > 0 ? Double(count) / Double(total) : 0
            )
        }
    }

    /// Reads the distribution in words.
    ///
    /// "Balanced" is generous on purpose — within 15 points of an even third
    /// counts. A wheel that only says "balanced" at exact thirds would call
    /// almost every real week unbalanced, which turns an observation into
    /// nagging.
    func insight(for effort: [DomainEffort]) -> BalanceInsight {
        let total = effort.reduce(0) { $0 + $1.completions }
        guard total > 0 else { return .noData }

        if let untouched = effort.first(where: { $0.completions == 0 }) {
            return .untouched(untouched.domain)
        }

        let evenShare = 1.0 / Double(DimensionDomain.allCases.count)
        let tolerance = 0.15
        let isBalanced = effort.allSatisfy { abs($0.share - evenShare) <= tolerance }
        if isBalanced { return .balanced }

        let leader = effort.max { $0.share < $1.share }
        return leader.map { .leaning($0.domain) } ?? .balanced
    }

    /// Completion rate for one habit over a window, 0...1.
    ///
    /// Counts only the days it was actually due, so a three-times-a-week habit
    /// is not penalised for the four days it was never meant to happen.
    func consistencyRate(
        for habit: Habit,
        from startDate: Date,
        to endDate: Date,
        in context: ModelContext,
        calendar: Calendar = .current
    ) throws -> Double {
        let logs = try context.fetch(
            ExecutionLogQuery.forHabit(
                habit.id, from: startDate, to: endDate, calendar: calendar
            )
        )
        let loggedDays = Set(logs.map(\.completedDayStart))

        let dueDays = eachDay(from: startDate, to: endDate, calendar: calendar).filter { day in
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            return habit.createdAt < dayEnd && habit.frequency.isDue(on: day, calendar: calendar)
        }

        guard !dueDays.isEmpty else { return 0 }
        let hit = dueDays.filter { loggedDays.contains($0) }.count
        return Double(hit) / Double(dueDays.count)
    }

    /// Total completions in the window — the plainest possible figure.
    func totalCompletions(
        from startDate: Date,
        to endDate: Date,
        in context: ModelContext,
        calendar: Calendar = .current
    ) throws -> Int {
        try context.fetch(
            ExecutionLogQuery.inRange(from: startDate, to: endDate, calendar: calendar)
        ).count
    }

    // MARK: Helpers

    /// Every day-start from `startDate` to `endDate`, inclusive.
    private func eachDay(from startDate: Date, to endDate: Date, calendar: Calendar) -> [Date] {
        var days: [Date] = []
        var cursor = calendar.startOfDay(for: startDate)
        let last = calendar.startOfDay(for: endDate)
        while cursor <= last {
            days.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return days
    }
}

extension ProgressService {

    /// Window for a timeframe, ending today.
    func range(
        for timeframe: ProgressTimeframe,
        endingOn endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        let end = calendar.startOfDay(for: endDate)
        // days - 1 so a 7-day window is today plus the six before it, not eight.
        let start = calendar.date(byAdding: .day, value: -(timeframe.days - 1), to: end) ?? end
        return (start, end)
    }
}

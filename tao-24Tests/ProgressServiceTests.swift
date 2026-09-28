//
//  ProgressServiceTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

@MainActor
final class ProgressServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: ProgressService!
    private var execution: HabitExecutionService!

    /// Fixed calendar and "today", so the suite never depends on the day or
    /// zone it runs in. 2026-01-07 is a Wednesday in GMT.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()
    private static let today: Date = {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 7)) ?? .distantPast
    }()

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
        try DatabaseService.seedIfNeeded(in: context)
        service = ProgressService()
        execution = HabitExecutionService()
    }

    override func tearDownWithError() throws {
        service = nil
        execution = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    // MARK: Window arithmetic

    func testSevenDayWindowIsTodayPlusSixNotEight() {
        let range = service.range(for: .week, endingOn: Self.today, calendar: Self.calendar)
        let days = Self.calendar.dateComponents(
            [.day], from: range.start, to: range.end
        ).day
        XCTAssertEqual(days, 6, "inclusive of both ends makes seven days")
    }

    func testEachTimeframeProducesItsOwnLength() throws {
        for timeframe in ProgressTimeframe.allCases {
            let range = service.range(
                for: timeframe, endingOn: Self.today, calendar: Self.calendar
            )
            let rows = try service.dailyCompletions(
                from: range.start, to: range.end, in: context, calendar: Self.calendar
            )
            XCTAssertEqual(rows.count, timeframe.days, "\(timeframe.label)")
        }
    }

    // MARK: Daily completion

    func testADayWithNothingScheduledIsNotAMiss() throws {
        // No habits at all: every day must report hasSchedule == false, so the
        // chart can distinguish a rest day from a failure.
        let range = service.range(for: .week, endingOn: Self.today, calendar: Self.calendar)
        let rows = try service.dailyCompletions(
            from: range.start, to: range.end, in: context, calendar: Self.calendar
        )
        XCTAssertTrue(rows.allSatisfy { !$0.hasSchedule })
        XCTAssertTrue(rows.allSatisfy { $0.ratio == 0 })
    }

    func testCompletingEverythingScheduledGivesAFullDay() throws {
        let habit = try makeHabit(createdDaysAgo: 10)
        try execution.logCompletion(
            for: habit, on: Self.today, in: context, calendar: Self.calendar
        )

        let rows = try dailyRows(.week)
        let today = try XCTUnwrap(rows.last)

        XCTAssertEqual(today.scheduled, 1)
        XCTAssertEqual(today.completed, 1)
        XCTAssertEqual(today.ratio, 1.0)
    }

    func testAHabitDoesNotCountBeforeItExisted() throws {
        // Created two days ago; the days before that had nothing scheduled.
        _ = try makeHabit(createdDaysAgo: 2)

        let rows = try dailyRows(.week)

        XCTAssertTrue(
            rows.prefix(4).allSatisfy { !$0.hasSchedule },
            "adding a habit must not retroactively wreck earlier days"
        )
        XCTAssertTrue(rows.suffix(3).allSatisfy(\.hasSchedule))
    }

    func testAHabitOnlyCountsOnDaysItIsDue() throws {
        // Mondays only, over a window containing exactly one Monday.
        _ = try makeHabit(
            createdDaysAgo: 30,
            frequency: .specificDays([.monday])
        )

        let rows = try dailyRows(.week)
        let scheduledDays = rows.filter(\.hasSchedule)

        XCTAssertEqual(scheduledDays.count, 1, "one Monday in a seven-day window")
    }

    func testPartialCompletionIsAFraction() throws {
        _ = try makeHabit(createdDaysAgo: 10, domain: .health)
        let career = try makeHabit(createdDaysAgo: 10, domain: .career, title: "Deep work")
        try execution.logCompletion(
            for: career, on: Self.today, in: context, calendar: Self.calendar)

        let today = try XCTUnwrap(try dailyRows(.week).last)

        XCTAssertEqual(today.scheduled, 2)
        XCTAssertEqual(today.completed, 1)
        XCTAssertEqual(today.ratio, 0.5, accuracy: 0.0001)
    }

    func testOneMissedDayDoesNotZeroTheWindow() throws {
        // The whole reason this replaces a streak: a gap costs one day, not
        // everything before it.
        let habit = try makeHabit(createdDaysAgo: 10)
        for offset in [6, 5, 4, 3, 1, 0] {
            try execution.logCompletion(
                for: habit, on: daysAgo(offset), in: context, calendar: Self.calendar)
        }

        let rows = try dailyRows(.week)
        let hit = rows.filter { $0.ratio == 1.0 }.count

        XCTAssertEqual(hit, 6, "six of seven days stand despite the gap")
    }

    // MARK: Domain effort

    func testEffortSharesSumToOne() throws {
        try logAcrossDomains(health: 2, career: 1, fun: 1)

        let effort = try domainEffort(.week)
        let total = effort.reduce(0) { $0 + $1.share }

        XCTAssertEqual(total, 1.0, accuracy: 0.0001)
    }

    func testEffortIsAttributedToTheRightDimension() throws {
        try logAcrossDomains(health: 3, career: 1, fun: 0)

        let effort = try domainEffort(.week)

        XCTAssertEqual(effort.first { $0.domain == .health }?.completions, 3)
        XCTAssertEqual(effort.first { $0.domain == .career }?.completions, 1)
        XCTAssertEqual(effort.first { $0.domain == .fun }?.completions, 0)
    }

    func testEveryDimensionAppearsEvenAtZero() throws {
        let effort = try domainEffort(.week)
        XCTAssertEqual(effort.count, DimensionDomain.allCases.count)
        XCTAssertTrue(effort.allSatisfy { $0.share == 0 })
    }

    // MARK: Insight copy

    func testNoDataInsightWhenNothingIsLogged() throws {
        XCTAssertEqual(service.insight(for: try domainEffort(.week)), .noData)
    }

    func testEvenEffortReadsAsBalanced() throws {
        try logAcrossDomains(health: 2, career: 2, fun: 2)
        XCTAssertEqual(service.insight(for: try domainEffort(.week)), .balanced)
    }

    func testAnUntouchedDimensionIsNamedGently() throws {
        try logAcrossDomains(health: 3, career: 2, fun: 0)

        let insight = service.insight(for: try domainEffort(.week))

        XCTAssertEqual(insight, .untouched(.fun))
        XCTAssertFalse(
            insight.message.lowercased().contains("fail"),
            "insight copy must never scold"
        )
    }

    func testAClearLeanIsReported() throws {
        try logAcrossDomains(health: 8, career: 1, fun: 1)
        XCTAssertEqual(service.insight(for: try domainEffort(.week)), .leaning(.health))
    }

    func testNearlyEvenStillCountsAsBalanced() throws {
        // Tolerance exists so a normal week is not called unbalanced.
        try logAcrossDomains(health: 4, career: 3, fun: 3)
        XCTAssertEqual(service.insight(for: try domainEffort(.week)), .balanced)
    }

    func testADimensionAtHalfTheOthersIsNotCalledBalanced() throws {
        // Regression: 40/40/20 was reported as balanced while the wheel drew a
        // visible lean, so the badge contradicted the chart beside it.
        try logAcrossDomains(health: 6, career: 6, fun: 3)

        let insight = service.insight(for: try domainEffort(.week))

        XCTAssertNotEqual(insight, .balanced)
        if case .leaning = insight {
        } else {
            XCTFail("expected a lean, got \(insight)")
        }
    }

    // MARK: Consistency rate

    func testConsistencyCountsOnlyDueDays() throws {
        // Twice a week, done on both its due days: 100%, not 2/7.
        let habit = try makeHabit(
            createdDaysAgo: 30,
            frequency: .specificDays([.monday, .tuesday])
        )
        let range = service.range(for: .week, endingOn: Self.today, calendar: Self.calendar)
        for offset in 0..<7 {
            let day = daysAgo(offset)
            if habit.frequency.isDue(on: day, calendar: Self.calendar) {
                try execution.logCompletion(
                    for: habit, on: day, in: context, calendar: Self.calendar)
            }
        }

        let rate = try service.consistencyRate(
            for: habit, from: range.start, to: range.end,
            in: context, calendar: Self.calendar
        )

        XCTAssertEqual(rate, 1.0, accuracy: 0.0001)
    }

    func testConsistencyIsAFractionNotAChain() throws {
        let habit = try makeHabit(createdDaysAgo: 30)
        let range = service.range(for: .week, endingOn: Self.today, calendar: Self.calendar)
        for offset in [6, 5, 3, 2, 0] {
            try execution.logCompletion(
                for: habit, on: daysAgo(offset), in: context, calendar: Self.calendar)
        }

        let rate = try service.consistencyRate(
            for: habit, from: range.start, to: range.end,
            in: context, calendar: Self.calendar
        )

        XCTAssertEqual(rate, 5.0 / 7.0, accuracy: 0.0001, "gaps reduce, they do not reset")
    }

    // MARK: Helpers

    private func daysAgo(_ offset: Int) -> Date {
        Self.calendar.date(byAdding: .day, value: -offset, to: Self.today) ?? Self.today
    }

    private func makeHabit(
        createdDaysAgo: Int,
        domain: DimensionDomain = .health,
        frequency: HabitFrequency = .daily,
        title: String = "Test habit"
    ) throws -> Habit {
        let goal = try context.fetch(LifeGoalQuery.active()).first { $0.domain == domain }
        let habit = Habit(
            title: title,
            domain: domain,
            frequency: frequency,
            goal: goal,
            createdAt: daysAgo(createdDaysAgo)
        )
        context.insert(habit)
        try context.save()
        return habit
    }

    private func dailyRows(_ timeframe: ProgressTimeframe) throws -> [DailyCompletion] {
        let range = service.range(for: timeframe, endingOn: Self.today, calendar: Self.calendar)
        return try service.dailyCompletions(
            from: range.start, to: range.end, in: context, calendar: Self.calendar
        )
    }

    private func domainEffort(_ timeframe: ProgressTimeframe) throws -> [DomainEffort] {
        let range = service.range(for: timeframe, endingOn: Self.today, calendar: Self.calendar)
        return try service.domainEffort(
            from: range.start, to: range.end, in: context, calendar: Self.calendar
        )
    }

    private func logAcrossDomains(health: Int, career: Int, fun: Int) throws {
        for (domain, count) in [
            (DimensionDomain.health, health), (.career, career), (.fun, fun),
        ] where count > 0 {
            let habit = try makeHabit(
                createdDaysAgo: 30, domain: domain, title: "\(domain.label) habit"
            )
            for offset in 0..<count {
                try execution.logCompletion(
                    for: habit, on: daysAgo(offset), in: context, calendar: Self.calendar)
            }
        }
    }
}

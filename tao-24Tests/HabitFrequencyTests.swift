//
//  HabitFrequencyTests.swift
//  tao-24Tests
//

import Foundation
import XCTest

@testable import tao_24

final class HabitFrequencyTests: XCTestCase {

    // MARK: Storage round-trip
    // The three columns are the persisted form. If a round-trip loses
    // information, saved habits silently change meaning.

    func testRoundTripPreservesEveryCase() {
        let cases: [HabitFrequency] = [
            .daily,
            .timesPerWeek(3),
            .specificDays([.monday, .wednesday, .friday]),
            .specificDays(.everyDay),
        ]
        for frequency in cases {
            let restored = HabitFrequency(
                kindRawValue: frequency.kind.rawValue,
                weeklyTargetCount: frequency.weeklyTargetCount,
                customWeekdayMask: frequency.customWeekdayMask
            )
            XCTAssertEqual(restored, frequency, "round-trip changed \(frequency)")
        }
    }

    func testUnknownDiscriminatorFallsBackToDailyRatherThanFailing() {
        let restored = HabitFrequency(
            kindRawValue: "SomethingAFutureVersionWrote",
            weeklyTargetCount: 4,
            customWeekdayMask: 0
        )
        XCTAssertEqual(restored, .daily)
    }

    // MARK: Expected completions
    // This is the denominator of the consistency rate, so a wrong value
    // silently skews every percentage in the Progress Hub.

    func testExpectedCompletionsPerWeek() {
        XCTAssertEqual(HabitFrequency.daily.expectedCompletionsPerWeek, 7)
        XCTAssertEqual(HabitFrequency.timesPerWeek(3).expectedCompletionsPerWeek, 3)
        XCTAssertEqual(
            HabitFrequency.specificDays([.monday, .wednesday, .friday])
                .expectedCompletionsPerWeek,
            3
        )
    }

    func testExpectedCompletionsIsClampedToARealWeek() {
        // Never zero — it is a denominator.
        XCTAssertEqual(HabitFrequency.timesPerWeek(0).expectedCompletionsPerWeek, 1)
        XCTAssertEqual(HabitFrequency.specificDays([]).expectedCompletionsPerWeek, 1)
        // Never more than seven days in a week.
        XCTAssertEqual(HabitFrequency.timesPerWeek(99).expectedCompletionsPerWeek, 7)
    }

    // MARK: Due-today
    // The question the daily checklist asks, and the reason this is a type
    // rather than the String the architecture doc specified.

    func testDailyIsDueEveryDay() throws {
        let calendar = Self.calendar
        for offset in 0..<7 {
            let date = try XCTUnwrap(
                calendar.date(byAdding: .day, value: offset, to: Self.knownMonday)
            )
            XCTAssertTrue(HabitFrequency.daily.isDue(on: date, calendar: calendar))
        }
    }

    func testTimesPerWeekIsDueEveryDay() throws {
        // Any day can count toward the target, so the habit is always offered;
        // progress against the target is a separate question.
        let calendar = Self.calendar
        for offset in 0..<7 {
            let date = try XCTUnwrap(
                calendar.date(byAdding: .day, value: offset, to: Self.knownMonday)
            )
            XCTAssertTrue(HabitFrequency.timesPerWeek(2).isDue(on: date, calendar: calendar))
        }
    }

    func testSpecificDaysIsDueOnlyOnThoseDays() throws {
        let calendar = Self.calendar
        let frequency = HabitFrequency.specificDays([.monday, .friday])
        let expected = [true, false, false, false, true, false, false]

        for (offset, shouldBeDue) in expected.enumerated() {
            let date = try XCTUnwrap(
                calendar.date(byAdding: .day, value: offset, to: Self.knownMonday)
            )
            XCTAssertEqual(
                frequency.isDue(on: date, calendar: calendar),
                shouldBeDue,
                "wrong for day offset \(offset)"
            )
        }
    }

    // MARK: Weekday bitmask

    func testCalendarWeekdayMapping() {
        // Calendar is 1-based with Sunday == 1.
        XCTAssertEqual(Weekday(calendarWeekday: 1), .sunday)
        XCTAssertEqual(Weekday(calendarWeekday: 2), .monday)
        XCTAssertEqual(Weekday(calendarWeekday: 7), .saturday)
    }

    func testOutOfRangeWeekdayIsEmptyRatherThanTrapping() {
        // Sits on the checklist read path — a malformed value should render
        // nothing due, not crash the screen.
        XCTAssertEqual(Weekday(calendarWeekday: 0), [])
        XCTAssertEqual(Weekday(calendarWeekday: 8), [])
        XCTAssertEqual(Weekday(calendarWeekday: -1), [])
    }

    func testConvenienceSetsCoverTheRightDays() {
        XCTAssertEqual(Weekday.everyDay.count, 7)
        XCTAssertEqual(Weekday.weekdays.count, 5)
        XCTAssertEqual(Weekday.weekends.count, 2)
        XCTAssertTrue(Weekday.weekends.contains(.saturday))
        XCTAssertFalse(Weekday.weekdays.contains(.sunday))
    }

    /// A gregorian calendar pinned to GMT.
    ///
    /// Both the fixture and the assertions use this one. An earlier version
    /// built the date in GMT and evaluated it in the machine's local zone,
    /// which shifted every weekday by one — midnight Monday GMT is Sunday
    /// afternoon in the Americas. Weekday is timezone-dependent, so a date
    /// fixture and the calendar reading it have to agree.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    /// 2026-01-05 is a Monday in GMT. Fixed so the suite never depends on the
    /// day it happens to run.
    private static let knownMonday: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 5
        return calendar.date(from: components) ?? .distantPast
    }()
}

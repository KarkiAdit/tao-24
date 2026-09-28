//
//  DatabaseServiceTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

/// Exercises the store for real: a live `ModelContainer`, real inserts, and
/// the actual predicates. The build proves these expressions compile; only
/// running them proves they return the right rows.
@MainActor
final class DatabaseServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    // MARK: Container

    func testSchemaV1ContainerBuilds() {
        // Covers every @Model and both #Index declarations: SwiftData
        // validates the schema when the container is constructed.
        XCTAssertNotNil(container)
    }

    // MARK: Seeding

    func testSeedingAnEmptyStoreCreatesOneGoalPerDomainAndOneProfile() throws {
        let inserted = try DatabaseService.seedIfNeeded(in: context)
        XCTAssertEqual(inserted, DimensionDomain.allCases.count + 1)

        let goals = try context.fetch(FetchDescriptor<LifeGoal>())
        XCTAssertEqual(Set(goals.map(\.domain)), Set(DimensionDomain.allCases))

        let profiles = try context.fetch(FetchDescriptor<UserValueProfile>())
        XCTAssertEqual(profiles.count, 1)
    }

    func testSeedingIsIdempotent() throws {
        try DatabaseService.seedIfNeeded(in: context)
        let second = try DatabaseService.seedIfNeeded(in: context)

        XCTAssertEqual(second, 0, "a second seed should insert nothing")
        XCTAssertEqual(try context.fetch(FetchDescriptor<LifeGoal>()).count, 3)
        XCTAssertEqual(try context.fetch(FetchDescriptor<UserValueProfile>()).count, 1)
    }

    func testSeedingRepairsAPartiallySeededStore() throws {
        // Simulates a crash after one goal was written: the next launch must
        // fill the gap rather than skip seeding because the store is non-empty.
        context.insert(LifeGoal(title: "Only one", domain: .health))
        try context.save()

        let inserted = try DatabaseService.seedIfNeeded(in: context)

        XCTAssertEqual(inserted, 3, "two missing goals plus the profile")
        XCTAssertEqual(try context.fetch(FetchDescriptor<LifeGoal>()).count, 3)
        XCTAssertEqual(try context.fetch(FetchDescriptor<UserValueProfile>()).count, 1)
    }

    func testSeedingNeverCreatesASecondProfile() throws {
        try DatabaseService.seedIfNeeded(in: context)
        try DatabaseService.seedIfNeeded(in: context)
        try DatabaseService.seedIfNeeded(in: context)

        let profiles = try context.fetch(UserValueProfileQuery.singleton())
        XCTAssertEqual(profiles.count, 1)
    }

    // MARK: Persistence round-trip

    func testHabitRoundTripsThroughTheStore() throws {
        let goal = LifeGoal(title: "Master system design", domain: .career)
        let habit = Habit(
            title: "45-min deep work block",
            domain: .career,
            frequency: .specificDays([.monday, .wednesday, .friday]),
            goal: goal
        )
        context.insert(goal)
        context.insert(habit)
        try context.save()

        let fetched = try XCTUnwrap(try context.fetch(FetchDescriptor<Habit>()).first)
        XCTAssertEqual(fetched.title, "45-min deep work block")
        XCTAssertEqual(fetched.domain, .career)
        XCTAssertEqual(fetched.frequency, .specificDays([.monday, .wednesday, .friday]))
        XCTAssertEqual(fetched.goal?.title, "Master system design")
        XCTAssertFalse(fetched.isArchived)
    }

    func testDeletingAHabitCascadesToItsLogs() throws {
        let habit = Habit(title: "Run", domain: .health)
        context.insert(habit)
        context.insert(HabitExecutionLog(habit: habit))
        try context.save()
        XCTAssertEqual(try context.fetch(FetchDescriptor<HabitExecutionLog>()).count, 1)

        context.delete(habit)
        try context.save()

        XCTAssertEqual(
            try context.fetch(FetchDescriptor<HabitExecutionLog>()).count,
            0,
            "logs should not outlive their habit"
        )
    }

    func testDeletingAGoalKeepsItsHabits() throws {
        // A goal changing must never erase the history underneath it.
        let goal = LifeGoal(title: "Temporary", domain: .fun)
        let habit = Habit(title: "Read", domain: .fun, goal: goal)
        context.insert(goal)
        context.insert(habit)
        try context.save()

        context.delete(goal)
        try context.save()

        let habits = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(habits.count, 1, "the habit should survive")
        XCTAssertNil(habits.first?.goal)
    }

    // MARK: Query descriptors
    // These run the real predicates. Compiling only proved them expressible.

    func testActiveHabitsExcludeArchivedOnes() throws {
        let kept = Habit(title: "Kept", domain: .health)
        let archived = Habit(title: "Archived", domain: .health)
        archived.isArchived = true
        context.insert(kept)
        context.insert(archived)
        try context.save()

        let active = try context.fetch(HabitQuery.active())
        XCTAssertEqual(active.map(\.title), ["Kept"])

        let archivedResults = try context.fetch(HabitQuery.archived())
        XCTAssertEqual(archivedResults.map(\.title), ["Archived"])
    }

    func testActiveHabitsFilterByDomain() throws {
        context.insert(Habit(title: "Run", domain: .health))
        context.insert(Habit(title: "Deep work", domain: .career))
        context.insert(Habit(title: "Read", domain: .fun))
        try context.save()

        let career = try context.fetch(HabitQuery.active(in: .career))
        XCTAssertEqual(career.map(\.title), ["Deep work"])
    }

    func testLogsOnDayFindTodayAndNotYesterday() throws {
        let habit = Habit(title: "Run", domain: .health)
        context.insert(habit)

        let today = Date()
        let yesterday = try XCTUnwrap(
            Calendar.current.date(byAdding: .day, value: -1, to: today)
        )
        context.insert(HabitExecutionLog(habit: habit, completedAt: today))
        context.insert(HabitExecutionLog(habit: habit, completedAt: yesterday))
        try context.save()

        XCTAssertEqual(try context.fetch(ExecutionLogQuery.onDay(today)).count, 1)
        XCTAssertEqual(try context.fetch(ExecutionLogQuery.onDay(yesterday)).count, 1)
    }

    func testForHabitOnDayIsTheExistenceCheckCompletionValidationNeeds() throws {
        let logged = Habit(title: "Logged", domain: .health)
        let unlogged = Habit(title: "Unlogged", domain: .health)
        context.insert(logged)
        context.insert(unlogged)
        context.insert(HabitExecutionLog(habit: logged))
        try context.save()

        let found = try context.fetch(ExecutionLogQuery.forHabit(logged.id, on: Date()))
        XCTAssertEqual(found.count, 1)

        let missing = try context.fetch(ExecutionLogQuery.forHabit(unlogged.id, on: Date()))
        XCTAssertTrue(missing.isEmpty)
    }

    func testRangeQueryIsInclusiveOfBothEnds() throws {
        let habit = Habit(title: "Run", domain: .health)
        context.insert(habit)

        let calendar = Calendar.current
        let today = Date()
        for daysAgo in 0...3 {
            let date = try XCTUnwrap(calendar.date(byAdding: .day, value: -daysAgo, to: today))
            context.insert(HabitExecutionLog(habit: habit, completedAt: date))
        }
        try context.save()

        let threeDaysAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -3, to: today))
        let all = try context.fetch(
            ExecutionLogQuery.forHabit(habit.id, from: threeDaysAgo, to: today)
        )
        XCTAssertEqual(all.count, 4, "both endpoints should be included")

        let oneDayAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -1, to: today))
        let recent = try context.fetch(
            ExecutionLogQuery.forHabit(habit.id, from: oneDayAgo, to: today)
        )
        XCTAssertEqual(recent.count, 2)
    }

    func testActiveGoalsExcludeRetiredOnes() throws {
        let active = LifeGoal(title: "Active", domain: .health)
        let retired = LifeGoal(title: "Retired", domain: .health)
        retired.isActive = false
        context.insert(active)
        context.insert(retired)
        try context.save()

        let results = try context.fetch(LifeGoalQuery.active())
        XCTAssertEqual(results.map(\.title), ["Active"])
    }
}

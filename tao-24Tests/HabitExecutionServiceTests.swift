//
//  HabitExecutionServiceTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

@MainActor
final class HabitExecutionServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: HabitExecutionService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
        service = HabitExecutionService()
        try DatabaseService.seedIfNeeded(in: context)
    }

    override func tearDownWithError() throws {
        service = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    // MARK: Completion

    func testLoggingCompletionMarksTheHabitComplete() throws {
        let habit = try makeHabit()
        XCTAssertFalse(try service.isComplete(habit, in: context))

        let inserted = try service.logCompletion(for: habit, in: context)

        XCTAssertTrue(inserted)
        XCTAssertTrue(try service.isComplete(habit, in: context))
    }

    func testLoggingTwiceInADayDoesNotDuplicate() throws {
        let habit = try makeHabit()
        XCTAssertTrue(try service.logCompletion(for: habit, in: context))
        XCTAssertFalse(try service.logCompletion(for: habit, in: context))

        let logs = try context.fetch(ExecutionLogQuery.forHabit(habit.id, on: Date()))
        XCTAssertEqual(logs.count, 1)
    }

    func testCompletionIsScopedToItsOwnDay() throws {
        let habit = try makeHabit()
        let yesterday = try XCTUnwrap(
            Calendar.current.date(byAdding: .day, value: -1, to: Date())
        )
        try service.logCompletion(for: habit, on: yesterday, in: context)

        XCTAssertTrue(try service.isComplete(habit, on: yesterday, in: context))
        XCTAssertFalse(
            try service.isComplete(habit, on: Date(), in: context),
            "yesterday's completion must not mark today complete"
        )
    }

    func testCompletionIsScopedToItsOwnHabit() throws {
        let logged = try makeHabit(title: "Logged")
        let other = try makeHabit(title: "Other")
        try service.logCompletion(for: logged, in: context)

        XCTAssertTrue(try service.isComplete(logged, in: context))
        XCTAssertFalse(try service.isComplete(other, in: context))
    }

    // MARK: Undo
    // Un-completing must be exactly as available as completing — a mis-tap
    // costs one tap to correct, and nothing is punished.

    func testRemovingCompletionUndoesIt() throws {
        let habit = try makeHabit()
        try service.logCompletion(for: habit, in: context)

        let removed = try service.removeCompletion(for: habit, in: context)

        XCTAssertTrue(removed)
        XCTAssertFalse(try service.isComplete(habit, in: context))
    }

    func testRemovingWhenNothingIsLoggedIsANoOp() throws {
        let habit = try makeHabit()
        XCTAssertFalse(try service.removeCompletion(for: habit, in: context))
    }

    func testTogglingReturnsTheResultingState() throws {
        let habit = try makeHabit()
        XCTAssertTrue(try service.toggleCompletion(for: habit, in: context))
        XCTAssertTrue(try service.isComplete(habit, in: context))

        XCTAssertFalse(try service.toggleCompletion(for: habit, in: context))
        XCTAssertFalse(try service.isComplete(habit, in: context))
    }

    func testTogglingRepeatedlyLeavesNoOrphanLogs() throws {
        let habit = try makeHabit()
        for _ in 0..<5 {
            try service.toggleCompletion(for: habit, in: context)
        }
        // Odd number of toggles: complete, with exactly one log.
        XCTAssertTrue(try service.isComplete(habit, in: context))
        XCTAssertEqual(try context.fetch(FetchDescriptor<HabitExecutionLog>()).count, 1)
    }

    // MARK: Creation and the goal anchor

    func testCreatedHabitFallsBackToTheSeededGoalForItsDomain() throws {
        let habit = try service.createHabit(
            title: "Deep work",
            domain: .career,
            in: context
        )

        let goal = try XCTUnwrap(habit.goal, "every habit must link to a goal")
        XCTAssertEqual(goal.domain, .career, "the anchor should match the habit's domain")
    }

    func testAnExplicitGoalWinsOverTheFallback() throws {
        let explicit = LifeGoal(title: "Ship the app", domain: .career)
        context.insert(explicit)
        try context.save()

        let habit = try service.createHabit(
            title: "Deep work",
            domain: .career,
            goal: explicit,
            in: context
        )

        XCTAssertEqual(habit.goal?.title, "Ship the app")
    }

    func testCreationFailsLoudlyWhenNoGoalExistsForTheDomain() throws {
        // An unseeded store cannot honour the goal-anchor rule. Better to
        // refuse than to silently create an unanchored habit.
        let bare = ModelContext(try DatabaseService.makeContainer(inMemory: true))

        XCTAssertThrowsError(
            try service.createHabit(title: "Orphan", domain: .fun, in: bare)
        ) { error in
            XCTAssertEqual(
                error as? HabitCreationError,
                .noGoalAvailable(domain: .fun)
            )
        }
    }

    func testCreatedHabitTitleIsTrimmed() throws {
        let habit = try service.createHabit(
            title: "  Read a chapter\n",
            domain: .fun,
            in: context
        )
        XCTAssertEqual(habit.title, "Read a chapter")
    }

    func testCreatedHabitStartsActiveAndIncomplete() throws {
        let habit = try service.createHabit(title: "Run", domain: .health, in: context)
        XCTAssertFalse(habit.isArchived)
        XCTAssertFalse(try service.isComplete(habit, in: context))
    }

    // MARK: Helpers

    private func makeHabit(
        title: String = "Test habit",
        domain: DimensionDomain = .health
    ) throws -> Habit {
        try service.createHabit(title: title, domain: domain, in: context)
    }
}

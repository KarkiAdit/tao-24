//
//  BlueprintServiceTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

@MainActor
final class BlueprintServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: BlueprintService!
    private var execution: HabitExecutionService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
        try DatabaseService.seedIfNeeded(in: context)
        execution = HabitExecutionService()
        service = BlueprintService(executionService: execution)
    }

    override func tearDownWithError() throws {
        service = nil
        execution = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    private var sample: Blueprint {
        PlannerContent.blueprints[0]
    }

    // MARK: Catalog shape
    // Balance is the product's core metaphor, so a set that skips a dimension
    // is a content bug rather than a styling one.

    func testEveryBlueprintCoversAllThreeDimensions() {
        for blueprint in PlannerContent.blueprints {
            XCTAssertEqual(
                Set(blueprint.habits.map(\.domain)),
                Set(DimensionDomain.allCases),
                "\(blueprint.title) does not span all three dimensions"
            )
        }
    }

    func testBlueprintAndResourceIdentifiersAreUnique() {
        let blueprintIDs = PlannerContent.blueprints.map(\.id)
        XCTAssertEqual(Set(blueprintIDs).count, blueprintIDs.count)

        let resourceIDs = PlannerContent.microResources.map(\.id)
        XCTAssertEqual(Set(resourceIDs).count, resourceIDs.count)
    }

    // MARK: Adoption

    func testAdoptingCreatesEveryHabitInTheSet() throws {
        let created = try service.adopt(sample, in: context)

        XCTAssertEqual(created.count, sample.habits.count)
        let titles = try context.fetch(HabitQuery.active()).map(\.title)
        for habit in sample.habits {
            XCTAssertTrue(titles.contains(habit.title), "missing \(habit.title)")
        }
    }

    func testAdoptedHabitsKeepTheirFrequency() throws {
        try service.adopt(sample, in: context)
        let habits = try context.fetch(HabitQuery.active())

        for template in sample.habits {
            let match = try XCTUnwrap(habits.first { $0.title == template.title })
            XCTAssertEqual(match.frequency, template.frequency, "\(template.title)")
        }
    }

    func testAdoptedHabitsAreAllGoalAnchored() throws {
        try service.adopt(sample, in: context)

        for habit in try context.fetch(HabitQuery.active()) {
            let goal = try XCTUnwrap(habit.goal, "\(habit.title) has no goal")
            XCTAssertEqual(goal.domain, habit.domain)
        }
    }

    func testAdoptingTwiceDoesNotDuplicate() throws {
        try service.adopt(sample, in: context)
        let second = try service.adopt(sample, in: context)

        XCTAssertTrue(second.isEmpty, "a second adoption should create nothing")
        XCTAssertEqual(try context.fetch(HabitQuery.active()).count, sample.habits.count)
    }

    func testPartialAdoptionFillsOnlyTheGaps() throws {
        // Someone already runs one of the three.
        let existing = sample.habits[0]
        _ = try execution.createHabit(
            title: existing.title,
            domain: existing.domain,
            frequency: existing.frequency,
            in: context
        )

        let created = try service.adopt(sample, in: context)

        XCTAssertEqual(created.count, sample.habits.count - 1)
        XCTAssertEqual(try context.fetch(HabitQuery.active()).count, sample.habits.count)
    }

    func testMatchingIgnoresTitleCase() throws {
        let existing = sample.habits[0]
        _ = try execution.createHabit(
            title: existing.title.uppercased(),
            domain: existing.domain,
            in: context
        )

        let created = try service.adopt(sample, in: context)

        XCTAssertEqual(created.count, sample.habits.count - 1, "case should not defeat matching")
    }

    func testSameTitleInAnotherDimensionIsNotAMatch() throws {
        let existing = sample.habits[0]
        let otherDomain = DimensionDomain.allCases.first { $0 != existing.domain }
        _ = try execution.createHabit(
            title: existing.title,
            domain: try XCTUnwrap(otherDomain),
            in: context
        )

        let created = try service.adopt(sample, in: context)

        XCTAssertEqual(created.count, sample.habits.count, "domain is part of identity")
    }

    func testArchivedHabitsDoNotBlockReadoption() throws {
        let created = try service.adopt(sample, in: context)
        for habit in created {
            habit.isArchived = true
        }
        try context.save()

        let again = try service.adopt(sample, in: context)

        XCTAssertEqual(
            again.count,
            sample.habits.count,
            "archiving should let someone pick the set back up"
        )
    }

    // MARK: State for the UI

    func testFullyAdoptedReflectsReality() throws {
        XCTAssertFalse(try service.isFullyAdopted(sample, in: context))
        try service.adopt(sample, in: context)
        XCTAssertTrue(try service.isFullyAdopted(sample, in: context))
    }

    func testActiveHabitCountIsPerDomain() throws {
        try service.adopt(sample, in: context)

        for domain in DimensionDomain.allCases {
            let expected = sample.habits.filter { $0.domain == domain }.count
            XCTAssertEqual(try service.activeHabitCount(for: domain, in: context), expected)
        }
    }
}

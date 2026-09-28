//
//  StarterHubControllerTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

@MainActor
final class StarterHubControllerTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var controller: StarterHubController!
    private var service: HabitExecutionService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
        try DatabaseService.seedIfNeeded(in: context)
        service = HabitExecutionService()
        controller = StarterHubController(executionService: service)
    }

    override func tearDownWithError() throws {
        controller = nil
        service = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    // MARK: Filtering

    func testNoFilterShowsEveryDomain() throws {
        try seedOnePerDomain()
        let visible = controller.visibleHabits(from: try allHabits())
        XCTAssertEqual(visible.count, 3)
    }

    func testFilterNarrowsToOneDomain() throws {
        try seedOnePerDomain()
        controller.selectedDomainFilter = .career

        let visible = controller.visibleHabits(from: try allHabits())

        XCTAssertEqual(visible.map(\.domain), [.career])
    }

    func testArchivedHabitsNeverAppear() throws {
        let habit = try service.createHabit(title: "Old", domain: .health, in: context)
        habit.isArchived = true
        try context.save()

        XCTAssertTrue(controller.visibleHabits(from: try allHabits()).isEmpty)
    }

    func testHabitsNotScheduledTodayAreHidden() throws {
        // Monday-only, checked on a Wednesday.
        _ = try service.createHabit(
            title: "Monday only",
            domain: .health,
            frequency: .specificDays([.monday]),
            in: context
        )
        let wednesday = try XCTUnwrap(
            Self.gmt.date(
                from: DateComponents(
                    year: 2026, month: 1, day: 7
                )))

        let visible = controller.visibleHabits(from: try allHabits(), on: wednesday)

        XCTAssertTrue(visible.isEmpty, "a Monday habit should not show on Wednesday")
    }

    func testDailyHabitsAlwaysAppear() throws {
        _ = try service.createHabit(title: "Every day", domain: .fun, in: context)
        let wednesday = try XCTUnwrap(
            Self.gmt.date(
                from: DateComponents(
                    year: 2026, month: 1, day: 7
                )))

        XCTAssertEqual(controller.visibleHabits(from: try allHabits(), on: wednesday).count, 1)
    }

    // MARK: Completion count

    func testCompletedCountTracksTheVisibleList() throws {
        try seedOnePerDomain()
        let habits = try allHabits()
        XCTAssertEqual(controller.completedCount(among: habits, in: context), 0)

        try service.logCompletion(for: try XCTUnwrap(habits.first), in: context)

        XCTAssertEqual(controller.completedCount(among: habits, in: context), 1)
    }

    func testCompletedCountRespectsTheFilter() throws {
        try seedOnePerDomain()
        let all = try allHabits()
        let career = try XCTUnwrap(all.first { $0.domain == .career })
        try service.logCompletion(for: career, in: context)

        controller.selectedDomainFilter = .health
        let visible = controller.visibleHabits(from: all)

        XCTAssertEqual(
            controller.completedCount(among: visible, in: context),
            0,
            "a completed Career habit must not count while filtered to Health"
        )
    }

    // MARK: Toggling

    func testTogglingFlipsCompletionThroughTheService() throws {
        let habit = try service.createHabit(title: "Run", domain: .health, in: context)

        controller.toggleCompletion(habit, in: context)
        XCTAssertTrue(controller.isComplete(habit, in: context))

        controller.toggleCompletion(habit, in: context)
        XCTAssertFalse(controller.isComplete(habit, in: context))
    }

    // MARK: Quick-add draft

    func testPresentingQuickAddResetsTheDraft() {
        controller.draftTitle = "leftover"
        controller.presentQuickAdd()

        XCTAssertTrue(controller.isShowingQuickAdd)
        XCTAssertEqual(controller.draftTitle, "")
        XCTAssertEqual(controller.draftFrequency, .daily)
        XCTAssertNil(controller.draftGoal)
    }

    func testQuickAddDefaultsToTheActiveFilter() {
        controller.selectedDomainFilter = .fun
        controller.presentQuickAdd()
        XCTAssertEqual(controller.draftDomain, .fun)
    }

    func testAnEmptyOrWhitespaceTitleCannotBeSaved() {
        controller.draftTitle = "   \n "
        XCTAssertFalse(controller.canSaveDraft)

        controller.draftTitle = "Read"
        XCTAssertTrue(controller.canSaveDraft)
    }

    func testSavingCreatesTheHabitAndClosesTheSheet() throws {
        controller.presentQuickAdd()
        controller.draftTitle = "Read 15 mins"
        controller.draftDomain = .fun

        controller.saveDraft(in: context)

        XCTAssertFalse(controller.isShowingQuickAdd)
        let habits = try allHabits()
        XCTAssertEqual(habits.map(\.title), ["Read 15 mins"])
        XCTAssertNotNil(habits.first?.goal, "quick-add must still anchor to a goal")
    }

    func testSavingAnEmptyDraftDoesNothing() throws {
        controller.presentQuickAdd()
        controller.draftTitle = "  "

        controller.saveDraft(in: context)

        XCTAssertTrue(controller.isShowingQuickAdd, "the sheet should stay open")
        XCTAssertTrue(try allHabits().isEmpty)
    }

    func testFailureKeepsTheSheetOpenSoInputIsNotLost() throws {
        // A store with no goals cannot satisfy the anchor rule.
        let bare = ModelContext(try DatabaseService.makeContainer(inMemory: true))
        controller.presentQuickAdd()
        controller.draftTitle = "Orphan"
        controller.draftDomain = .fun

        controller.saveDraft(in: bare)

        XCTAssertTrue(controller.isShowingQuickAdd)
        XCTAssertNotNil(controller.errorMessage)
    }

    func testGoalPickerOffersOnlyTheDraftDomainsGoals() throws {
        let goals = try context.fetch(LifeGoalQuery.active())
        let offered = controller.goals(for: .career, from: goals)

        XCTAssertEqual(offered.map(\.domain), [.career])
    }

    // MARK: Helpers

    private static let gmt: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    private func allHabits() throws -> [Habit] {
        try context.fetch(HabitQuery.active())
    }

    private func seedOnePerDomain() throws {
        for domain in DimensionDomain.allCases {
            _ = try service.createHabit(
                title: "\(domain.label) habit",
                domain: domain,
                in: context
            )
        }
    }
}

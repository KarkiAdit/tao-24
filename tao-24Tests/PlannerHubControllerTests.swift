//
//  PlannerHubControllerTests.swift
//  tao-24Tests
//

import Foundation
import SwiftData
import XCTest

@testable import tao_24

@MainActor
final class PlannerHubControllerTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var controller: PlannerHubController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try DatabaseService.makeContainer(inMemory: true)
        context = ModelContext(container)
        try DatabaseService.seedIfNeeded(in: context)
        controller = PlannerHubController(
            blueprintService: BlueprintService(executionService: HabitExecutionService())
        )
    }

    override func tearDownWithError() throws {
        controller = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    private var sample: Blueprint { PlannerContent.blueprints[0] }

    // MARK: Resource filtering

    func testNoFocusShowsEveryResource() {
        XCTAssertEqual(
            controller.resources(for: nil).count,
            PlannerContent.microResources.count
        )
    }

    func testFocusKeepsCrossCuttingResources() {
        let health = controller.resources(for: .health)

        XCTAssertTrue(
            health.contains { $0.domain == nil },
            "a general read should survive a domain filter"
        )
        XCTAssertFalse(
            health.contains { $0.domain != nil && $0.domain != .health },
            "another dimension's read should not"
        )
    }

    // MARK: Counts

    func testActiveHabitCountStartsAtZero() {
        for domain in DimensionDomain.allCases {
            XCTAssertEqual(controller.activeHabitCount(for: domain, in: context), 0)
        }
    }

    func testAdoptingUpdatesTheDomainCounts() {
        controller.adopt(sample, in: context)

        for domain in DimensionDomain.allCases {
            let expected = sample.habits.filter { $0.domain == domain }.count
            XCTAssertEqual(controller.activeHabitCount(for: domain, in: context), expected)
        }
    }

    // MARK: Inspection

    func testInspectingOpensTheSheetCollapsed() {
        controller.isRationaleExpanded = true
        controller.inspect(sample)

        XCTAssertEqual(controller.inspectedBlueprint, sample)
        XCTAssertFalse(
            controller.isRationaleExpanded,
            "the accordion should not stay open from a previous sheet"
        )
    }

    func testDismissingClearsTheSheet() {
        controller.inspect(sample)
        controller.dismissInspection()
        XCTAssertNil(controller.inspectedBlueprint)
    }

    // MARK: Adoption

    func testAdoptingClosesTheSheetAndReportsTheCount() {
        controller.inspect(sample)
        controller.adopt(sample, in: context)

        XCTAssertNil(controller.inspectedBlueprint)
        XCTAssertEqual(controller.lastAdoptedCount, sample.habits.count)
    }

    func testPendingCountDropsToZeroOnceAdopted() {
        XCTAssertEqual(
            controller.pendingCount(for: sample, in: context),
            sample.habits.count
        )

        controller.adopt(sample, in: context)

        XCTAssertEqual(controller.pendingCount(for: sample, in: context), 0)
        XCTAssertTrue(controller.isFullyAdopted(sample, in: context))
    }

    func testAdoptionFailureSurfacesAMessage() throws {
        // A store with no goals cannot satisfy the anchor rule.
        let bare = ModelContext(try DatabaseService.makeContainer(inMemory: true))
        controller.inspect(sample)

        controller.adopt(sample, in: bare)

        XCTAssertNotNil(controller.errorMessage)
    }
}

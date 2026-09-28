//
//  PlannerHubController.swift
//  tao-24
//

import Foundation
import Observation
import SwiftData

/// Presentation state for the Habit Planner.
///
/// Owns which blueprint is being inspected and runs adoption through
/// `BlueprintService`. No SwiftUI import.
@Observable
@MainActor
final class PlannerHubController {

    /// The blueprint shown in the detail sheet, or `nil` when closed.
    var inspectedBlueprint: Blueprint?

    /// Expanded state of the rationale accordion, reset per sheet.
    var isRationaleExpanded = false

    /// Set after a successful adoption so the sheet can confirm what happened
    /// rather than just closing.
    var lastAdoptedCount: Int?

    var errorMessage: String?

    private let blueprintService: BlueprintService

    init(blueprintService: BlueprintService? = nil) {
        self.blueprintService = blueprintService ?? .shared
    }

    // MARK: Derived state

    func activeHabitCount(for domain: DimensionDomain, in context: ModelContext) -> Int {
        (try? blueprintService.activeHabitCount(for: domain, in: context)) ?? 0
    }

    func isFullyAdopted(_ blueprint: Blueprint, in context: ModelContext) -> Bool {
        (try? blueprintService.isFullyAdopted(blueprint, in: context)) ?? false
    }

    /// How many of the set's habits are not yet present — drives the button
    /// label, so it can say "Add the 2 you're missing" instead of implying a
    /// duplicate.
    func pendingCount(for blueprint: Blueprint, in context: ModelContext) -> Int {
        (try? blueprintService.pendingHabits(of: blueprint, in: context).count) ?? 0
    }

    /// Resources for a dimension, plus the cross-cutting ones. A reader
    /// browsing Health should still see "the science of habit stacking".
    func resources(for domain: DimensionDomain?) -> [MicroResource] {
        guard let domain else { return PlannerContent.microResources }
        return PlannerContent.microResources.filter { $0.domain == domain || $0.domain == nil }
    }

    // MARK: Actions

    func inspect(_ blueprint: Blueprint) {
        inspectedBlueprint = blueprint
        isRationaleExpanded = false
        lastAdoptedCount = nil
    }

    func dismissInspection() {
        inspectedBlueprint = nil
        lastAdoptedCount = nil
    }

    func adopt(_ blueprint: Blueprint, in context: ModelContext) {
        do {
            let created = try blueprintService.adopt(blueprint, in: context)
            lastAdoptedCount = created.count
            inspectedBlueprint = nil
        } catch HabitCreationError.noGoalAvailable(let domain) {
            errorMessage = "No \(domain.label) goal to attach these to yet."
        } catch {
            errorMessage = "Could not add that set."
        }
    }
}

//
//  BlueprintService.swift
//  tao-24
//

import Foundation
import SwiftData

/// Turns a blueprint into real habits.
///
/// Adoption is the one place the app writes several habits at once, so the
/// rules that hold for a single quick-add have to hold in bulk: every habit
/// gets a goal anchor, and adopting the same set twice does not duplicate it.
final class BlueprintService {

    static let shared = BlueprintService()

    private let executionService: HabitExecutionService

    init(executionService: HabitExecutionService? = nil) {
        self.executionService = executionService ?? .shared
    }

    /// How many active habits a dimension currently has — the count on a hero
    /// card.
    func activeHabitCount(for domain: DimensionDomain, in context: ModelContext) throws -> Int {
        try context.fetch(HabitQuery.active(in: domain)).count
    }

    /// Whether every habit in the blueprint already exists and is active.
    ///
    /// Matched on title and domain rather than an adoption record. A blueprint
    /// is a template, not a subscription — once adopted, the habits belong to
    /// the user, who is free to rename or archive them. Storing "adopted" as
    /// state would start lying the moment they did.
    func isFullyAdopted(_ blueprint: Blueprint, in context: ModelContext) throws -> Bool {
        let existing = try activeSignatures(in: context)
        return blueprint.habits.allSatisfy { existing.contains(signature(for: $0)) }
    }

    /// Which habits in the blueprint are not yet present.
    func pendingHabits(
        of blueprint: Blueprint,
        in context: ModelContext
    ) throws -> [BlueprintHabit] {
        let existing = try activeSignatures(in: context)
        return blueprint.habits.filter { !existing.contains(signature(for: $0)) }
    }

    /// Adds the blueprint's habits, skipping any that already exist.
    ///
    /// Partial adoption is the normal case, not an edge case: someone who
    /// already runs the walk should get the other two rather than a duplicate
    /// walk or a refusal.
    ///
    /// - Returns: the habits actually created. Empty means it was already
    ///   fully adopted.
    @discardableResult
    func adopt(_ blueprint: Blueprint, in context: ModelContext) throws -> [Habit] {
        let pending = try pendingHabits(of: blueprint, in: context)
        guard !pending.isEmpty else { return [] }

        return try pending.map { template in
            try executionService.createHabit(
                title: template.title,
                domain: template.domain,
                frequency: template.frequency,
                in: context
            )
        }
    }

    // MARK: Matching

    /// Title and domain together. Title alone would collide across dimensions
    /// — "Read a few pages" could plausibly be Fun or Career.
    private func signature(for habit: BlueprintHabit) -> String {
        signature(title: habit.title, domain: habit.domain)
    }

    private func signature(title: String, domain: DimensionDomain) -> String {
        "\(domain.rawValue)|\(title.lowercased())"
    }

    private func activeSignatures(in context: ModelContext) throws -> Set<String> {
        let active = try context.fetch(HabitQuery.active())
        return Set(active.map { signature(title: $0.title, domain: $0.domain) })
    }
}

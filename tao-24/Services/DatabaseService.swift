//
//  DatabaseService.swift
//  tao-24
//

import Foundation
import SwiftData

/// The store dependency, as Controllers see it.
///
/// Exists so a Controller can be handed an in-memory container in a test
/// without a UI host, per the MVCS rules.
@MainActor
protocol DatabaseServicing {
    var container: ModelContainer { get }
    var isEphemeral: Bool { get }
}

/// Owns the `ModelContainer` and seeds an empty store.
@MainActor
final class DatabaseService: DatabaseServicing {

    static let shared = DatabaseService()

    let container: ModelContainer

    /// True when the on-disk store could not be opened and an in-memory store
    /// is standing in, so nothing written will survive relaunch.
    ///
    /// Surfaced rather than swallowed: silently degrading to a store that
    /// forgets everything is worse than saying so, and a habit tracker that
    /// loses yesterday is not a habit tracker.
    let isEphemeral: Bool

    private init() {
        do {
            self.container = try Self.makeContainer(inMemory: false)
            self.isEphemeral = false
        } catch {
            guard let fallback = try? Self.makeContainer(inMemory: true) else {
                // Nothing can work without a store of some kind. Fail loudly
                // with the original reason rather than with a bare try!.
                fatalError("No store could be opened, on disk or in memory: \(error)")
            }
            self.container = fallback
            self.isEphemeral = true
        }
    }

    /// Builds a container for `SchemaV1` under `TaoMigrationPlan`.
    ///
    /// `nonisolated` so tests can build one without hopping to the main actor
    /// for what is just object construction.
    nonisolated static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: TaoMigrationPlan.self,
            configurations: configuration
        )
    }

    /// Fills in anything an empty store is missing: one active goal per
    /// dimension, and the single profile row.
    ///
    /// Idempotent by construction — it inserts only what is absent, so running
    /// it on every launch is safe and re-running it is a no-op. It repairs a
    /// partially seeded store too, which matters because a crash mid-seed
    /// would otherwise leave the app permanently short a goal.
    ///
    /// - Returns: how many objects were inserted. Zero means nothing was
    ///   missing.
    @discardableResult
    static func seedIfNeeded(in context: ModelContext) throws -> Int {
        var inserted = 0

        let existingGoals = try context.fetch(FetchDescriptor<LifeGoal>())
        let seededDomains = Set(existingGoals.map(\.domainRawValue))

        for domain in DimensionDomain.allCases where !seededDomains.contains(domain.rawValue) {
            context.insert(
                LifeGoal(title: SeedContent.defaultGoalTitle(for: domain), domain: domain)
            )
            inserted += 1
        }

        // SwiftData cannot express "at most one row", so the invariant is kept
        // here: seed a profile only when none exists, and never a second.
        let existingProfiles = try context.fetch(FetchDescriptor<UserValueProfile>())
        if existingProfiles.isEmpty {
            context.insert(UserValueProfile())
            inserted += 1
        }

        if inserted > 0 {
            try context.save()
        }
        return inserted
    }

    /// Seeds the shared container's main context.
    @discardableResult
    func seedIfNeeded() throws -> Int {
        try Self.seedIfNeeded(in: container.mainContext)
    }
}

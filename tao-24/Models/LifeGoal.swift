//
//  LifeGoal.swift
//  tao-24
//

import Foundation
import SwiftData

/// A long-term objective that habits ladder up to.
///
/// The goal anchor is what separates this app from a checklist, so a goal
/// exists per domain from first launch — quick-add always has something to
/// attach to rather than forcing the user to invent one mid-flow.
@Model
final class LifeGoal {

    @Attribute(.unique) var id: UUID

    var title: String

    /// Backing column for `domain`.
    var domainRawValue: String

    var createdAt: Date

    /// Retired goals stay in the store so past habits keep their context.
    var isActive: Bool

    /// Deleting a goal detaches its habits rather than destroying them — a
    /// goal changing does not mean the user's history should vanish.
    @Relationship(deleteRule: .nullify, inverse: \Habit.goal)
    var habits: [Habit] = []

    /// Which Dimension of Joy this belongs to.
    var domain: DimensionDomain {
        get { DimensionDomain(rawValue: domainRawValue) ?? .health }
        set { domainRawValue = newValue.rawValue }
    }

    init(title: String, domain: DimensionDomain, createdAt: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.domainRawValue = domain.rawValue
        self.createdAt = createdAt
        self.isActive = true
    }
}

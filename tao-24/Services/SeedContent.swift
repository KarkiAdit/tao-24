//
//  SeedContent.swift
//  tao-24
//

import Foundation

/// Content written into an empty store on first launch.
///
/// One goal per dimension, so the product rule that every habit links to a
/// goal can hold from the very first quick-add — without making the user
/// invent a long-term objective before they can tick anything off.
///
/// These are starting points, not prescriptions: phrased as directions rather
/// than targets, and the user is expected to rename them.
enum SeedContent {

    static func defaultGoalTitle(for domain: DimensionDomain) -> String {
        switch domain {
        case .health: "Feel strong and rested"
        case .career: "Grow toward work that matters"
        case .fun: "Make room for play"
        }
    }
}

//
//  DimensionDomain.swift
//  tao-24
//

import Foundation

/// The three Dimensions of Joy every habit belongs to.
///
/// Model layer: deliberately free of UI imports so it stays usable from
/// Services and tests without a SwiftUI host. Presentation — accent color,
/// symbol — lives in `DimensionDomain+Style` in the DesignSystem layer.
///
/// Raw values are the display strings from the product spec and are persisted
/// by SwiftData via `Habit.domainRawValue`; changing one is a data migration.
enum DimensionDomain: String, Codable, CaseIterable, Identifiable, Sendable {
    case health = "Health"
    case career = "Career"
    case fun = "Fun"

    var id: String { rawValue }
}

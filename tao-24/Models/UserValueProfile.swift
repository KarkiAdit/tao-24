//
//  UserValueProfile.swift
//  tao-24
//

import Foundation
import SwiftData

/// The user's onboarding answers, and the input to habit recommendations.
///
/// **This is the most sensitive data the app holds** — personality and values.
/// It never leaves the device: scoring and habit mapping run locally, and
/// nothing here is sent anywhere. See the privacy rules in `CLAUDE.md`.
///
/// Exactly one row is expected. Singleton-ness is enforced by `DatabaseService`
/// at seed time rather than by the schema, since SwiftData has no way to
/// express "at most one".
///
/// Unlike `Habit`, the enum-backed fields here are *not* decomposed for
/// querying — this row is always fetched whole, never filtered by field, so
/// there is nothing for a predicate or index to reach into.
@Model
final class UserValueProfile {

    @Attribute(.unique) var id: UUID

    var primaryIntentRawValue: String
    var structurePreferenceRawValue: String
    var energyWindowRawValue: String
    var socialPreferenceRawValue: String

    /// Raw values of the chosen `CoreValue`s, at most
    /// `CoreValue.selectionLimit`.
    var coreValueRawValues: [String]

    /// When the questionnaire was finished. `nil` while still in progress, so
    /// a partially answered flow can be resumed rather than restarted.
    var completedAt: Date?

    var updatedAt: Date

    // MARK: Typed façades

    var primaryIntent: PrimaryIntent {
        get { PrimaryIntent(rawValue: primaryIntentRawValue) ?? .balanced }
        set { primaryIntentRawValue = newValue.rawValue }
    }

    var structurePreference: StructurePreference {
        get { StructurePreference(rawValue: structurePreferenceRawValue) ?? .flexible }
        set { structurePreferenceRawValue = newValue.rawValue }
    }

    var energyWindow: EnergyWindow {
        get { EnergyWindow(rawValue: energyWindowRawValue) ?? .earlyMorning }
        set { energyWindowRawValue = newValue.rawValue }
    }

    var socialPreference: SocialPreference {
        get { SocialPreference(rawValue: socialPreferenceRawValue) ?? .hybrid }
        set { socialPreferenceRawValue = newValue.rawValue }
    }

    /// Chosen core values. Setting more than the limit keeps the first three;
    /// unknown raw values are dropped, so a row written by a newer schema
    /// degrades rather than failing to load.
    var coreValues: [CoreValue] {
        get { coreValueRawValues.compactMap(CoreValue.init(rawValue:)) }
        set { coreValueRawValues = newValue.prefix(CoreValue.selectionLimit).map(\.rawValue) }
    }

    /// Whether onboarding has been finished.
    var isComplete: Bool { completedAt != nil }

    init(
        primaryIntent: PrimaryIntent = .balanced,
        structurePreference: StructurePreference = .flexible,
        energyWindow: EnergyWindow = .earlyMorning,
        socialPreference: SocialPreference = .hybrid,
        coreValues: [CoreValue] = [],
        completedAt: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = UUID()
        self.primaryIntentRawValue = primaryIntent.rawValue
        self.structurePreferenceRawValue = structurePreference.rawValue
        self.energyWindowRawValue = energyWindow.rawValue
        self.socialPreferenceRawValue = socialPreference.rawValue
        self.coreValueRawValues = coreValues.prefix(CoreValue.selectionLimit).map(\.rawValue)
        self.completedAt = completedAt
        self.updatedAt = updatedAt
    }
}

//
//  OnboardingPreferences.swift
//  tao-24
//

import Foundation

/// The five answers the onboarding questionnaire collects, one type per step.
///
/// Every raw value is persisted on `UserValueProfile`, so raw values are
/// schema — add cases freely, never rename an existing one without a
/// migration. Case names are Swift-idiomatic; raw values are stable
/// identifiers, which is why the two differ.

/// Step 1 — the focus area the user leads with. Sets initial domain weighting.
enum PrimaryIntent: String, Codable, CaseIterable, Identifiable, Sendable {
    case health = "Health"
    case career = "Career"
    case fun = "Fun"
    case balanced = "Balanced"

    var id: String { rawValue }
}

/// Step 2 — whether fixed time blocks or habit-stacking triggers fit better.
enum StructurePreference: String, Codable, CaseIterable, Identifiable, Sendable {
    case structured = "Structured"
    case flexible = "Flexible"
    case exploratory = "Exploratory"

    var id: String { rawValue }
}

/// Step 3 — peak energy window, so high-friction habits avoid the dips.
enum EnergyWindow: String, Codable, CaseIterable, Identifiable, Sendable {
    case earlyMorning = "EarlyMorning"
    case midDay = "MidDay"
    case lateEvening = "LateEvening"

    var id: String { rawValue }
}

/// Step 4 — solo, group, or a mix. Picks the habit modality.
enum SocialPreference: String, Codable, CaseIterable, Identifiable, Sendable {
    case solitary = "Solitary"
    case group = "Group"
    case hybrid = "Hybrid"

    var id: String { rawValue }
}

/// Step 5 — the user's top drivers. The questionnaire takes at most
/// `CoreValue.selectionLimit` of these.
enum CoreValue: String, Codable, CaseIterable, Identifiable, Sendable {
    case mastery = "Mastery"
    case peaceOfMind = "PeaceOfMind"
    case physicalVitality = "PhysicalVitality"
    case professionalImpact = "ProfessionalImpact"
    case creativeExpression = "CreativeExpression"
    case socialConnection = "SocialConnection"

    var id: String { rawValue }

    /// The questionnaire caps selection at three, per the product spec.
    static let selectionLimit = 3
}

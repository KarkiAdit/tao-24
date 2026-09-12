//
//  DimensionDomain+Style.swift
//  tao-24
//

import SwiftUI

/// Presentation for `DimensionDomain`, kept out of the Model layer.
///
/// Each domain pairs an accent with a distinct symbol silhouette. The symbol
/// is a requirement, not a flourish: green/blue/orange are hard to tell apart
/// with deuteranopia, so colour must never be the only signal carrying which
/// dimension something belongs to.
extension DimensionDomain {

    /// The domain's accent — rings, pills, active states, glows.
    var accent: Color {
        switch self {
        case .health: ColorTokens.healthAccent
        case .career: ColorTokens.careerAccent
        case .fun: ColorTokens.funAccent
        }
    }

    /// Label colour on a filled `accent`. Black for all three: every accent is
    /// bright enough on dark that white text would fail AA.
    var onAccent: Color { ColorTokens.onAccent }

    /// SF Symbol paired with `accent`. Silhouettes are deliberately unalike.
    var symbolName: String {
        switch self {
        case .health: "heart.fill"
        case .career: "briefcase.fill"
        case .fun: "sparkles"
        }
    }

    /// Human-readable name, as written in the product spec.
    var label: String { rawValue }

    /// A faint wash of the accent, for hero-card gradients. Kept low enough
    /// that white body copy over it still clears AA.
    var gradientWash: LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.28), ColorTokens.backgroundCard],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

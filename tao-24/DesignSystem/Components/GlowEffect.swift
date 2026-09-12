//
//  GlowEffect.swift
//  tao-24
//

import SwiftUI

/// Ambient aura behind an active element.
///
/// On a black ground a coloured glow is the cheapest way to say "this one is
/// live" without adding a border or a badge. It is decoration only — never the
/// sole indicator of state, since a glow is invisible to anyone who cannot
/// separate the hue from the background.
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double
    let isActive: Bool

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .background {
                if isActive && !reduceTransparency {
                    Capsule()
                        .fill(color)
                        .blur(radius: radius)
                        .opacity(opacity)
                        .allowsHitTesting(false)
                }
            }
    }
}

extension View {

    /// Soft aura, for an active pill or chip.
    func softGlow(_ color: Color, isActive: Bool = true) -> some View {
        modifier(
            GlowEffect(
                color: color,
                radius: LayoutTokens.Glow.softRadius,
                opacity: LayoutTokens.Glow.softOpacity,
                isActive: isActive
            )
        )
    }

    /// Strong aura, for a hero card.
    func strongGlow(_ color: Color, isActive: Bool = true) -> some View {
        modifier(
            GlowEffect(
                color: color,
                radius: LayoutTokens.Glow.strongRadius,
                opacity: LayoutTokens.Glow.strongOpacity,
                isActive: isActive
            )
        )
    }
}

//
//  CompletionRing.swift
//  tao-24
//

import SwiftUI
import UIKit

/// Habit completion control: a ring that fills with a spring and a light
/// impact tap.
///
/// Two product constraints shape this, both from the ethical-engagement rules:
/// the incomplete state is *neutral*, never red or scolding, and un-completing
/// is as easy as completing — reversing is animated the same way, not punished.
struct CompletionRing: View {
    let domain: DimensionDomain
    @Binding var isComplete: Bool
    var diameter: CGFloat = 28

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            toggle()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(
                        isComplete ? domain.accent : ColorTokens.controlOutline,
                        lineWidth: LayoutTokens.Stroke.ring
                    )

                Circle()
                    .fill(domain.accent)
                    .scaleEffect(isComplete ? 1 : 0.1)
                    .opacity(isComplete ? 1 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: diameter * 0.44, weight: .heavy))
                    .foregroundStyle(domain.onAccent)
                    .scaleEffect(isComplete ? 1 : 0.4)
                    .opacity(isComplete ? 1 : 0)
            }
            .frame(width: diameter, height: diameter)
            .softGlow(domain.accent, isActive: isComplete)
            .animation(
                reduceMotion ? .easeInOut(duration: 0.15) : LayoutTokens.Motion.spring,
                value: isComplete
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(domain.label) habit")
        .accessibilityValue(isComplete ? "Completed" : "Not completed")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(
            isComplete ? "Double tap to mark incomplete" : "Double tap to mark complete"
        )
    }

    private func toggle() {
        isComplete.toggle()
        // Soft on the way in, softer on the way out — undoing should not feel
        // like a penalty.
        UIImpactFeedbackGenerator(style: isComplete ? .light : .soft).impactOccurred()
    }
}

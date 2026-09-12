//
//  DomainPill.swift
//  tao-24
//

import SwiftUI

/// Filter chip / badge for one dimension.
///
/// Active is a filled accent with a soft aura; inactive is an outlined
/// overlay. The symbol and label are present in both states, so the active one
/// is never signalled by colour alone.
struct DomainPill: View {
    let domain: DimensionDomain
    let isActive: Bool
    let action: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(domain: DimensionDomain, isActive: Bool = false, action: (() -> Void)? = nil) {
        self.domain = domain
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: LayoutTokens.Spacing.xs) {
                Image(systemName: domain.symbolName)
                    .imageScale(.small)
                Text(domain.label)
                    .textCase(.uppercase)
            }
            .font(TypographyTokens.tag)
            .tracking(0.6)
            .foregroundStyle(isActive ? domain.onAccent : ColorTokens.textSecondary)
            .padding(.horizontal, LayoutTokens.Spacing.md)
            .padding(.vertical, LayoutTokens.Spacing.sm)
            .background {
                Capsule()
                    .fill(
                        isActive
                            ? AnyShapeStyle(domain.accent)
                            : AnyShapeStyle(ColorTokens.backgroundOverlay)
                    )
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isActive ? Color.clear : ColorTokens.borderSubtle,
                        lineWidth: LayoutTokens.Stroke.hairline
                    )
            }
            .softGlow(domain.accent, isActive: isActive)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .animation(reduceMotion ? nil : LayoutTokens.Motion.spring, value: isActive)
        .accessibilityLabel(domain.label)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

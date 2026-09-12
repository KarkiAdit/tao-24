//
//  TaoCard.swift
//  tao-24
//

import SwiftUI

/// The shared card container: a cover-art style surface with an optional
/// domain-tinted gradient and a spring press response.
///
/// Carries the `Tao` prefix because `Card` alone is too generic to read well
/// at a call site and would collide with anything SwiftUI adds later. The
/// other components in this folder are already unambiguous, so they stay
/// unprefixed — see `CLAUDE.md` for the naming rule.
///
/// Set `isHero` for the larger radius and ambient aura used by a screen's
/// lead card; leave it off for ordinary rows and tiles.
struct TaoCard<Content: View>: View {
    let domain: DimensionDomain?
    let isHero: Bool
    let action: (() -> Void)?
    @ViewBuilder var content: () -> Content

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        domain: DimensionDomain? = nil,
        isHero: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.domain = domain
        self.isHero = isHero
        self.action = action
        self.content = content
    }

    private var cornerRadius: CGFloat {
        isHero ? LayoutTokens.Radius.hero : LayoutTokens.Radius.card
    }

    var body: some View {
        content()
            .padding(LayoutTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .modifier(HeroGlow(domain: domain, isHero: isHero))
            .scaleEffect(scale)
            .animation(reduceMotion ? nil : LayoutTokens.Motion.spring, value: isPressed)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onTapGesture { action?() }
            .onLongPressGesture(minimumDuration: 0, pressing: { isPressed = $0 }, perform: {})
            .accessibilityAddTraits(action == nil ? [] : .isButton)
    }

    private var scale: CGFloat {
        guard isPressed, !reduceMotion else { return 1 }
        return LayoutTokens.Motion.pressedScale
    }

    @ViewBuilder
    private var surface: some View {
        if let domain {
            domain.gradientWash
        } else {
            ColorTokens.backgroundCard
        }
    }
}

/// Applies the hero aura only when a card is both hero-sized and domain-tinted.
private struct HeroGlow: ViewModifier {
    let domain: DimensionDomain?
    let isHero: Bool

    func body(content: Content) -> some View {
        if let domain, isHero {
            content.strongGlow(domain.accent)
        } else {
            content
        }
    }
}

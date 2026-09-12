//
//  TypographyTokens.swift
//  tao-24
//

import SwiftUI

/// The type scale, mirroring `docs/design-tokens.json`.
///
/// The hierarchy is built on weight contrast: heavy, tight headings dropping
/// sharply to light grey supporting copy. The reference face is proprietary,
/// so this reproduces the *relationship* on SF Pro rather than the typeface.
///
/// Every style is built on a system text style, so all of it scales with
/// Dynamic Type. Never construct a font with a fixed point size.
enum TypographyTokens {

    /// Screen titles.
    static let display = Font.system(.largeTitle, weight: .bold)

    /// Hero card titles.
    static let header1 = Font.system(.title, weight: .bold)

    /// Card titles.
    static let header2 = Font.system(.title2, weight: .bold)

    /// Section headers.
    static let header3 = Font.system(.headline, weight: .semibold)

    /// Reading copy.
    static let body = Font.system(.body)

    /// Copy that needs to stand out — a habit name in a row.
    static let bodyEmphasis = Font.system(.body, weight: .semibold)

    /// Metadata and timestamps.
    static let caption = Font.system(.caption)

    /// Domain pills. Pair with `.textCase(.uppercase)`.
    static let tag = Font.system(.caption2, weight: .bold)
}

/// Applies a type style together with the text colour it is meant to carry,
/// so the pairing cannot drift apart across screens.
struct TextStyleModifier: ViewModifier {
    let font: Font
    let color: Color
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .tracking(tracking)
            .foregroundStyle(color)
    }
}

extension View {

    /// Screen title.
    func displayStyle() -> some View {
        modifier(
            TextStyleModifier(
                font: TypographyTokens.display,
                color: ColorTokens.textPrimary,
                tracking: -0.4
            )
        )
    }

    /// Hero card title.
    func header1Style() -> some View {
        modifier(
            TextStyleModifier(
                font: TypographyTokens.header1,
                color: ColorTokens.textPrimary,
                tracking: -0.3
            )
        )
    }

    /// Card title.
    func header2Style() -> some View {
        modifier(
            TextStyleModifier(
                font: TypographyTokens.header2,
                color: ColorTokens.textPrimary,
                tracking: -0.2
            )
        )
    }

    /// Section header.
    func header3Style() -> some View {
        modifier(
            TextStyleModifier(
                font: TypographyTokens.header3,
                color: ColorTokens.textPrimary,
                tracking: 0
            )
        )
    }

    /// Reading copy.
    func bodyStyle(emphasised: Bool = false) -> some View {
        modifier(
            TextStyleModifier(
                font: emphasised ? TypographyTokens.bodyEmphasis : TypographyTokens.body,
                color: ColorTokens.textPrimary,
                tracking: 0
            )
        )
    }

    /// Metadata and timestamps.
    func captionStyle(muted: Bool = false) -> some View {
        modifier(
            TextStyleModifier(
                font: TypographyTokens.caption,
                color: muted ? ColorTokens.textMuted : ColorTokens.textSecondary,
                tracking: 0
            )
        )
    }
}

//
//  ColorTokens.swift
//  tao-24
//

import SwiftUI

extension Color {

    /// Builds a colour from a 6-digit RGB hex, with or without a leading `#`.
    ///
    /// Invalid input resolves to magenta rather than trapping — a wrong colour
    /// is visible in a preview, whereas a crash in a token accessor would take
    /// down every screen at once.
    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
            self = .init(red: 1, green: 0, blue: 1)
            return
        }
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }

    /// Resolves to a different hex per appearance.
    ///
    /// Unused today — the palette is dark-only and the app locks
    /// `preferredColorScheme(.dark)`. It exists so that adding light mode is a
    /// matter of supplying second values in `ColorTokens`, not rewriting how
    /// colours are declared.
    init(dark: String, light: String) {
        self.init(
            uiColor: UIColor { traits in
                UIColor(Color(hex: traits.userInterfaceStyle == .light ? light : dark))
            }
        )
    }
}

/// The colour palette, mirroring `docs/design-tokens.json`.
///
/// Deep-dark: a black ground with grey surfaces stepping up
/// by luminance, and saturated colour spent only where it carries meaning.
/// Change a value here and in the JSON together — the JSON records the
/// measured contrast ratio that justifies it.
///
/// Never write a literal `Color` in a view. Add a token.
enum ColorTokens {

    // MARK: Backgrounds — each step up is a luminance step, not a shadow

    /// App ground, behind scroll content and under sheets.
    static let backgroundBase = Color(hex: "#000000")

    /// Default screen surface. The reference background for all contrast math.
    static let backgroundSurface = Color(hex: "#121212")

    /// Cards and rows lifted off the surface.
    static let backgroundCard = Color(hex: "#181818")

    /// Pressed and hovered states, unfilled progress tracks, sheet grabbers.
    static let backgroundOverlay = Color(hex: "#282828")

    // MARK: Text — ratios are against `backgroundSurface`

    /// Headings, habit names, metrics. 18.73:1.
    static let textPrimary = Color(hex: "#FFFFFF")

    /// Supporting copy, metadata, inactive tabs. 8.93:1.
    static let textSecondary = Color(hex: "#B3B3B3")

    /// Timestamps and the quietest labels. 5.43:1.
    ///
    /// The reference grey this was drawn from, `#6A6A6A`, measures 3.46:1 and
    /// fails AA. Lightened deliberately; do not "correct" it back.
    static let textMuted = Color(hex: "#8A8A8A")

    // MARK: Domain accents — prefer the `DimensionDomain` accessors

    static let healthAccent = Color(hex: "#30D158")
    static let careerAccent = Color(hex: "#0A84FF")
    static let funAccent = Color(hex: "#FF5500")

    /// Label colour on a filled accent. Black against all three — every accent
    /// is bright enough that white would fail.
    static let onAccent = Color(hex: "#000000")

    // MARK: Borders

    /// Hairline dividers. Rare — luminance separates surfaces first.
    static let borderSubtle = Color(hex: "#2A2A2A")

    /// Focus rings and outlined controls.
    static let borderStrong = Color(hex: "#3E3E3E")

    // MARK: Status

    /// Completion confirmed. Shares the Health hue deliberately, so the app
    /// speaks one positive language.
    static let statusPositive = Color(hex: "#30D158")

    /// Gentle attention. Never applied to a missed habit.
    ///
    /// There is deliberately no error colour for habit completion: missing a
    /// day is not a failure state. See the product rules in `CLAUDE.md`.
    static let statusNotice = Color(hex: "#FFD60A")
}

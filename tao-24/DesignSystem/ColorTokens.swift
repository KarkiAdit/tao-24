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

    /// The raw values, exposed so `ContrastTests` can verify the palette
    /// rather than the rule living only in a comment. Nothing outside the
    /// tests should reach for these — use the `Color` properties below.
    enum Hex {
        static let backgroundBase = "#000000"
        static let backgroundSurface = "#121212"
        static let backgroundCard = "#181818"
        static let backgroundOverlay = "#282828"

        static let textPrimary = "#FFFFFF"
        static let textSecondary = "#B3B3B3"
        static let textMuted = "#909090"

        static let healthAccent = "#30D158"
        static let careerAccent = "#0A84FF"
        static let funAccent = "#FF5500"
        static let onAccent = "#000000"

        static let borderSubtle = "#2A2A2A"
        static let borderStrong = "#3E3E3E"
        static let controlOutline = "#7A7A7A"

        static let statusPositive = "#30D158"
        static let statusNotice = "#FFD60A"

        /// Every surface text can legibly sit on.
        static let allSurfaces = [
            backgroundBase, backgroundSurface, backgroundCard, backgroundOverlay,
        ]

        /// Every foreground that carries words.
        static let allTextTokens = [textPrimary, textSecondary, textMuted]

        /// The three domain accents.
        static let allAccents = [healthAccent, careerAccent, funAccent]

        /// Tokens that outline an interactive control. Held to the 3:1 bar for
        /// non-text UI on every surface — an unchecked ring that cannot be
        /// seen is not an affordance.
        static let allControlOutlines = [controlOutline]
    }

    // MARK: Backgrounds — each step up is a luminance step, not a shadow

    /// App ground, behind scroll content and under sheets.
    static let backgroundBase = Color(hex: Hex.backgroundBase)

    /// Default screen surface. The reference background for all contrast math.
    static let backgroundSurface = Color(hex: Hex.backgroundSurface)

    /// Cards and rows lifted off the surface.
    static let backgroundCard = Color(hex: Hex.backgroundCard)

    /// Pressed and hovered states, unfilled progress tracks, sheet grabbers.
    static let backgroundOverlay = Color(hex: Hex.backgroundOverlay)

    // MARK: Text — ratios are against `backgroundSurface`

    /// Headings, habit names, metrics. 18.73:1.
    static let textPrimary = Color(hex: Hex.textPrimary)

    /// Supporting copy, metadata, inactive tabs. 8.93:1.
    static let textSecondary = Color(hex: Hex.textSecondary)

    /// Timestamps and the quietest labels. 5.87:1 on the surface, 4.62:1 on
    /// the overlay — its worst case, and the value that sets this token.
    ///
    /// Lightened twice, both times deliberately. The reference grey `#6A6A6A`
    /// measures 3.46:1 and fails outright. `#8A8A8A` then passed on the
    /// surface but failed at 4.27:1 on `backgroundOverlay`, which is where
    /// muted text actually lands inside a pill or a pressed row — caught only
    /// by checking every surface rather than the default one. Do not darken.
    static let textMuted = Color(hex: Hex.textMuted)

    // MARK: Domain accents — prefer the `DimensionDomain` accessors

    static let healthAccent = Color(hex: Hex.healthAccent)
    static let careerAccent = Color(hex: Hex.careerAccent)
    static let funAccent = Color(hex: Hex.funAccent)

    /// Label colour on a filled accent. Black against all three — every accent
    /// is bright enough that white would fail.
    static let onAccent = Color(hex: Hex.onAccent)

    // MARK: Borders

    /// Hairline dividers. Rare — luminance separates surfaces first.
    static let borderSubtle = Color(hex: Hex.borderSubtle)

    /// Decorative emphasis on a divider. Not for anything interactive — at
    /// 1.66:1 on a card it is invisible as a control. Use `controlOutline`.
    static let borderStrong = Color(hex: Hex.borderStrong)

    /// The outline of an interactive control in its resting state — an
    /// unchecked completion ring, an unfilled field.
    ///
    /// 4.14:1 on a card and 3.43:1 on the overlay. `borderStrong` was used
    /// here first and measured 1.66:1, which made the checklist's primary
    /// control almost invisible against its own card.
    static let controlOutline = Color(hex: Hex.controlOutline)

    // MARK: Status

    /// Completion confirmed. Shares the Health hue deliberately, so the app
    /// speaks one positive language.
    static let statusPositive = Color(hex: Hex.statusPositive)

    /// Gentle attention. Never applied to a missed habit.
    ///
    /// There is deliberately no error colour for habit completion: missing a
    /// day is not a failure state. See the product rules in `CLAUDE.md`.
    static let statusNotice = Color(hex: Hex.statusNotice)
}

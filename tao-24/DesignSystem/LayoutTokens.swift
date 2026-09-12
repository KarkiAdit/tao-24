//
//  LayoutTokens.swift
//  tao-24
//

import CoreGraphics
import SwiftUI

/// Spacing, radii, glow and motion, mirroring `docs/design-tokens.json`.
enum LayoutTokens {

    /// Multiples of a 4pt base grid.
    enum Spacing {
        /// 4pt — icon-to-label.
        static let xs: CGFloat = 4
        /// 8pt — inside a pill.
        static let sm: CGFloat = 8
        /// 12pt — between rows.
        static let md: CGFloat = 12
        /// 16pt — screen margins, card padding.
        static let lg: CGFloat = 16
        /// 24pt — between sections.
        static let xl: CGFloat = 24
        /// 32pt — above a screen title.
        static let xxl: CGFloat = 32
    }

    enum Radius {
        /// Fully rounded — domain pills, filter chips.
        static let pill: CGFloat = .infinity
        /// 8pt — standard cards and rows.
        static let card: CGFloat = 8
        /// 16pt — album-art style hero cards.
        static let hero: CGFloat = 16
        /// 16pt — modal sheet corners.
        static let sheet: CGFloat = 16
    }

    enum Stroke {
        /// Hairline dividers.
        static let hairline: CGFloat = 1
        /// The completion ring on a habit row.
        static let ring: CGFloat = 2.5
    }

    /// Dark surfaces separate by luminance, not drop shadows. The only
    /// elevation in this system is an accent glow on *active* elements — which
    /// is why both values are tied to a domain accent, never to black.
    enum Glow {
        static let softRadius: CGFloat = 12
        static let softOpacity: Double = 0.35
        static let strongRadius: CGFloat = 24
        static let strongOpacity: Double = 0.45
    }

    /// One spring for the whole system: tactile, not bouncy.
    enum Motion {
        static let springResponse: Double = 0.34
        static let springDamping: Double = 0.7
        static let pressedScale: CGFloat = 0.97

        static var spring: Animation {
            .spring(response: springResponse, dampingFraction: springDamping)
        }
    }
}

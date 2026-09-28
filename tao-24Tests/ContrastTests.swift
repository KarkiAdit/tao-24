//
//  ContrastTests.swift
//  tao-24Tests
//

import XCTest

@testable import tao_24

/// Makes the palette's accessibility claim executable.
///
/// The claim used to live in a comment, and the comment was checked against
/// one surface. That is how `textMuted` shipped passing on `#121212` at
/// 5.43:1 while failing on `#282828` at 4.27:1 — which is exactly where muted
/// text sits inside a pill or a pressed row. These tests check every
/// foreground against every surface, so the next token that misses cannot
/// merely be asserted to be fine.
final class ContrastTests: XCTestCase {

    /// WCAG 2.1 minimum for body text.
    private let textMinimum = 4.5

    /// WCAG 2.1 minimum for non-text UI — an unlabelled ring or bar.
    private let uiMinimum = 3.0

    func testEveryTextTokenIsLegibleOnEverySurface() {
        for text in ColorTokens.Hex.allTextTokens {
            for surface in ColorTokens.Hex.allSurfaces {
                let ratio = Self.contrastRatio(text, surface)
                XCTAssertGreaterThanOrEqual(
                    ratio,
                    textMinimum,
                    "\(text) on \(surface) is \(String(format: "%.2f", ratio)):1"
                )
            }
        }
    }

    func testEveryAccentIsVisibleOnEverySurface() {
        for accent in ColorTokens.Hex.allAccents {
            for surface in ColorTokens.Hex.allSurfaces {
                let ratio = Self.contrastRatio(accent, surface)
                XCTAssertGreaterThanOrEqual(
                    ratio,
                    uiMinimum,
                    "\(accent) on \(surface) is \(String(format: "%.2f", ratio)):1"
                )
            }
        }
    }

    func testAccentsAreAlsoLegibleAsText() {
        // Accents are used for text on the surface, not only as fills, so they
        // are held to the stricter bar there.
        for accent in ColorTokens.Hex.allAccents {
            let ratio = Self.contrastRatio(accent, ColorTokens.Hex.backgroundSurface)
            XCTAssertGreaterThanOrEqual(ratio, textMinimum, "\(accent) as text")
        }
    }

    func testLabelsOnFilledAccentsAreLegible() {
        // onAccent is black for all three because white fails on every one.
        // If an accent is ever lightened, this catches it.
        for accent in ColorTokens.Hex.allAccents {
            let ratio = Self.contrastRatio(ColorTokens.Hex.onAccent, accent)
            XCTAssertGreaterThanOrEqual(
                ratio,
                textMinimum,
                "onAccent on \(accent) is \(String(format: "%.2f", ratio)):1"
            )
        }
    }

    func testTheKnownRegressionStaysFixed() {
        // textMuted on backgroundOverlay: 4.27:1 before, must stay above 4.5.
        let ratio = Self.contrastRatio(
            ColorTokens.Hex.textMuted,
            ColorTokens.Hex.backgroundOverlay
        )
        XCTAssertGreaterThanOrEqual(ratio, textMinimum)
    }

    // MARK: WCAG 2.1 relative luminance

    private static func contrastRatio(_ a: String, _ b: String) -> Double {
        let lighter = max(luminance(a), luminance(b))
        let darker = min(luminance(a), luminance(b))
        return (lighter + 0.05) / (darker + 0.05)
    }

    private static func luminance(_ hex: String) -> Double {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
            XCTFail("malformed hex token: \(hex)")
            return 0
        }
        let channels = [
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255,
        ]
        .map { channel -> Double in
            channel <= 0.04045
                ? channel / 12.92
                : pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }
}

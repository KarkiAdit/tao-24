//
//  DimensionBalanceWheel.swift
//  tao-24
//

import SwiftUI

/// Three-axis radar chart of where effort went.
///
/// Drawn in `Canvas` rather than Swift Charts, which has no radar mark. Three
/// axes make a triangle, so the geometry is small enough to be worth owning.
///
/// The shape is the product's core metaphor made visible: an even triangle is
/// a balanced period, a spike is a lean. It reports distribution and does not
/// grade it — there is no "target" ring to fall short of, deliberately.
struct DimensionBalanceWheel: View {
    let effort: [DomainEffort]
    var lineWidth: CGFloat = 2

    /// Largest share in the set, used to scale the plot so a lopsided period
    /// still fills the frame. Floored so a near-empty period does not explode
    /// one completion into a full triangle.
    private var scale: Double {
        max(effort.map(\.share).max() ?? 0, 0.34)
    }

    private var hasData: Bool {
        effort.contains { $0.completions > 0 }
    }

    var body: some View {
        Canvas { context, size in
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 28

            drawGrid(in: context, centre: centre, radius: radius)
            if hasData {
                drawPlot(in: context, centre: centre, radius: radius)
            }
            drawVertices(in: context, centre: centre, radius: radius)
        }
        .frame(height: 220)
        .accessibilityElement()
        .accessibilityLabel("Effort distribution")
        .accessibilityValue(accessibilityValue)
    }

    /// The chart is a picture; VoiceOver gets the numbers instead.
    private var accessibilityValue: String {
        guard hasData else { return "Nothing logged yet" }
        return
            effort
            .map { "\($0.domain.label) \(Int(($0.share * 100).rounded()))%" }
            .joined(separator: ", ")
    }

    // MARK: Geometry

    /// Axis angles, one per dimension, starting at the top and going clockwise.
    private func angle(for index: Int) -> Double {
        let step = 2 * Double.pi / Double(max(effort.count, 1))
        return -Double.pi / 2 + step * Double(index)
    }

    private func point(centre: CGPoint, radius: CGFloat, index: Int, fraction: Double) -> CGPoint {
        let theta = angle(for: index)
        return CGPoint(
            x: centre.x + cos(theta) * radius * fraction,
            y: centre.y + sin(theta) * radius * fraction
        )
    }

    private func polygon(centre: CGPoint, radius: CGFloat, fractions: [Double]) -> Path {
        var path = Path()
        for (index, fraction) in fractions.enumerated() {
            let vertex = point(centre: centre, radius: radius, index: index, fraction: fraction)
            if index == 0 {
                path.move(to: vertex)
            } else {
                path.addLine(to: vertex)
            }
        }
        path.closeSubpath()
        return path
    }

    // MARK: Drawing

    private func drawGrid(in context: GraphicsContext, centre: CGPoint, radius: CGFloat) {
        // Two rings only. More would imply gradations that mean nothing here.
        for ring in [0.5, 1.0] {
            let path = polygon(
                centre: centre,
                radius: radius,
                fractions: Array(repeating: ring, count: effort.count)
            )
            context.stroke(path, with: .color(ColorTokens.borderSubtle), lineWidth: 1)
        }

        for index in effort.indices {
            var spoke = Path()
            spoke.move(to: centre)
            spoke.addLine(to: point(centre: centre, radius: radius, index: index, fraction: 1))
            context.stroke(spoke, with: .color(ColorTokens.borderSubtle), lineWidth: 1)
        }
    }

    private func drawPlot(in context: GraphicsContext, centre: CGPoint, radius: CGFloat) {
        let fractions = effort.map { min($0.share / scale, 1) }
        let path = polygon(centre: centre, radius: radius, fractions: fractions)

        // A single fill colour would have to belong to one dimension. Grey
        // keeps the area neutral and leaves hue to the vertices, which do name
        // a dimension each.
        context.fill(path, with: .color(ColorTokens.textPrimary.opacity(0.12)))
        context.stroke(path, with: .color(ColorTokens.textSecondary), lineWidth: lineWidth)

        for (index, item) in effort.enumerated() {
            let vertex = point(
                centre: centre, radius: radius, index: index, fraction: fractions[index]
            )
            let dot = Path(
                ellipseIn: CGRect(x: vertex.x - 5, y: vertex.y - 5, width: 10, height: 10)
            )
            context.fill(dot, with: .color(item.domain.accent))
        }
    }

    private func drawVertices(in context: GraphicsContext, centre: CGPoint, radius: CGFloat) {
        for (index, item) in effort.enumerated() {
            let anchor = point(centre: centre, radius: radius + 18, index: index, fraction: 1)
            // Symbol as well as colour: the axes must be tellable apart
            // without relying on hue.
            let label = context.resolve(
                Text(Image(systemName: item.domain.symbolName))
                    .font(TypographyTokens.caption)
                    .foregroundStyle(item.domain.accent)
            )
            context.draw(label, at: anchor)
        }
    }
}

#Preview("Balanced") {
    DimensionBalanceWheel(effort: [
        DomainEffort(domain: .health, completions: 4, share: 0.34),
        DomainEffort(domain: .career, completions: 4, share: 0.33),
        DomainEffort(domain: .fun, completions: 4, share: 0.33),
    ])
    .padding()
    .background(ColorTokens.backgroundBase)
    .preferredColorScheme(.dark)
}

#Preview("Leaning") {
    DimensionBalanceWheel(effort: [
        DomainEffort(domain: .health, completions: 9, share: 0.75),
        DomainEffort(domain: .career, completions: 2, share: 0.17),
        DomainEffort(domain: .fun, completions: 1, share: 0.08),
    ])
    .padding()
    .background(ColorTokens.backgroundBase)
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    DimensionBalanceWheel(
        effort: DimensionDomain.allCases.map {
            DomainEffort(domain: $0, completions: 0, share: 0)
        }
    )
    .padding()
    .background(ColorTokens.backgroundBase)
    .preferredColorScheme(.dark)
}

//
//  DesignSystemGallery.swift
//  tao-24
//

import SwiftUI

/// Renders every token and component together, so the system can be reviewed
/// as a whole rather than one screen at a time.
private struct DesignSystemGallery: View {
    @State private var activeDomain: DimensionDomain? = .career
    @State private var completion: [DimensionDomain: Bool] = [
        .health: true,
        .career: false,
        .fun: false,
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                Text("Dimensions of Joy")
                    .displayStyle()

                heroCard

                group("Domain pills") {
                    HStack(spacing: LayoutTokens.Spacing.sm) {
                        ForEach(DimensionDomain.allCases) { domain in
                            DomainPill(domain: domain, isActive: activeDomain == domain) {
                                activeDomain = activeDomain == domain ? nil : domain
                            }
                        }
                    }
                }

                group("Completion rings") {
                    ForEach(DimensionDomain.allCases) { domain in
                        HStack(spacing: LayoutTokens.Spacing.md) {
                            CompletionRing(
                                domain: domain,
                                isComplete: binding(for: domain)
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sampleHabit(for: domain)).bodyStyle(emphasised: true)
                                Text("Goal: \(sampleGoal(for: domain))").captionStyle(muted: true)
                            }
                            Spacer()
                        }
                    }
                }

                group("Surfaces") {
                    ForEach(surfaces, id: \.0) { name, color in
                        HStack(spacing: LayoutTokens.Spacing.md) {
                            RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
                                .fill(color)
                                .overlay {
                                    RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
                                        .strokeBorder(
                                            ColorTokens.borderSubtle,
                                            lineWidth: LayoutTokens.Stroke.hairline
                                        )
                                }
                                .frame(width: 64, height: 32)
                            Text(name).captionStyle()
                        }
                    }
                }

                group("Type") {
                    Text("Display").displayStyle()
                    Text("Header 1").header1Style()
                    Text("Header 2").header2Style()
                    Text("Header 3").header3Style()
                    Text("Body copy").bodyStyle()
                    Text("Body emphasis").bodyStyle(emphasised: true)
                    Text("Caption").captionStyle()
                    Text("Muted caption").captionStyle(muted: true)
                }
            }
            .padding(LayoutTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ColorTokens.backgroundBase)
    }

    private var surfaces: [(String, Color)] {
        [
            ("backgroundBase", ColorTokens.backgroundBase),
            ("backgroundSurface", ColorTokens.backgroundSurface),
            ("backgroundCard", ColorTokens.backgroundCard),
            ("backgroundOverlay", ColorTokens.backgroundOverlay),
        ]
    }

    private var heroCard: some View {
        TaoCard(domain: activeDomain ?? .career, isHero: true) {
            VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
                Text("This week").captionStyle()
                Text("Sustained deep work & recovery").header1Style()
                Text("8 of 11 habits, balanced across all three dimensions")
                    .captionStyle(muted: true)
            }
        }
    }

    private func binding(for domain: DimensionDomain) -> Binding<Bool> {
        Binding(
            get: { completion[domain] ?? false },
            set: { completion[domain] = $0 }
        )
    }

    private func sampleHabit(for domain: DimensionDomain) -> String {
        switch domain {
        case .health: "5km run"
        case .career: "45-min deep work block"
        case .fun: "Read one chapter"
        }
    }

    private func sampleGoal(for domain: DimensionDomain) -> String {
        switch domain {
        case .health: "Run a half marathon"
        case .career: "Master system design"
        case .fun: "Finish 12 books"
        }
    }

    private func group<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            Text(title).header3Style()
            content()
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundSurface,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }
}

#Preview("Gallery") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility XXXL") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}

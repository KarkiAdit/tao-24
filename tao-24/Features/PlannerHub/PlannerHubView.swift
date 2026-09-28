//
//  PlannerHubView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// Discovery: the three dimension portals, a feed of short reads, and the
/// curated sets.
///
/// This is the half of the product that explains rather than tracks — the
/// reason the app claims to build understanding and not just streaks — so the
/// reads sit alongside the sets rather than behind a menu.
struct PlannerHubView: View {
    @Environment(\.modelContext) private var context
    @State private var controller = PlannerHubController()
    @State private var focusedDomain: DimensionDomain?

    var body: some View {
        ZStack {
            ColorTokens.backgroundBase.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                    header
                    domainGrid
                    resourceFeed
                    blueprintSets
                }
                .padding(LayoutTokens.Spacing.lg)
            }
        }
        .sheet(item: $controller.inspectedBlueprint) { blueprint in
            BlueprintDetailSheet(
                blueprint: blueprint,
                controller: controller,
                pendingCount: controller.pendingCount(for: blueprint, in: context)
            ) {
                controller.adopt(blueprint, in: context)
            }
        }
        .alert(
            "Something went wrong",
            isPresented: .init(
                get: { controller.errorMessage != nil },
                set: { if !$0 { controller.errorMessage = nil } }
            ),
            actions: { Button("OK", role: .cancel) { controller.errorMessage = nil } },
            message: { Text(controller.errorMessage ?? "") }
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
            Text("Plan").displayStyle()
            Text("Explore a dimension, or take a whole set.")
                .captionStyle()
        }
    }

    // MARK: Dimension portals

    private var domainGrid: some View {
        VStack(spacing: LayoutTokens.Spacing.md) {
            ForEach(DimensionDomain.allCases) { domain in
                domainCard(domain)
            }
        }
    }

    private func domainCard(_ domain: DimensionDomain) -> some View {
        let count = controller.activeHabitCount(for: domain, in: context)
        let isFocused = focusedDomain == domain
        return TaoCard(
            domain: domain,
            isHero: true,
            action: {
                withAnimation(LayoutTokens.Motion.spring) {
                    focusedDomain = isFocused ? nil : domain
                }
            }
        ) {
            HStack(alignment: .top, spacing: LayoutTokens.Spacing.md) {
                Image(systemName: domain.symbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(domain.accent)

                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
                    Text(domain.label).header2Style()
                    Text(countLabel(count)).captionStyle()
                }

                Spacer(minLength: LayoutTokens.Spacing.sm)

                Image(systemName: isFocused ? "chevron.up" : "chevron.down")
                    .foregroundStyle(ColorTokens.textSecondary)
            }
        }
        .accessibilityLabel("\(domain.label), \(countLabel(count))")
        .accessibilityHint("Filters the reads below")
    }

    /// Zero is stated neutrally. An empty dimension is a place to start, not a
    /// gap to feel bad about.
    private func countLabel(_ count: Int) -> String {
        switch count {
        case 0: "Nothing here yet"
        case 1: "1 active habit"
        default: "\(count) active habits"
        }
    }

    // MARK: Micro-resources

    private var resourceFeed: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            HStack {
                Text("Worth a minute").header3Style()
                Spacer()
                if let focusedDomain {
                    Text(focusedDomain.label.uppercased())
                        .font(TypographyTokens.tag)
                        .tracking(0.6)
                        .foregroundStyle(focusedDomain.accent)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LayoutTokens.Spacing.md) {
                    ForEach(controller.resources(for: focusedDomain)) { resource in
                        resourceCard(resource)
                    }
                }
            }
        }
    }

    private func resourceCard(_ resource: MicroResource) -> some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text("\(resource.readMinutes) MIN READ")
                .font(TypographyTokens.tag)
                .tracking(0.6)
                .foregroundStyle(resource.domain?.accent ?? ColorTokens.textMuted)

            Text(resource.title)
                .bodyStyle(emphasised: true)
                .fixedSize(horizontal: false, vertical: true)

            Text(resource.summary)
                .captionStyle(muted: true)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(width: 260, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: Blueprints

    private var blueprintSets: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            Text("Curated sets").header3Style()

            ForEach(PlannerContent.blueprints) { blueprint in
                blueprintCard(blueprint)
            }
        }
    }

    private func blueprintCard(_ blueprint: Blueprint) -> some View {
        let adopted = controller.isFullyAdopted(blueprint, in: context)
        return TaoCard(action: { controller.inspect(blueprint) }) {
            VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
                        Text(blueprint.title).header2Style()
                        Text(blueprint.targetOutcome)
                            .captionStyle()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: LayoutTokens.Spacing.sm)
                    if adopted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ColorTokens.statusPositive)
                            .accessibilityLabel("Already added")
                    }
                }

                HStack(spacing: LayoutTokens.Spacing.sm) {
                    ForEach(blueprint.habits, id: \.self) { habit in
                        DomainPill(domain: habit.domain)
                    }
                }

                Text("Inspect set")
                    .font(TypographyTokens.tag)
                    .tracking(0.6)
                    .foregroundStyle(ColorTokens.textPrimary)
            }
        }
        .accessibilityLabel("\(blueprint.title). \(blueprint.targetOutcome)")
        .accessibilityHint("Opens the set")
    }
}

#Preview("Planner") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    let context = container.mainContext
    try! DatabaseService.seedIfNeeded(in: context)
    try! HabitExecutionService().createHabit(title: "5km run", domain: .health, in: context)

    return PlannerHubView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

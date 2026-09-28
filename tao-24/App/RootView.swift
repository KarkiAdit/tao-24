//
//  RootView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// Temporary root.
///
/// Phase 01 ships no screens — the Starter Hub replaces this in M2.1. Until
/// then it exists to prove the stack is actually wired: it reads seeded rows
/// through `@Query`, so if the container, schema or seeding were broken this
/// screen would be empty rather than everything looking fine until a feature
/// lands on top.
struct RootView: View {
    @Query(sort: \LifeGoal.createdAt, order: .forward) private var goals: [LifeGoal]

    /// True when the store could not be opened on disk. Surfaced because data
    /// written in this state disappears on relaunch.
    let isEphemeral: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                Text("Dimensions of Joy")
                    .displayStyle()

                if isEphemeral {
                    ephemeralWarning
                }

                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
                    Text("Your goals")
                        .header3Style()

                    if goals.isEmpty {
                        Text("No goals yet.")
                            .captionStyle(muted: true)
                    } else {
                        ForEach(goals) { goal in
                            goalCard(goal)
                        }
                    }
                }
            }
            .padding(LayoutTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ColorTokens.backgroundBase)
    }

    private func goalCard(_ goal: LifeGoal) -> some View {
        TaoCard(domain: goal.domain) {
            VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
                DomainPill(domain: goal.domain)
                Text(goal.title)
                    .header2Style()
            }
        }
    }

    private var ephemeralWarning: some View {
        HStack(spacing: LayoutTokens.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(ColorTokens.statusNotice)
            Text("Storage is temporary — changes will not survive a relaunch.")
                .captionStyle()
        }
        .padding(LayoutTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }
}

#Preview("Seeded") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    try! DatabaseService.seedIfNeeded(in: container.mainContext)
    return RootView(isEphemeral: false)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

#Preview("Ephemeral store") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    try! DatabaseService.seedIfNeeded(in: container.mainContext)
    return RootView(isEphemeral: true)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

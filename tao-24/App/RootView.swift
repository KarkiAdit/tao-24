//
//  RootView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// App root.
///
/// Carries the two shipped hubs and the app-level concern neither should own —
/// telling the user when their data is not being persisted.
///
/// The tab bar partly anticipates M3.1, which still owns navigation properly —
/// the onboarding deep link in particular. It lives here because a screen no
/// one can open cannot be reviewed.
struct RootView: View {

    /// True when the store could not be opened on disk. Surfaced because data
    /// written in this state disappears on relaunch.
    let isEphemeral: Bool

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                StarterHubView()
                    .tabItem { Label("Today", systemImage: "checklist") }

                PlannerHubView()
                    .tabItem { Label("Plan", systemImage: "square.grid.2x2") }

                ProgressHubView()
                    .tabItem { Label("Progress", systemImage: "chart.bar") }
            }
            .tint(ColorTokens.textPrimary)

            if isEphemeral {
                ephemeralWarning
                    .padding(.horizontal, LayoutTokens.Spacing.lg)
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
            ColorTokens.backgroundOverlay,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }
}

#Preview("Seeded") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    let context = container.mainContext
    try! DatabaseService.seedIfNeeded(in: context)
    try! HabitExecutionService().createHabit(
        title: "45-min deep work block",
        domain: .career,
        in: context
    )
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

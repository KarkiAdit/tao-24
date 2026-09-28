//
//  RootView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// App root.
///
/// The Starter Hub is the only screen in the MVP so far; tab navigation across
/// Planner and Progress arrives in M3.1. Until then this exists to own the
/// app-level concern the hub should not carry — telling the user when their
/// data is not being persisted.
struct RootView: View {

    /// True when the store could not be opened on disk. Surfaced because data
    /// written in this state disappears on relaunch.
    let isEphemeral: Bool

    var body: some View {
        ZStack(alignment: .top) {
            StarterHubView()

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

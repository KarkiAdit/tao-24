//
//  HabitRowCard.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// One habit in the daily checklist.
///
/// Layout follows the wireframe: ring on the left, name and goal anchor in the
/// middle, domain pill on the right. The goal tag is not decoration — it is
/// the thing that makes this a goal-aligned tracker rather than a to-do list,
/// so it stays visible on every row.
///
/// Pure presentation. Toggling calls back to the caller; this view never
/// touches a `ModelContext`.
struct HabitRowCard: View {
    let habit: Habit
    let isComplete: Bool
    let onToggle: () -> Void

    var body: some View {
        TaoCard {
            HStack(spacing: LayoutTokens.Spacing.md) {
                CompletionRing(domain: habit.domain, isComplete: toggleBinding)

                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
                    Text(habit.title)
                        .bodyStyle(emphasised: true)
                        // Completed rows soften rather than strike through:
                        // done is not "cancelled".
                        .opacity(isComplete ? 0.6 : 1)

                    if let goal = habit.goal {
                        Text("Goal: \(goal.title)")
                            .captionStyle(muted: true)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: LayoutTokens.Spacing.sm)

                DomainPill(domain: habit.domain)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: isComplete ? "Mark incomplete" : "Mark complete", onToggle)
    }

    /// Bridges `CompletionRing`'s binding to a callback. The ring animates from
    /// `isComplete`, which the store owns, so writes are forwarded rather than
    /// held locally — no chance of the ring and the database disagreeing.
    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { isComplete },
            set: { _ in onToggle() }
        )
    }

    private var accessibilityLabel: String {
        var parts = [habit.title, habit.domain.label]
        if let goal = habit.goal {
            parts.append("toward \(goal.title)")
        }
        parts.append(isComplete ? "completed" : "not completed")
        return parts.joined(separator: ", ")
    }
}

#Preview("Row states") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    let context = container.mainContext
    try! DatabaseService.seedIfNeeded(in: context)
    let goal = try! context.fetch(LifeGoalQuery.active()).first { $0.domain == .career }
    let habit = Habit(
        title: "45-min deep work block",
        domain: .career,
        frequency: .daily,
        goal: goal
    )

    return VStack(spacing: LayoutTokens.Spacing.md) {
        HabitRowCard(habit: habit, isComplete: false, onToggle: {})
        HabitRowCard(habit: habit, isComplete: true, onToggle: {})
    }
    .padding(LayoutTokens.Spacing.lg)
    .background(ColorTokens.backgroundBase)
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

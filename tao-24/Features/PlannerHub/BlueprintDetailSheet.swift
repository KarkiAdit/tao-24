//
//  BlueprintDetailSheet.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// Blueprint preview, with the adopt action.
///
/// The rationale accordion is the point of the screen as much as the habit
/// list is: the product's promise is understanding, not just tracking, so the
/// reasoning sits next to the thing it justifies rather than behind a link.
struct BlueprintDetailSheet: View {
    let blueprint: Blueprint
    @Bindable var controller: PlannerHubController
    let pendingCount: Int
    let onAdopt: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                    outcome
                    habitList
                    rationale
                    adoptButton
                }
                .padding(LayoutTokens.Spacing.lg)
            }
            .background(ColorTokens.backgroundBase)
            .navigationTitle(blueprint.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { controller.dismissInspection() }
                }
            }
        }
    }

    private var outcome: some View {
        Text(blueprint.targetOutcome)
            .header2Style()
    }

    private var habitList: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            Text("What you'd add").header3Style()

            ForEach(blueprint.habits, id: \.self) { habit in
                TaoCard {
                    HStack(spacing: LayoutTokens.Spacing.md) {
                        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
                            Text(habit.title).bodyStyle(emphasised: true)
                            Text(frequencyLabel(habit.frequency)).captionStyle(muted: true)
                        }
                        Spacer(minLength: LayoutTokens.Spacing.sm)
                        DomainPill(domain: habit.domain)
                    }
                }
            }
        }
    }

    private var rationale: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Button {
                withAnimation(LayoutTokens.Motion.spring) {
                    controller.isRationaleExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Why this combination works").header3Style()
                    Spacer()
                    Image(
                        systemName: controller.isRationaleExpanded ? "chevron.up" : "chevron.down"
                    )
                    .foregroundStyle(ColorTokens.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(controller.isRationaleExpanded ? "Collapses" : "Expands")

            if controller.isRationaleExpanded {
                Text(blueprint.rationale)
                    .bodyStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }

    @ViewBuilder
    private var adoptButton: some View {
        if pendingCount == 0 {
            // Already adopted. Say so plainly rather than offering a button
            // that would silently do nothing.
            HStack(spacing: LayoutTokens.Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ColorTokens.statusPositive)
                Text("You already have all of these.").captionStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Button(action: onAdopt) {
                Text(adoptLabel)
                    .font(TypographyTokens.bodyEmphasis)
                    .foregroundStyle(ColorTokens.backgroundBase)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LayoutTokens.Spacing.md)
                    .background(Capsule().fill(ColorTokens.textPrimary))
            }
            .buttonStyle(.plain)
        }
    }

    /// Names the real number so adopting a partly-held set never looks like it
    /// will duplicate what is already there.
    private var adoptLabel: String {
        pendingCount == blueprint.habits.count
            ? "Add these \(pendingCount) habits"
            : "Add the \(pendingCount) you're missing"
    }

    private func frequencyLabel(_ frequency: HabitFrequency) -> String {
        switch frequency {
        case .daily:
            "Every day"
        case .timesPerWeek(let count):
            "\(count)× a week"
        case .specificDays(let days):
            days == .weekdays ? "Weekdays" : "\(days.count) set days"
        }
    }
}

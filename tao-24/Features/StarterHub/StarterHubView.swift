//
//  StarterHubView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// The daily execution screen.
///
/// Reads active habits through `@Query` and lets `StarterHubController` decide
/// which are due and visible. The view renders and forwards gestures; every
/// mutation goes through the controller.
struct StarterHubView: View {
    @Query(HabitQuery.active()) private var habits: [Habit]
    @Query(LifeGoalQuery.active()) private var goals: [LifeGoal]
    @Environment(\.modelContext) private var context

    @State private var controller = StarterHubController()

    private var visible: [Habit] { controller.visibleHabits(from: habits) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ColorTokens.backgroundBase.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                    header
                    filterChips
                    checklist
                }
                .padding(LayoutTokens.Spacing.lg)
                // Room to scroll clear of the floating button.
                .padding(.bottom, LayoutTokens.Spacing.xxl * 2)
            }

            quickAddButton
                .padding(LayoutTokens.Spacing.lg)
        }
        .sheet(isPresented: $controller.isShowingQuickAdd) {
            QuickAddHabitSheet(controller: controller, goals: goals) {
                controller.saveDraft(in: context)
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

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                .captionStyle()

            Text("Today").displayStyle()

            // Progress as a plain count, never a streak. It states where you
            // are; it does not imply a chain you can break.
            Text("\(completedCount) of \(visible.count) done")
                .font(TypographyTokens.metric)
                .foregroundStyle(ColorTokens.textPrimary)
        }
    }

    private var completedCount: Int {
        controller.completedCount(among: visible, in: context)
    }

    // MARK: Filters

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LayoutTokens.Spacing.sm) {
                allChip
                ForEach(DimensionDomain.allCases) { domain in
                    DomainPill(
                        domain: domain,
                        isActive: controller.selectedDomainFilter == domain
                    ) {
                        controller.selectedDomainFilter =
                            controller.selectedDomainFilter == domain ? nil : domain
                    }
                }
            }
        }
    }

    private var allChip: some View {
        let isActive = controller.selectedDomainFilter == nil
        return Button {
            controller.selectedDomainFilter = nil
        } label: {
            Text("All")
                .textCase(.uppercase)
                .font(TypographyTokens.tag)
                .tracking(0.6)
                .foregroundStyle(isActive ? ColorTokens.onAccent : ColorTokens.textSecondary)
                .padding(.horizontal, LayoutTokens.Spacing.md)
                .padding(.vertical, LayoutTokens.Spacing.sm)
                .background {
                    Capsule()
                        .fill(
                            isActive
                                ? AnyShapeStyle(ColorTokens.textPrimary)
                                : AnyShapeStyle(ColorTokens.backgroundOverlay)
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }

    // MARK: Checklist

    @ViewBuilder
    private var checklist: some View {
        if visible.isEmpty {
            emptyState
        } else {
            VStack(spacing: LayoutTokens.Spacing.md) {
                ForEach(visible) { habit in
                    HabitRowCard(
                        habit: habit,
                        isComplete: controller.isComplete(habit, in: context)
                    ) {
                        controller.toggleCompletion(habit, in: context)
                    }
                }
            }
        }
    }

    /// Deliberately gentle. An empty list is a starting point, not a failure —
    /// no "you have nothing planned" scolding.
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text(emptyTitle).header2Style()
            Text("Add one with the button below whenever you're ready.")
                .captionStyle(muted: true)
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }

    private var emptyTitle: String {
        if let domain = controller.selectedDomainFilter {
            "Nothing in \(domain.label) today."
        } else {
            "Nothing scheduled today."
        }
    }

    // MARK: Quick add

    private var quickAddButton: some View {
        Button {
            controller.presentQuickAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                // Neutral white, not a domain accent: every hue in this app
                // names a dimension, and a green plus would read as "Health".
                .foregroundStyle(ColorTokens.backgroundBase)
                .frame(width: 56, height: 56)
                .background(Circle().fill(ColorTokens.textPrimary))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a habit")
    }
}

#Preview("Starter Hub") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    let context = container.mainContext
    try! DatabaseService.seedIfNeeded(in: context)
    let service = HabitExecutionService()
    try! service.createHabit(title: "45-min deep work block", domain: .career, in: context)
    try! service.createHabit(title: "5km run", domain: .health, in: context)
    let read = try! service.createHabit(title: "Read one chapter", domain: .fun, in: context)
    try! service.logCompletion(for: read, in: context)

    return StarterHubView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

#Preview("Empty") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    try! DatabaseService.seedIfNeeded(in: container.mainContext)
    return StarterHubView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

//
//  QuickAddHabitSheet.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// Low-friction habit creation.
///
/// Title is the only required field — everything else has a working default,
/// so a habit can be created in two taps and refined later. The goal picker
/// shows only the chosen domain's goals, and leaving it alone still anchors
/// the habit, because the Service falls back to the seeded goal for that
/// domain.
struct QuickAddHabitSheet: View {
    @Bindable var controller: StarterHubController
    let goals: [LifeGoal]
    let onSave: () -> Void

    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                    titleField
                    dimensionPicker
                    frequencyPicker
                    goalPicker
                }
                .padding(LayoutTokens.Spacing.lg)
            }
            .background(ColorTokens.backgroundBase)
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { controller.dismissQuickAdd() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(!controller.canSaveDraft)
                }
            }
        }
        .onAppear { titleFocused = true }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text("Habit").header3Style()
            TextField("Read 15 mins", text: $controller.draftTitle)
                .textInputAutocapitalization(.sentences)
                .focused($titleFocused)
                .font(TypographyTokens.body)
                .foregroundStyle(ColorTokens.textPrimary)
                .padding(LayoutTokens.Spacing.md)
                .background(
                    ColorTokens.backgroundCard,
                    in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
                )
        }
    }

    private var dimensionPicker: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text("Dimension").header3Style()
            HStack(spacing: LayoutTokens.Spacing.sm) {
                ForEach(DimensionDomain.allCases) { domain in
                    DomainPill(domain: domain, isActive: controller.draftDomain == domain) {
                        controller.draftDomain = domain
                        // The previous pick belongs to the old domain.
                        controller.draftGoal = nil
                    }
                }
            }
        }
    }

    private var frequencyPicker: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text("How often").header3Style()

            Picker("How often", selection: kindBinding) {
                Text("Daily").tag(HabitFrequency.Kind.daily)
                Text("Times a week").tag(HabitFrequency.Kind.timesPerWeek)
                Text("Set days").tag(HabitFrequency.Kind.specificDays)
            }
            .pickerStyle(.segmented)

            switch controller.draftFrequency {
            case .daily:
                EmptyView()
            case .timesPerWeek(let count):
                Stepper(
                    "\(count) \(count == 1 ? "day" : "days") a week",
                    value: timesPerWeekBinding,
                    in: 1...7
                )
                .font(TypographyTokens.body)
                .foregroundStyle(ColorTokens.textPrimary)
            case .specificDays(let days):
                weekdayRow(selected: days)
            }
        }
    }

    private func weekdayRow(selected: Weekday) -> some View {
        HStack(spacing: LayoutTokens.Spacing.xs) {
            ForEach(Self.weekdayOptions, id: \.label) { option in
                let isOn = selected.contains(option.day)
                Button {
                    var updated = selected
                    if isOn {
                        updated.remove(option.day)
                    } else {
                        updated.insert(option.day)
                    }
                    controller.draftFrequency = .specificDays(updated)
                } label: {
                    Text(option.label)
                        .font(TypographyTokens.tag)
                        .foregroundStyle(
                            isOn ? controller.draftDomain.onAccent : ColorTokens.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LayoutTokens.Spacing.sm)
                        .background {
                            Capsule()
                                .fill(
                                    isOn
                                        ? AnyShapeStyle(controller.draftDomain.accent)
                                        : AnyShapeStyle(ColorTokens.backgroundOverlay)
                                )
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.name)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
    }

    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            Text("Toward").header3Style()

            let available = controller.goals(for: controller.draftDomain, from: goals)
            if available.isEmpty {
                Text("No \(controller.draftDomain.label) goal yet.")
                    .captionStyle(muted: true)
            } else {
                ForEach(available) { goal in
                    goalRow(goal, isSelected: controller.draftGoal?.id == goal.id)
                }
                Text("Leave unpicked and it attaches to your \(controller.draftDomain.label) goal.")
                    .captionStyle(muted: true)
            }
        }
    }

    private func goalRow(_ goal: LifeGoal, isSelected: Bool) -> some View {
        Button {
            controller.draftGoal = isSelected ? nil : goal
        } label: {
            HStack(spacing: LayoutTokens.Spacing.sm) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? goal.domain.accent : ColorTokens.textMuted)
                Text(goal.title)
                    .bodyStyle()
                Spacer()
            }
            .padding(LayoutTokens.Spacing.md)
            .background(
                ColorTokens.backgroundCard,
                in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: Bindings

    /// Switching kind keeps a sensible payload rather than resetting to zero.
    private var kindBinding: Binding<HabitFrequency.Kind> {
        Binding(
            get: { controller.draftFrequency.kind },
            set: { kind in
                switch kind {
                case .daily: controller.draftFrequency = .daily
                case .timesPerWeek: controller.draftFrequency = .timesPerWeek(3)
                case .specificDays: controller.draftFrequency = .specificDays(.weekdays)
                }
            }
        )
    }

    private var timesPerWeekBinding: Binding<Int> {
        Binding(
            get: { controller.draftFrequency.weeklyTargetCount },
            set: { controller.draftFrequency = .timesPerWeek($0) }
        )
    }

    private static let weekdayOptions: [(label: String, name: String, day: Weekday)] = [
        ("S", "Sunday", .sunday),
        ("M", "Monday", .monday),
        ("T", "Tuesday", .tuesday),
        ("W", "Wednesday", .wednesday),
        ("T", "Thursday", .thursday),
        ("F", "Friday", .friday),
        ("S", "Saturday", .saturday),
    ]
}

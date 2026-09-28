//
//  ProgressHubView.swift
//  tao-24
//

import SwiftData
import SwiftUI

/// Balance and momentum over a chosen window.
///
/// Everything here is a trend. There is no streak counter, no chain, and no
/// red — the screen's job is to show where effort went, not to grade it.
struct ProgressHubView: View {
    @Environment(\.modelContext) private var context
    @State private var controller = ProgressHubController()

    private var effort: [DomainEffort] { controller.domainEffort(in: context) }
    private var days: [DailyCompletion] { controller.dailyCompletions(in: context) }

    var body: some View {
        ZStack {
            ColorTokens.backgroundBase.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xl) {
                    header
                    timeframePicker
                    balanceSection
                    consistencySection
                }
                .padding(LayoutTokens.Spacing.lg)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.xs) {
            Text("Progress").displayStyle()
            Text(
                "\(controller.totalCompletions(in: context)) completions in the last "
                    + controller.timeframe.label
            )
            .captionStyle()
        }
    }

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $controller.timeframe) {
            ForEach(ProgressTimeframe.allCases) { timeframe in
                Text(timeframe.label).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: Balance

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            Text("Balance").header3Style()

            DimensionBalanceWheel(effort: effort)

            insightBadge

            VStack(spacing: LayoutTokens.Spacing.sm) {
                ForEach(effort) { item in
                    HStack(spacing: LayoutTokens.Spacing.sm) {
                        DomainPill(domain: item.domain)
                        Spacer()
                        Text("\(item.completions)")
                            .font(TypographyTokens.bodyEmphasis)
                            .foregroundStyle(ColorTokens.textPrimary)
                        Text("\(Int((item.share * 100).rounded()))%")
                            .captionStyle(muted: true)
                            .frame(width: 44, alignment: .trailing)
                    }
                }
            }
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }

    private var insightBadge: some View {
        Text(controller.insight(for: effort).message)
            .captionStyle()
            .fixedSize(horizontal: false, vertical: true)
            .padding(LayoutTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ColorTokens.backgroundOverlay,
                in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
            )
    }

    // MARK: Consistency

    private var consistencySection: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.md) {
            Text("Consistency").header3Style()
            ConsistencyBarChart(days: days, timeframe: controller.timeframe)
            Text("Faint bars are days with nothing scheduled.")
                .captionStyle(muted: true)
        }
        .padding(LayoutTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ColorTokens.backgroundCard,
            in: RoundedRectangle(cornerRadius: LayoutTokens.Radius.card)
        )
    }
}

#Preview("Progress") {
    let container = try! DatabaseService.makeContainer(inMemory: true)
    let context = container.mainContext
    try! DatabaseService.seedIfNeeded(in: context)
    let execution = HabitExecutionService()
    let calendar = Calendar.current
    let today = Date()

    for (domain, title) in [
        (DimensionDomain.health, "5km run"),
        (.career, "Deep work"),
        (.fun, "Read a chapter"),
    ] {
        let habit = try! execution.createHabit(title: title, domain: domain, in: context)
        habit.createdAt = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        for offset in 0..<6 where offset % (domain == .fun ? 3 : 1) == 0 {
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            try! execution.logCompletion(for: habit, on: day, in: context)
        }
    }
    try! context.save()

    return ProgressHubView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}

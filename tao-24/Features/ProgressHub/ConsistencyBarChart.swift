//
//  ConsistencyBarChart.swift
//  tao-24
//

import Charts
import SwiftUI

/// Daily completion across the window.
///
/// Reads as a trend rather than a chain. There is no gap-highlighting, no red,
/// and no "streak broken" marker: a missed day is simply a shorter bar beside
/// taller ones, which is the honest picture and the one the product asks for.
///
/// Rest days — nothing scheduled — are drawn as a faint baseline rather than
/// as zero. A day you were never meant to do anything is not a day you failed.
struct ConsistencyBarChart: View {
    let days: [DailyCompletion]
    let timeframe: ProgressTimeframe

    /// Average across days that actually had something scheduled. Rest days
    /// are excluded, since including them would drag the figure down for
    /// resting as planned.
    private var average: Double {
        let scheduled = days.filter(\.hasSchedule)
        guard !scheduled.isEmpty else { return 0 }
        return scheduled.reduce(0) { $0 + $1.ratio } / Double(scheduled.count)
    }

    private var hasAnySchedule: Bool { days.contains(where: \.hasSchedule) }

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutTokens.Spacing.sm) {
            if hasAnySchedule {
                Text("\(Int((average * 100).rounded()))% average")
                    .font(TypographyTokens.metric)
                    .foregroundStyle(ColorTokens.textPrimary)
            }

            chart
                .frame(height: 160)
                .accessibilityElement()
                .accessibilityLabel("Daily completion over \(timeframe.label)")
                .accessibilityValue(accessibilityValue)
        }
    }

    private var chart: some View {
        Chart(days) { day in
            if day.hasSchedule {
                BarMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Completed", day.ratio)
                )
                .foregroundStyle(ColorTokens.textPrimary)
                .cornerRadius(2)
            } else {
                // Visible but plainly different: nothing was due.
                BarMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Completed", 0.04)
                )
                .foregroundStyle(ColorTokens.backgroundOverlay)
                .cornerRadius(2)
            }
        }
        .chartYScale(domain: 0...1)
        .chartYAxis {
            AxisMarks(values: [0, 0.5, 1]) { value in
                AxisGridLine().foregroundStyle(ColorTokens.borderSubtle)
                AxisValueLabel {
                    if let ratio = value.as(Double.self) {
                        Text("\(Int(ratio * 100))%")
                            .font(TypographyTokens.caption)
                            .foregroundStyle(ColorTokens.textMuted)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: axisStride)) { value in
                AxisValueLabel(format: .dateTime.month(.narrow).day())
                    .font(TypographyTokens.caption)
                    .foregroundStyle(ColorTokens.textMuted)
            }
        }
    }

    /// Fewer labels on longer windows — 90 daily ticks would be unreadable.
    private var axisStride: Int {
        switch timeframe {
        case .week: 1
        case .month: 7
        case .quarter: 21
        }
    }

    private var accessibilityValue: String {
        guard hasAnySchedule else { return "Nothing scheduled in this window" }
        let scheduled = days.filter(\.hasSchedule).count
        let full = days.filter { $0.ratio == 1 }.count
        return "\(Int((average * 100).rounded())) percent average across \(scheduled) days, "
            + "\(full) fully complete"
    }
}

#Preview("Week") {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let days = (0..<7).reversed().map { offset -> DailyCompletion in
        let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
        let scheduled = offset == 3 ? 0 : 3
        return DailyCompletion(
            day: day,
            completed: scheduled == 0 ? 0 : max(0, 3 - (offset % 3)),
            scheduled: scheduled
        )
    }

    return ConsistencyBarChart(days: days, timeframe: .week)
        .padding()
        .background(ColorTokens.backgroundBase)
        .preferredColorScheme(.dark)
}

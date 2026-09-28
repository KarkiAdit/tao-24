//
//  ProgressMetrics.swift
//  tao-24
//

import Foundation

/// The windows the Progress Hub can look back over.
enum ProgressTimeframe: Int, CaseIterable, Identifiable, Sendable {
    case week = 7
    case month = 30
    case quarter = 90

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .week: "7 days"
        case .month: "30 days"
        case .quarter: "90 days"
        }
    }

    var days: Int { rawValue }
}

/// One day's completion, as a fraction of what was scheduled that day.
///
/// `scheduled` is the denominator, and it is not simply "all habits" — a habit
/// only counts on days it was actually due, and not before it existed. Without
/// that, adding a habit today would retroactively wreck last month.
struct DailyCompletion: Identifiable, Hashable, Sendable {
    let day: Date
    let completed: Int
    let scheduled: Int

    var id: Date { day }

    /// 0...1. A day with nothing scheduled is 0 rather than undefined, but
    /// `hasSchedule` distinguishes it from a day that was missed.
    var ratio: Double {
        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }

    /// False on a rest day. Rendering has to tell "nothing was due" apart from
    /// "nothing was done" — conflating them turns a planned day off into an
    /// apparent failure.
    var hasSchedule: Bool { scheduled > 0 }
}

/// How one dimension's completions compare with the others over a window.
struct DomainEffort: Identifiable, Hashable, Sendable {
    let domain: DimensionDomain
    let completions: Int
    /// 0...1 of all completions in the window.
    let share: Double

    var id: String { domain.rawValue }
}

/// What the balance wheel is saying, in words.
///
/// Every case is neutral or warm. There is deliberately no "you are failing
/// Health" — the wheel reports distribution, it does not grade it.
enum BalanceInsight: Equatable, Sendable {
    case noData
    case balanced
    case leaning(DimensionDomain)
    case untouched(DimensionDomain)

    var message: String {
        switch self {
        case .noData:
            "Nothing logged in this window yet."
        case .balanced:
            "Effort is spread evenly across all three dimensions."
        case .leaning(let domain):
            "Most of your effort went to \(domain.label) this period."
        case .untouched(let domain):
            "\(domain.label) hasn't seen anything yet — worth a look when you're ready."
        }
    }
}

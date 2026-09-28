//
//  ProgressHubController.swift
//  tao-24
//

import Foundation
import Observation
import SwiftData

/// Presentation state for the Progress Hub.
@Observable
@MainActor
final class ProgressHubController {

    var timeframe: ProgressTimeframe = .week

    private let progressService: ProgressService

    init(progressService: ProgressService? = nil) {
        self.progressService = progressService ?? .shared
    }

    /// The window the current timeframe covers, ending today.
    func range(endingOn endDate: Date = Date(), calendar: Calendar = .current) -> (
        start: Date, end: Date
    ) {
        progressService.range(for: timeframe, endingOn: endDate, calendar: calendar)
    }

    func dailyCompletions(
        in context: ModelContext,
        endingOn endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [DailyCompletion] {
        let window = range(endingOn: endDate, calendar: calendar)
        return
            (try? progressService.dailyCompletions(
                from: window.start, to: window.end, in: context, calendar: calendar
            )) ?? []
    }

    func domainEffort(
        in context: ModelContext,
        endingOn endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [DomainEffort] {
        let window = range(endingOn: endDate, calendar: calendar)
        return
            (try? progressService.domainEffort(
                from: window.start, to: window.end, in: context, calendar: calendar
            ))
            ?? DimensionDomain.allCases.map {
                DomainEffort(domain: $0, completions: 0, share: 0)
            }
    }

    func insight(for effort: [DomainEffort]) -> BalanceInsight {
        progressService.insight(for: effort)
    }

    func totalCompletions(
        in context: ModelContext,
        endingOn endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let window = range(endingOn: endDate, calendar: calendar)
        return
            (try? progressService.totalCompletions(
                from: window.start, to: window.end, in: context, calendar: calendar
            )) ?? 0
    }
}

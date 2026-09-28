//
//  StarterHubController.swift
//  tao-24
//

import Foundation
import Observation
import SwiftData

/// Presentation state for the Starter Hub.
///
/// Holds what the screen is showing — the active filter, the quick-add sheet
/// and its draft — and delegates every mutation to `HabitExecutionService`.
/// No SwiftUI import: the view reads this, this never reaches back.
@Observable
@MainActor
final class StarterHubController {

    // MARK: Filter

    /// `nil` means "All". Filtering is presentation state, so it lives here
    /// rather than in a `@Query` predicate — switching chips should not
    /// re-query the store.
    var selectedDomainFilter: DimensionDomain?

    // MARK: Quick-add draft

    var isShowingQuickAdd = false
    var draftTitle = ""
    var draftDomain: DimensionDomain = .health
    var draftFrequency: HabitFrequency = .daily
    var draftGoal: LifeGoal?

    /// Surfaced to the view when an action fails, instead of failing silently.
    var errorMessage: String?

    private let executionService: HabitExecutionService

    /// Takes `nil` rather than defaulting to `.shared` in the signature:
    /// default-argument expressions are evaluated nonisolated in Swift 5 mode,
    /// so naming the main-actor singleton there warns. Resolving it in the
    /// body keeps injection available without the warning.
    init(executionService: HabitExecutionService? = nil) {
        self.executionService = executionService ?? .shared
    }

    // MARK: Derived state

    /// Today's list: active habits scheduled for `date`, narrowed by the
    /// filter chip. Takes the fetched habits rather than querying, so the view
    /// keeps its `@Query` and this stays testable without a store.
    func visibleHabits(from habits: [Habit], on date: Date = Date()) -> [Habit] {
        habits
            .filter { !$0.isArchived }
            .filter { selectedDomainFilter == nil || $0.domain == selectedDomainFilter }
            .filter { $0.frequency.isDue(on: date) }
    }

    /// How many of the given habits are done — the "3 of 7" figure.
    ///
    /// Counted against the *visible* list so the number always matches what is
    /// on screen under the current filter.
    func completedCount(
        among habits: [Habit],
        on date: Date = Date(),
        in context: ModelContext
    ) -> Int {
        habits.filter { habit in
            (try? executionService.isComplete(habit, on: date, in: context)) ?? false
        }
        .count
    }

    /// Goals offered in the quick-add picker, narrowed to the draft's domain
    /// so the anchor always makes sense.
    func goals(for domain: DimensionDomain, from goals: [LifeGoal]) -> [LifeGoal] {
        goals.filter { $0.isActive && $0.domain == domain }
    }

    /// A draft is savable once it has a title. The goal anchor is resolved by
    /// the Service, so it is not required here.
    var canSaveDraft: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Actions

    func isComplete(_ habit: Habit, on date: Date = Date(), in context: ModelContext) -> Bool {
        (try? executionService.isComplete(habit, on: date, in: context)) ?? false
    }

    func toggleCompletion(
        _ habit: Habit,
        on date: Date = Date(),
        in context: ModelContext
    ) {
        do {
            try executionService.toggleCompletion(for: habit, on: date, in: context)
        } catch {
            errorMessage = "Could not update that habit."
        }
    }

    func presentQuickAdd(defaultDomain: DimensionDomain? = nil) {
        draftTitle = ""
        draftDomain = defaultDomain ?? selectedDomainFilter ?? .health
        draftFrequency = .daily
        draftGoal = nil
        isShowingQuickAdd = true
    }

    func dismissQuickAdd() {
        isShowingQuickAdd = false
    }

    /// Saves the draft. Leaves the sheet open on failure so the input is not
    /// lost.
    func saveDraft(in context: ModelContext) {
        guard canSaveDraft else { return }
        do {
            try executionService.createHabit(
                title: draftTitle,
                domain: draftDomain,
                frequency: draftFrequency,
                goal: draftGoal,
                in: context
            )
            isShowingQuickAdd = false
        } catch HabitCreationError.noGoalAvailable(let domain) {
            errorMessage = "No \(domain.label) goal to attach this to yet."
        } catch {
            errorMessage = "Could not save that habit."
        }
    }
}

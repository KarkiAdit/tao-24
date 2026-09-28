//
//  PlannerContent.swift
//  tao-24
//

import Foundation

/// One habit inside a blueprint, before it becomes a `Habit` row.
struct BlueprintHabit: Hashable, Sendable {
    let title: String
    let domain: DimensionDomain
    let frequency: HabitFrequency
}

/// A pre-packaged set of habits covering all three dimensions.
struct Blueprint: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    /// What adopting this is meant to achieve, in the user's terms.
    let targetOutcome: String
    /// Why *this combination* works — the "Research Rationale" accordion.
    let rationale: String
    /// One habit per dimension, which is what makes a set balanced.
    let habits: [BlueprintHabit]
}

/// A one-minute read explaining the reasoning behind a habit pattern.
struct MicroResource: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let readMinutes: Int
    /// `nil` when the idea spans dimensions rather than belonging to one.
    let domain: DimensionDomain?
}

/// Blueprints and micro-resources, shipped as code rather than as rows.
///
/// Deliberately not SwiftData entities. They are read-only app content, so as
/// rows every copy edit would become a schema migration, and CloudKit would
/// sync three identical copies of the same text to every device. As a static
/// catalog they version with the binary, which is what they actually are.
///
/// The user's *adopted* habits are rows. The template is not.
enum PlannerContent {

    static let blueprints: [Blueprint] = [
        Blueprint(
            id: "balanced-engineer",
            title: "The Balanced Engineer",
            targetOutcome: "Deep focus without burning out the rest of your life.",
            rationale: """
                Concentrated work is limited by recovery, not by willpower. Pairing a \
                single protected focus block with daily movement and a genuinely \
                unproductive hour keeps the focus sustainable — the fun habit is not a \
                reward for the work, it is part of what makes the work repeatable.
                """,
            habits: [
                BlueprintHabit(
                    title: "45-min deep work block",
                    domain: .career,
                    frequency: .specificDays(.weekdays)
                ),
                BlueprintHabit(title: "20-min walk", domain: .health, frequency: .daily),
                BlueprintHabit(
                    title: "An hour with no screens",
                    domain: .fun,
                    frequency: .timesPerWeek(3)
                ),
            ]
        ),
        Blueprint(
            id: "steady-restart",
            title: "The Steady Restart",
            targetOutcome: "Rebuild momentum after a gap, without overcommitting.",
            rationale: """
                Restarting fails when the plan is sized for the person you were before \
                the gap. Every habit here is small enough to finish on a bad day, \
                because the point of the first few weeks is proving the routine exists \
                at all — not making progress on it.
                """,
            habits: [
                BlueprintHabit(
                    title: "Ten minutes of movement", domain: .health, frequency: .daily),
                BlueprintHabit(
                    title: "Write down tomorrow's one priority",
                    domain: .career,
                    frequency: .specificDays(.weekdays)
                ),
                BlueprintHabit(
                    title: "Read a few pages",
                    domain: .fun,
                    frequency: .timesPerWeek(4)
                ),
            ]
        ),
        Blueprint(
            id: "social-anchor",
            title: "The Social Anchor",
            targetOutcome: "Build consistency through people rather than discipline.",
            rationale: """
                For anyone who finds solo routines fragile, accountability does the work \
                that motivation cannot. Each habit here has another person attached, so \
                showing up is a commitment to someone rather than a negotiation with \
                yourself.
                """,
            habits: [
                BlueprintHabit(
                    title: "Partner workout",
                    domain: .health,
                    frequency: .timesPerWeek(2)
                ),
                BlueprintHabit(
                    title: "Weekly peer check-in",
                    domain: .career,
                    frequency: .timesPerWeek(1)
                ),
                BlueprintHabit(
                    title: "See a friend, no agenda",
                    domain: .fun,
                    frequency: .timesPerWeek(1)
                ),
            ]
        ),
    ]

    static let microResources: [MicroResource] = [
        MicroResource(
            id: "habit-stacking",
            title: "The science of habit stacking",
            summary: """
                A new habit sticks faster when it is attached to one you already do \
                without thinking. The existing habit becomes the reminder, so you are \
                not relying on memory or motivation.
                """,
            readMinutes: 1,
            domain: nil
        ),
        MicroResource(
            id: "fun-prevents-burnout",
            title: "Why fun prevents career burnout",
            summary: """
                Rest that is scheduled gets taken; rest that is left over does not. \
                Treating a genuinely unproductive hour as a commitment protects the \
                capacity that ambitious work spends.
                """,
            readMinutes: 1,
            domain: .fun
        ),
        MicroResource(
            id: "missing-a-day",
            title: "Missing a day costs less than you think",
            summary: """
                A single missed day has almost no effect on whether a habit forms. What \
                breaks a routine is the decision to abandon it after the miss — which is \
                why this app tracks your trend rather than an unbroken chain.
                """,
            readMinutes: 1,
            domain: nil
        ),
        MicroResource(
            id: "smallest-viable",
            title: "Start smaller than feels worthwhile",
            summary: """
                A habit you can finish on your worst day is the one that survives. Scale \
                up only once showing up has stopped requiring a decision.
                """,
            readMinutes: 1,
            domain: .health
        ),
    ]
}

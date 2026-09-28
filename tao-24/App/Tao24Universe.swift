//
//  Tao24Universe.swift
//  tao-24
//
//  Created by Aditya Karki on 9/12/26.
//

import SwiftData
import SwiftUI

@main
struct Tao24Universe: App {

    private let database = DatabaseService.shared

    init() {
        do {
            // Synchronous on purpose. The store is local-first, so there is
            // nothing to wait on, and a screen that renders before its goals
            // exist would flash empty on first launch.
            try database.seedIfNeeded()
        } catch {
            // Not fatal: the app still runs, the user just has no starter
            // goals. Loud in debug, silent in release.
            assertionFailure("Seeding failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(isEphemeral: database.isEphemeral)
                // The palette is dark-only: ColorTokens has no light values,
                // so following the system setting would render unreadable.
                // Supplying light values is what unlocks removing this.
                .preferredColorScheme(.dark)
        }
        .modelContainer(database.container)
    }
}

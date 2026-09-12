//
//  Tao24Universe.swift
//  tao-24
//
//  Created by Aditya Karki on 9/12/26.
//

import SwiftUI

@main
struct Tao24Universe: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // The palette is dark-only: ColorTokens has no light values,
                // so following the system setting would render unreadable.
                // Supplying light values is what unlocks removing this.
                .preferredColorScheme(.dark)
        }
    }
}

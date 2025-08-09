//
//  subtrackerApp.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-07-04.
//

import SwiftUI

@main
struct subtrackerApp: App {
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"

    private var colorSchemePreference: ColorScheme? {
        switch selectedTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorSchemePreference)
        }
    }
}

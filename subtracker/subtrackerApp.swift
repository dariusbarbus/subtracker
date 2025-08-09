//
//  subtrackerApp.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-07-04.
//

import SwiftUI

class SubscriptionStore: ObservableObject {
    @AppStorage("selectedTheme") private var storedTheme: String = "system"

    @Published var selectedTheme: String = "system" {
            didSet {
                storedTheme = selectedTheme
            }
        }
    
    init() {
        selectedTheme = storedTheme
    }
    
    @Published var subscriptions: [Subscription] = []
    
    func loadSubscriptions() {
        // Implement loading logic here
    }
    
    func saveSubscriptions() {
        // Implement saving logic here
    }
}

@main
struct subtrackerApp: App {
    @StateObject private var store = SubscriptionStore()

    private var colorSchemePreference: ColorScheme? {
        switch store.selectedTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(colorSchemePreference)
        }
    }
}

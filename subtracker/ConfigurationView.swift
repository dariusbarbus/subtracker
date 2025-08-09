//
//  ConfigurationView.swift
//  subtracker
//
//  Created by Dario Simpson on 2025-08-09.
//

import SwiftUI

struct ConfigurationView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    @Environment(\.colorScheme) var colorScheme

    private var colorSchemePreference: ColorScheme? {
        switch selectedTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Appearance", selection: $selectedTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }
        }
        .preferredColorScheme(colorSchemePreference)
        .navigationTitle("Configuration")
    }
}

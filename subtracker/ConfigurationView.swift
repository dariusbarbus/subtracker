import SwiftUI
import UIKit

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ConfigurationView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    
    // Read subscriptions from UserDefaults (adjust if you store them elsewhere)
    @State private var subscriptions: [Subscription] = UserDefaults.standard.loadSubscriptions()
    
    // State to control showing the share sheet
    @State private var isSharePresented = false
    
    // Temporary URL for the JSON backup file
    @State private var backupURL: IdentifiableURL?

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
            
            Section {
                Button("Export Backup") {
                    exportBackup()
                }
            }
        }
        .navigationTitle("Configuration")
        .sheet(item: $backupURL, onDismiss: {
            if let url = backupURL?.url {
                try? FileManager.default.removeItem(at: url)
            }
            backupURL = nil
        }) { identifiableURL in
            ActivityView(activityItems: [identifiableURL.url])
        }
    }
    
    func exportBackup() {
        // Prepare data dictionary with subscriptions and settings
        let backupData = BackupData(subscriptions: subscriptions, selectedTheme: selectedTheme)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(backupData)
            
            // Create a temp file URL
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("subtracker_backup.json")
            
            // Write JSON to file
            try jsonData.write(to: tempURL)
            
            // Set URL and present share sheet
            backupURL = IdentifiableURL(url: tempURL)
            isSharePresented = true
            
        } catch {
            print("Error creating backup JSON: \(error)")
        }
    }
}

// Struct representing the full backup payload
struct BackupData: Codable {
    var subscriptions: [Subscription]
    var selectedTheme: String
}

// Wrapper to use UIKit share sheet in SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

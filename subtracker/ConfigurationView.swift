struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
import SwiftUI
import UIKit
import UniformTypeIdentifiers // For UTType.json

struct ConfigurationView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = "system"
    
    @State private var subscriptions: [Subscription] = UserDefaults.standard.loadSubscriptions()
    @State private var isSharePresented = false
    @State private var backupURL: IdentifiableURL?
    
    // New state to present the file importer
    @State private var isImporting = false
    
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
            Section{
                Button("Export Backup")
                {
                    exportBackup()
                }
            }
            
            Section {
                Button("Import Backup") {
                    isImporting = true
                }
                Text("App needs to be restarted to display changes")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    print("Selected file URL for import: \(url)")
                    importBackup(from: url)
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
    }
    
    func exportBackup() {
        let backupData = BackupData(subscriptions: subscriptions, selectedTheme: selectedTheme)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(backupData)
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("subtracker_backup.json")
            try jsonData.write(to: tempURL)
            
            backupURL = IdentifiableURL(url: tempURL)
            isSharePresented = true
            
        } catch {
            print("Error creating backup JSON: \(error)")
        }
    }
    
    func importBackup(from url: URL) {
        print("Starting import from URL: \(url)")
        do {
            let data = try Data(contentsOf: url)
            print("Read data of length: \(data.count)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Imported JSON content: \(jsonString)")
            }
            let decoder = JSONDecoder()
            let importedBackup = try decoder.decode(BackupData.self, from: data)
            
            // Merge imported subscriptions
            var updatedSubs = subscriptions
            
            for importedSub in importedBackup.subscriptions {
                if let existingIndex = updatedSubs.firstIndex(where: { $0.id == importedSub.id }) {
                    updatedSubs[existingIndex] = importedSub // overwrite existing
                } else {
                    updatedSubs.append(importedSub) // add new
                }
            }
            
            // Update state and storage
            subscriptions = updatedSubs
            selectedTheme = importedBackup.selectedTheme
            UserDefaults.standard.saveSubscriptions(updatedSubs)
            
        } catch {
            print("Failed to import backup: \(error)")
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

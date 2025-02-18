import SwiftUI

struct DatabaseSetting: View {
    @ObservedObject private var settings = Settings.shared

    @State private var showMessage: Bool = false
    @State private var sheetMessage: String = "Operation finished!"
    var body: some View {
        CloseableHeader()
        Text("Database Settings")
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text("Current Path:")
                .font(.headline)
            Text(settings.sharedPath.isEmpty ? "No database selected" : "~ \(settings.sharedPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        VStack {
            SettingsButton(
                action: {
                    let message = DatabaseManager.shared.selectDatabaseFile(settings: settings)
                    if(!message.isEmpty) {
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
                    }
                },
                icon: "externaldrive.fill.badge.questionmark",
                title: "Browse Database",
                subtitle: "Select a database file with extension .sqlite from your device."
            )

            SettingsButton(
                action: {
                    DatabaseManager.shared.selectFolder { folderURL in
                        if let folderURL = folderURL {
                            let message = DatabaseManager.shared.generateEmptyDatabase(at: folderURL)
                            if(!message.isEmpty) {
                                showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    withAnimation {
                                        showMessage = false
                                    }
                                }
                            }
                        }
                    }
                    
                },
                icon: "externaldrive.connected.to.line.below.fill",
                title: "Create Database File",
                subtitle: "Generate a new empty database file in the selected folder."
            )

            SettingsButton(
                action: {
                    DatabaseManager.shared.selectFolder { folderURL in
                        if let folderURL = folderURL {
                            let message = DatabaseManager.shared.backupDatabase(using: settings.sharedPath, to: folderURL)
                            if(!message.isEmpty) {
                                showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    withAnimation {
                                        showMessage = false
                                    }
                                }
                            }
                        }
                    }
               
                },
                icon: "tray.full.fill",
                title: "Create Database Backup",
                subtitle: "Create a backup of the currently used database in the selected folder."
            )
            
            
            

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showMessage) {
            AutoDismissSheetView(
                message: LocalizedStringKey(sheetMessage),
                displayDuration: 1.5,
                isPresented: $showMessage
            )
            .environment(\.locale, .init(identifier: settings.language.code))
        }
    }
}

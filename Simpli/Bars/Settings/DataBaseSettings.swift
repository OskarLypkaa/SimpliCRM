import SwiftUI

struct DatabaseSetting: View {
    @ObservedObject private var settings = Settings.shared

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
                    DatabaseManager.shared.selectDatabaseFile(settings: settings)
                },
                icon: "externaldrive.fill.badge.questionmark",
                title: "Browse Database",
                subtitle: "Select a database file with extension .sqlite from your device."
            )

            SettingsButton(
                action: {
                    DatabaseManager.shared.selectFolder { folderURL in
                        if let folderURL = folderURL {
                            DatabaseManager.shared.generateEmptyDatabase(at: folderURL)
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
                            DatabaseManager.shared.backupDatabase(using: settings.sharedPath, to: folderURL)
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
    }
}

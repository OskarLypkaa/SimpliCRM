import SwiftUI

struct DatabaseSetting: View {
    @ObservedObject private var settings = Settings.shared

    @State private var showMessage: Bool = false
    @State private var sheetMessage: String = "operation_finished"
    
    var body: some View {
        CloseableHeader()
        Text(LocalizedStringKey("database_settings"))
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text(LocalizedStringKey("current_path"))
                .font(.headline)
            Text(settings.sharedPath.isEmpty ? LocalizedStringKey("no_database_selected") : "~ \(settings.sharedPath)")
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
                title: LocalizedStringKey("browse_database"),
                subtitle: LocalizedStringKey("browse_database_description")
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
                title: LocalizedStringKey("create_database_file"),
                subtitle: LocalizedStringKey("create_database_file_description")
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
                title: LocalizedStringKey("create_database_backup"),
                subtitle: LocalizedStringKey("create_database_backup_description")
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

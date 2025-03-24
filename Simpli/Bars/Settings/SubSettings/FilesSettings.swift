import SwiftUI

struct FilesSetting: View {
    @ObservedObject private var settings = Settings.shared
    
    @State private var showMessage: Bool = false
    @State private var sheetMessage: String = "operation_finished"

    var body: some View {
        CloseableHeader()
        Text(LocalizedStringKey("files_settings"))
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text(LocalizedStringKey("current_path"))
                .font(.headline)
            Text(settings.filesPath.isEmpty ? LocalizedStringKey("no_path_selected") : "~ \(settings.filesPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        VStack {
            SettingsButton(
                action: {
                    let message = FilesManager.shared.setFilesFolder(settings: settings)
                    if (!message.isEmpty) {
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
                    }
                },
                icon: "folder.fill.badge.questionmark",
                title: LocalizedStringKey("select_files_folder"),
                subtitle: LocalizedStringKey("select_files_folder_description")
            )

            SettingsButton(
                action: {
                    var message = ""
                    do {
                        try message = FilesManager.shared.generateFoldersForUsers()
                    } catch {
                        print("Error generating folders!")
                    }
                    if (!message.isEmpty) {
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
                    }
                },
                icon: "folder.fill.badge.plus",
                title: LocalizedStringKey("generate_clients_folders"),
                subtitle: LocalizedStringKey("generate_clients_folders_description")
            )

            SettingsButton(
                action: {
                    DatabaseManager.shared.selectFolder { folderURL in
                        if let folderURL = folderURL {
                            let message = FilesManager.shared.backupFilesPath(using: settings.filesPath, to: folderURL) { progress in
                                print("Progress: \(progress * 100)%")
                            }
                            if (!message.isEmpty) {
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
                title: LocalizedStringKey("archive_files_folder"),
                subtitle: LocalizedStringKey("archive_files_folder_description")
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

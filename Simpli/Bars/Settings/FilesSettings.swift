import SwiftUI

struct FilesSetting: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        CloseableHeader()
        Text("Files Settings")
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text("Current Path:")
                .font(.headline)
            Text(settings.filesPath.isEmpty ? "No path selected" : "~ \(settings.filesPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        VStack {
            SettingsButton(
                action: {
                    FilesManager.shared.setFilesFolder(settings: settings)
                },
                icon: "folder.fill.badge.questionmark",
                title: "Select Files Folder",
                subtitle: "Select the folder where all of the client files will be stored."
            )

            SettingsButton(
                action: {
                    do {
                        try FilesManager.shared.generateFoldersForUsers()
                    } catch {
                        print("Error generating folders!")
                    }
                },
                icon: "folder.fill.badge.plus",
                title: "Generate Clients Folders",
                subtitle: "Generate folders for each client in the selected location."
            )

            SettingsButton(
                action: {
                    DatabaseManager.shared.selectFolder { folderURL in
                        if let folderURL = folderURL {
                            FilesManager.shared.backupFilesPath(using: settings.filesPath, to: folderURL) { progress in
                                print("Progress: \(progress * 100)%")
                            }
                        }
                    }
                },
                icon: "tray.full.fill",
                title: "Archive Files Folder",
                subtitle: "Archive all files to a selected folder."
            )
            

            Spacer()
        }
        .padding()
    }
}

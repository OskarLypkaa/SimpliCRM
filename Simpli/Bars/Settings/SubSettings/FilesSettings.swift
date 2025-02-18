import SwiftUI

struct FilesSetting: View {
    @ObservedObject private var settings = Settings.shared
    
    @State private var showMessage: Bool = false
    @State private var sheetMessage: String = "Operation finished!"
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
                    let message = FilesManager.shared.setFilesFolder(settings: settings)
                    if(!message.isEmpty) {
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
                    }
                },
                icon: "folder.fill.badge.questionmark",
                title: "Select Files Folder",
                subtitle: "Select the folder where all of the client files will be stored."
            )

            SettingsButton(
                action: {
                    var message = ""
                    do {
                        try message = FilesManager.shared.generateFoldersForUsers()
                    } catch {
                        print("Error generating folders!")
                    }
                    if(!message.isEmpty) {
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
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
                            let message = FilesManager.shared.backupFilesPath(using: settings.filesPath, to: folderURL) { progress in
                                print("Progress: \(progress * 100)%")
                            }
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
                title: "Archive Files Folder",
                subtitle: "Archive all files to a selected folder."
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

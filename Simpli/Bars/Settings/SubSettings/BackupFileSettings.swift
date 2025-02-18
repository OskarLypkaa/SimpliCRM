import SwiftUI

struct BackupFilesSetting: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        CloseableHeader()
        
        Text("Files Backup Settings")
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text("Backup Path:")
                .font(.headline)
            Text(settings.sharedPath.isEmpty ? "No files folder selected" : "~ \(settings.sharedPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        VStack {
            SettingsButton(
                action: {
                    DatabaseManager.shared.selectDatabaseFile(settings: settings)
                },
                icon: "folder.fill.badge.questionmark",
                title: "Select Backup Folder",
                subtitle: "Select a folder when you want to store automatically created backup."
            )
        
            HStack {
                Image(systemName: "checkmark.gobackward")
                    .font(.title2)
                    .foregroundColor(.primary)

                VStack(alignment: .leading) { // Wyrównanie zawartości do lewej
                    Text("Create Database Automatically:")
                        .font(.headline)
                    Toggle(isOn: $settings.automaticBackup) {}
                        .toggleStyle(SwitchToggleStyle())
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
            HStack {
                Image(systemName: "arrowshape.turn.up.backward.badge.clock.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 25)

                VStack(alignment: .leading) { // Wyrównanie zawartości do lewej
                    Text("Automatic Backup Of Files Interval:")
                        .font(.headline)

                    Picker("", selection: $settings.automaticBackupInterval) {
                        Text("3 minutes").tag(3)
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                        Text("30 minutes").tag(30)
                        Text("60 minutes").tag(60)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden() // Ukrywa pustą etykietę Picker
                    .fixedSize() // Zapobiega niepotrzebnemu rozciąganiu
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Zapewnia wyrównanie w HStack
            }

            Divider()
            Spacer()
        }
        .padding()
    }
}

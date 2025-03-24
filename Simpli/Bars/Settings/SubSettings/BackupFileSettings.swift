import SwiftUI

struct BackupFilesSetting: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        CloseableHeader()
        
        Text(LocalizedStringKey("files_backup_settings"))
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text(LocalizedStringKey("backup_path"))
                .font(.headline)
            Text(settings.automaticFilesBackupPath.isEmpty
                 ? LocalizedStringKey("no_files_folder_selected")
                 : "~ \(settings.automaticFilesBackupPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        VStack {
            SettingsButton(
                action: {
                    DatabaseManager.shared.setAutomaticFilesBackupPath { newPath in
                        if let path = newPath {
                            print("New Path: \(path)")
                        }
                    }
                },
                icon: "folder.fill.badge.questionmark",
                title: LocalizedStringKey("select_backup_folder"),
                subtitle: LocalizedStringKey("select_backup_folder_description")
            )
        
            HStack {
                Image(systemName: "checkmark.gobackward")
                    .font(.title2)
                    .foregroundColor(.primary)

                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("create_files_backup_automatically"))
                        .font(.headline)
                    Toggle(isOn: $settings.automaticFilesBackup) {}
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(settings.automaticFilesBackupPath.isEmpty)
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

                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("automatic_backup_files_interval"))
                        .font(.headline)

                    Picker("", selection: $settings.automaticFilesBackupInterval) {
                        Text(LocalizedStringKey("3_minutes")).tag(3)
                        Text(LocalizedStringKey("5_minutes")).tag(5)
                        Text(LocalizedStringKey("10_minutes")).tag(10)
                        Text(LocalizedStringKey("30_minutes")).tag(30)
                        Text(LocalizedStringKey("60_minutes")).tag(60)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden()
                    .fixedSize()
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
            Spacer()
        }
        .padding()
    }
}

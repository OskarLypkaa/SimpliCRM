import SwiftUI

struct BackupDatabaseSetting: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        CloseableHeader()
        
        Text(LocalizedStringKey("backup_settings_title"))
            .font(.largeTitle)
            .fontWeight(.bold)

        HStack {
            Text(LocalizedStringKey("backup_path"))
                .font(.headline)
            Text(settings.automaticDatabaseBackupPath.isEmpty
                 ? LocalizedStringKey("no_backup_folder_selected")
                 : "~ \(settings.automaticDatabaseBackupPath)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        VStack {
            SettingsButton(
                action: {
                    DatabaseManager.shared.setAutomaticDatabaseBackupPath { newPath in
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
                    Text(LocalizedStringKey("create_database_automatically"))
                        .font(.headline)
                    Toggle(isOn: $settings.automaticDatabaseBackup) {}
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(settings.automaticDatabaseBackupPath.isEmpty)
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
                    Text(LocalizedStringKey("automatic_backup_interval"))
                        .font(.headline)

                    Picker("", selection: $settings.automaticDatabaseBackupInterval) {
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

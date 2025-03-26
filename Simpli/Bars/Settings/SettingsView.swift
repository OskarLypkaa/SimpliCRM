import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct SettingsView: View {
    @State private var showMessage: Bool = false
    @ObservedObject private var settings = Settings.shared
    @State private var showDatabaseSettings: Bool = false
    @State private var showFilesSettings: Bool = false
    @State private var showBackupDatabaseSettings: Bool = false
    @State private var showBackupFilesSettings: Bool = false
    @State private var feedbackMessage: LocalizedStringKey = "operation_finished"

    var body: some View {
        CloseableHeader()
        Text(LocalizedStringKey("settings_title"))
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)

        Text(LocalizedStringKey("settings_subtitle"))
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

        ScrollView {
            Form {
                Section(header: Text(LocalizedStringKey("data_files_section")).font(.title)) {
                    Button(action: {
                        initializeNewEnvironment(settings: Settings.shared)
                        showMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showMessage = false
                            }
                        }
                        
                    }) {
                        Text(LocalizedStringKey("create_workspace"))
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showDatabaseSettings = true
                    }) {
                        Text(LocalizedStringKey("database_settings"))
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showDatabaseSettings) {
                        DatabaseSetting()
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showBackupDatabaseSettings = true
                    }) {
                        Text(LocalizedStringKey("automatic_database_backup_settings"))
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showBackupDatabaseSettings) {
                        BackupDatabaseSetting()
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showFilesSettings = true
                    }) {
                        Text(LocalizedStringKey("clients_files_settings"))
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showFilesSettings) {
                        FilesSetting()
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showBackupFilesSettings = true
                    }) {
                        Text(LocalizedStringKey("automatic_files_backup_settings"))
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .sheet(isPresented: $showBackupFilesSettings) {
                        BackupFilesSetting()
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                }
                Section(header: Text(LocalizedStringKey("appearance_section")).font(.title).padding(.bottom, 10)) {
                    Section(header: Text(LocalizedStringKey("color_section"))
                        .font(.title3)
                        .foregroundColor(.secondary)
                        ) {
                        VStack {
                            Picker("", selection: $settings.themeMode) {
                                ForEach(ThemeMode.allCases, id: \.self) { mode in
                                    Text(mode.localizedKey).tag(mode)
                                }
                            }
                            .padding(.bottom, 5)
                            .pickerStyle(SegmentedPickerStyle())
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                        }
                    }
                    

                    Section(header:
                        Text(LocalizedStringKey("language_section"))
                        .font(.title3)
                        .foregroundColor(.secondary)
                        ) {
                            Picker("", selection: $settings.language) {
                                ForEach(Language.allCases, id: \.self) { lang in
                                    Text(lang.rawValue).tag(lang)
                                }
                            }
                            .padding(.bottom, 10)
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }

                    Section(header: Text(LocalizedStringKey("archived_actions_section"))
                        .font(.title3)
                        .foregroundColor(.secondary)
                    ) {
                        Toggle(isOn: $settings.showArchived) {}
                            .toggleStyle(SwitchToggleStyle())
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                        }
                }
            }
        }
        .padding()
        .frame(width: 550, height: 500, alignment: .leading)
        .sheet(isPresented: $showMessage) {
            AutoDismissSheetView(
                message: feedbackMessage,
                displayDuration: 2,
                isPresented: $showMessage
            )
            .environment(\.locale, .init(identifier: settings.language.code))
        }
        .onChange(of: showMessage) {}
    }

    private func handleFileSelection(message: String) {
        feedbackMessage = LocalizedStringKey(message)
        showMessage = true
    }
}

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
    @State private var feedbackMessage: LocalizedStringKey = ""

    var body: some View {
        CloseableHeader()
        Text("settings_title")
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)

        Text("settings_subtitle")
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

        ScrollView {
            Form {
                Section(header: Text("Data & Files").font(.title)) {
                    Button(action: {
                        showDatabaseSettings = true
                    }) {
                        Text("Database Settings")
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            
                            
                    }
                    .sheet(isPresented: $showDatabaseSettings) {
                        DatabaseSetting()
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showBackupDatabaseSettings = true
                    }) {
                        Text("Automatic Database Backup Settings")
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            
                    }
                    .sheet(isPresented: $showBackupDatabaseSettings) {
                        BackupDatabaseSetting()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 10)
                    
                    Button(action: {
                        showFilesSettings = true
                    }) {
                        Text("Client's Files Settings")
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            
                    }
                    .sheet(isPresented: $showFilesSettings) {
                        FilesSetting()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showBackupFilesSettings = true
                    }) {
                        Text("Automatic Files Backup Settings")
                            .frame(minWidth:0 ,maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            
                    }
                    .sheet(isPresented: $showBackupFilesSettings) {
                        BackupFilesSetting()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 20)
                }
                Section(header: Text("appearance_section").font(.title)) {
                    VStack {
                        Picker("", selection: $settings.themeMode) {
                            ForEach(ThemeMode.allCases, id: \.self) { mode in
                                Text(mode.localizedKey).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        
                    }
                    .padding(.bottom, 20)
                }

                Section(header: Text("language_section").font(.title)) {
                    Picker("", selection: $settings.language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }

                Section(header: Text("archived_actions_section").font(.title)) {
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

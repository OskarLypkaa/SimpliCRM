import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct SettingsView: View {
    @State private var showMessage: Bool = false
    @ObservedObject private var settings = Settings.shared
    @State private var showDatabaseSettings: Bool = false
        @State private var showFilesSettings: Bool = false
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
                Section(header: Text("Data Base").font(.title2)) {
                    HStack {
                        Text("Path:")
                        if settings.sharedPath != "" {
                            Text("~ \(settings.sharedPath)")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text("no_database_selected")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    Button(action: {
                        showDatabaseSettings = true
                    }) {
                        Text("Additional Settings")
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkGray))
                            .cornerRadius(4)
                            
                    }
                    .padding(.bottom, 15)
                    .sheet(isPresented: $showDatabaseSettings) {
                        DatabaseSetting()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                
                Section(header: Text("Files").font(.title2)) {
                    HStack {
                        Text("Path:")
                        if settings.filesPath != "" {
                            Text("~ \(settings.filesPath)")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text("No file folder is selected")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    Button(action: {
                        showFilesSettings = true
                    }) {
                        Text("Additional Settings")
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkGray))
                            .cornerRadius(4)
                            
                    }
                    .padding(.bottom, 15)
                    .sheet(isPresented: $showFilesSettings) {
                        FilesSetting()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
           
                Section(header: Text("appearance_section").font(.title2)) {
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
                    .padding(.bottom, 15)
                }

                Section(header: Text("language_section").font(.title2)) {
                    Picker("", selection: $settings.language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .padding(.bottom, 15)
                }
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }

                Section(header: Text("archived_actions_section").font(.title2)) {
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
    
    
        .frame(width: 550, height: 450, alignment: .leading)
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

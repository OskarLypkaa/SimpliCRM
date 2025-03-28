import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "home_tab"
    @State private var showSettings: Bool = false
    @State private var showHelp: Bool = false
    @ObservedObject var settings = Settings.shared
    @State private var refreshToken = UUID()

    @State private var showToast = false
    
    
    var body: some View {
        
        NavigationSplitView {
            // Sidebar z zakładkami
            NavigationSidebar(selectedTab: $selectedTab)
        } detail: {
            // Sprawdzenie czy są ustawione ścieżki
            if Settings.shared.sharedPath.isEmpty || Settings.shared.filesPath.isEmpty {
                tabToViewMap["NoDB_home_tab"]
            } else if let view = tabToViewMap[selectedTab] {
                view
                    .id(refreshToken) // Odświeżenie tylko detalu
            } else {
                Text("select_tab")
                    .padding()
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showHelp = true
                }) {
                    Image(systemName: "questionmark")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigation) {
                ZStack(alignment: .top) {
                    ToastView(message: LocalizedStringKey("starting_backup"), isVisible: showToast)
                }
                .onChange(of: settings.automaticBackupMessage) {
                    showToast = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showToast = false
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(\.locale, .init(identifier: settings.language.code))
                .onDisappear {
                    refreshToken = UUID() // Odśwież po zamknięciu ustawień
                }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
                .environment(\.locale, .init(identifier: settings.language.code))
        }
        .onAppear {
            // 👇 Pętla przez wszystkie okna na wypadek gdyby nie było tylko jedno
            for window in NSApplication.shared.windows {
                window.title = "" // ← najważniejsze
                window.titleVisibility = .hidden
                // 👇 Opcjonalnie: żeby pasek wyglądał nowocześnie
                window.toolbarStyle = .unified
            }
        }

    }
}


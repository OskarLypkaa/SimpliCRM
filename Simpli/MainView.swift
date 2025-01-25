import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "home_tab"
    @State private var showSettings: Bool = false
    @State private var showHelp: Bool = false
    @ObservedObject var settings = Settings.shared
    @State private var refreshToken = UUID()

    var body: some View {
        NavigationSplitView {
            // Sidebar z zakładkami
            NavigationSidebar(selectedTab: $selectedTab)
        } detail: {
            // Wyświetlanie widoku na podstawie wybranej zakładki
            if let view = tabToViewMap[selectedTab] {
                view
                    .id(refreshToken) // Odświeżenie tylko detalu
            } else {
                Text("select_tab")
                    .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showHelp = true
                }) {
                    Image(systemName: "questionmark")
                        .font(.headline)
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
    }
}


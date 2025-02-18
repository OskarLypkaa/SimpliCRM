import SwiftUI

@main
struct SimpliApp: App {
    @ObservedObject var settings = Settings.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(settings)
                .environment(\.locale, .init(identifier: settings.language.code))
                .preferredColorScheme(settings.themeMode.colorScheme)
                .onAppear {
                    BackupManager.shared.startAutomaticBackup()
                }
        }
    }
}

extension ThemeMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

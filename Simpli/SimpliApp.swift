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
                    BackupManager.shared.startAutomaticDatabaseBackup()
                    BackupManager.shared.startAutomaticFilesBackup()
                }
s                .onChange(of: settings.automaticDatabaseBackup) { newValue, oldValue in
                    if newValue {
                        BackupManager.shared.startAutomaticDatabaseBackup()
                    } else {
                        BackupManager.shared.stopAutomaticDatabaseBackup()
                    }
                }
                .onChange(of: settings.automaticFilesBackup) { newValue, oldValue in
                    if newValue {
                        BackupManager.shared.startAutomaticFilesBackup()
                    } else {
                        BackupManager.shared.stopAutomaticFilesBackup()
                    }
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

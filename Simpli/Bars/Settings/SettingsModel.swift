import SwiftUI
import UniformTypeIdentifiers
import Foundation
import AppKit
import ZIPFoundation
import CoreData
import SQLite3

class Settings: ObservableObject {
    static let shared = Settings()
    private let settingsFileName = "AppSettings.plist"

    @Published var sharedPath: String = "" {
        didSet {
            saveSettings()
        }
    }

    @Published var filesPath: String = "" { // Dodana ścieżka do plików
        didSet {
            saveSettings()
        }
    }

    @Published var refreshViews = UUID() // Token odświeżenia

    @Published var themeMode: ThemeMode = .dark {
        didSet {
            saveSettings()
        }
    }
    @Published var language: Language = .english {
        didSet {
            saveSettings()
        }
    }
    @Published var showArchived: Bool = false { // Dodana zmienna
        didSet {
            saveSettings()
        }
    }

    private init() {
        loadSettings()
    }

    func triggerViewRefresh() {
        DispatchQueue.main.async {
            self.refreshViews = UUID() // Wymuszenie zmiany
        }
    }

    private func settingsFileURL() -> URL {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[0].appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.default.app")

        try? FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        return appSupportURL.appendingPathComponent(settingsFileName)
    }

    private func saveSettings() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        let settings = SettingsData(
            sharedPath: sharedPath,
            filesPath: filesPath, // Zapis nowej ścieżki
            themeMode: themeMode.rawValue,
            language: language.rawValue,
            showArchived: showArchived // Dodano do struktury danych
        )

        do {
            let data = try encoder.encode(settings)
            let url = settingsFileURL()
            try data.write(to: url)
            print("Settings saved successfully at\n\(url.path)")
        } catch {
            print("Failed to save settings: \(error.localizedDescription)")
        }
    }

    private func loadSettings() {
        let url = settingsFileURL()
        let decoder = PropertyListDecoder()

        guard let data = try? Data(contentsOf: url),
              let loadedSettings = try? decoder.decode(SettingsData.self, from: data) else {
            sharedPath = ""
            filesPath = "" // Domyślna wartość dla nowej ścieżki
            themeMode = .dark
            language = .english
            showArchived = false // Domyślna wartość
            return
        }

        sharedPath = loadedSettings.sharedPath
        filesPath = loadedSettings.filesPath // Wczytanie nowej ścieżki
        themeMode = ThemeMode(rawValue: loadedSettings.themeMode) ?? .dark
        language = Language(rawValue: loadedSettings.language) ?? .english
        showArchived = loadedSettings.showArchived
        print("Settings loaded successfully from \(url.path)")
    }
}

struct SettingsData: Codable {
    let sharedPath: String
    let filesPath: String 
    let themeMode: String
    let language: String
    let showArchived: Bool
}

enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"

    var localizedKey: LocalizedStringKey {
        switch self {
        case .light: return "theme_mode_light"
        case .dark: return "theme_mode_dark"
        }
    }
}

enum Language: String, CaseIterable {
    case english = "English"
    case german = "Deutsch"
    case polish = "Polski"
    case french = "Français"
    case italian = "Italiano"

    var code: String {
        switch self {
        case .english: return "en"
        case .german: return "de"
        case .polish: return "pl"
        case .french: return "fr"
        case .italian: return "it"
        }
    }
}


class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    func generateEmptyDatabase(at folderURL: URL) -> String {
        print("Starting database creation in folder: \(folderURL.path)")

        let databaseURL = folderURL.appendingPathComponent("database.sqlite")
        let fileManager = FileManager.default

        // Sprawdzenie i tworzenie folderu, jeśli nie istnieje
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Created folder at: \(folderURL.path)")
            } catch {
                print("Failed to create folder: \(error.localizedDescription)")
                return "Failed to create folder"
            }
        }

        // Lokalizacja modelu Core Data
        guard let modelURL = Bundle.main.url(forResource: "Simpli", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Failed to locate the Core Data model named Simpli.")
            return "Failed to locate Core Data model"
        }
        print("Core Data model loaded successfully from: \(modelURL.path)")

        // Konfiguracja Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: databaseURL,
                options: nil
            )
            print("Persistent store added successfully at: \(databaseURL.path)")
        } catch {
            print("Failed to add the persistent store: \(error.localizedDescription)")
            return "Failed to add persistent store"
        }

        // Zapis pustej bazy danych
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        do {
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
                print("Changes saved to database.")
            }
            print("An empty database has been created at: \(databaseURL.path)")
            return "Database created successfully"
        } catch {
            print("Error saving the empty database: \(error.localizedDescription)")
            return "Failed to save empty database"
        }
    }

    func backupDatabase(using settingsPath: String, to databaseURL: URL) -> String {
        let fileManager = FileManager.default
        
        performCheckpointForCoreData(persistentContainer: PersistenceController.shared.container)

        // Konwersja settingsPath na URL (ścieżka źródłowa bazy danych)
        let sourceDatabaseURL = URL(fileURLWithPath: settingsPath)

        // Sprawdzenie, czy baza danych istnieje w ścieżce źródłowej
        guard fileManager.fileExists(atPath: sourceDatabaseURL.path) else {
            print("Database file does not exist at: \(sourceDatabaseURL.path)")
            return "Database file does not exist"
        }

        // Tworzenie nazwy dla pliku archiwum (np. database_backup_YYYYMMDD_HHMMSS.zip)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let archiveName = "database_backup_\(timestamp).zip"
        let archiveURL = databaseURL.appendingPathComponent(archiveName)

        // Utworzenie folderu docelowego, jeśli nie istnieje
        if !fileManager.fileExists(atPath: databaseURL.path) {
            do {
                try fileManager.createDirectory(at: databaseURL, withIntermediateDirectories: true, attributes: nil)
                print("Created destination folder at: \(databaseURL.path)")
            } catch {
                print("Failed to create destination folder: \(error.localizedDescription)")
                return "Failed to create destination folder"
            }
        }

        // Tworzenie archiwum ZIP
        do {
            try fileManager.zipItem(at: sourceDatabaseURL, to: archiveURL)
            print("Database successfully archived at: \(archiveURL.path)")
            return "Database successfully archived"
        } catch {
            print("Failed to archive database: \(error.localizedDescription)")
            return "Failed to archive database"
        }
    }

    func selectDatabaseFile(settings: Settings) -> String {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "sqlite")!]
        panel.prompt = "Select Database File"

        if panel.runModal() == .OK, let selectedURL = panel.url {
            settings.sharedPath = selectedURL.path
            PersistenceController.shared.changeDatabasePath(to: settings.sharedPath)
            return "Database file selected successfully"
        } else {
            return "Database file selection cancelled or failed"
        }
    }
    
    func selectFolder(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK {
            completion(panel.url)
        }
    }
    
    func performCheckpointForCoreData(persistentContainer: NSPersistentContainer) {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            print("Persistent store URL not found.")
            return
        }
        
        let databasePath = storeURL.path
        var db: OpaquePointer?

        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            if sqlite3_exec(db, "PRAGMA wal_checkpoint(FULL);", nil, nil, nil) == SQLITE_OK {
                print("Checkpoint completed successfully for Core Data database.")
            } else {
                print("Failed to perform checkpoint: \(String(cString: sqlite3_errmsg(db)))")
            }
            sqlite3_close(db)
        } else {
            print("Failed to open Core Data SQLite database.")
        }
    }
}


extension FileManager {
    /// Tworzy archiwum ZIP z podanego pliku.
    func zipItem(at sourceURL: URL, to destinationURL: URL) throws {
        // Użycie nowej wersji `Archive` z obsługą wyjątków
        let archive: Archive
        do {
            archive = try Archive(url: destinationURL, accessMode: .create)
        } catch {
            throw NSError(domain: "FileManager.zipItem", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create ZIP archive: \(error.localizedDescription)"])
        }

        let fileName = sourceURL.lastPathComponent
        do {
            try archive.addEntry(with: fileName, relativeTo: sourceURL.deletingLastPathComponent())
        } catch {
            throw NSError(domain: "FileManager.zipItem", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to add \(fileName) to archive: \(error.localizedDescription)"])
        }
    }
}


class FilesManager {
    static let shared = FilesManager()

    private init() {}

    func setFilesFolder(settings: Settings) -> String {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK, let selectedURL = panel.url {
            settings.filesPath = selectedURL.path
            PersistenceController.shared.changeFilePath(to: settings.filesPath)
            return "Files storage folder selected successfully"
        } else {
            return "Files storage folder selection cancelled or failed"
        }
    }

    func generateFoldersForUsers() throws -> String {
        guard !Settings.shared.sharedPath.isEmpty else {
            throw FilesManagerError.databaseNotSelected
        }

        guard !Settings.shared.filesPath.isEmpty else {
            throw FilesManagerError.filesPathNotSet
        }

        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()

        var createdCount = 0

        do {
            let clients = try context.fetch(fetchRequest)
            let basePath = URL(fileURLWithPath: Settings.shared.filesPath)

            for client in clients {
                guard let clientName = client.name, !clientName.isEmpty else { continue }
                let sanitizedClientName = clientName.replacingOccurrences(of: "/", with: "-")
                let clientFolder = basePath.appendingPathComponent(sanitizedClientName)

                if !FileManager.default.fileExists(atPath: clientFolder.path) {
                    try FileManager.default.createDirectory(at: clientFolder, withIntermediateDirectories: true)
                    createdCount += 1
                }
            }
        } catch {
            let errorMessage = "Failed to fetch clients or create folders: \(error.localizedDescription)"
            print(errorMessage)
            throw error
        }

        return "Folders created for \(createdCount) clients."
    }


    func selectDatabaseFile(settings: Settings) -> String {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "sqlite")!]
        panel.prompt = "Select Database File"

        if panel.runModal() == .OK, let selectedURL = panel.url {
            settings.sharedPath = selectedURL.path
            PersistenceController.shared.changeDatabasePath(to: settings.sharedPath)
            return "Database file selected successfully"
        } else {
            return "Database file selection cancelled or failed"
        }
    }

    func selectFolder(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK {
            completion(panel.url)
        }
    }
    func openClientFolderInFinder(clientName: String) {
        // Pobierz ścieżkę bazową z ustawień

        
        // Utwórz pełną ścieżkę do folderu klienta
        let sanitizedClientName = clientName.replacingOccurrences(of: "/", with: "-")
        let clientFolderPath = URL(fileURLWithPath: Settings.shared.filesPath).appendingPathComponent(sanitizedClientName)
        
        do {
            // Jeśli folder nie istnieje, utwórz go
            if !FileManager.default.fileExists(atPath: clientFolderPath.path) {
                try FileManager.default.createDirectory(at: clientFolderPath, withIntermediateDirectories: true)
                print("Created folder for client: \(clientName) at \(clientFolderPath.path)")
            }
            
            // Otwórz folder w Finderze
            NSWorkspace.shared.open(clientFolderPath)
           
            
        } catch {
            print("Failed to create or open folder for client \(clientName): \(error.localizedDescription)")
        }
    }
    func backupFilesPath(using filesPath: String, to destinationURL: URL, progressCallback: ((Double) -> Void)? = nil) -> String {
        let fileManager = FileManager.default

        // Sprawdzenie, czy `filesPath` jest ustawione i istnieje
        guard !filesPath.isEmpty else {
            return "Files path is not set."
        }

        let sourceFolderURL = URL(fileURLWithPath: filesPath)

        guard fileManager.fileExists(atPath: sourceFolderURL.path) else {
            return "Source folder does not exist at: \(sourceFolderURL.path)"
        }

        // Tworzenie nazwy dla pliku archiwum (np. files_backup_YYYYMMDD_HHMMSS.zip)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let archiveName = "files_backup_\(timestamp).zip"
        let archiveURL = destinationURL.appendingPathComponent(archiveName)

        // Tworzenie folderu docelowego, jeśli nie istnieje
        if !fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                print("Created destination folder at: \(destinationURL.path)")
            } catch {
                print("Failed to create destination folder: \(error.localizedDescription)")
                return "Failed to create destination folder"
            }
        }

        // Tworzenie archiwum ZIP
        do {
            guard let archive = Archive(url: archiveURL, accessMode: .create) else {
                return "Failed to create ZIP archive."
            }

            let items = try fileManager.contentsOfDirectory(at: sourceFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let totalItems = Double(items.count)
            var completedItems = 0.0

            for item in items {
                let relativePath = item.lastPathComponent

                do {
                    try archive.addEntry(with: relativePath, relativeTo: sourceFolderURL)
                    completedItems += 1
                    progressCallback?(completedItems / totalItems) // Aktualizacja postępu
                } catch {
                    return "Failed to add \(relativePath) to archive: \(error.localizedDescription)"
                }
            }

            print("Files successfully archived at: \(archiveURL.path)")
            return "Files successfully archived to \(archiveURL.path)"
        } catch {
            print("Failed to archive files: \(error.localizedDescription)")
            return "Failed to archive files"
        }
    }
}

enum FilesManagerError: Error {
    case databaseNotSelected
    case filesPathNotSet

    var localizedDescription: String {
        switch self {
        case .databaseNotSelected:
            return "No database selected. Please select a database first."
        case .filesPathNotSet:
            return "Files path not set. Please set a folder path for storing files."
        }
    }
}

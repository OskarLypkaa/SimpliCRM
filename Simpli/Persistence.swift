import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Simpli")
        loadStore(at: Settings.shared.sharedPath)
    }

    func loadStore(at path: String) {
        let storeURL = URL(fileURLWithPath: path)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store loaded successfully at: \(storeDescription.url?.path ?? "")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func changeDatabasePath(to newPath: String) {
        do {
            for store in container.persistentStoreCoordinator.persistentStores {
                try container.persistentStoreCoordinator.remove(store)
            }

            loadStore(at: newPath)

            Settings.shared.triggerViewRefresh()
        } catch {
            print("Error while changing database path: \(error.localizedDescription)")
        }
    }
    
    
    func changeFilePath(to newPath: String) {
        do {
            let fileManager = FileManager.default

            // Sprawdź, czy nowa ścieżka istnieje, jeśli nie, utwórz ją
            if !fileManager.fileExists(atPath: newPath) {
                try fileManager.createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
            }

            // Zmień ścieżkę w ustawieniach aplikacji
            Settings.shared.filesPath = newPath

            // Odśwież interfejs użytkownika lub wykonaj inne działania po zmianie
            Settings.shared.triggerViewRefresh()
        } catch {
            // Obsłuż błędy podczas zmiany ścieżki do plików
            print("Error while changing file path: \(error.localizedDescription)")
        }
    }
}

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Simpli")
        
        // Określenie niestandardowej ścieżki do bazy danych
        let storeURL = URL(fileURLWithPath: "/Users/zuzanna/Desktop/Simpli.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        // Przypisanie ścieżki do kontenera
        container.persistentStoreDescriptions = [storeDescription]
        
        // Załadowanie persistent store
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

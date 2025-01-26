import Foundation
import CoreData
import SwiftUI

func importClientsFromCSV(filePath: URL, context: NSManagedObjectContext) {
    do {
        // Odczyt danych z pliku CSV
        let csvContent = try String(contentsOf: filePath, encoding: .utf8)
        let rows = csvContent.components(separatedBy: "\n")

        // Sprawdzenie i odrzucenie nagłówków
        guard rows.count > 1 else {
            print("Plik CSV jest pusty lub zawiera tylko nagłówki.")
            return
        }

        let dataRows = rows.dropFirst() // Pomijamy pierwszą linię z nagłówkami

        for row in dataRows {
            let columns = row.components(separatedBy: ",")
            
            // Uzupełnienie brakujących wartości pustymi stringami, aby uniknąć błędów
            let paddedColumns = columns + Array(repeating: "", count: max(0, 9 - columns.count))

            // Tworzenie nowego obiektu Client
            let client = Client(context: context)
            client.id = UUID()
            client.name = paddedColumns[0].trimmingCharacters(in: .whitespaces)
            client.email = paddedColumns[1].trimmingCharacters(in: .whitespaces)
            client.phone = paddedColumns[2].trimmingCharacters(in: .whitespaces)
            client.address = paddedColumns[3].trimmingCharacters(in: .whitespaces)
            client.gender = paddedColumns[4].trimmingCharacters(in: .whitespaces)
            client.firstInformation = paddedColumns[5].trimmingCharacters(in: .whitespaces)
            client.secondInformation = paddedColumns[6].trimmingCharacters(in: .whitespaces)
            client.thirdInformation = paddedColumns[7].trimmingCharacters(in: .whitespaces)
        }

        // Zapis danych do bazy
        try context.save()
        print("Dane z CSV zaimportowano pomyślnie.")
    } catch {
        print("Wystąpił błąd podczas importowania CSV: \(error.localizedDescription)")
    }
}

func importClientsFromJSON(filePath: URL, context: NSManagedObjectContext) {
    do {
        // Odczyt danych z pliku JSON
        let jsonData = try Data(contentsOf: filePath)
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let clientsArray = jsonObject["Clients"] as? [[String: Any]] else {
            print("Nieprawidłowy format JSON.")
            return
        }

        for clientData in clientsArray {
            // Tworzenie nowego obiektu Client
            let client = Client(context: context)
            client.id = UUID()
            client.name = clientData["Name"] as? String ?? ""
            client.email = clientData["Email"] as? String ?? ""
            client.phone = clientData["Phone"] as? String ?? ""
            client.address = clientData["Address"] as? String ?? ""
            client.gender = clientData["Gender"] as? String ?? ""
            client.firstInformation = clientData["FirstInformation"] as? String ?? ""
            client.secondInformation = clientData["SecondInformation"] as? String ?? ""
            client.thirdInformation = clientData["ThirdInformation"] as? String ?? ""
        }

        // Zapis danych do bazy
        try context.save()
        print("Dane z JSON zaimportowano pomyślnie.")
    } catch {
        print("Wystąpił błąd podczas importowania JSON: \(error.localizedDescription)")
    }
}


func importWithLoading(context: NSManagedObjectContext, importType: String, filePath: URL, completion: @escaping () -> Void) {
    let loadingView = NSHostingController(rootView: LoadingView())

    if let keyWindow = NSApplication.shared.windows.first {
        keyWindow.contentViewController?.presentAsSheet(loadingView)
    }

    DispatchQueue.global().async {
        switch importType {
        case "csv":
            importClientsFromCSV(filePath: filePath, context: context)
        case "json":
            importClientsFromJSON(filePath: filePath, context: context)
        default:
            print("Nieobsługiwany typ eksportu")
        }

        DispatchQueue.main.async {
            loadingView.dismiss(nil)
            completion()
        }
    }
}

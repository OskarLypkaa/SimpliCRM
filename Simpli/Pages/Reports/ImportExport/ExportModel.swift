import Foundation
import SwiftUI

import CoreXLSX


func exportClientsToCSV(clients: FetchedResults<Client>, fileName: String, filePath: URL) {
    // Ścieżka do pulpitu użytkownika
    let filePath = filePath.appendingPathComponent("\(fileName).csv")

    // Tworzenie nagłówków i danych
    let headers = ["ID", "Name", "Email", "Phone", "Address", "Gender", "First Information", "Second Information", "Third Information"]
    var csvData = [headers]

    for client in clients {
        let row = [
            client.name ?? "",
            client.email ?? "",
            client.phone ?? "",
            client.address ?? "",
            client.gender ?? "",
            client.firstInformation ?? "",
            client.secondInformation ?? "",
            client.thirdInformation ?? ""
        ]
        csvData.append(row)
    }

    // Konwersja danych na format CSV
    let csvContent = csvData.map { $0.joined(separator: ",") }.joined(separator: "\n")

    do {
        // Zapis danych do pliku
        try csvContent.write(to: filePath, atomically: true, encoding: .utf8)
        print("Plik CSV zapisano na pulpicie: \(filePath.path)")
    } catch {
        print("Wystąpił błąd podczas zapisywania pliku CSV: \(error.localizedDescription)")
    }
}


func exportClientsToJSON(clients: FetchedResults<Client>, fileName: String, filePath: URL) {
    let filePath = filePath.appendingPathComponent("\(fileName).json")

    // Tworzenie danych w formacie JSON
    var jsonData: [String: Any] = [:]

    // Dodanie klientów do JSON
    let clientsData = clients.map { client in
        [
            "Name": client.name ?? "",
            "Email": client.email ?? "",
            "Phone": client.phone ?? "",
            "Address": client.address ?? "",
            "Gender": client.gender ?? "",
            "FirstInformation": client.firstInformation ?? "",
            "SecondInformation": client.secondInformation ?? "",
            "ThirdInformation": client.thirdInformation ?? ""
        ]
    }
    jsonData["Clients"] = clientsData


    do {
        // Konwersja danych na format JSON
        let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)

        // Zapis danych do pliku
        try json.write(to: filePath, options: .atomic)
        print("Plik JSON zapisano na pulpicie: \(filePath.path)")
    } catch {
        print("Wystąpił błąd podczas zapisywania pliku JSON: \(error.localizedDescription)")
    }
}


func exportWithLoading(exportType: String, data: Any, fileName: String, filePath: URL, completion: @escaping () -> Void) {
    let loadingView = NSHostingController(rootView: LoadingView())

    if let keyWindow = NSApplication.shared.windows.first {
        keyWindow.contentViewController?.presentAsSheet(loadingView)
    }

    DispatchQueue.global().async {
        switch exportType {
        case "csv":
            if let clients = data as? FetchedResults<Client> {
                exportClientsToCSV(clients: clients, fileName: fileName, filePath: filePath)
            }
        case "json":
            if let clients = data as? FetchedResults<Client> {
                exportClientsToJSON(clients: clients, fileName: fileName, filePath: filePath)
            }
        default:
            print("Nieobsługiwany typ eksportu")
        }

        DispatchQueue.main.async {
            loadingView.dismiss(nil)
            completion()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .padding(20)
        .cornerRadius(10)
        .frame(width: 100)
    
    }
}


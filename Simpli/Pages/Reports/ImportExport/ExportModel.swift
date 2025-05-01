import Foundation
import SwiftUI


func exportClientsToCSV(clients: FetchedResults<Client>, fileName: String, filePath: URL) {
    // Ścieżka do pulpitu użytkownika
    let filePath = filePath.appendingPathComponent("\(fileName).csv")

    // Tworzenie nagłówków i danych
    let headers = ["Name", "Email", "Phone", "Address", "Gender", "First Information", "Second Information", "Third Information", "Fourth Information"]
    var csvData = [headers]

    for client in clients {
        let name = client.name ?? ""
        let email = client.email ?? ""
        let phone = client.phone ?? ""
        let address = client.address ?? ""
        let gender = client.gender ?? ""
        let info1 = client.firstInformation ?? ""
        let info2 = client.secondInformation ?? ""
        let info3 = client.thirdInformation ?? ""
        let info4 = client.fourthInformation ?? ""

        csvData.append([name, email, phone, address, gender, info1, info2, info3, info4])
    }

    // Konwersja danych na format CSV
    let csvContent = csvData.map { $0.joined(separator: ";") }.joined(separator: "\n")

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
    let clientsData: [()] = clients.map { client in
        let name = client.name ?? ""
        let email = client.email ?? ""
        let phone = client.phone ?? ""
        let address = client.address ?? ""
        let gender = client.gender ?? ""
        let info1 = client.firstInformation ?? ""
        let info2 = client.secondInformation ?? ""
        let info3 = client.thirdInformation ?? ""
        let info4 = client.fourthInformation ?? ""

        [
            "Name": name,
            "Email": email,
            "Phone": phone,
            "Address": address,
            "Gender": gender,
            "FirstInformation": info1,
            "SecondInformation": info2,
            "ThirdInformation": info3,
            "FourthInformation": info4
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


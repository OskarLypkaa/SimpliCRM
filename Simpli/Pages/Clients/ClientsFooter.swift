import SwiftUI
import CoreData

struct ClientsFooter: View {
    @Binding var currentPage: Int
    @Environment(\.managedObjectContext) private var viewContext
    var searchText: String = "" // Możesz zaktualizować ten stan, żeby pobrać go z `ClientView`

    private let itemsPerPage = 20  // Liczba klientów na stronę
    
    // Obliczanie liczby stron
    private var totalPages: Int {
        let totalClients = fetchClientsCount()
        let totalNumberOfPages = (totalClients + itemsPerPage - 1) / itemsPerPage
        return totalNumberOfPages == 0 ? 1 : totalNumberOfPages
    }
    
    // Funkcja do pobierania liczby klientów na podstawie wyszukiwania
    private func fetchClientsCount() -> Int {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()
        
        // Dodanie predykatu do zapytania, jeśli wyszukiwany tekst jest niepusty
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        }
        
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
            return 0
        }
    }

    var body: some View {
        HStack {
            Button(action: {
                if currentPage > 0 {
                    currentPage -= 1
                }
            }) {
                Text("pagination_previous")
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            HStack {
                Text(LocalizedStringKey("pagination_page"))
                    .font(.headline)
                Text("\(currentPage + 1)")
                    .font(.headline)
                Text(LocalizedStringKey("pagination_of"))
                    .font(.headline)
                Text("\(totalPages)")
                    .font(.headline)
            }

            
            Spacer()
            
            Button(action: {
                if currentPage < totalPages - 1 {
                    currentPage += 1
                }
            }) {
                Text("pagination_next")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .frame(width: 300)
    }
}

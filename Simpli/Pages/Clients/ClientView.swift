import SwiftUI
import CoreData


struct ClientView: View {
    @State private var currentPage: Int = 0
    private let itemsPerPage = 20  // Liczba klientów na stronę

    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText: String = ""  // Wyszukiwana fraza
    @State private var highlighted: Bool = false
    @State private var isAscending: Bool = true
    @State private var sortingKey: String = "name"
    @State private var showSheet = false
    @State private var showingAddClient = false
    @State private var refreshList: Bool = false // Flaga do odświeżania listy

    // Strona z klientami
    private var pagedClients: [Client] {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()

        // Wyszukiwanie według nazwy klienta, jeśli searchText jest wprowadzony
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR phone CONTAINS[cd] %@", searchText, searchText, searchText)

        }

        fetchRequest.fetchLimit = itemsPerPage
        fetchRequest.fetchOffset = currentPage * itemsPerPage
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: isAscending)
        ]

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    var body: some View {
        VStack {
            HStack {
                // Użycie paska wyszukiwania
                SearchBar(searchText: $searchText, showSheet: $showSheet)
                    .onChange(of: searchText) { oldValue, newValue in
                        if newValue.count > oldValue.count {
                            highlighted = true
                            currentPage = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                highlighted = false
                            }
                        }
                    }

                HStack {
                    Button(action: {
                        showingAddClient = true
                    }) {
                        Image(systemName: "person.fill.badge.plus")
                            .font(.system(size: 30))
                            .padding(.leading, 15)
                            .padding(.top, 5)
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle()) // Usuwa domyślny styl przycisku
                    .sheet(isPresented: $showingAddClient) {
                        AddClient(refreshList: $refreshList) // Wyświetla AddClient jako arkusz
                    }
                }
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
                .padding(.trailing, 37)
            }
            TableHeaders(isAscending: $isAscending, sortingKey: $sortingKey)

            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(pagedClients, id: \.id) { client in
                            HStack {
                                Clients(client: client, highlighted: $highlighted)
                                DeleteClientView(client: client, refreshList: $refreshList)
                            }
                            .id(client.id) // Ustawiamy unikalne ID dla każdego klienta
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: currentPage) {
                    if let firstClient = pagedClients.first {
                        scrollView.scrollTo(firstClient.id, anchor: .top)
                    }
                }
            }

            // Użycie PaginationFooter
            ClientsFooter(currentPage: $currentPage, searchText: searchText)
                
        }
        .onChange(of: refreshList) {
            // Odśwież widok, gdy `refreshList` się zmienia
        }
    }

}


#Preview {
    ClientView()
}

struct ClientView_Previews: PreviewProvider {
    static var previews: some View {
        // Utworzenie kontekstu na potrzeby podglądu
        let context = PersistenceController.preview.container.viewContext
        
        return ClientView()
            .environment(\.managedObjectContext, context)
    }
}

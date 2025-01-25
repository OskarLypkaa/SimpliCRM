import SwiftUI
import CoreData

struct ClientView: View {
    @State private var currentPage: Int = 0
    private let itemsPerPage = 20

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var settings = Settings.shared
    
    @State private var searchText: String = ""
    @State private var isAscending: Bool = true
    @State private var sortingKey: String = "name"
    @State private var showSheet = false
    @State private var showingAddClient = false
    @State private var showingClientFilter = false
    @State private var refreshList: Bool = false

    @State private var clients: [Client] = []
    @State private var displayedFilters: Set<String> = [
        "name",
        "phone",
        "email",
        "firstInformation",
        "secondInformation"
    ]

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchText: $searchText, showSheet: $showSheet)
                    .onChange(of: searchText) { _, _ in
                        currentPage = 0
                        fetchClients() // Odśwież listę klientów
                    }
                    .environment(\.locale, .init(identifier: settings.language.code))

                HStack {
                    Button(action: {
                        showingAddClient = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.largeTitle)
                            .padding(.top, 8)
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.set()
                                } else {
                                    NSCursor.arrow.set()
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAddClient) {
                        AddClient(refreshList: $refreshList)
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .padding(.trailing, 29)
                    Button(action: {
                        showingClientFilter = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.largeTitle)
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
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingClientFilter) {
                        ClientFilter(selectedItems: $displayedFilters)
                            .environment(\.locale, .init(identifier: settings.language.code))
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

            ClientsHeaders(isAscending: $isAscending, sortingKey: $sortingKey, refreshList: $refreshList, displayedFilters: displayedFilters)
                .environment(\.locale, .init(identifier: settings.language.code))
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(clients, id: \.id) { client in
                            HStack {
                                Clients(client: client, displayedFilters: displayedFilters)
                                    .environment(\.locale, .init(identifier: settings.language.code))
                                DeleteClientView(client: client, refreshList: $refreshList)
                                    .environment(\.locale, .init(identifier: settings.language.code))
                            }
                            .opacityTransition()
                        }
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut(duration: 0.2), value: clients) // Minimalistyczna animacja
                }
                .onChange(of: currentPage) {
                    fetchClients() // Pobierz klientów dla aktualnej strony
                }
            }

            ClientsFooter(currentPage: $currentPage, searchText: searchText)
                .environment(\.locale, .init(identifier: settings.language.code))
        }
        .onAppear {
            fetchClients() // Pobierz początkowych klientów
        }
        .onChange(of: refreshList) {
            fetchClients() // Odśwież listę klientów
        }
        .frame(minWidth: 900)
    }

    private func fetchClients() {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()

        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR phone CONTAINS[cd] %@", searchText, searchText, searchText)
        }

        fetchRequest.fetchLimit = itemsPerPage
        fetchRequest.fetchOffset = currentPage * itemsPerPage
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: sortingKey, ascending: isAscending)
        ]

        do {
            let fetchedClients = try viewContext.fetch(fetchRequest)
            withAnimation {
                clients = fetchedClients
            }
        } catch {
            clients = []
        }
    }
}

extension View {
    func opacityTransition() -> some View {
        self.transition(.opacity)
    }
}

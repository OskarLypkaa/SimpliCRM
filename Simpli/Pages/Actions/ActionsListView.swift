import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct ActionsListView: View {
    @State private var refreshList: Bool = false
    @State private var searchText: String = ""
    @State private var highlighted: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var draggedAction: Actions? = nil

    @EnvironmentObject var settings: Settings
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var filterData = FilterData()
    
    
    @FetchRequest var actions: FetchedResults<Actions>

    var statuses: [String] {
        settings.showArchived
            ? ["ToDo", "In Progress", "Blocked", "Done", "Archived"]
            : ["ToDo", "In Progress", "Blocked", "Done"]
    }

    init() {
        let fetchRequest: NSFetchRequest<Actions> = Actions.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Actions.creationDate, ascending: false)]
        _actions = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        VStack {
            HStack {
                ActionsHeader(
                    searchText: $searchText,
                    highlighted: $highlighted,
                    showSheet: $showFilterSheet,
                    showFilterSheet: $showFilterSheet,
                    draggedAction: $draggedAction
                )
                .environment(\.locale, .init(identifier: settings.language.code))
                
                Button(action: {
                    showFilterSheet = true
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.largeTitle)
                            .padding(.trailing, 29)
                            .padding(.top, 5)
                            .onHover { hovering in
                                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                            }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showFilterSheet) {
                    ActionListFilter(filterData: filterData) {
                        applyFilters()
                        withAnimation {
                            showFilterSheet = false
                        }
                    }
                    .environment(\.locale, .init(identifier: settings.language.code))
                }
                Spacer()
            }

            ScrollView(.vertical) {
                HStack(alignment: .top) {
                    ForEach(statuses, id: \.self) { status in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey(status)) // Użycie lokalizowanego klucza
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.trailing, 30)
                            ForEach(filteredActions(for: status).prefix(filterData.actionsLimit), id: \.id) { action in
                                ActionBlock(action: action)
                                    .onDrag {
                                        draggedAction = action
                                        return NSItemProvider(object: action.id?.uuidString as NSString? ?? "")
                                    }
                                    
                            }
                            Spacer()
                        }
                        .frame(minWidth: 200)
                        .onDrop(of: [.plainText], isTargeted: nil) { providers in
                            if let draggedAction = draggedAction {
                                updateActionStatus(action: draggedAction, status: status)
                            }
                            return true
                        }
                    }
                }
                .animation(.easeInOut, value: actions.count)
                .padding(10)
            }
            .onAppear {
                updateFetchRequest()
            }
            .onChange(of: searchText) {
                updateFetchRequest()
            }
        }
    }

    private func filteredActions(for status: String) -> [Actions] {
        actions.filter { action in
            if settings.showArchived {
                return action.status == status
            } else {
                return action.status == status && status != "Archived"
            }
        }
    }

    private func updateFetchRequest() {
        var predicates: [NSPredicate] = []

        // Filtruj na podstawie tekstu wyszukiwania
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "message CONTAINS[cd] %@ OR client.name CONTAINS[cd] %@", searchText, searchText)
            predicates.append(searchPredicate)
        }

        // Dodaj filtrację dla zarchiwizowanych elementów
        if !settings.showArchived {
            let archivedPredicate = NSPredicate(format: "status != %@", "Archived")
            predicates.append(archivedPredicate)
        }

        // Połącz predykaty w jeden, jeśli jest ich więcej
        let compoundPredicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        actions.nsPredicate = compoundPredicate
    }

    private func updateActionStatus(action: Actions, status: String) {
        withAnimation {
            action.status = status
            do {
                try viewContext.save()
                refreshList.toggle()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError)")
            }
        }
    }

    private func applyFilters() {
        withAnimation {
            actions.nsPredicate = filterData.toPredicate()
        }
    }
}

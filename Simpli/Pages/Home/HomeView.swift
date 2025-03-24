import SwiftUI
import CoreData

struct HomeView: View {
    @State private var showAddAction: Bool = false
    @State private var refreshList: Bool = false

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var actions: FetchedResults<Actions>

    init() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        _actions = FetchRequest<Actions>(
            entity: Actions.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Actions.criticality, ascending: true), // Sortowanie według priorytetu
                NSSortDescriptor(keyPath: \Actions.client?.name, ascending: true) // Sortowanie według nazwy klienta
            ],
            predicate: NSPredicate(
                format: "(status IN %@) AND (dueDate < %@)",
                ["ToDo", "In Progress", "Blocked"], tomorrow as NSDate
            )
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text("welcome_message")
                Image(systemName: "face.smiling")
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            
            Text("manage_clients_message")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text("tasks_today_message")
                .font(.title2)
                .multilineTextAlignment(.center)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(groupedActionsByClient(), id: \.clientName) { clientGroup in
                        VStack(alignment: .leading) {
                    
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.headline)
                                Text(clientGroup.clientName)
                                    .font(.headline)
                                    
                            }.padding(.horizontal)
                            Divider()
                            ForEach(clientGroup.actions, id: \.id) { action in
                                HStack{
                                    ActionInClientListView(action: action)
                                    DeleteActionView(action: action, refreshList: $refreshList)
                                        .padding(.bottom, 4)
                                }.padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .frame(minWidth: 800)
    }
    
    /// Grupuje akcje według klienta
    private func groupedActionsByClient() -> [ClientGroup] {
        var groups: [ClientGroup] = []

        // Grupowanie akcji według nazw klientów
        let grouped = Dictionary(grouping: actions) { (action: Actions) -> String in
            action.client?.name ?? ""
        }

        // Iterowanie po grupach i sortowanie akcji w każdej z nich
        for (clientName, clientActions) in grouped {
            let sortedActions = clientActions.sorted { (action1, action2) in
                guard let priority1 = action1.criticality, let priority2 = action2.criticality else {
                    return false
                }
                return priority1 < priority2
            }
            groups.append(ClientGroup(clientName: clientName, actions: sortedActions))
        }

        // Sortowanie klientów alfabetycznie
        return groups.sorted { $0.clientName < $1.clientName }
    }
}

/// Model grupy klientów i ich akcji
struct ClientGroup {
    let clientName: String
    let actions: [Actions]
}

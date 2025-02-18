import SwiftUI
import CoreData

struct DayInformations: View {
    @State private var showAddAction: Bool = false
    @State private var refreshList: Bool = false
    @State private var isHovered: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedDate: Date
    
    @ObservedObject var settings = Settings.shared
    private var actionsFetchRequest: FetchRequest<Actions>
    private var actions: FetchedResults<Actions> {
        actionsFetchRequest.wrappedValue
    }

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate

        // Uzyskaj początek i koniec dnia dla podanej daty
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate.wrappedValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Używamy przedziału czasu w predykacie
        self.actionsFetchRequest = FetchRequest<Actions>(
            entity: Actions.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Actions.criticality, ascending: true),
                NSSortDescriptor(keyPath: \Actions.client?.name, ascending: true)
            ],
            predicate: NSPredicate(
                format: "(status IN %@) AND (dueDate >= %@) AND (dueDate < %@)",
                ["ToDo", "In Progress", "Blocked"], startOfDay as NSDate, endOfDay as NSDate
            )
        )
    }

    var body: some View {
        CloseableHeader()
        VStack {

                HStack {
                    
                    Text(LocalizedStringKey("Acrions for: \(formattedDate(selectedDate))"))
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    Button(action: {
                        showAddAction = true
                    }) {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .font(.largeTitle)
                            .padding(.leading, 15)
                            .padding(.bottom, 6)
                            .onHover { hovering in
                                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showAddAction) {
                        AddActionCalendarMonthView(selectedDate: selectedDate, isMonthView: true)
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                }
                .frame(width: 500)
                
                ScrollView {
                    if actions.isEmpty {
                        Text(LocalizedStringKey("no_actions_for_day"))
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding(.top, 100)
                    }
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(groupedActionsByClient(), id: \.clientName) { clientGroup in
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.headline)
                                    Text(clientGroup.clientName.isEmpty
                                         ? ""
                                         : clientGroup.clientName)
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                Divider()
                                ForEach(clientGroup.actions, id: \.id) { action in
                                    HStack {
                                        ActionInClientListView(action: action)
                                            .environment(\.locale, .init(identifier: settings.language.code))
                                        DeleteActionView(action: action, refreshList: $refreshList)
                                            .padding(.bottom, 4)
                                            .environment(\.locale, .init(identifier: settings.language.code))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(height: 400)
                
            
        }
        .onChange(of: refreshList) {
        
        }
    }

    /// Grupuje akcje według klienta
    private func groupedActionsByClient() -> [ClientGroup] {
        var groups: [ClientGroup] = []

        // Grupowanie akcji według nazw klientów
        let grouped = Dictionary(grouping: actions) { (action: Actions) -> String in
            action.client?.name ?? NSLocalizedString("no_client_name", comment: "")
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
    
    private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
}

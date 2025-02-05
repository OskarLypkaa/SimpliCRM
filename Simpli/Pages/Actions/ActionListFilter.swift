import SwiftUI
import CoreData

struct ActionListFilter: View {
    // Obiekt trzymający stan filtra
    @ObservedObject var filterData: FilterData
    
    @Environment(\.managedObjectContext) private var viewContext
    // Pobieranie klientów, by je wyświetlić w rozwijanej liście
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
                  animation: .default)
    private var clients: FetchedResults<Client>
    
    // Callback - wywoływany po kliknięciu "Apply Filters"
    var onApplyFilters: (() -> Void)?
    
    var body: some View {
        CloseableHeader()
        HStack {
            Text(LocalizedStringKey("filter_actions_title"))
                .padding(.horizontal)
            
            Spacer()

            // Przycisk "Clear" - czyści filtry w FilterData
            Button(LocalizedStringKey("clear_filters_button")) {
                withAnimation {
                    filterData.clear()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)

            // Przycisk "Apply Filters" - wywołuje callback
            Button(LocalizedStringKey("apply_filters_button")) {
                onApplyFilters?()
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .font(.title3)
        .fontWeight(.bold)
        
        VStack {
            HStack {
                TextField(LocalizedStringKey("search_client_placeholder"), text: $filterData.clientName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Przycisk rozwijania listy klientów
                Button(action: {
                    withAnimation {
                        filterData.isListExpanded.toggle()
                    }
                }) {
                    Image(systemName: filterData.isListExpanded ? "chevron.down" : "chevron.right")
                        .font(.title)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 400)

            // Rozwijana lista klientów
            if filterData.isListExpanded {
                List(filteredClients, id: \.self) { client in
                    Text(client.name ?? "")
                        .onTapGesture {
                            withAnimation {
                                filterData.isListExpanded = false
                                filterData.selectedClient = client
                                filterData.clientName = client.name ?? ""
                            }
                        }
                }
                .frame(maxWidth: 400, maxHeight: 100)
            }
            
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("filter_by_criticality_label"))
                Picker("", selection: $filterData.criticality) {
                    Text(LocalizedStringKey("criticality_all")).tag("All")
                    Text(LocalizedStringKey("criticality_low")).tag("Low")
                    Text(LocalizedStringKey("criticality_medium")).tag("Medium")
                    Text(LocalizedStringKey("criticality_high")).tag("High")
                    Text(LocalizedStringKey("criticality_very_high")).tag("Very High")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("Max actions displayed per page"))
                Picker("", selection: $filterData.actionsLimit) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("20").tag(20)
                    Text("30").tag(30)
                    Text("50").tag(50)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            Spacer()
        }
        .frame(width: 500, height: 200)
    }
    
    private var filteredClients: [Client] {
        if filterData.clientName.isEmpty {
            // Jeśli nazwa klienta jest pusta - zwracamy wszystkie
            return Array(clients)
        } else {
            // W przeciwnym wypadku - filtrujemy listę klientów
            return clients.filter { client in
                (client.name ?? "")
                    .lowercased()
                    .contains(filterData.clientName.lowercased())
            }
        }
    }
}

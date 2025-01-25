import SwiftUI

struct AddActionWithClient: View {
    @State private var showMessage: Bool = false
    @State private var isWarningVisible: Bool = false
    @State private var showCalendar: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)], animation: .default)
    private var clients: FetchedResults<Client>
    
    @State private var action: Action = Action(message: "", criticality: "Low", dueDate: Calendar.current.startOfDay(for: Date()), status: "ToDo", type: "General")
    @Binding var refreshList: Bool
    
    @State private var searchedClientName = ""
    @State private var selectedClient: Client? = nil
    @EnvironmentObject var settings: Settings

    @State private var sheetMessage: String = ""
    @State private var isListExpanded: Bool = false  // Zmienna kontrolująca rozwinięcie listy

    var body: some View {
        CloseableHeader()
        
        ZStack {
            VStack {
                HStack {
                    Text(LocalizedStringKey("add_action_title"))
                        .font(.title)
                    Spacer()
                    Button(action: {
                        clear()
                    }) {
                        Text(LocalizedStringKey("add_action_clear_button"))
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        if doesClientExist(name: searchedClientName) {
                            addItem()
                            clear()
                        } else {
                            sheetMessage = "client_not_found"
                            showMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                withAnimation {
                                    showMessage = false
                                }
                            }
                        }
                    }) {
                        Text(LocalizedStringKey("add_action_add_button"))
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: LocalizedStringKey(sheetMessage),
                            displayDuration: 1.5,
                            isPresented: $showMessage
                        )
                        .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .environment(\.locale, .init(identifier: settings.language.code))
                }
                .padding(.horizontal)
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 500, alignment: .leading)
                
                VStack(alignment: .leading) {
                    HStack {
                        TextField(LocalizedStringKey("search_client_placeholder"), text: $searchedClientName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Przycisk do rozwinięcia/zwiń listę
                        Button(action: {
                            withAnimation {
                                isListExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isListExpanded ? "chevron.down" : "chevron.right")
                                .font(.title)
                                .padding(.leading, 15)
                                .onHover { hovering in
                                    hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.bottom, 5)
                    
                    if isListExpanded {
                        // Lista klientów, rozwinięta po kliknięciu
                        List(filteredClients, id: \.self) { client in
                            Text(client.name ?? "")
                                .onTapGesture {
                                    withAnimation {
                                        isListExpanded = false
                                        selectedClient = client
                                        searchedClientName = client.name ?? ""
                                    }
                                }
                        }
                        .frame(maxHeight: 75)
                    }
                }.padding(.horizontal, 35)
                
                ZStack {
                    List {
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey("add_action_message_label"))
                                .font(.headline)
                            TextEditorWithWarning(actionMessage: $action.message, isWarningVisible: $isWarningVisible)
                                .environment(\.locale, .init(identifier: settings.language.code))
                        }
                        .padding()
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey("add_action_type_label"))
                                .font(.headline)
                            Picker("", selection: $action.type) {
                                Text(LocalizedStringKey("action_type_general")).tag("General")
                                Text(LocalizedStringKey("action_type_meeting")).tag("Meeting")
                                Text(LocalizedStringKey("action_type_call")).tag("Call")
                                Text(LocalizedStringKey("action_type_email")).tag("Email")
                                Text(LocalizedStringKey("action_type_follow_up")).tag("Follow-Up")
                                Text(LocalizedStringKey("action_type_contract")).tag("Contract")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey("add_action_criticality_label"))
                                .font(.headline)
                            Picker("", selection: $action.criticality) {
                                Text(LocalizedStringKey("criticality_low")).tag("Low")
                                Text(LocalizedStringKey("criticality_medium")).tag("Medium")
                                Text(LocalizedStringKey("criticality_high")).tag("High")
                                Text(LocalizedStringKey("criticality_very_high")).tag("Very High")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }.padding()
                        
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey("add_action_status_label"))
                                .font(.headline)
                            Picker("", selection: $action.status) {
                                Text(LocalizedStringKey("status_to_do")).tag("ToDo")
                                Text(LocalizedStringKey("status_in_progress")).tag("In Progress")
                                Text(LocalizedStringKey("status_done")).tag("Done")
                                Text(LocalizedStringKey("status_blocked")).tag("Blocked")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }.padding()
                        DatePickerWithCallendar(actionDueDate: $action.dueDate, isDatePickerPresented: $showCalendar)
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(width: 500, height: 600, alignment: .leading)
        }
    }

    
    private func textValidation() -> Bool {
        var isValid: Bool = true
        
        let fields = [action.message]
        if fields.contains(where: { !$0.isEmpty }) && !searchedClientName.isEmpty {
            isValid = false
        }
        
        return isValid
    }
    
    func doesClientExist(name: String) -> Bool {
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try viewContext.fetch(request)
            return !results.isEmpty
        } catch {
            print("Error fetching clients: \(error.localizedDescription)")
            return false
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Actions(context: viewContext)
            newItem.id = UUID()  // Unikalne ID
            newItem.message = action.message
            newItem.criticality = action.criticality
            newItem.dueDate = action.dueDate
            newItem.status = action.status
            newItem.type = action.type
            newItem.creationDate = Date()
            newItem.client = selectedClient
            do {
                try viewContext.save()
                refreshList.toggle()
                sheetMessage = "add_action_success_message"
                showMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation {
                        showMessage = false
                    }
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func clear() {
        searchedClientName = ""
        selectedClient = nil
        action.message = ""
        action.criticality = "Low"
        action.dueDate = Date()
        action.status = "ToDo"
        action.type = "General"
    }
    
    private var filteredClients: [Client] {
        if searchedClientName.isEmpty {
            return Array(clients)
        } else {
            return clients.filter { $0.name?.lowercased().contains(searchedClientName.lowercased()) ?? false }
        }
    }
}

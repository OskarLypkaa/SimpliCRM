import SwiftUI

struct Action: Identifiable {
    var id = UUID()
    var message: String
    var criticality: String
    var dueDate: Date
    var status: String
    var type: String
}

struct AddAction: View {
    @State private var showMessage: Bool = false
    @State private var isWarningVisible: Bool = false
    @State private var showCalendar: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var action: Action = Action(message: "", criticality: "Low", dueDate: Date(), status: "ToDo", type: "General")
    
    @ObservedObject var settings = Settings.shared
    @Binding var refreshList: Bool
    var client: Client

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
                        addItem()
                        clear()
                    }) {
                        Text(LocalizedStringKey("add_action_add_button"))
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: LocalizedStringKey("add_action_success_message"),
                            displayDuration: 1.5,
                            isPresented: $showMessage
                        )
                        .environment(\.locale, .init(identifier: settings.language.code))
                    }
                }
                .padding(.horizontal)
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 500, alignment: .leading)
                
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
            .frame(width: 500, height: 550, alignment: .leading)
        }
    }
    
    func textValidation() -> Bool {
        var isValid: Bool = true
        
        let fields = [action.message]
        if fields.contains(where: { !$0.isEmpty }) {
            isValid = false
        }
        
        return isValid
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Actions(context: viewContext)
            newItem.id = UUID()
            newItem.message = action.message
            newItem.criticality = action.criticality
            newItem.dueDate = action.dueDate
            newItem.status = action.status
            newItem.type = action.type
            newItem.creationDate = Date()
            newItem.client = client
            
            do {
                try viewContext.save()
                refreshList.toggle()
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
    func clear() {
        action.message = ""
        action.criticality = "Low"
        action.dueDate = Date()
        action.status = "ToDo"
        action.type = "General"
    }
}

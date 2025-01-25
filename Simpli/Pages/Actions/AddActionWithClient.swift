import SwiftUI

struct AddActionWithClient: View {
    @State private var showMessage: Bool = false
    @State private var isWarningVisible: Bool = false
    @State private var showCalendar: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var action: Action = Action(message: "", criticality: "Low", dueDate: Date(), status: "ToDo")

    @Binding var refreshList: Bool

    var body: some View {
        CloseableHeader()
        
        ZStack {
            VStack {
                HStack {
                    Text("Add new action")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        clear()
                    }) {
                        Text("Clear")
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        addItem()
                        clear()
                    }) {
                        Text("Add")
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: "New action added!",
                            displayDuration: 1.5,
                            isPresented: $showMessage
                        )
                    }
                }
                .padding(.horizontal)
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 500, alignment: .leading)
                
                ZStack {
                    List {
                        TextEditorWithWarning(actionMessage: $action.message, isWarningVisible: $isWarningVisible)
                            .padding()
                        VStack(alignment: .leading) {
                            Text("Criticality:")
                                .font(.headline)
                            Picker("", selection: $action.criticality) {
                                Text("Low").tag("Low")
                                Text("Medium").tag("Medium")
                                Text("High").tag("High")
                                Text("Very High").tag("Very High")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }.padding()
                        
                        VStack(alignment: .leading) {
                            Text("Status:")
                                .font(.headline)
                            Picker("", selection: $action.status) {
                                Text("ToDo").tag("ToDo")
                                Text("In Progress").tag("In Progress")
                                Text("Done").tag("Done")
                                Text("Blocked").tag("Blocked")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }.padding()
                        DatePickerWithCallendar(actionDueDate: $action.dueDate, isDatePickerPresented: $showCalendar)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(.bottom, 40)
            .frame(width: 500, height: 500, alignment: .leading)
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
            newItem.id = UUID()  // Unikalne ID
            newItem.message = action.message
            newItem.criticality = action.criticality
            newItem.dueDate = action.dueDate
            newItem.status = action.status
            newItem.creationDate = Date()  // Data utworzenia
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
    }
}

import SwiftUI

struct AddAction: View {
    @State private var actionMessage: String = ""
    @State private var showMessage: Bool = false
    @State private var isWarningVisible: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var refreshList: Bool
    
    var client: Client

    var body: some View {
        CloseableHeader()
        if isWarningVisible {
            Text("Warning text can have maximum of 600 characters")
                .foregroundColor(.red)
                .font(.largeTitle)
                .fontWeight(.bold)
                .zIndex(12)
                .transition(.opacity)
        }
        ZStack {
            if showMessage {
                Text("Action added!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(0.9)
                    .zIndex(10)
                    .transition(.opacity)
            }
            
            VStack {
                HStack {
                    Text("Add new client")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        addItem()
                        clear()
                    }) {
                        Text("Add")
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        clear()
                    }) {
                        Text("Clear")
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: 500, alignment: .leading)
                
                ZStack {
                    List {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Message:")
                                    .font(.headline)
                                ZStack(alignment: .leading) {
                                    TextEditor(text: $actionMessage)
                                        .textEditorStyle(.plain)
                                        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 200)
                                        .scrollContentBackground(.hidden)
                                        .scrollDisabled(true)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                        .font(.body)
                                        .onChange(of: actionMessage) {
                                            if actionMessage.count > 600 {
                                                isWarningVisible = true
                                            } else {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        isWarningVisible = false
                                                    }
                                                }
                                            }
                                            limitText(&actionMessage, to: 600)
                                        }
                                }
                                .padding()
                            }
                        }
                        
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(.bottom, 40)
            .frame(width: 500, height: 360, alignment: .leading)
        }
    }
    
    func textValidation() -> Bool {
        var isValid: Bool = true
        
        let fields = [actionMessage]
        if fields.contains(where: { !$0.isEmpty }) {
            isValid = false
        }
        
        return isValid
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Actions(context: viewContext)
            newItem.id = UUID()  // Unikalne ID
            newItem.message = actionMessage
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
        actionMessage = ""
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Tworzenie przykładowego klienta dla podglądu
    let client = Client(context: context)
    client.id = UUID()
    client.name = "Example Client"
    
    return AddAction(refreshList: .constant(false), client: client)
        .environment(\.managedObjectContext, context)
}

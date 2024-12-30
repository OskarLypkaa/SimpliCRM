import SwiftUI

struct AddClient: View {
    @State private var clientName: String = ""
    @State private var clientEmail: String = ""
    @State private var clientPhone: String = ""
    @State private var clientAddress: String = ""
    
    @State private var showMessage: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var refreshList: Bool
    
    var body: some View {
        CloseableHeader()
        ZStack {
            if showMessage {
                Text("User added!")
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
                            Text("Name:   ")
                                .font(.headline)
                                .frame(width: 60, alignment: .leading)
                            TextField("Set name", text: $clientName)
                                .padding()
                        }
                        
                        HStack {
                            Text("Email:    ")
                                .font(.headline)
                                .frame(width: 60, alignment: .leading)
                            TextField("Set email", text: $clientEmail)
                                .padding()
                        }
                        
                        HStack {
                            Text("Phone:   ")
                                .font(.headline)
                                .frame(width: 60, alignment: .leading)
                            TextField("Set phone", text: $clientPhone)
                                .padding()
                        }
                        
                        HStack {
                            Text("Address:")
                                .font(.headline)
                                .frame(width: 60, alignment: .leading)
                            TextField("Set address", text: $clientAddress)
                                .padding()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)              
                }
            }
            .padding(.bottom, 40)
            .frame(width: 500, height:360, alignment: .leading)
        }
    }
    
    func textValidation() -> Bool{
        var isValid: Bool = true
        
        let fields = [clientName, clientEmail, clientPhone, clientAddress]
        if fields.contains(where: { !$0.isEmpty }) {
            isValid = false
        }
        
        return isValid
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Client(context: viewContext)
            newItem.id = UUID()  // Dodajemy unikalne ID
            newItem.name = clientName
            newItem.email = clientEmail
            newItem.phone = clientPhone
            newItem.address = clientAddress
            
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
        clientName = ""
        clientEmail = ""
        clientPhone = ""
        clientAddress = ""
    }
}

import SwiftUI

struct AddClient: View {
    @State private var clientName: String = ""
    @State private var clientEmail: String = ""
    @State private var clientPhone: String = ""
    @State private var clientAddress: String = ""
    @State private var clientGender: String = ""
    @State private var clientFirstInformation: String = ""
    @State private var clientSecondInformation: String = ""
    @State private var clientThirdInformation: String = ""
    
    @ObservedObject var settings = Settings.shared
    @State private var showMessage: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var refreshList: Bool
    
    var body: some View {
        CloseableHeader()
        ZStack {
            VStack {
                HStack {
                    Text("add_client_title")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        clear()
                    }) {
                        Text("add_client_clear_button")
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        addItem()
                        clear()
                    }) {
                        Text("add_client_add_button")
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: LocalizedStringKey("add_client_success_message"),
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
                        HStack {
                            Text("add_client_name_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_name_placeholder", text: $clientName)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_email_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_email_placeholder", text: $clientEmail)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_phone_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_phone_placeholder", text: $clientPhone)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_address_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_address_placeholder", text: $clientAddress)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_gender_label")
                                .font(.headline)
                                .frame(width: 120, alignment: .leading)
                            Picker("", selection: $clientGender) {
                                Text("add_client_gender_male").tag("Male")
                                Text("add_client_gender_female").tag("Female")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }
                        
                        HStack {
                            Text("add_client_first_info_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_first_info_placeholder", text: $clientFirstInformation)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_second_info_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_second_info_placeholder", text: $clientSecondInformation)
                                .padding()
                        }
                        
                        HStack {
                            Text("add_client_third_info_label")
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField("add_client_third_info_placeholder", text: $clientThirdInformation)
                                .padding()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(width: 500, height: 570, alignment: .leading)
        }
    }
    
    func textValidation() -> Bool {
        var isValid: Bool = true
        if (!clientName.isEmpty) {
            isValid = false
        }
        return isValid
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Client(context: viewContext)
            newItem.id = UUID()
            newItem.name = clientName
            newItem.email = clientEmail
            newItem.phone = clientPhone
            newItem.address = clientAddress
            newItem.gender = clientGender
            newItem.firstInformation = clientFirstInformation
            newItem.secondInformation = clientSecondInformation
            newItem.thirdInformation = clientThirdInformation
            
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
        clientGender = ""
        clientFirstInformation = ""
        clientSecondInformation = ""
        clientThirdInformation = ""
    }
}

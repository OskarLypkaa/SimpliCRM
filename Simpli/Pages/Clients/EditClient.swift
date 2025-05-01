import SwiftUI

struct EditClient: View {
    @State private var clientName: String = ""
    @State private var clientEmail: String = ""
    @State private var clientPhone: String = ""
    @State private var clientAddress: String = ""
    @State private var clientGender: String = ""
    @State private var clientFirstInformation = ""
    @State private var clientSecondInformation = ""
    @State private var clientThirdInformation = ""
    @State private var clientFourthInformation = ""

    @ObservedObject var settings = Settings.shared
    @State private var showMessage: Bool = false
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var refreshList: Bool
    var client: Client

    var body: some View {
        CloseableHeader()
        ZStack {
            VStack {
                HStack {
                    Text(LocalizedStringKey("change_client_info_title"))
                        .font(.title)

                    Spacer()

                    Button(action: {
                        resetToOriginalValues()
                    }) {
                        Text(LocalizedStringKey("add_client_clear_button"))
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        updateClient()
                    }) {
                        Text(LocalizedStringKey("edit_client_button"))
                            .padding(.horizontal)
                    }
                    .disabled(textValidation())
                    .buttonStyle(PlainButtonStyle())

                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: LocalizedStringKey("client_updated_message"),
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
                            Text(LocalizedStringKey("add_client_name_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_name_placeholder"), text: $clientName)
                                .padding()
                        }

                        HStack {
                            Text(LocalizedStringKey("add_client_email_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_email_placeholder"), text: $clientEmail)
                                .padding()
                        }

                        HStack {
                            Text(LocalizedStringKey("add_client_phone_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_phone_placeholder"), text: $clientPhone)
                                .padding()
                        }

                        HStack {
                            Text(LocalizedStringKey("add_client_address_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_address_placeholder"), text: $clientAddress)
                                .padding()
                        }

                        HStack {
                            Text(LocalizedStringKey("add_client_gender_label"))
                                .font(.headline)
                                .frame(width: 120, alignment: .leading)
                            Picker("", selection: $clientGender) {
                                Text(LocalizedStringKey("add_client_gender_male")).tag("Male")
                                Text(LocalizedStringKey("add_client_gender_female")).tag("Female")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                        }

                        HStack {
                            Text(LocalizedStringKey("add_client_first_info_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_first_info_placeholder"), text: $clientFirstInformation)
                                .padding()
                        }
                        HStack {
                            Text(LocalizedStringKey("add_client_second_info_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_second_info_placeholder"), text: $clientSecondInformation)
                                .padding()
                        }
                        HStack {
                            Text(LocalizedStringKey("add_client_third_info_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_third_info_placeholder"), text: $clientThirdInformation)
                                .padding()
                        }
                        HStack {
                            Text(LocalizedStringKey("add_client_fourth_info_label"))
                                .font(.headline)
                                .frame(width: 130, alignment: .leading)
                            TextField(LocalizedStringKey("add_client_fourth_info_placeholder"), text: $clientFourthInformation)
                                .padding()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(width: 500, height: 570, alignment: .leading)
            .onAppear {
                loadClientData()
            }
        }
    }

    private func loadClientData() {
        clientName = client.name ?? ""
        clientEmail = client.email ?? ""
        clientPhone = client.phone ?? ""
        clientAddress = client.address ?? ""
        clientGender = client.gender ?? ""
        clientFirstInformation = client.firstInformation ?? ""
        clientSecondInformation = client.secondInformation ?? ""
        clientThirdInformation = client.thirdInformation ?? ""
        clientFourthInformation = client.fourthInformation ?? ""
    }

    private func resetToOriginalValues() {
        loadClientData()
    }

    func textValidation() -> Bool {
        return clientName.isEmpty
    }

    private func updateClient() {
        withAnimation {
            client.name = clientName
            client.email = clientEmail
            client.phone = clientPhone
            client.address = clientAddress
            client.gender = clientGender
            client.firstInformation = clientFirstInformation
            client.secondInformation = clientSecondInformation
            client.thirdInformation = clientThirdInformation
            client.fourthInformation = clientFourthInformation

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
}

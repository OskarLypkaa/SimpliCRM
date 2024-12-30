import SwiftUI

struct ClientInfo: View {
    @State private var showAddAction: Bool = false
    @State private var refreshList: Bool = false
    
    var client = Client()
    
    var body: some View {
        CloseableHeader()
        
        VStack(spacing: 20) {
            
            HStack {
                Text("Client information")
                    .font(.title)
                Spacer()
                Button(action: {
                    showAddAction = true
                }) {
                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        .font(.system(size: 30))
                        .padding(.leading, 15)
                        .padding(.top, 5)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle()) // Usuwa domyślny styl przycisku
                .sheet(isPresented: $showAddAction) {
                    AddAction(refreshList: $refreshList, client: client)
                }
            }
            
            // Imię klienta
            HStack {
                Text("Name:")
                    .font(.headline)
                Text(client.name ?? "No name")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Email klienta
            HStack {
                Text("Email:")
                    .font(.headline)
                Text(client.email ?? "No name")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Telefon klienta
            HStack {
                Text("Phone:")
                    .font(.headline)
                Text(client.phone ?? "No name")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Adres klienta
            HStack {
                Text("Address:")
                    .font(.headline)
                Text(client.address ?? "No name")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.bottom, 40)
        .frame(width: 500, height:360, alignment: .leading)
    }
}

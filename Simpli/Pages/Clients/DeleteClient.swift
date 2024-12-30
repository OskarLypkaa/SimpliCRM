import SwiftUI


struct DeleteClientView: View {
    
    @State private var showAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var client: Client // Obiekt klienta do usunięcia
    @Binding var refreshList: Bool
    
    
    var body: some View {
        VStack {
            Button(action: {
                self.showAlert = true // Pokazujemy alert przed usunięciem klienta
            }) {
                Image(systemName: "trash")
                    .frame(width: 24, height: 24)
                    .font(.title2)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
            
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showAlert) {
                CloseableHeader()
                VStack {
                    Text("Are you sure you want to delete this client?")
                       .font(.headline)
                    Text(client.name ?? "Unknown")
                       .font(.title)
                       .fontWeight(.bold)
                       .padding(.bottom)
                   
                    HStack {
                       Button("Cancel") {
                           showAlert = false
                       }
                       .buttonStyle(PlainButtonStyle())
                       Spacer()
                       Button("Yes") {
                           deleteClient()
                           showAlert = false
                           
                       }
                       .buttonStyle(PlainButtonStyle())
                   }
                   .frame(width: 200)
               }
               .frame(width: 320, height: 150)
            }
        }
        .padding(.horizontal)
    }
    
    private func deleteClient() {
        withAnimation {
            // Usuwamy klienta z kontekstu
            viewContext.delete(client)
            do {
                // Zapisujemy zmiany w bazie danych
                try viewContext.save()
                refreshList.toggle()
    
            } catch {
                // Obsługa błędu w przypadku problemów z zapisaniem
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

import SwiftUI

struct DeleteClientView: View {
    
    @State private var showAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var settings = Settings.shared
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
                    Text(LocalizedStringKey("delete_client_confirmation"))
                        .font(.headline)
                    Text(client.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    HStack {
                        Button(LocalizedStringKey("cancel_button")) {
                            showAlert = false
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.title)
                        Spacer()
                        Button(LocalizedStringKey("confirm_button")) {
                            deleteClient()
                            showAlert = false
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.title)
                    }
                    .frame(width: 200)
                    Spacer()
                }
                
                .environment(\.locale, .init(identifier: settings.language.code))
                .frame(width: 320, height: 120)
            }
        }
        .padding(.horizontal)
    }
    
    private func deleteClient() {
        withAnimation {
            // Usuwamy wszystkie akcje związane z klientem
            if let actionsToDelete = client.actions?.allObjects as? [NSManagedObject] {
                for action in actionsToDelete {
                    viewContext.delete(action)
                }
            }
            
            // Usuwamy klienta
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

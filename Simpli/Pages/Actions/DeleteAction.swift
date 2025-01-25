import SwiftUI

struct DeleteActionView: View {
    @State private var showAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: Settings // Dostęp do settings
    
    var action: Actions
    @Binding var refreshList: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                self.showAlert = true // Pokazujemy alert przed zmianą statusu lub usunięciem
            }) {
                Image(systemName: "trash")
                    .frame(width: 24, height: 24)
                    .font(.title2)
                    .onHover { hovering in
                        hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showAlert) {
                CloseableHeader()
                VStack {
                    if settings.showArchived && action.status == "Archived" {
                        // Potwierdzenie usunięcia akcji
                        Text(LocalizedStringKey("delete_action_confirmation"))
                            .font(.headline)
                    } else {
                        // Potwierdzenie archiwizacji akcji
                        Text(LocalizedStringKey("archive_action_confirmation"))
                            .font(.headline)
                            .padding(.bottom)
                    }
                    HStack {
                        Button(LocalizedStringKey("cancel_button")) {
                            showAlert = false
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Button(LocalizedStringKey("yes_button")) {
                            if settings.showArchived && action.status == "Archived" {
                                deleteAction() // Usuwamy akcję
                            } else {
                                archiveAction() // Archiwizujemy akcję
                            }
                            showAlert = false
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.title)
                    .frame(width: 200)
                    .padding(.bottom, 20)
                    Spacer()
                }
                .frame(width: 320, height: 100)
            }
        }
        .padding(.horizontal)
    }
    
    private func deleteAction() {
        withAnimation {
            viewContext.delete(action) // Usunięcie akcji
            
            do {
                try viewContext.save() // Zapisanie zmian w bazie danych
                refreshList.toggle()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func archiveAction() {
        withAnimation {
            action.status = "Archived" // Zmieniamy status na "Archived"
            
            do {
                try viewContext.save() // Zapisanie zmian w bazie danych
                refreshList.toggle()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

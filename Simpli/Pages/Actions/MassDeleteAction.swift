import SwiftUI

struct MassDeleteAction: View {
    @State private var showFirstAlert = false
    @State private var showSecondAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: Settings
    
    @FetchRequest(
        entity: Actions.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Actions.creationDate, ascending: false)]
    ) var actions: FetchedResults<Actions>
    
    var body: some View {
        VStack {
            Button(action: {
                showFirstAlert = true
            }) {
                Image(systemName: "archivebox")
                    .font(.largeTitle)
                    .padding(.leading, 15)
                    .onHover { hovering in
                        hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showFirstAlert) {
                if settings.showArchived {
                    // Potwierdzenie usunięcia akcji
                    ConfirmationSheet(
                        message: LocalizedStringKey("delete_archived_confirmation"),
                        onConfirm: {
                            showFirstAlert = false
                            showSecondAlert = true // Przejdź do drugiego potwierdzenia
                        },
                        onCancel: {
                            showFirstAlert = false
                        }
                    )
                    .environment(\.locale, .init(identifier: settings.language.code))
                } else {
                    // Potwierdzenie archiwizacji akcji
                    ConfirmationSheet(
                        message: LocalizedStringKey("archive_done_confirmation"),
                        onConfirm: {
                            archiveDoneActions()
                            showFirstAlert = false
                        },
                        onCancel: {
                            showFirstAlert = false
                        }
                    )
                    .environment(\.locale, .init(identifier: settings.language.code))
                }
            }
            .sheet(isPresented: $showSecondAlert) {
                // Drugie potwierdzenie dla usunięcia
                ConfirmationSheet(
                    message: LocalizedStringKey("delete_archived_irreversible_confirmation"),
                    onConfirm: {
                        deleteArchivedActions()
                        showSecondAlert = false
                    },
                    onCancel: {
                        showSecondAlert = false
                    }
                )
                .environment(\.locale, .init(identifier: settings.language.code))
            }
        }
    }
    
    private func archiveDoneActions() {
        withAnimation {
            for action in actions where action.status == "Done" {
                action.status = "Archived"
            }
            saveContext()
        }
    }
    
    private func deleteArchivedActions() {
        withAnimation {
            for action in actions where action.status == "Archived" {
                viewContext.delete(action)
            }
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ConfirmationSheet: View {
    let message: LocalizedStringKey
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        CloseableHeader()
        VStack {
            Text(message)
                .font(.headline)
                .padding(.bottom)
            HStack {
                Button(LocalizedStringKey("cancel_button")) {
                    onCancel()
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button(LocalizedStringKey("yes_button")) {
                    onConfirm()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.title)
            .frame(width: 200)
            Spacer()
        }
        .frame(width: 320, height: 100)
    }
}

import SwiftUI

struct ActionsHeader: View {
    @State private var showAddAction: Bool = false
    @State private var showDeleteAction: Bool = false
    @State private var showBatchAction: Bool = false // Nowy stan dla BatchActionView
    @Binding var searchText: String
    @Binding var highlighted: Bool
    @Binding var showSheet: Bool
    @Binding var showFilterSheet: Bool
    @State private var refreshList: Bool = false
    
    @State private var isDraggingOver = false
    @Binding var draggedAction: Actions?
    
    @ObservedObject var settings = Settings.shared
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            HStack {
                SearchBar(searchText: $searchText, showSheet: $showSheet)
                    .onChange(of: searchText) { oldValue, newValue in
                        if newValue.count > oldValue.count {
                            highlighted = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                highlighted = false
                            }
                        }
                    }
                    .environment(\.locale, .init(identifier: settings.language.code))
                // Istniejące przyciski
                HStack {
                    Button(action: {
                        showAddAction = true
                    }) {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .font(.largeTitle)
                            .padding(.leading, 15)
                            .padding(.bottom, 6)
                            .onHover { hovering in
                                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showAddAction) {
                        AddActionWithClient(refreshList: $refreshList)
                            .environment(\.locale, .init(identifier: settings.language.code))
                    }
                    
                    MassDeleteAction() // Wywołanie BatchActionView
                        .environment(\.managedObjectContext, viewContext)
                        .environment(\.locale, .init(identifier: settings.language.code))
                
                    
                    Button(action: {
                        showDeleteAction = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation {
                                showDeleteAction = false
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .padding(.leading, 22)
                            .padding(.bottom, 6)
                            .onHover { hovering in
                                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onDrop(of: [.plainText], isTargeted: $isDraggingOver) { _ in
                        if settings.showArchived && draggedAction?.status == "Archived" {
                            deleteAction() // Usuwamy akcję
                        } else {
                            archiveAction() // Archiwizujemy akcję
                        }
                        return true
                    }
                }
                .padding(.trailing, 32)
            }
        }
        .padding(.trailing, 20)
        .sheet(isPresented: $showDeleteAction) {
            AutoDismissSheetView(
                message: LocalizedStringKey("delete_action_prompt"),
                displayDuration: 3,
                isPresented: $showDeleteAction
            )
            .environment(\.locale, .init(identifier: settings.language.code))
        }
    }
    
    private func deleteAction() {
        withAnimation {
            viewContext.delete(draggedAction!) // Usunięcie akcji
            
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
            draggedAction?.status = "Archived" // Zmieniamy status na "Archived"
            
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

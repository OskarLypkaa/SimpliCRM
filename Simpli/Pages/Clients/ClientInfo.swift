import SwiftUI
import CoreData

struct ClientInfo: View {
    @State private var showAddAction: Bool = false
    @State private var showEditClient: Bool = false
    
    @State private var refreshList: Bool = false
    @State private var clientNote: String = ""
    @State private var showMessage: Bool = false
    
    @State private var isWarningVisible: Bool = false
    @EnvironmentObject var settings: Settings
    @Environment(\.managedObjectContext) private var viewContext
    // Używamy FetchRequest, aby pobrać akcje przypisane do konkretnego klienta
    @FetchRequest var actions: FetchedResults<Actions>

    var client: Client // Zmieniamy na prawdziwy obiekt Client

    init(client: Client) {
        self.client = client
        // Filtrowanie akcji na podstawie klienta (relacja client w Actions)
        _actions = FetchRequest<Actions>(
            entity: Actions.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Actions.creationDate, ascending: false)],
            predicate: NSPredicate(format: "client == %@", client)
        )
    }

    var body: some View {
        CloseableHeader()

        VStack(spacing: 10) {
            HStack {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.title)
                    Text(client.name ?? "Something went wrong :(")
                        .font(.title)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                Button(action: {
                    showEditClient = true
                }) {
                    Image(systemName: "pencil")
                        .font(.title)
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
                .sheet(isPresented: $showEditClient) {
                    EditClient(refreshList: $refreshList, client: client)
                        .environment(\.locale, .init(identifier: settings.language.code))
                }
                Spacer()
                Button(action: {
                    FilesManager.shared.openClientFolderInFinder(clientName: client.name ?? "")
                }) {
                    Image(systemName: "folder")
                        .font(.largeTitle)
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
                
                Button(action: {
                    showAddAction = true
                }) {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.largeTitle)
                        .padding(.leading, 15)
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
                        .environment(\.locale, .init(identifier: settings.language.code))
                }
                
            }
            .padding(.horizontal)
            HStack {
                if(client.email != "") {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .frame(width: 24, height: 18)
                        Text(client.email ?? "Something went wrong :(")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
   
                if(client.phone != "") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .frame(width: 24, height: 18)
                        Text(client.phone ?? "Something went wrong :(")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                

                if(client.address != "") {
                    HStack {
                        Image(systemName: "map.fill")
                            .frame(width: 24, height: 18)
                        Text(client.address ?? "Something went wrong :(")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
                
                if(client.gender != "") {
                    HStack {
                        if(client.gender == "Male") {
                            Image(systemName: "figure.stand")
                                .frame(width: 24, height: 18)
                        } else {
                            Image(systemName: "figure.stand.dress")
                                .frame(width: 24, height: 18)
                        }
                        Text(client.gender ?? "Something went wrong :(")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }.padding(.horizontal)
            
            HStack {
                if(client.firstInformation != "") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.firstInformation ?? "Something went wrong :(")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
   
                if(client.secondInformation != "") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.secondInformation ?? "Something went wrong :(")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                

                if(client.thirdInformation != "") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.thirdInformation ?? "Something went wrong :(")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }.padding(.horizontal)

            
            VStack(alignment: .leading) {
                
                
                TextEditorWithWarning(actionMessage: $clientNote, isWarningVisible: $isWarningVisible)
                    .padding(.horizontal)
                    .frame(height: 100)
                HStack {
                    Spacer()
                    Button(action: {
                        updateNote()
                    }) {
                        Text(LocalizedStringKey("save_note_button"))
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom)
                    .sheet(isPresented: $showMessage) {
                        AutoDismissSheetView(
                            message: LocalizedStringKey("note_saved_message"),
                            displayDuration: 1.5,
                            isPresented: $showMessage
                        )
                        .environment(\.locale, .init(identifier: settings.language.code))
                    }
                }
            }
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if actions.isEmpty {
                            Text(LocalizedStringKey("no_actions_available"))
                                .font(.title)
                                .padding()
                        } else {
                            ForEach(filteredActions, id: \.id) { action in
                                HStack {
                                    ActionInClientListView(action: action)
                                    DeleteActionView(action: action, refreshList: $refreshList)
                                        .padding(.bottom, 8)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadClientData()
        }
        .onChange(of: refreshList) {
            // Odśwież widok, gdy `refreshList` się zmienia
        }
        .padding(.bottom, 40)
        .frame(width: 700, height: 500, alignment: .leading)
    }
    private var filteredActions: [Actions] {
        actions.filter { action in
            // Wyświetlaj "Archived" tylko, jeśli settings.showArchived jest true
            if action.status == "Archived" {
                return settings.showArchived
            }
            return true // Wyświetlaj pozostałe akcje zawsze
        }
    }

    private func loadClientData() {
        clientNote = client.note ?? ""
    }
    
    private func updateNote() {
        withAnimation {
            client.note = clientNote
            
            
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



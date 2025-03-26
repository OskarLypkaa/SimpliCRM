import SwiftUI

// Widok pojedynczego klienta
struct ActionInClientListView: View {
    var action: Actions
    
    @State private var isHovered: Bool = false // Stan najechania

    @State private var showSheet = false
    @State private var showingEditAction: Bool = false
    @State private var refreshList: Bool = false 
    @ObservedObject var settings = Settings.shared
    var body: some View {
        ZStack {
            // Tło z animacją
            Rectangle()
                .fill(
                    isHovered ? Color.gray.opacity(0.04) :
                    Color.clear
                )
                .cornerRadius(6)
            
            VStack {
                HStack {
                    VStack{
                        Text(action.message ?? "")
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            if let creationDate = action.creationDate {
                                Text("\(formattedDate(creationDate))")
                                    .opacity(0.5)
                                    .font(.subheadline)
                                Spacer()
                            }
                            switch action.status {
                            case "ToDo":
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.orange)
                            case "In Progress":
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.blue)
                            case "Blocked":
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.red)
                            case "Done":
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.green)
                            case "Archived":
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.gray)
                            default:
                                EmptyView()
                            }
                            
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                    Divider()
                    VStack {
                        if let dueDate = action.dueDate {
                            Text(" \(formattedDateNoTime(dueDate))")
                                .foregroundColor(.gray)
                        }
                        Text(LocalizedStringKey(action.criticality ?? ""))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 120, maxWidth: 120)
                    
                }
                
            }
            .padding(3)
        }
        .scaleEffect(isHovered ? 1.003 : 1) // Powiększenie przy hover
        .onHover { hovering in
            withAnimation {
                isHovered = hovering // Obsługa hover
            }
            if isHovered {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .sheet(isPresented: $showingEditAction) {
            EditAction(actionObject: action, refreshList: $refreshList)
                .environment(\.locale, .init(identifier: settings.language.code))
        }
        .onTapGesture {
            showingEditAction.toggle()
        }
        .onChange(of: refreshList) {
            // Odśwież widok, gdy `refreshList` się zmienia
        }
       
    }
}




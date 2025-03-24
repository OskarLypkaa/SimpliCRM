import SwiftUI

// Widok pojedynczego klienta
struct ActionBlock: View {
    var action: Actions
    
    @State private var isHovered: Bool = false // Stan najechania
    @State private var showSheet = false
    @State private var showingEditAction = false
    @ObservedObject var settings = Settings.shared
    @State private var refreshList: Bool = false
    
    var body: some View {
        ZStack {
            // Tło z animacją
            Rectangle()
                .fill(
                    isHovered ? Color.gray.opacity(0.04) :
                    Color.gray.opacity(0.03)
                )
                .cornerRadius(8)
            

                
            VStack{
                HStack {
                    Image(systemName: {
                        switch action.type {
                        case "Meeting":
                            return "person.3.fill"
                        case "Call":
                            return "phone.fill"
                        case "Email":
                            return "envelope.fill"
                        case "Follow-Up":
                            return "arrow.triangle.branch"
                        case "Contract":
                            return "doc.text.fill"
                        default:
                            return "checkmark.circle.fill"
                        }
                    }())
                    Text(action.client?.name ?? "")
                        .font(.headline)
                        .padding(4)
                    Spacer()
                    Text(LocalizedStringKey(action.criticality ?? ""))
                        .opacity(0.2)
                        .font(.caption2)
                }
                .padding(.horizontal)
                Divider()
                    .padding(.horizontal)
                Text(action.message!)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                    
                    if let dueDate = action.dueDate {
                        Text(" \(formattedDateNoTime(dueDate))")
                            .font(.headline)
                    }
                    Spacer()
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
                
                if let creationDate = action.creationDate {
                    Text("\(formattedDate(creationDate))")
                        .opacity(0.2)
                        .font(.caption2)
                }
            }

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
        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
    }
}


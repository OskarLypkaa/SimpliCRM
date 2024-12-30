import SwiftUI

// Widok nagłówków tabeli z opcją sortowania
struct TableHeaders: View {
    
    @Binding var isAscending: Bool
    @Binding var sortingKey: String 

    var body: some View {
        HStack {
            HStack {
                Text("Name")
                    .font(.headline)
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 10, height: 10)
                    .padding(.leading, 3)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                    .onTapGesture {
                        sortingKey = "name"
                        isAscending.toggle() // Przełączenie porządku sortowania
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Email")
                    .font(.headline)
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 10, height: 10)
                    .padding(.leading, 3)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                    .onTapGesture {
                        sortingKey = "email"
                        isAscending.toggle() // Przełączenie porządku sortowania
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Phone")
                    .font(.headline)
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 10, height: 10)
                    .padding(.leading, 3)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                    .onTapGesture {
                        sortingKey = "phone"
                        isAscending.toggle() // Przełączenie porządku sortowania
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Address")
                    .font(.headline)
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(.gray)
                    .frame(width: 10, height: 10)
                    .padding(.leading, 3)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                    .onTapGesture {
                        sortingKey = "address"
                        isAscending.toggle() // Przełączenie porządku sortowania
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 70)
        .padding(.trailing, 50)
    }
}

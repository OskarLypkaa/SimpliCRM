import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var showSheet: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
}

// Funkcja nagłówka z przyciskiem do zamknięcia okna
struct CloseableHeader: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                dismiss() // Zamyka obecne okno
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
            }
            
            .buttonStyle(PlainButtonStyle())
        }
        .padding(3)
    }
}

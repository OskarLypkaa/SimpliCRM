import SwiftUI
import CoreData

struct ClientFilter: View {
    @Binding var selectedItems: Set<String> // Powiązanie z nadrzędnym widokiem
    
    private let options = [
        "name",
        "phone",
        "email",
        "firstInformation",
        "secondInformation",
        "thirdInformation",
        "fourthInformation",
        "gender",
        "address"
    ]
    
    var body: some View {
        CloseableHeader()
        VStack {
            HStack {
                Text(LocalizedStringKey("filter_clients"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            // Lista z selekcją
            VStack {
                ForEach(options, id: \.self) { item in
                    HStack {
                        Text(LocalizedStringKey(item))
                            .font(.body)
                            .padding(.vertical,3)
                        
                        Spacer()
                        
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark.circle.fill")
                                .padding(2)
                                .animation(.easeInOut(duration: 0.15), value: selectedItems)
                        }
                    }
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(selectedItems.contains(item) ? Color.gray.opacity(0.03) : Color.clear)
                            .animation(.easeInOut(duration: 0.15), value: selectedItems)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(of: item)
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                }
            }
            
            Spacer()
            
            Text(LocalizedStringKey("selected_filters"))
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
            Text(selectedItems.map { NSLocalizedString($0, comment: "") }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            // Zapewniamy, że na starcie zawsze jest przynajmniej jeden filtr
            if selectedItems.isEmpty {
                selectedItems.insert(options.first!)
            }
        }
    }
   
    private func toggleSelection(of item: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selectedItems.contains(item) {
                if selectedItems.count > 1 { // Nie pozwalamy na usunięcie ostatniego filtra
                    selectedItems.remove(item)
                }
            } else {
                selectedItems.insert(item)
            }
        }
    }
}

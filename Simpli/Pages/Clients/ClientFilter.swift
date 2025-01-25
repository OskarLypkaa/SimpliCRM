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
        "gender",
        "address"
    ]
    
    var body: some View {
        CloseableHeader()
        VStack {
            HStack {
                Text("Filter Clients")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            // Lista z selekcją
            VStack {
                ForEach(options, id: \ .self) { item in
                    HStack {
                        Text(item.capitalized)
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
            
            Text("Selected: \(selectedItems.joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
        
    }
   
    
    private func toggleSelection(of item: String) {
        if selectedItems.contains(item) {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedItems.remove(item)
            }
        } else {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedItems.insert(item)
            }
        }
    }
}

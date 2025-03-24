import SwiftUI

struct ActionButton: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let image: String
    
    let isUnderDevelopment: Bool
    let action: () -> Void // Akcja, która zostanie wykonana po kliknięciu
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: action) { // Przekazywana akcja
            ZStack {
                Image(systemName: image)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)

                Spacer()

                if isUnderDevelopment {
                    Text(LocalizedStringKey("feature_under_development"))
                        .font(.footnote)
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovered ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle()) // Usuwa domyślny styl przycisku
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .scaleEffect(isHovered ? 1.002 : 1)
    }
}

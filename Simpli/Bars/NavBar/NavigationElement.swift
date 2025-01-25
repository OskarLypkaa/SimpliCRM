import SwiftUI

struct NavElement: View {
    var title: String
    var imageName: String
    @Binding var isSelected: String
    @State private var isHovered: Bool = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected == title ? Color.gray.opacity(0.2) : (isHovered ? Color.gray.opacity(0.05) : Color.clear))
                .cornerRadius(8)

            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                Image(systemName: imageName)
                    .frame(maxWidth: .infinity)
            }
            .font(.title2)
            .padding(.vertical, 6)
            .scaleEffect(isHovered ? 1.01 : 1)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isSelected = title
        }
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
            if hovering { NSCursor.pointingHand.set() }
            else { NSCursor.arrow.set() }
        }
    }
}

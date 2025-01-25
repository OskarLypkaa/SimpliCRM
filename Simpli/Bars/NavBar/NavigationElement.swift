import SwiftUI

struct NavElement: View {
    var title: LocalizedStringKey
    var imageName: String
    @Binding var isSelected: String
    @Binding var isCalendarExpanded: Bool
    @State private var isHovered: Bool = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected == localizedString(from: title) ? Color.gray.opacity(0.2) : (isHovered ? Color.gray.opacity(0.05) : Color.clear))
                .cornerRadius(5)

            HStack {
                Image(systemName: imageName)
                    .padding(.horizontal)
                    .frame(width: imageName == "" ? 0 : 59)
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    
            }
            .font(.title)
            .padding(.vertical, 6)
            .scaleEffect(isHovered ? 1.01 : 1)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            isSelected = localizedString(from: title)
            if(isSelected != "calendar_month" && isSelected != "calendar_week") {
                isCalendarExpanded = false
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
            if hovering { NSCursor.pointingHand.set() }
            else { NSCursor.arrow.set() }
        }
    }

    private var titleAsString: String {
        Mirror(reflecting: title).children.first(where: { $0.label == "key" })?.value as? String ?? ""
    }
}

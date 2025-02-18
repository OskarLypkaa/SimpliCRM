import SwiftUI

struct SettingsButton: View {
    let action: () -> Void
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(3)
            .frame(maxWidth: .infinity)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .padding(.bottom, 8)
        Divider()
    }
}

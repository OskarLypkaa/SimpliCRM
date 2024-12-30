import SwiftUI

// Widok pojedynczego klienta
struct Clients: View {
    var client: Client

    @Binding var highlighted: Bool


    @State private var isHovered: Bool = false // Stan najechania
    @State private var isPressed: Bool = false // Stan kliknięcia
    
    @State private var showSheet = false

    var body: some View {
        ZStack {
            // Tło z animacją
            Rectangle()
                .fill(
                    highlighted ? Color.yellow.opacity(0.03) :
                    isPressed ? Color.gray.opacity(0.1) :
                    isHovered ? Color.gray.opacity(0.02) :
                    Color.clear
                )
                .cornerRadius(6)
                .animation(.easeInOut(duration: 0.7), value: highlighted) // Animacja koloru

            HStack {
                // Imię klienta z ikoną
                HStack {
                    Image(systemName: "person.fill")
                        .frame(width: 24, height: 18)
                    Text(client.name ?? "WTF")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Pionowy separator
                Divider()
                    .frame(height: 18)
                    .background(Color.gray)

                // Email z ikoną
                HStack {
                    Image(systemName: "envelope.fill")
                        .frame(width: 24, height: 18)
                    Text(client.email ?? "WTF")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Pionowy separator
                Divider()
                    .frame(height: 18)
                    .background(Color.gray)

                // Telefon z ikoną
                HStack {
                    Image(systemName: "phone.fill")
                        .frame(width: 24, height: 18)
                    Text(client.phone ?? "WTF")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Pionowy separator
                Divider()
                    .frame(height: 18)
                    .background(Color.gray)

                // Adres z ikoną
                HStack {
                    Image(systemName: "map.fill")
                        .frame(width: 24, height: 18)
                    Text(client.address ?? "WTF")
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                
            }
            .padding()
        }
        .scaleEffect(isHovered ? 1.003 : 1) // Powiększenie przy hover
        .onHover { hovering in
            withAnimation {
                isHovered = hovering // Obsługa hover
            }
            if isHovered {
                NSCursor.pointingHand.set()
            }
            else {
                NSCursor.arrow.set()
            }
        }
        .onTapGesture {
            isPressed.toggle() // Zmiana stanu kliknięcia
            showSheet.toggle()
        }
        .sheet(isPresented: $showSheet) {
            ClientInfo(client: client) // Okno, które się pojawi po kliknięciu przycisku
        }
        .onAppear {
            // Zaczynamy nasłuchiwanie na naciśnięcie klawisza ESC
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // ESC key code
                    isPressed = false // Zmieniamy stan na false po naciśnięciu ESC
                }
                return event
            }
        }
    }
}


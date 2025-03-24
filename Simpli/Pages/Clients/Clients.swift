import SwiftUI

struct Clients: View {
    var client: Client
    @State private var isHovered: Bool = false
    @ObservedObject var settings = Settings.shared
    @State private var showSheet = false
    var displayedFilters: Set<String> // Przekazane filtry

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isHovered ? Color.gray.opacity(0.02) : Color.clear)
                .cornerRadius(6)

            HStack {
                if displayedFilters.contains("name") {
                    HStack {
                        Image(systemName: "person.fill")
                            .frame(width: 24, height: 18)
                        Text(client.name!)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if displayedFilters.contains("email") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "envelope.fill")
                            .frame(width: 24, height: 18)
                        Text(client.email!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if displayedFilters.contains("phone") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "phone.fill")
                            .frame(width: 24, height: 18)
                        Text(client.phone!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if displayedFilters.contains("firstInformation") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.firstInformation!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if displayedFilters.contains("secondInformation") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.secondInformation!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if displayedFilters.contains("thirdInformation") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 24, height: 18)
                        Text(client.thirdInformation!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if displayedFilters.contains("address") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        Image(systemName: "map.fill")
                            .frame(width: 24, height: 18)
                        Text(client.address!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if displayedFilters.contains("gender") {
                    Divider()
                        .frame(height: 18)
                        .background(Color.gray)

                    HStack {
                        if(client.gender == "Male") {
                            Image(systemName: "figure.stand")
                                .frame(width: 24, height: 18)
                            Text(LocalizedStringKey("gender_male"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        } else {
                            Image(systemName: "figure.stand.dress")
                                .frame(width: 24, height: 18)
                            Text(LocalizedStringKey("gender_female"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                
            }
            .padding()
        }
        .scaleEffect(isHovered ? 1.003 : 1)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
            if isHovered {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .onTapGesture {
            showSheet.toggle()
        }
        .sheet(isPresented: $showSheet) {
            ClientInfo(client: client)
                .environment(\.locale, .init(identifier: settings.language.code))
        }
    }
}

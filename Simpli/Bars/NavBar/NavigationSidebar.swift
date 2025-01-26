import SwiftUI

struct NavigationSidebar: View {
    @Binding var selectedTab: String
    @ObservedObject var settings = Settings.shared
    @State private var isCalendarExpanded: Bool = false

    var body: some View {
        List {
            // Home Tab
            NavElement(
                title: LocalizedStringKey("home_tab"),
                imageName: "house.fill",
                isSelected: $selectedTab,
                isCalendarExpanded: $isCalendarExpanded
            )
            .environment(\.locale, .init(identifier: settings.language.code))
         
            // Clients Tab
            NavElement(
                title: LocalizedStringKey("clients_tab"),
                imageName: "person.fill",
                isSelected: $selectedTab,
                isCalendarExpanded: $isCalendarExpanded
            )
            .environment(\.locale, .init(identifier: settings.language.code))
         
            // Actions Tab
            NavElement(
                title: LocalizedStringKey("actions_tab"),
                imageName: "book.fill",
                isSelected: $selectedTab,
                isCalendarExpanded: $isCalendarExpanded
            )
            .environment(\.locale, .init(identifier: settings.language.code))
       
            NavElement(
                title: LocalizedStringKey("reports_tab"),
                imageName: "chart.pie.fill",
                isSelected: $selectedTab,
                isCalendarExpanded: $isCalendarExpanded
            )
        
            .environment(\.locale, .init(identifier: settings.language.code))
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "calendar")
                        .padding(.horizontal)
                    Text("Calendar")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image(systemName: isCalendarExpanded ? "chevron.down" : "chevron.right")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .font(.title)
                .padding(.vertical, 10)
                .padding(.bottom, 5)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) { // Animacja zmiany stanu
                        isCalendarExpanded.toggle()
                    }
                }

                VStack(alignment: .leading) {
                    NavElement(
                        title: LocalizedStringKey("calendar_month"),
                        imageName: "calendar.and.person",
                        isSelected: $selectedTab,
                        isCalendarExpanded: $isCalendarExpanded
                    )
                    .environment(\.locale, .init(identifier: settings.language.code))

                    NavElement(
                        title: LocalizedStringKey("calendar_week"),
                        imageName: "list.bullet",
                        isSelected: $selectedTab,
                        isCalendarExpanded: $isCalendarExpanded
                    )
                    .environment(\.locale, .init(identifier: settings.language.code))
                    .padding(.bottom, 3)
                    
                }
                .padding(5)
                .opacity(isCalendarExpanded ? 1 : 0) // Animacja przezroczystości
                .animation(.easeInOut, value: isCalendarExpanded) // Animacja zmiany wartości opacity
                .allowsHitTesting(isCalendarExpanded) // Zapobieganie interakcji, gdy ukryte
            }
            .background(isCalendarExpanded ?.gray.opacity(0.05) : Color.clear)
            .cornerRadius(5)
        }
        .navigationSplitViewColumnWidth(min: 210, ideal: 210, max: 270)
    }
}

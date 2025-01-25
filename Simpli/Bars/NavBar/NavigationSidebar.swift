import SwiftUI

struct NavigationSidebar: View {
    @Binding var selectedTab: String

    var body: some View {
        List {
            // Home Tab
            NavElement(
                title: "Home",
                imageName: "house.fill",
                isSelected: $selectedTab
            )

            // Clients Tab
            NavElement(
                title: "Clients",
                imageName: "person.fill",
                isSelected: $selectedTab
            )

            // Actions Tab
            NavElement(
                title: "Actions",
                imageName: "book.fill",
                isSelected: $selectedTab
            )

            // Calendar Tab
            NavElement(
                title: "Calendar",
                imageName: "calendar",
                isSelected: $selectedTab
            )

            // Reports Tab
            NavElement(
                title: "Reports",
                imageName: "chart.pie.fill",
                isSelected: $selectedTab
            )
            
            // Setting Tab
            NavElement(
                title: "Settings",
                imageName: "gearshape.fill",
                isSelected: $selectedTab
            )
        }
        .padding(.top, 10)
        .navigationSplitViewColumnWidth(min: 210, ideal: 210, max: 270)
    }
}

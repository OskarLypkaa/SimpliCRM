import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "Home"

    var body: some View {
        NavigationSplitView {
            NavigationSidebar(selectedTab: $selectedTab)
        } detail: {
            // Display different content based on the selectedTab value
            switch selectedTab {
            case "Home":
                //WelcomeView()
                Text("Select a Tab")
                    .padding()
            case "Clients":
                ClientView()
                
            case "Actions":
                //ActionListView()
                Text("Select a Tab")
                    .padding()
            case "Calendar":
                //CalendarView()
                Text("Select a Tab")
                    .padding()
            case "Reports":
                //ReportView()
                Text("Select a Tab")
                    .padding()
            case "Settings":
                //SettingsView()
                Text("Select a Tab")
                    .padding()
            default:
                Text("Select a Tab")
                    .padding()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

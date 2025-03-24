import SwiftUI
import CoreData

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var clients: FetchedResults<Client>
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var actions: FetchedResults<Actions>
    
    var body: some View {
        CloseableHeader()
        VStack(spacing: 10) {
            Text(LocalizedStringKey("overview_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Zawijamy zawartość w ScrollView, aby była przewijalna
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    // Liczba klientów
                    InfoCard(title: LocalizedStringKey("total_clients"), value: "\(clients.count)")
                    
                    // Liczba akcji
                    InfoCard(title: LocalizedStringKey("total_actions"), value: "\(actions.count)")
                    
                    // Średnia liczba akcji na klienta
                    InfoCard(
                        title: LocalizedStringKey("average_actions_per_client"),
                        value: clients.count > 0 ? String(format: "%.2f", Double(actions.count) / Double(clients.count)) : "N/A"
                    )
                    
                    // Liczba akcji według statusu
                    InfoCard(title: LocalizedStringKey("actions_todo"), value: "\(actions.filter { $0.status == "ToDo" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_in_progress"), value: "\(actions.filter { $0.status == "In Progress" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_done"), value: "\(actions.filter { $0.status == "Done" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_blocked"), value: "\(actions.filter { $0.status == "Blocked" }.count)")
                    
                    // Liczba klientów według płci
                    InfoCard(title: LocalizedStringKey("male_clients"), value: "\(clients.filter { $0.gender == "Male" }.count)")
                    InfoCard(title: LocalizedStringKey("female_clients"), value: "\(clients.filter { $0.gender == "Female" }.count)")
                    
                    // Liczba akcji według typu
                    InfoCard(title: LocalizedStringKey("actions_meeting"), value: "\(actions.filter { $0.type == "Meeting" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_call"), value: "\(actions.filter { $0.type == "Call" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_email"), value: "\(actions.filter { $0.type == "Email" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_follow_up"), value: "\(actions.filter { $0.type == "Follow-Up" }.count)")
                    InfoCard(title: LocalizedStringKey("actions_contract"), value: "\(actions.filter { $0.type == "Contract" }.count)")
                }
                .padding()
            }
        }
    }
}

struct InfoCard: View {
    var title: LocalizedStringKey
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

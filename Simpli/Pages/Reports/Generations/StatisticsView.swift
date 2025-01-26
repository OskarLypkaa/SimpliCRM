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
            Text("Overview")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Zawijamy zawartość w ScrollView, aby była przewijalna
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    // Liczba klientów
                    InfoCard(title: "Total Clients", value: "\(clients.count)")
                    
                    // Liczba akcji
                    InfoCard(title: "Total Actions", value: "\(actions.count)")
                    
                    // Średnia liczba akcji na klienta
                    InfoCard(
                        title: "Average Actions per Client",
                        value: clients.count > 0 ? String(format: "%.2f", Double(actions.count) / Double(clients.count)) : "N/A"
                    )
                    
                    // Liczba akcji według statusu
                    InfoCard(title: "Actions - ToDo", value: "\(actions.filter { $0.status == "ToDo" }.count)")
                    InfoCard(title: "Actions - In Progress", value: "\(actions.filter { $0.status == "In Progress" }.count)")
                    InfoCard(title: "Actions - Done", value: "\(actions.filter { $0.status == "Done" }.count)")
                    InfoCard(title: "Actions - Blocked", value: "\(actions.filter { $0.status == "Blocked" }.count)")
                    
                    // Liczba klientów według płci
                    InfoCard(title: "Male Clients", value: "\(clients.filter { $0.gender == "Male" }.count)")
                    InfoCard(title: "Female Clients", value: "\(clients.filter { $0.gender == "Female" }.count)")
                    
                    // Liczba akcji według typu
                    InfoCard(title: "Actions - Meeting", value: "\(actions.filter { $0.type == "Meeting" }.count)")
                    InfoCard(title: "Actions - Call", value: "\(actions.filter { $0.type == "Call" }.count)")
                    InfoCard(title: "Actions - Email", value: "\(actions.filter { $0.type == "Email" }.count)")
                    InfoCard(title: "Actions - Follow-Up", value: "\(actions.filter { $0.type == "Follow-Up" }.count)")
                    InfoCard(title: "Actions - Contract", value: "\(actions.filter { $0.type == "Contract" }.count)")
                }
                .padding()
            }
        }
    }
}

struct InfoCard: View {
    var title: String
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

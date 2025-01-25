import SwiftUI

struct DataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Overview")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Zawijamy zawartość w ScrollView, aby była przewijalna
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    // Liczba klientów
                    InfoCard(title: "Total Clients", value: "150")

                    // Średnia liczba akcji dziennie na klienta
                    InfoCard(title: "Avg Actions per Day", value: "3.5")

                    // Liczba zakończonych akcji
                    InfoCard(title: "Completed Actions", value: "320")

                    // Liczba akcji w trakcie
                    InfoCard(title: "Actions in Progress", value: "45")

                    // Liczba akcji do zrobienia
                    InfoCard(title: "Actions to be Done", value: "120")

                    // Liczba akcji on hold
                    InfoCard(title: "Actions On Hold", value: "10")

                    // Liczba plików
                    InfoCard(title: "Total Files", value: "2,350")

                    // Liczba nowych plików w tym tygodniu
                    InfoCard(title: "New Files This Week", value: "58")

                    // Liczba aktywnych klientów (w ciągu ostatnich 30 dni)
                    InfoCard(title: "Active Clients (Last 30 Days)", value: "85")

                    // Liczba klientów bez akcji w ostatnich 30 dniach
                    InfoCard(title: "Inactive Clients", value: "15")

                    // Najnowszy plik dodany
                    InfoCard(title: "Newest File Added", value: "Invoice_2345.pdf")

                    Spacer()
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

struct ClientInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}

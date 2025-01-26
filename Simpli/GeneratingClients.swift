import SwiftUI
import CoreData

struct RandomDataGeneratorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Button("Generate 100 Random Clients with Actions") {
                addRandomClientsAndActions()
            }
            .padding()
        }
        .frame(width: 300, height: 200)
    }
    
    private func addRandomClientsAndActions() {
        for _ in 1...100 {
            let client = Client(context: viewContext)
            client.id = UUID()
            client.name = randomName()
            client.email = "\(client.name?.lowercased().replacingOccurrences(of: " ", with: ".") ?? "unknown")@example.com"
            client.phone = randomPhoneNumber()
            client.address = randomAddress()
            client.gender = Bool.random() ? "Male" : "Female"
            client.note = randomNote()
            client.firstInformation = randomFirstInformation()
            client.secondInformation = randomSecondInformation()
            client.thirdInformation = randomThirdInformation()
            
            // Generowanie od 0 do 5 akcji dla klienta
            let actionsCount = Int.random(in: 0...5)
            if actionsCount > 0 {
                for _ in 1...actionsCount {
                    let action = Actions(context: viewContext)
                    action.id = UUID()
                    action.type = randomActionTypeFromPicker()
                    action.status = randomStatusFromPicker()
                    action.message = randomActionMessage()
                    action.dueDate = randomDateWithTime() // Losowa data i czas w jednym
                    action.criticality = randomCriticalityFromPicker()
                    action.creationDate = Date()
                    action.client = client // Powiązanie akcji z klientem
                }
            }
        }
        
        do {
            try viewContext.save()
            print("Random clients and actions have been added successfully!")
        } catch {
            print("Failed to save random data: \(error.localizedDescription)")
        }
    }

    // Funkcje do generowania losowych danych
    private func randomName() -> String {
        let firstNames = ["John", "Jane", "Chris", "Anna", "Mike", "Emily", "Robert", "Sophia", "David", "Laura",
                          "Oliver", "Emma", "Liam", "Isabella", "Noah", "Mia", "James", "Amelia"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Martinez", "Davis", "Lopez", "Taylor",
                         "Anderson", "Thomas", "Moore", "Martin", "Lee", "Perez", "White", "Clark"]
        return "\(firstNames.randomElement()!) \(lastNames.randomElement()!)"
    }

    private func randomPhoneNumber() -> String {
        let areaCode = Int.random(in: 100...999)
        let prefix = Int.random(in: 100...999)
        let lineNumber = Int.random(in: 1000...9999)
        return "\(areaCode)-\(prefix)-\(lineNumber)"
    }

    private func randomAddress() -> String {
        let streets = ["Main St.", "Elm St.", "Maple Ave.", "Oak Dr.", "Pine Ln.", "Cedar Ct.", "Birch Way", "Park Blvd.", "Sunset Ave."]
        let houseNumber = Int.random(in: 1...9999)
        return "\(houseNumber) \(streets.randomElement()!)"
    }

    private func randomNote() -> String {
        let notes = ["VIP Client", "Frequent customer", "Needs follow-up", "Potential lead", "High-value client", "Requires special attention"]
        return notes.randomElement()!
    }

    private func randomFirstInformation() -> String {
        let info = ["Priority Client", "Gold Member", "Basic Plan", "Corporate Account", "Startup Package"]
        return info.randomElement()!
    }

    private func randomSecondInformation() -> String {
        let info = ["Signed contract", "Trial version", "Pending approval", "Needs upgrade", "Standard Package"]
        return info.randomElement()!
    }

    private func randomThirdInformation() -> String {
        let info = ["Uses email marketing", "Interested in webinars", "Prefers phone contact", "No newsletter", "High engagement"]
        return info.randomElement()!
    }

    private func randomActionTypeFromPicker() -> String {
        let actionTypes = ["General", "Meeting", "Call", "Email", "Follow-Up", "Contract"]
        return actionTypes.randomElement()!
    }

    private func randomStatusFromPicker() -> String {
        let statuses = ["ToDo", "In Progress", "Done", "Blocked"]
        return statuses.randomElement()!
    }

    private func randomCriticalityFromPicker() -> String {
        let levels = ["Low", "Medium", "High", "Very High"]
        return levels.randomElement()!
    }

    private func randomActionMessage() -> String {
        let messages = [
            "Discussed project updates.",
            "Scheduled a follow-up meeting.",
            "Sent email proposal to the client.",
            "Called client for feedback.",
            "Reviewed contract details.",
            "Completed initial setup for the client.",
            "Blocked due to missing requirements."
        ]
        return messages.randomElement()!
    }

    private func randomDateWithTime() -> Date {
        let daysToAdd = Int.random(in: -30...30) // Data w zakresie +/- 30 dni od dzisiaj
        let randomHour = Int.random(in: 0...23)
        let randomMinute = Int.random(in: 0...59)
        var date = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())!
        date = Calendar.current.date(bySettingHour: randomHour, minute: randomMinute, second: 0, of: date)!
        return date
    }
}

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

func limitText(_ text: inout String, to maxCharacters: Int) {
      if text.count > maxCharacters {
          text = String(text.prefix(maxCharacters))
      }
  }

func formattedDate(_ date: Date) -> String {
    @ObservedObject var settings = Settings.shared
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    dateFormatter.locale = Locale(identifier: Settings.shared.language.code)
    return dateFormatter.string(from: date)
}
func formattedDateNoTime(_ date: Date) -> String {
    @ObservedObject var settings = Settings.shared
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.locale = Locale(identifier: Settings.shared.language.code)
    return dateFormatter.string(from: date)
}
final class FilterData: ObservableObject {
    @Published var clientName = ""
    @Published var selectedClient: Client? = nil
    @Published var criticality: String = "All"
    @Published var isListExpanded: Bool = false

    // Czyszczenie filtrów
    func clear() {
        clientName = ""
        selectedClient = nil
        criticality = "All"
        isListExpanded = false
    }

    /// Zwraca NSPredicate do filtrowania akcji, albo nil, jeśli brak warunków.
    func toPredicate() -> NSPredicate? {
        var predicates: [NSPredicate] = []
        
        if let selectedName = selectedClient?.name, !selectedName.isEmpty {
            predicates.append(NSPredicate(format: "client.name CONTAINS[c] %@", selectedName))
        } else if !clientName.isEmpty {
            predicates.append(NSPredicate(format: "client.name CONTAINS[c] %@", clientName))
        }

        // Filtrowanie po criticality (tylko jeśli != "All")
        if criticality != "All" {
            predicates.append(NSPredicate(format: "criticality == %@", criticality))
        }

        // Jeśli nie dodaliśmy żadnego warunku, zwróć nil
        if predicates.isEmpty {
            return nil
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
}


func localizedString(from key: LocalizedStringKey) -> String {
    Mirror(reflecting: key).children.first(where: { $0.label == "key" })?.value as? String ?? ""
}

let tabToViewMap: [String: AnyView] = [
    "home_tab": AnyView(HomeView()),
    "clients_tab": AnyView(ClientView()),
    "actions_tab": AnyView(ActionsListView()),
    "reports_tab": AnyView(ReportView()),
    "calendar_month": AnyView(MonthView()),
    "calendar_week": AnyView(WeekView())
    
]

extension Notification.Name {
    static let databasePathChanged = Notification.Name("databasePathChanged")
}




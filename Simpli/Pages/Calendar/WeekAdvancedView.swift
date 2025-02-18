import SwiftUI

struct WeekAdvancedView: View {
    var firstRowDate: Date
    
    var body: some View {
        ScrollView([.vertical, .horizontal], showsIndicators: true) {
            HStack(alignment: .top) {
                // Kolumna godzin
                HourColumnAdvanced()

                // Siatka komórek z podziałem na 15 minut
                DayGridAdvanced(firstRowDate: firstRowDate)
                    .padding(.trailing)
                    .padding(.top)
            }
            .padding(.horizontal, 30)
            
        }
    }
}

struct HourColumnAdvanced: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(6..<23, id: \.self) { hour in
                VStack(spacing: 0) {
                    Text("\(hour):00")
                        .frame(height: 28) // Pierwsze okno godziny
                    ForEach(1..<4, id: \.self) { quarter in
                        Text("\(hour):\(quarter * 15)")
                            .frame(height: 28) // Pozostałe 15-minutowe okna
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct DayGridAdvanced: View {
    var firstRowDate: Date
    let calendar = Calendar.current
    
    @AppStorage("selectedColumn") private var selectedColumn: Int = 0
    @AppStorage("selectedRow") private var selectedRow: Int = 0

    @State private var showDayInformations = false
    
    
    
    @FetchRequest(
        entity: Actions.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Actions.dueDate, ascending: false)],
        predicate: NSPredicate(format: "status IN %@", ["ToDo", "In Progress", "Blocked"])
    ) var actions: FetchedResults<Actions>

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Tło
            Rectangle()
                .frame(width: 685, height: 1900)
                .opacity(0.03)
                .foregroundColor(.gray)
            
            // Pionowe linie siatki
            HStack(spacing: 135) {
                ForEach(0..<8, id: \.self) { column in
                    Rectangle()
                        .frame(width: 2, height: 1900)
                        .foregroundColor(.gray.opacity(0.2))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // Poziome linie siatki
            VStack(spacing: 26) {
                ForEach(0..<69, id: \.self) { row in
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.gray.opacity(row % 4 == 0 ? 1 : 0.2))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            
            
            
            // ------------ Actions ---------------
            let actionsForWeek = getActions(firstRowDate: firstRowDate)
            let gruppedActionsForWeek = groupActionsByQuarterHour(actionsForWeek: actionsForWeek)
            
            let calendar = Calendar.current
 
            ForEach(Array(gruppedActionsForWeek.enumerated()), id: \.0) { _, group in
                if let firstAction = group.first, let dueDate = firstAction.dueDate {
                    let dayOffset = calendar.dateComponents([.day], from: firstRowDate, to: dueDate).day ?? 0
                    let minuteOffset = calendar.dateComponents([.minute], from: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: dueDate)!, to: dueDate).minute ?? 0
                    let rowOffset = minuteOffset / 15 // Każde 15 minut to 1 "rząd"

                    ZStack {
                        if group.count == 1 {
                            if let clientName = firstAction.client?.name {
                                HStack{
                                    Text(clientName)
                                        .opacity(0.8)
                                        .frame(maxWidth: 70, alignment: .leading)
                                    Image(systemName: iconName(for: firstAction.type!))
                                        .font(.system(size: 15))
                                }
                            }
                        } else {
                            HStack(spacing: 0) {
                                ForEach(0..<min(group.count, 3), id: \.self) { index in
                                    Image(systemName: iconName(for: group[index].type!))
                                        .font(.system(size: 15))
                                }
                                if group.count > 3 {
                                    Text(" +\(group.count - 3)")
                                }
                            }
                            .opacity(0.8)
                            
                        }
                    }
                    .frame(width: 139, height: 30)
                    .padding(.leading, CGFloat(137 * dayOffset)) // Przesunięcie w prawo na podstawie dnia
                    .padding(.top, CGFloat(28 * rowOffset)) // Przesunięcie w dół na podstawie 15-minutowych kroków
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                   
                }
            }
            // ------------ Grid ---------------
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { column in
                    VStack(spacing: 0) {
                        ForEach(0..<68, id: \.self) { row in
                            ZStack {
                            }
                            .frame(width: 137, height: 28)
                            .background(.gray)
                            .opacity(0.01)
                            .onTapGesture {
                                showDayInformations = true
                                selectedColumn = column
                                selectedRow = row
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Zabezpiecza przed rozjechaniem
        
        .sheet(isPresented: $showDayInformations) {
            HourInformations(
                selectedDate: .constant(calculateDate())
            )
        }
    }

    
    private func iconName(for type: String) -> String {
        switch type {
        case "Meeting":
            return "person.3.fill"
        case "Call":
            return "phone.fill"
        case "Email":
            return "envelope.fill"
        case "Follow-Up":
            return "arrow.triangle.branch"
        case "Contract":
            return "doc.text.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
    
    private func groupActionsByQuarterHour(actionsForWeek: [Actions]) -> [[Actions]] {
        let calendar = Calendar.current
        
        // Słownik do grupowania akcji
        var groupedActions: [String: [Actions]] = [:]

        for action in actionsForWeek {
            guard let dueDate = action.dueDate else { continue }

            // Pobranie daty (rok, miesiąc, dzień) i zaokrąglenie czasu do 15-minutowego interwału
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            let roundedMinutes = (components.minute! / 15) * 15 // Zaokrąglenie do najbliższego kwadransa
            
            // Odtworzenie daty dla klucza (bez sekund)
            let intervalStart = calendar.date(from: DateComponents(
                year: components.year,
                month: components.month,
                day: components.day,
                hour: components.hour,
                minute: roundedMinutes
            ))!

            let key = ISO8601DateFormatter().string(from: intervalStart) // Klucz dla grupy

            // Dodaj akcję do odpowiedniej grupy
            if groupedActions[key] == nil {
                groupedActions[key] = []
            }
            groupedActions[key]?.append(action)
        }

        // Konwersja słownika na tablicę tablic
        return Array(groupedActions.values)
    }

    
    private func getActions(firstRowDate: Date) -> [Actions] {
        var allActions: [Actions] = []

        let actionsForThisDay = actionsForWeek(firstRowDate: firstRowDate)
        allActions.append(contentsOf: actionsForThisDay)

        return allActions
    }
    
    
    private func actionsForWeek(firstRowDate: Date) -> [Actions] {
        let calendar = Calendar.current

        return actions.filter { action in
            guard let dueDate = action.dueDate else { return false }

            // Sprawdzenie, czy dueDate jest w zakresie firstRowDate -> firstRowDate + 7 dni
            let endDate = calendar.date(byAdding: .day, value: 7, to: firstRowDate)!
            guard dueDate >= firstRowDate && dueDate < endDate else { return false }

            // Sprawdzenie, czy godzina mieści się w przedziale 6:00 - 23:00
            let startOfDay = calendar.startOfDay(for: dueDate)
            let intervalStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: startOfDay)!
            let intervalEnd = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: startOfDay)!

            return dueDate >= intervalStart && dueDate < intervalEnd
        }
    }

    
    
    private func calculateDate() -> Date {
        let minuteOffset = selectedRow * 15
        let dayOffset = selectedColumn

        // Dodaj dni na podstawie kolumny
        let baseDate = calendar.date(byAdding: .day, value: dayOffset, to: firstRowDate)!


        return calendar.date(byAdding: .minute, value: minuteOffset, to: baseDate)!
    }
}




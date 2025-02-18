import SwiftUI
import Foundation

struct WeekDayView: View {
    let isAdvancedView: Bool
    let selectedDay: Date
    let actionForSelectedDay: [Actions]
    let weekColumn: Int
    
    @State private var showDayInformations = false
    @State private var isHovered = false
    
    @StateObject private var model = CalendarModel()
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(height: isAdvancedView ? 30 : 15)
                .foregroundColor(isHovered ? Color.gray.opacity(0.1) : .clear)
                .border(.gray.opacity(0.17), width: 1.5)
                .background(weekColumn < 5 ? Color.gray.opacity(0.03) : Color.clear)
                .onHover { hovering in
                    isHovered = hovering
                }
            
            if !actionForSelectedDay.isEmpty {
                let actionTypes = getActionTypes()
                HStack() {
                    if actionTypes.count == 1 {
                        if let clientName = actionForSelectedDay.first?.client?.name {
                            Text(clientName)
                                .opacity(0.8)
                                .frame(maxWidth: 70, alignment: .leading)
                        }
                    }
                    HStack(spacing: 0) { // Ustaw odstęp między ikonami na 4 punkty (lub inna wartość)
                        ForEach(0..<min(actionTypes.count, 4), id: \.self) { index in
                            Image(systemName: iconName(for: actionTypes[index]))
                                .font(.system(size: isAdvancedView ? 15 : 10))
                        }
                    }
                    .opacity(0.2)
                    if actionTypes.count > 4 {
                        Text("+\(actionTypes.count - 4)")
                            .opacity(0.4)
                    }
                }
                .font(.system(size: isAdvancedView ? 10 : 7))
            }
            
        }
        .onTapGesture {
            showDayInformations = true
        }
        .sheet(isPresented: $showDayInformations) {
            HourInformations(selectedDate: .constant(selectedDay))
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
    
    private func getActionTypes() -> [String] {
        let startOfDay = model.calendar.startOfDay(for: selectedDay)
        let allowedStatuses: Set<String> = ["ToDo", "In Progress", "Blocked"]

        return actionForSelectedDay.compactMap { action in
            guard let dueDate = action.dueDate,
                  let status = action.status,
                  let type = action.type else {
                return nil
            }
            return model.calendar.isDate(dueDate, inSameDayAs: startOfDay) && allowedStatuses.contains(status) ? type : nil
        }
    }
}

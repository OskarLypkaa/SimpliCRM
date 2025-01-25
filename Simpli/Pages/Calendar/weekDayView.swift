import SwiftUI
import Foundation

struct weekDayView: View {
    let column: Int
    let row: Int
    let isAdvancedView: Bool
    @Binding var hoveredColumn: Int?
    @Binding var hoveredRow: Int?
    @State private var isHovered = false
    var firstRowDate: Date

    @State private var showDayInformations = false

    @StateObject private var model = CalendarModel()

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Actions.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Actions.dueDate, ascending: true)]
    ) var allActions: FetchedResults<Actions>

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: isAdvancedView ? 30 : 15)
                .foregroundColor(isHovered ? Color.gray.opacity(0.1) : (shouldHighlight ? Color.gray.opacity(0.05) : .clear))
                .border(column >= 5 ? .gray.opacity(0.08) : .gray.opacity(0.17), width: 1.5)
                .onHover { hovering in
                    withAnimation {
                        isHovered = hovering
                        if hovering {
                            hoveredColumn = column
                            hoveredRow = row
                        } else if hoveredColumn == column && hoveredRow == row {
                            hoveredColumn = nil
                            hoveredRow = nil
                        }
                    }
                    if hovering { NSCursor.pointingHand.set() }
                    else { NSCursor.arrow.set() }
                }
                
                let actionCount:Int = countActionsInInterval()
                if actionCount > 0{
                    Text("\(actionCount) actions")
                        .opacity(0.4)
                        .font(.caption2)
                }
        }
        .onTapGesture {
            showDayInformations = true
        }
        .sheet(isPresented: $showDayInformations) {
            HourInformations(selectedDate: .constant(calculateDate()))
        }
    }

    private var shouldHighlight: Bool {
        if let hoveredColumn = hoveredColumn, let hoveredRow = hoveredRow {
            return row == hoveredRow && column <= hoveredColumn
        }
        return false
    }

    private func calculateDate() -> Date {
        let calendar = Calendar.current
        let minutesPerRow = isAdvancedView ? 15 : 30
        let minuteOffset = row * minutesPerRow

        // Dodaj dni na podstawie kolumny do firstRowDate
        let baseDate = calendar.date(byAdding: .day, value: column, to: firstRowDate)!

        // Dodaj minuty na podstawie wiersza
        let calculatedDate = calendar.date(byAdding: .minute, value: minuteOffset, to: baseDate)!

        return calculatedDate
    }
    
    private func countActionsInInterval() -> Int {
        let calendar = Calendar.current
        let intervalStart = calculateDate()
        let intervalEnd = calendar.date(byAdding: .minute, value: isAdvancedView ? 15 : 30, to: intervalStart)!

        // Filtrowanie akcji z już załadowanej listy allActions
        let matchingActions = allActions.filter { action in
            guard let dueDate = action.dueDate else { return false }
            return dueDate >= intervalStart && dueDate < intervalEnd
        }

        return matchingActions.count
    }


}

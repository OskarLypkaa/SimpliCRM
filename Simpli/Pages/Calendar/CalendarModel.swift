import Foundation
import Combine
import CoreData
import SwiftUI

class CalendarModel: ObservableObject {
    @Published var displayedDate: Date = Date()
    @Published var actionsForDay: [Date: Int] = [:]
    @Published var actionsForHour: [Date: Int] = [:]
    let calendar = Calendar.current

    var shortWeekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let adjustedSymbols = symbols.dropFirst() + symbols.prefix(1)
        return Array(adjustedSymbols)
    }

    func monthAndYear(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: date)
    }

    func generateDays(for date: Date) -> [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        return Array(range)
    }
    
    func previousWeek() {
        updateDisplayedDate(byAdding: .weekOfYear, value: -1)
    }

    func nextWeek() {
        updateDisplayedDate(byAdding: .weekOfYear, value: 1)
    }
    
    func previousMonth() {
        updateDisplayedDate(byAdding: .month, value: -1)
    }

    func nextMonth() {
        updateDisplayedDate(byAdding: .month, value: 1)
    }

    func previousYear() {
        updateDisplayedDate(byAdding: .year, value: -1)
    }

    func nextYear() {
        updateDisplayedDate(byAdding: .year, value: 1)
    }

    func isCurrentDay(_ day: Int) -> Bool {
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: displayedDate)
        return today.year == dayComponents.year && today.month == dayComponents.month && today.day == day
    }
    
    func isCurrentWeekday(index: Int) -> Bool {
        let today = Date()
        let calendar = calendar
        let weekdayIndex = (calendar.component(.weekday, from: today) + 5) % 7 // Przesunięcie, aby poniedziałek = 0
        return index == weekdayIndex
    }
    
    private func updateDisplayedDate(byAdding component: Calendar.Component, value: Int) {
        if let newDate = calendar.date(byAdding: component, value: value, to: displayedDate) {
            displayedDate = newDate
        }
    }
    
    func weekOfYear(for date: Date) -> Int? {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        return weekOfYear
    }

   
    func date(for day: Int, in month: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        return calendar.date(from: components)!
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM" // np. "22 Jan"
        formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: date)
    }
    
    func isSameDay(_ date1: Date, _ date2: Date, calendar: Calendar = .current) -> Bool {
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }

}
struct SelectableDay: Identifiable {
    var id: Int
    var day: Int
}

enum CalendarMode: String, CaseIterable {
    case year = "Year"
    case month = "Month"
    case week = "Week"
}


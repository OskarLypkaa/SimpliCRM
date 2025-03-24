import SwiftUI

struct MonthView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Actions.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Actions.dueDate, ascending: true)]
    ) var allActions: FetchedResults<Actions>
    
    @StateObject private var model = CalendarModel()
    @State private var selectedDate: Date?
    @State private var transitionDirection: CGFloat = 0
    @State private var showDayInformations: Bool = false

    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        VStack {
            Text("\(String(describing: selectedDate))").opacity(0)
            HStack {
                Spacer()
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = -1
                        model.previousYear()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.left.2")
                
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = -1
                        model.previousMonth()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.left")
                
                Text(model.monthAndYear(for: model.displayedDate))
                    .font(.largeTitle)
                    .padding()
                    .frame(width: 250)
                
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = 1
                        model.nextMonth()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.right")
                
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = 1
                        model.nextYear()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.right.2")
                Spacer()
            }
            .padding(.horizontal)
            
            let days = model.generateDays(for: model.displayedDate)
            let weekDays = model.shortWeekdaySymbols
            
            // Obliczenie dnia tygodnia dla pierwszego dnia miesiąca
            let firstDayOfMonth = model.date(for: days.first ?? 1, in: model.displayedDate)
            let weekday = model.calendar.component(.weekday, from: firstDayOfMonth)
            let firstWeekday = (weekday == 1) ? 7 : weekday - 1

            // Obliczenie dni z poprzedniego miesiąca
            let previousMonthDate = model.calendar.date(byAdding: .month, value: -1, to: model.displayedDate)!
            let daysInPreviousMonth = model.calendar.range(of: .day, in: .month, for: previousMonthDate)!.count
            let previousMonthDays: [Int] = firstWeekday > 1 ? Array((daysInPreviousMonth - firstWeekday + 2)...daysInPreviousMonth) : []

            // Obliczenie dni z następnego miesiąca
            let remainingDays = (7 - (days.count + firstWeekday - 1) % 7) % 7
            let nextMonthDays: [Int] = remainingDays > 0 ? Array(1...remainingDays) : []

            // Ustawienie siatki
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                // Nagłówki dni tygodnia
                ForEach(weekDays.indices, id: \.self) { index in
                    Text(weekDays[index])
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(
                            model.isCurrentWeekday(index: index) ? Color.yellow.opacity(0.8) : Color.primary
                        )
                        .cornerRadius(5)
                }

                // Dni z poprzedniego miesiąca
                ForEach(previousMonthDays, id: \.self) { day in
                    let fullDate = model.date(for: day, in: previousMonthDate)
                    DayCellView(
                        day: day,
                        fullDate: fullDate,
                        actionTypes: getActionTypes(for: fullDate),
                        isCurrentDay: false, // Dni z poprzedniego miesiąca nie są aktualnym dniem
                        onDateSelected: { date in
                            selectedDate = date
                        },
                        showDayInformations: {
                            showDayInformations = true
                        }
                    )
                    .opacity(0.6) // Ustawienie niższej widoczności dla dni z poprzedniego miesiąca
                }

                // Dni miesiąca
                ForEach(days, id: \.self) { day in
                    let fullDate = model.date(for: day, in: model.displayedDate)
                    DayCellView(
                        day: day,
                        fullDate: fullDate,
                        actionTypes: getActionTypes(for: fullDate),
                        isCurrentDay: model.isCurrentDay(day),
                        onDateSelected: { date in
                            selectedDate = date
                        },
                        showDayInformations: {
                            showDayInformations = true
                        }
                    )
                    .fontWeight(.bold)
                }

                // Dni z następnego miesiąca
                ForEach(nextMonthDays, id: \.self) { day in
                    let nextMonthDate = model.calendar.date(byAdding: .month, value: 1, to: model.displayedDate)!
                    let fullDate = model.date(for: day, in: nextMonthDate)
                    DayCellView(
                        day: day,
                        fullDate: fullDate,
                        actionTypes: getActionTypes(for: fullDate),
                        isCurrentDay: false,
                        onDateSelected: { date in
                            selectedDate = date
                        },
                        showDayInformations: {
                            showDayInformations = true
                        }
                    )
                    .opacity(0.6)
                }
            }
            .transition(.move(edge: transitionDirection < 0 ? .leading : .trailing))
            .padding()
            Spacer()
        }
        .frame(width: 1000, height: 500)
        .sheet(isPresented: $showDayInformations) {
            DayInformations(selectedDate: .constant(selectedDate ?? Date()))
                .environment(\.locale, .init(identifier: settings.language.code))
        }
    }

    /// Zlicza akcje dla konkretnej daty
    private func getActionTypes(for date: Date) -> [String] {
        let startOfDay = model.calendar.startOfDay(for: date)
        let allowedStatuses: Set<String> = ["ToDo", "In Progress", "Blocked"]

        return allActions.compactMap { action in
            guard let dueDate = action.dueDate,
                  let status = action.status,
                  let type = action.type else {
                return nil
            }
            return model.calendar.isDate(dueDate, inSameDayAs: startOfDay) && allowedStatuses.contains(status) ? type : nil
        }
    }
}

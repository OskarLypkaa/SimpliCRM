import SwiftUI

struct WeekView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Actions.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Actions.dueDate, ascending: true)]
    ) var allActions: FetchedResults<Actions>
    
    @StateObject private var model = CalendarModel()
    @State private var selectedDate: Date?
    @State private var transitionDirection: CGFloat = 0
    @State private var showDayInformations: Bool = false
    
    @State private var isBacisViewDisplayed: Bool = false
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack {
            Text("\(String(describing: selectedDate))").opacity(0)
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isBacisViewDisplayed.toggle()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(isBacisViewDisplayed ? (isHovered ? Color.gray.opacity(0.07) : Color.clear) : Color.gray.opacity(0.15))
                            .cornerRadius(5)
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .font(.largeTitle)
                            .onHover { hovering in
                                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
                                withAnimation {
                                    isHovered = hovering
                                }
                            }
                    }
                    .frame(width: 60, height: 40)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHovered ? 1.01 : 1)
                
                Spacer()
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = -1
                        model.previousMonth()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.left.2")
                
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = -1
                        model.previousWeek()
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
                        model.nextWeek()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.right")
                
                ChevronButton(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        transitionDirection = 1
                        model.nextMonth()
                        transitionDirection = 0
                    }
                }, imageName: "chevron.right.2")
                Spacer()
            }
            .padding(.horizontal)
            
            
            
            HStack(alignment: .top) {
                ForEach(model.shortWeekdaySymbols.indices, id: \.self) { index in
                    VStack {
                        if let startOfWeek = model.calendar.date(from: model.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: model.displayedDate)) {
                            if let weekdayDate = model.calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                                Text(model.shortWeekdaySymbols[index])
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(
                                        model.isSameDay(weekdayDate, Date()) ? Color.yellow.opacity(0.8) : Color.primary
                                    )

                                Text(model.formatDate(date: weekdayDate))
                                    .font(.subheadline)
                                    .foregroundColor(
                                        model.isSameDay(weekdayDate, Date()) ? Color.yellow.opacity(0.8) : Color.secondary
                                    )
                                    .padding(.bottom, 15)
                            }
                        }
                    }
                }
                .transition(.move(edge: transitionDirection < 0 ? .leading : .trailing))
                
            }
            .padding(.leading, 70)
            .padding(.trailing, 70)
            .frame(width: 1100)
            

            if isBacisViewDisplayed {
                if let weekStartDate = model.calendar.date(from: model.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: model.displayedDate)),
                   let startOfDay = model.calendar.date(bySettingHour: 6, minute: 0, second: 0, of: weekStartDate) {
                    WeekBasicView(firstRowDate: startOfDay)
                }
            } else {
                if let weekStartDate = model.calendar.date(from: model.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: model.displayedDate)),
                   let startOfDay = model.calendar.date(bySettingHour: 6, minute: 0, second: 0, of: weekStartDate) {
                    WeekAdvancedView(firstRowDate: startOfDay)
                }
            }
        
            Spacer()
        }
        Spacer()
    }
}



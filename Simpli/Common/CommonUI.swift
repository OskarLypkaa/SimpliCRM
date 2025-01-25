import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var showSheet: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            TextField(LocalizedStringKey("search_placeholder"), text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
}

// Funkcja nagłówka z przyciskiem do zamknięcia okna
struct CloseableHeader: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                dismiss() // Zamyka obecne okno
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
            }
            
            .buttonStyle(PlainButtonStyle())
        }
        .padding(3)
    }
}

struct TextEditorWithWarning: View {
    @Binding var actionMessage: String
    @Binding var isWarningVisible: Bool

    var body: some View {
        VStack(alignment: .leading) {
            

            ZStack(alignment: .leading) {
                if isWarningVisible {
                    Text(LocalizedStringKey("warning_text_max_characters"))
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .zIndex(12)
                        .transition(.opacity)
                }
                
                TextEditor(text: $actionMessage)
                    .textEditorStyle(.plain)
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 200)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                    .padding(.leading, 10)
                    .font(.body)
                    .blur(radius: isWarningVisible ? 2 : 0)
                    .onChange(of: actionMessage) {
                        if actionMessage.count > 600 {
                            isWarningVisible = true
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isWarningVisible = false
                                }
                            }
                        }
                        limitText(&actionMessage, to: 600)
                    }
            }
        }
    }

    /// Function to limit text to a maximum number of characters
    private func limitText(_ text: inout String, to maxCharacters: Int) {
        if text.count > maxCharacters {
            text = String(text.prefix(maxCharacters))
        }
    }
}


import SwiftUI

struct DatePickerWithCallendar: View {
    @Binding var actionDueDate: Date
    @Binding var isDatePickerPresented: Bool
    @EnvironmentObject var settings: Settings // Ustawienia dla języka aplikacji
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("due_date_label"))
                .font(.headline)

            HStack {
                Text("Date: ")
                DatePicker("Date: ", selection: $actionDueDate, displayedComponents: .date)
                    .labelsHidden()
                    .padding(.leading, 10)
                    .environment(\.locale, .init(identifier: settings.language.code)) // Lokalizacja języka
                Text("Time: ")
                DatePicker(
                    "Time: ",
                    selection: $actionDueDate,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .padding(.leading, 10)
            }
        }
        .padding()
    }
    
    // Formatowanie daty do wyświetlenia na przycisku (jeśli potrzebne)
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: settings.language.code) // Lokalizacja języka
        return formatter.string(from: actionDueDate)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}




struct AutoDismissSheetView: View {
    let message: LocalizedStringKey
    let displayDuration: Double
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(message)
                .font(.title)
                .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                isPresented = false
            }
        }
        
    }
}

struct DayCellView: View {
    let day: Int
    let fullDate: Date
    let actionCount: Int?
    let isCurrentDay: Bool
    let onDateSelected: (Date) -> Void
    let showDayInformations: () -> Void

    @State private var isHovering: Bool = false

    var body: some View {
        ZStack {
            Text("\(day)")
            if let actionCount = actionCount, actionCount > 0 {
                Text("\(actionCount) actions")
                    .opacity(0.4)
                    .font(.caption2)
                    .padding(.top, 35)
            }
        }
        .frame(width: 80, height: 50)
        .contentShape(Rectangle())
        .background(isCurrentDay ? Color.yellow.opacity(0.3) : Color.clear)
        .cornerRadius(5)
        .onTapGesture {
            onDateSelected(fullDate)
            showDayInformations()
        }
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

struct ChevronButton: View {
    var action: () -> Void
    var imageName: String
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(isHovered ? Color.gray.opacity(0.1) : Color.clear)
                    .cornerRadius(5)
                Image(systemName: imageName)
                    .font(.title2)
            }
            .frame(width: 60, height: 40)
            .onHover { hovering in
                withAnimation {
                    isHovered = hovering
                }
                hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconButton: View {
    var imageName: String
    var isSelected: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? (isHovered ? Color.gray.opacity(0.07) : Color.clear) : Color.gray.opacity(0.15))
                .cornerRadius(5)
            Image(systemName: imageName)
                .font(.largeTitle)
        }
        .frame(width: 60, height: 40)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
            hovering ? NSCursor.pointingHand.set() : NSCursor.arrow.set()
        }
        .scaleEffect(isHovered ? 1.01 : 1)
    }
}

struct HoverableRectangle: View {
    let column: Int
    let row: Int
    let isAdvancedView: Bool
    @Binding var hoveredColumn: Int?
    @Binding var hoveredRow: Int?
    @State private var isHovered = false

    var body: some View {
        Rectangle()
            .frame(height: isAdvancedView ? 30 : 15)
            .foregroundColor(isHovered ? Color.gray.opacity(0.1): (shouldHighlight ? Color.gray.opacity(0.05) : .clear))
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
    }

    private var shouldHighlight: Bool {
        if let hoveredColumn = hoveredColumn, let hoveredRow = hoveredRow {
            return row == hoveredRow && column <= hoveredColumn
        }
        return false
    }
}

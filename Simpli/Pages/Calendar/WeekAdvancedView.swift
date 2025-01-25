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
                    .frame(minWidth: 950, maxWidth: .infinity)
                    .padding(.trailing)
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
                        .frame(height: 30) // Pierwsze okno godziny
                    ForEach(1..<4, id: \.self) { quarter in
                        Text("\(hour):\(quarter * 15)")
                            .frame(height: 30) // Pozostałe 15-minutowe okna
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(width: 50) // Szerokość kolumny godzin
    }
}

struct DayGridAdvanced: View {
    var firstRowDate: Date
    let calendar = Calendar.current
    @State private var hoveredColumn: Int? = nil
    @State private var hoveredRow: Int? = nil
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(0..<7, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(0..<68, id: \.self) { row in
                        ZStack {
                            // Podstawowa siatka
                            weekDayView(
                                column: column,
                                row: row,
                                isAdvancedView: true,
                                hoveredColumn: $hoveredColumn,
                                hoveredRow: $hoveredRow,
                                firstRowDate: firstRowDate
                            )

                            // Dodatkowe linie
                            if row % 4 == 0 {
                                Rectangle()
                                    .frame(height: 3)
                                    .foregroundColor(column >= 5 ? .gray.opacity(0.16) : .gray.opacity(0.4))
                                    .padding(.bottom, 26)
                            }

                            // Żółty prostokąt dla aktualnego dnia i godziny
                            if isCurrentTime(in: column, at: row) {
                                Rectangle()
                                    .frame(height: 3)
                                    .foregroundColor(.yellow.opacity(0.4))
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 10)
    }
    
    // Sprawdzanie, czy to aktualny czas
    private func isCurrentTime(in column: Int, at row: Int) -> Bool {
        let now = Date()
        let currentWeekday = (calendar.component(.weekday, from: now) + 5) % 7 // Przesunięcie: poniedziałek = 0
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // Kolumna odpowiada bieżącemu dniu tygodnia
        guard column == currentWeekday else { return false }

        // Wiersz odpowiada bieżącej godzinie i minucie (15-minutowe okna)
        let rowHour = 6 + (row / 4) // 6:00 to początek
        let rowMinuteSlot = (row % 4) * 15

        return rowHour == currentHour && currentMinute >= rowMinuteSlot && currentMinute < rowMinuteSlot + 15
    }
}

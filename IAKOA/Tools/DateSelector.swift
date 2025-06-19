import SwiftUI

struct SingleDatePickerView: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .font(.system(size: 12))
                .environment(\.locale, Locale(identifier: "fr_FR"))
                .frame(maxHeight: 280)

            Text("Date sélectionnée : \(formatted(selectedDate))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(6)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DateRangeSelector: View {
    @Binding var startDate: Date
    @Binding var endDate: Date

    @State private var selectedDates: Set<DateComponents> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            MultiDatePicker("", selection: Binding(get: {
                selectedDates
            }, set: { newValue in
                handleDateSelection(newValue)
            }))
            .environment(\.calendar, Calendar.current)
            .environment(\.locale, Locale(identifier: "fr_FR"))
            .frame(maxHeight: 280)

            Text("Du \(formatted(startDate)) au \(formatted(endDate))")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Spacer()
                Button("Réinitialiser la sélection") {
                    selectedDates.removeAll()
                    startDate = Date()
                    endDate = Date()
                }
                .font(.caption2)
                .foregroundColor(.blue)
            }
        }
        .padding(2)
    }

    private func handleDateSelection(_ newValue: Set<DateComponents>) {
        let dates = newValue.compactMap { Calendar.current.date(from: $0) }.sorted()

        switch dates.count {
        case 0:
            selectedDates.removeAll()
            startDate = Date()
            endDate = Date()

        case 1:
            selectedDates = Set([Calendar.current.dateComponents([.year, .month, .day], from: dates[0])])
            startDate = dates[0]
            endDate = dates[0]

        case 2:
            let start = dates.first!
            let end = dates.last!
            startDate = start
            endDate = end

            let intermediateDates = datesInRange(start: start, end: end)
                .filter { $0 != start && $0 != end }

            var newSelectedDates = Set(intermediateDates.map {
                Calendar.current.dateComponents([.year, .month, .day], from: $0)
            })

            newSelectedDates.insert(Calendar.current.dateComponents([.year, .month, .day], from: start))
            newSelectedDates.insert(Calendar.current.dateComponents([.year, .month, .day], from: end))

            selectedDates = newSelectedDates

        default:
            if let lastDate = dates.last {
                selectedDates = Set([Calendar.current.dateComponents([.year, .month, .day], from: lastDate)])
                startDate = lastDate
                endDate = lastDate
            }
        }
    }

    private func datesInRange(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        let calendar = Calendar.current
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

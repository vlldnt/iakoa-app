import SwiftUI

struct SingleDatePickerView: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .font(.system(size: 14))
                .environment(\.locale, Locale(identifier: "fr_FR"))

            Text("Date sélectionnée : \(formatted(selectedDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Sélectionnez une période")
                .font(.headline)

            MultiDatePicker("", selection: Binding(get: {
                selectedDates
            }, set: { newValue in
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

                    // Dates intermédiaires excluant start et end
                    let intermediateDates = datesInRange(start: start, end: end)
                        .filter { $0 != start && $0 != end }

                    var newSelectedDates = Set(intermediateDates.map {
                        Calendar.current.dateComponents([.year, .month, .day], from: $0)
                    })

                    // Insert start et end en dernier
                    newSelectedDates.insert(Calendar.current.dateComponents([.year, .month, .day], from: start))
                    newSelectedDates.insert(Calendar.current.dateComponents([.year, .month, .day], from: end))

                    selectedDates = newSelectedDates

                default:
                    // 3ème clic ou plus : reset avec nouvelle date sélectionnée (la dernière)
                    if let lastDate = dates.last {
                        selectedDates = Set([Calendar.current.dateComponents([.year, .month, .day], from: lastDate)])
                        startDate = lastDate
                        endDate = lastDate
                    }
                }
            }))
            .environment(\.calendar, Calendar.current)
            .environment(\.locale, Locale(identifier: "fr_FR"))
            .frame(maxHeight: 400)

            Text("Du \(formatted(startDate)) au \(formatted(endDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Spacer()
                Button("Réinitialiser la sélection") {
                    selectedDates.removeAll()
                    startDate = Date()
                    endDate = Date()
                }
                .font(.caption)
                .foregroundColor(.blue)
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

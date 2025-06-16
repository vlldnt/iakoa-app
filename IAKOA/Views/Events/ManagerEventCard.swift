import SwiftUI

struct ManagerEventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.name)
                .font(.headline)

            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(formattedDates(event.dates))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDates(_ dates: [Date]) -> String {
        switch dates.count {
        case 0:
            return "Date non définie"
        case 1:
            return "Date : \(formattedDate(dates[0]))"
        case 2:
            let start = formattedDate(dates[0])
            let end = formattedDate(dates[1])
            return "Du \(start) au \(end)"
        default:
            return "Dates multiples"
        }
    }
}

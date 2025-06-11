import SwiftUI

struct Step1BasicInfo: View {
    
    @Binding var event: Event

    private var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }

    var body: some View {
        Form {
            Section(header: Text("Informations de base").font(.headline)) {
                TextField("Nom de l'événement", text: $event.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextEditor(text: $event.description)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date et heure")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    MinuteIntervalDatePicker(
                        selection: $event.date,
                        minuteInterval: 15,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .frame(height: 150)
                }

                TextField("Prix", value: $event.pricing, formatter: priceFormatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

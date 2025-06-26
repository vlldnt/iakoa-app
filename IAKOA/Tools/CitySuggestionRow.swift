import SwiftUI

struct CitySuggestionRow: View {
    let city: City
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(city.nom)
                        .bold()
                        .foregroundColor(Color.blueIakoa)
                        .font(.system(size: 16))

                    Text("(\(city.codesPostaux.first ?? ""))")
                        .foregroundColor(Color.blueIakoa)
                        .font(.system(size: 14))
                        .italic()
                }
                .padding(5)
                .padding(.horizontal, 65)

                Divider()
                    .background(Color(.systemGray2))
                    .padding(.horizontal, 65)
            }
            .background(Color.white)
        }
        .buttonStyle(.plain)
    }
}

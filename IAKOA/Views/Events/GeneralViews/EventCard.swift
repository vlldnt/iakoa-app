import SwiftUI

struct EventCard: View {
    let event: Event
    let isLoggedIn: Bool
    let isCreator: Bool
    let isFavorite: Bool          // <-- true si cet événement est dans les favoris
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                if let firstImageLink = event.imagesLinks.first,
                   let url = URL(string: firstImageLink), !firstImageLink.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 130)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                            .frame(width: 170, height: 130)
                            .cornerRadius(12)
                    }
                }
                if !isCreator && isLoggedIn {
                    HStack {
                        Spacer()
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(isFavorite ? .red : .gray)
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(isFavorite ? Color.white.opacity(0.9) : Color.white)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                        }
                        .padding(8)
                    }
                    .frame(width: 170, height: 130, alignment: .top)
                }
            }
            .cornerRadius(15)
            .contentShape(Rectangle())

            Text(event.name)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(DateUtils.formattedDates(event.dates))
                .font(.system(size: 12))
                .fontWeight(.heavy)
                .foregroundColor(.blueIakoa)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Text(event.address)
                .font(.system(size: 8))
                .lineLimit(2)

            HStack {
                if event.pricing == 0 {
                    Text("Gratuit")
                        .bold()
                        .font(.system(size: 12))
                        .foregroundColor(Color.blueIakoa)
                } else {
                    (
                        Text("à partir de: ")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        + Text(String(format: "%.2f €", event.pricing))
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(Color.blueIakoa)
                    )
                }
            }
        }
        .frame(maxHeight: 285, alignment: .top)
        .background(Color(.systemBackground))
        .onTapGesture(perform: onTap)
    }
}

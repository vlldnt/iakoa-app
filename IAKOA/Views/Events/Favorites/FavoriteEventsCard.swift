import SwiftUI

struct FavoriteEventCard: View {
    let event: Event
    let isImageOnRight: Bool
    let onDelete: () -> Void
    let onTap: () -> Void
    

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if isImageOnRight {
                    content
                    eventImage
                } else {
                    eventImage
                    content
                }
            }
            .padding(2)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .onTapGesture {
                        onTap()
                    }

                Text(DateUtils.formattedDates(event.dates))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Button(action: onDelete) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.red)
                    Text("Enlever de mes favoris")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(2)
    }

    private var eventImage: some View {
        Group {
            if let imageUrlString = event.imagesLinks.first,
               let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                            .frame(width: 150, height: 100)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Color.red.opacity(0.2)
                            .frame(width: 150, height: 100)
                            .cornerRadius(8)
                    @unknown default:
                        Color.gray.opacity(0.2)
                            .frame(width: 150, height: 100)
                            .cornerRadius(8)
                    }
                }
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 150, height: 100)
                    .cornerRadius(8)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

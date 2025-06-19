import SwiftUI
import MapKit

struct Step4EventPreview: View {
    @Binding var eventName: String
    @Binding var eventDescription: String
    @Binding var eventCategories: [String]

    @Binding var eventDates: [Date]
    @Binding var eventAddress: String
    @Binding var eventPrice: String

    @Binding var selectedImages: [UIImage]

    @Binding var facebookLink: String
    @Binding var instagramLink: String
    @Binding var xLink: String
    @Binding var youtubeLink: String
    @Binding var websiteLink: String

    var onClose: () -> Void

    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var showFullDescription = false
    @State private var isTextTruncated = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Image("playstore")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                    HStack {
                        Button(action: { onClose() }) {
                            Image(systemName: "chevron.backward")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)

                TabView {
                    if selectedImages.isEmpty {
                        Image("playstore")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 270)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        ForEach(Array(selectedImages.prefix(3).enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 270)
                                .clipped()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 270)

                VStack(spacing: 10) {
                    Text(eventName)
                        .font(.system(size: 22))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .padding(.horizontal, 10)

                    HStack {
                        Text("Description:")
                            .font(.system(size: 14))
                            .bold()
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !websiteLink.isEmpty {
                            Button(action: {
                                if let url = URL(string: websiteLink) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 2) {
                                    Image("website-icon")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .padding(8)
                                    Text("Lien site web")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.trailing, 8)
                                }
                            }
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 5)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(eventDescription)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(showFullDescription ? nil : 4)
                        if isTextTruncated {
                            Button(showFullDescription ? "Voir moins" : "Voir plus...") {
                                showFullDescription.toggle()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 5)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {

                            Text(DateUtils.formattedDates(eventDates))
                                .font(.system(size: 14))
                                .bold()
                                .foregroundColor(.blue)
                            Text("Adresse: \(eventAddress)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .italic()
                        }
                        Spacer()
                        Text(eventPrice.isEmpty || eventPrice == "0" ? "Gratuit" : "\(eventPrice) €")
                            .font(.headline)
                    }
                    .padding(.horizontal, 5)

                    Map(position: $cameraPosition) {
                        Marker(eventName, coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522))
                    }
                    .cornerRadius(12)
                    .frame(height: 300)

                    VStack {
                        Text("Organisé par: Utilisateur")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack(spacing: 14) {
                            if !facebookLink.isEmpty {
                                SocialButton(imageName: "facebook-icon", link: "https://facebook.com/\(facebookLink)")
                            }
                            if !instagramLink.isEmpty {
                                SocialButton(imageName: "instagram-icon", link: "https://instagram.com/\(instagramLink)")
                            }
                            if !youtubeLink.isEmpty {
                                SocialButton(imageName: "youtube-icon", link: "https://youtube.com/@\(youtubeLink)")
                            }
                            if !xLink.isEmpty {
                                SocialButton(imageName: "x-icon", link: "https://x.com/\(xLink)")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SocialButton: View {
    let imageName: String
    let link: String

    var body: some View {
        Button {
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        } label: {
            Image(imageName)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}

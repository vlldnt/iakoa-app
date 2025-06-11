import SwiftUI
import MapKit
import UIKit

struct EventDetailView: View {
    let event: Event
    let onClose: () -> Void
    
    @State private var showFullDescription = false
    @State private var isTextTruncated = false
    @State private var cameraPosition: MapCameraPosition
    
    init(event: Event, onClose: @escaping () -> Void) {
        self.event = event
        self.onClose = onClose
        let coordinate = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        )))
    }
    
    var status: String {
        let now = Date()
        let target = event.date
        let calendar = Calendar.current
        
        guard let daysRemaining = calendar.dateComponents([.day], from: now, to: target).day else {
            return ""
        }
        
        if daysRemaining < 0 {
            return "(Évènement passé)"
        } else if daysRemaining == 0 {
            return "(Aujourd'hui)"
        } else if daysRemaining == 1 {
            return "(Demain)"
        }
        
        // Calcul des mois et semaines
        let months = daysRemaining / 30
        let weeks = (daysRemaining % 30) / 7
        let days = (daysRemaining % 30) % 7
        
        var parts: [String] = []
        
        if months > 0 {
            parts.append("\(months) mois")
        }
        if weeks > 0 {
            parts.append("\(weeks) semaine\(weeks > 1 ? "s" : "")")
        }
        if days > 0 {
            parts.append("\(days) jour\(days > 1 ? "s" : "")")
        }
        
        return "(dans \(parts.joined(separator: ", ")))"
    }
    
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
                                .foregroundColor(Color.blueIakoa)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            }
            TabView {
                if event.imagesLinks.isEmpty {
                    Image("playstore")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 270)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    ForEach(event.imagesLinks.prefix(3), id: \.self) { link in
                        if let url = URL(string: link) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 270)
                                        .frame(maxWidth: .infinity)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 270)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 270)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 270)
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 270)

            VStack(spacing: 10) {
                Text(event.name)
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

                    Button(action: {
                        /* Action */
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
                    .background(Color.blueIakoa)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 5)


                VStack(alignment: .leading, spacing: 4) {
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(Color(UIColor.systemGray))
                        .lineLimit(showFullDescription ? nil : 4)
                        .background(
                            Text(event.description)
                                .font(.body)
                                .lineLimit(6)
                                .background(GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        let text = event.description
                                        let textHeight = text.height(withConstrainedWidth: geometry.size.width, font: UIFont.preferredFont(forTextStyle: .body))
                                        let lineHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight
                                        isTextTruncated = textHeight > (lineHeight * 4)
                                    }
                                })
                                .hidden()
                        )
                    if isTextTruncated {
                        Button(showFullDescription ? "Voir moins" : "Voir plus...") {
                            showFullDescription.toggle()
                        }
                        .font(.caption)
                        .foregroundColor(Color.blue)
                    }
                }
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 18))
                        .bold()
                        .foregroundColor(Color.blueIakoa)
                    Text(status)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.systemGray))
                        .lineLimit(1)
                        .italic()
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                    Text(event.pricing == 0 ? "Gratuit" : "\(Int(event.pricing)) €")
                        .font(.headline)
                }
                .padding(.horizontal, 5)
            }
            Map(position: $cameraPosition) {
                Marker(event.name, coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude))
            }
            .cornerRadius(12)
            .frame(height: 300)
            .frame(maxWidth: .infinity)


            VStack {
                Text("Organisé par: \(event.creatorID)")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray2))
                HStack(spacing: 14) {
                    if !event.facebookLink.isEmpty {
                        Button {
                            if let appURL = URL(string: "fb://profile/\(event.facebookLink)"),
                               UIApplication.shared.canOpenURL(appURL) {
                                UIApplication.shared.open(appURL)
                            } else if let webURL = URL(string: "https://facebook.com/\(event.facebookLink)") {
                                UIApplication.shared.open(webURL)
                            }
                        } label: {
                            Image("facebook-icon").resizable().frame(width: 40, height: 40)
                        }
                    }

                    if !event.instagramLink.isEmpty {
                        Button {
                            if let url = URL(string: "https://instagram.com/\(event.instagramLink)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image("instagram-icon").resizable().frame(width: 40, height: 40)
                        }
                    }

                    if !event.youtubeLink.isEmpty {
                        Button {
                            if let url = URL(string: "https://youtube.com/@\(event.youtubeLink)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image("youtube-icon").resizable().frame(width: 40, height: 40)
                        }
                    }

                    if !event.xLink.isEmpty {
                        Button {
                            if let url = URL(string: "https://x.com/\(event.xLink)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image("x-icon").resizable().frame(width: 40, height: 40)
                        }
                    }
                }
            }
        }
    }
}

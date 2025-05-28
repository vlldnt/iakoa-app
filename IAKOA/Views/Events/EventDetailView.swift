import SwiftUI
import MapKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

struct EventDetailView: View {
    let event: Event
    let onClose: () -> Void
    let imageNames = ["image-duck", "image"]
    
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
                                .foregroundColor(Color(hex: "#2397FF"))
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            }
            TabView {
                ForEach(imageNames, id: \.self) { name in
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 270)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
            }
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
                    .background(Color(hex: "#2397FF"))
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
                        .foregroundColor(Color(hex: "#2397FF"))
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
            .frame(height: 200)
            .cornerRadius(12)
            .frame(maxWidth: .infinity)

            VStack {
                Text("Organisé par: \(event.creatorID)")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray2))
                HStack(spacing: 14) {
                    if !event.facebookLink.isEmpty {
                        Image("facebook-icon").resizable().frame(width: 40, height: 40)
                    }
                    if !event.instagramLink.isEmpty {
                        Image("instagram-icon").resizable().frame(width: 40, height: 40)
                    }
                    if !event.youtubeLink.isEmpty {
                        Image("youtube-icon").resizable().frame(width: 40, height: 40)
                    }
                    if !event.xLink.isEmpty {
                        Image("x-icon").resizable().frame(width: 40, height: 40)
                    }
                }
            }
        }
    }
}

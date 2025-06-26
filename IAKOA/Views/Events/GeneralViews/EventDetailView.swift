import SwiftUI
import MapKit
import UIKit

struct EventDetailView: View {
    let event: Event
    let onClose: () -> Void

    @State private var showFullDescription = false
    @State private var isTextTruncated = false
    @State private var cameraPosition: MapCameraPosition
    @State private var creatorName: String = ""
    @State private var creatorWebsite: String = ""
    @State private var selectedImageURL: URL? = nil
    @State private var showFullScreen = false
    @State private var imageSizes: [String: CGSize] = [:]
    @State private var showDirectionsMenu = false
    @Namespace private var directionsMenuNamespace

    init(event: Event, onClose: @escaping () -> Void) {
        self.event = event
        self.onClose = onClose

        if let location = event.location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            )))
        } else {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
            )))
        }
    }

    var body: some View {
        ZStack {
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)

                    TabView {
                        if event.imagesLinks.isEmpty {
                            Image("playstore")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .aspectRatio(4/3, contentMode: .fit)
                                .clipped()
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        } else {
                            ForEach(event.imagesLinks.prefix(3), id: \.self) { link in
                                if let url = URL(string: link) {
                                    GeometryReader { geo in
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            case .success(let image):
                                                let imageSize = imageSizes[link] ?? CGSize(width: 4, height: 3)
                                                let imageRatio = imageSize.height / imageSize.width
                                                let computedHeight = geo.size.width * imageRatio

                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geo.size.width, height: computedHeight)
                                                    .clipped()
                                                    .cornerRadius(12)
                                                    .onAppear {
                                                        if imageSizes[link] == nil, let uiImage = image.asUIImage() {
                                                            imageSizes[link] = uiImage.size
                                                        }
                                                    }
                                                    .onTapGesture {
                                                        selectedImageURL = url
                                                        showFullScreen = true
                                                    }
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .aspectRatio(4/3, contentMode: .fit)
                                                    .clipped()
                                                    .cornerRadius(12)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                    .frame(height: 300)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)

                    VStack(spacing: 10) {
                        Text(event.name)
                            .font(.system(size: 22))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .padding(.horizontal, 10)

                        HStack(spacing: 3) {
                            ForEach(event.categories, id: \.self) { category in
                                let data = EventCategories.dict[category]
                                let color = Color(hex: data?.color ?? "#999999")
                                HStack(spacing: 6) {
                                    Image(systemName: data?.icon ?? "questionmark")
                                        .font(.system(size: 13))
                                        .foregroundColor(color)
                                    Text(data?.label ?? category)
                                        .font(.system(size: 13))
                                        .foregroundColor(color)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal, 5)
                                .background(color.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text("Description:")
                                .font(.system(size: 14))
                                .bold()
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: {
                                if let url = URL(string: event.websiteLink) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                if !event.websiteLink.isEmpty {
                                    Button(action: {
                                        var link = event.websiteLink.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !link.lowercased().hasPrefix("http") {
                                            link = "https://" + link
                                        }
                                        if let url = URL(string: link) {
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
                            .background(Color.blueIakoa)
                            .cornerRadius(10)
                            .padding(10)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 5)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(DateUtils.formattedDates(event.dates))
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundColor(Color.blueIakoa)
                                Text(EventStatusUtils.eventStatus(from: event.dates))
                                    .font(.system(size: 12))
                            }
                            Spacer()
                                    .italic()
                                    .foregroundColor(Color(.systemGray))
                            Text(event.pricing == 0 ? "Gratuit" : "à partir de \(Int(event.pricing)) €")
                                .font(.headline)
                        }
                        .padding(.horizontal, 5)
                    }

                    ZStack(alignment: .bottomTrailing) {
                        Map(position: $cameraPosition) {
                            if let location = event.location {
                                Marker(event.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                            }
                        }
                        .cornerRadius(12)
                        .frame(height: 300)

                        if let location = event.location {
                            VStack(spacing: 12) {
                                if !showDirectionsMenu {
                                    // Bouton recentrer
                                    Button(action: {
                                        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            cameraPosition = .region(MKCoordinateRegion(
                                                center: coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                                            ))
                                        }
                                    }) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color.blueIakoa)
                                            .padding(14)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    }
                                    .matchedGeometryEffect(id: "recenter", in: directionsMenuNamespace)

                                    // Bouton voiture qui affiche le menu
                                    Button(action: {
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65, blendDuration: 0.2)) {
                                            showDirectionsMenu = true
                                        }
                                    }) {
                                        Image(systemName: "car.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color.green)
                                            .padding(14)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    }
                                    .matchedGeometryEffect(id: "car", in: directionsMenuNamespace)
                                } else {
                                    VStack(spacing: 20) {
                                        // Icônes verticales
                                        Button {
                                            let url = URL(string: "http://maps.apple.com/?ll=\(location.latitude),\(location.longitude)")!
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            }
                                        } label: {
                                            Image("applemaps-icon")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .padding(10)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                        }

                                        Button {
                                            let url = URL(string: "comgooglemaps://?q=\(location.latitude),\(location.longitude)")!
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                let webUrl = URL(string: "https://maps.google.com/?q=\(location.latitude),\(location.longitude)")!
                                                UIApplication.shared.open(webUrl)
                                            }
                                        } label: {
                                            Image("googlemaps-icon")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .padding(10)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                        }

                                        Button {
                                            let url = URL(string: "waze://?ll=\(location.latitude),\(location.longitude)&navigate=yes")!
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                let webUrl = URL(string: "https://waze.com/ul?ll=\(location.latitude),\(location.longitude)&navigate=yes")!
                                                UIApplication.shared.open(webUrl)
                                            }
                                        } label: {
                                            Image("waze-icon")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .padding(10)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                        }

                                        // Bouton pour fermer le menu
                                        Button(action: {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.65, blendDuration: 0.2)) {
                                                showDirectionsMenu = false
                                            }
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 22))
                                                .foregroundColor(Color.gray)
                                                .padding(10)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                        }
                                        .padding(.top, 8)
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .matchedGeometryEffect(id: "car", in: directionsMenuNamespace)
                                }
                            }
                            .padding(20)
                        }
                    }

                    VStack {
                        HStack(spacing: 4) {
                            Text("Organisé par:")
                                .font(.subheadline)
                                .foregroundColor(Color(.systemGray2))
                            Button(action: {
                                var link = creatorWebsite.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !link.isEmpty {
                                        if !link.lowercased().hasPrefix("http") {
                                            link = "https://" + link
                                        }
                                        if let url = URL(string: link) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                            }) {
                                Text(creatorName.isEmpty ? "Utilisateur inconnu" : creatorName)
                                    .font(.subheadline)
                                    .foregroundColor(Color.blueIakoa)
                                    .italic()
                            }
                        }
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
                .onAppear {
                    fetchCreatorName()
                }
            }

            if showFullScreen, let url = selectedImageURL {
                ZStack {
                    Color.black.opacity(0.95).ignoresSafeArea()
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            ZoomableImage(image: image)
                        case .failure:
                            Image(systemName: "xmark.octagon")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showFullScreen = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private func fetchCreatorName() {
        UserServices.fetchUser(uid: event.creatorID) { user in
            if let user = user {
                self.creatorName = user.name
                self.creatorWebsite = user.website
            } else {
                self.creatorName = "Utilisateur inconnu"
                self.creatorWebsite = ""
            }
        }
    }

    private func computedHeight(for link: String, containerWidth: CGFloat) -> CGFloat {
        guard let size = imageSizes[link], size.width > 0 else {
            return 270
        }
        let aspectRatio = size.height / size.width
        return containerWidth * aspectRatio
    }
}

extension Image {
    func asUIImage() -> UIImage? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let uiImage = child.value as? UIImage {
                return uiImage
            }
        }
        return nil
    }
}

struct ZoomableImage: View {
    let image: Image
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .scaleEffect(currentScale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = currentScale
                        },
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}

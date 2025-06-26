import SwiftUI
import MapKit
import FirebaseFirestore
import CoreLocation

struct MapView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true
    @StateObject private var locationManager = LocationManagerTool()
    @State private var selectedEvent: Event? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                ForEach(events.filter { $0.location != nil }) { event in
                    Annotation(event.name, coordinate: event.location!) {
                        Button(action: {
                            selectedEvent = event
                        }) {
                            Image(systemName: "mappin")
                                .font(.system(size: 38))
                                .foregroundColor(
                                    Color(
                                        hex: EventCategories.dict[event.categories.first ?? ""]?.color ?? "#FF0000"
                                    )
                                )
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .onChange(of: locationManager.userLocation) { _, coord in
                if let coord = coord {
                    let region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    cameraPosition = .region(region)
                }
            }

            if isLoading {
                ProgressView("Chargement des événements...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }

            Button(action: centerOnUser) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .padding()
        }
        .onAppear {
            fetchEvents()
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }

    func fetchEvents() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Firestore fetch error: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No events found")
                    isLoading = false
                    return
                }
                events = documents.compactMap { Event(document: $0) }
                isLoading = false
            }
        }
    }

    private func centerOnUser() {
        if let location = locationManager.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
}

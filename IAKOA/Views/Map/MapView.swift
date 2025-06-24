import SwiftUI
import MapKit
import FirebaseFirestore
import CoreLocation

struct MapView: View {
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.6119, longitude: 3.8772), // Montpellier
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @State private var events: [Event] = []
    @State private var isLoading = true
    @StateObject private var locationManager = LocationManager()
    @State private var selectedEvent: Event? = nil   // Pour la sheet

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                ForEach(events.filter { $0.location != nil }) { event in
                    Annotation(event.name, coordinate: event.location!) {
                        Button(action: {
                            selectedEvent = event
                        }) {
                            Image(systemName: "mappin")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            if isLoading {
                ProgressView("Loading events...")
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
            locationManager.requestAuthorization()
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }
    
    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
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
            let fetchedEvents = documents.compactMap { Event(document: $0) }
            DispatchQueue.main.async {
                self.events = fetchedEvents
                self.isLoading = false
            }
        }
    }
    
    func centerOnUser() {
        if let userLocation = locationManager.lastLocation {
            cameraPosition = .region(MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
}

// Gestionnaire de localisation simple
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

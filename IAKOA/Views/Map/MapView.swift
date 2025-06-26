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

    @State private var selectedCategories: Set<String> = []
    @State private var searchRadius: Double = 30
    @State private var isSearchExpanded = false

    @State private var searchText: String = ""

    var availableCategories: [(key: String, label: String, icon: String, color: String)] {
        EventCategories.dict.map {
            (key: $0.key,
             label: $0.value.label,
             icon: $0.value.icon,
             color: $0.value.color)
        }
        .sorted { $0.label < $1.label }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                UserAnnotation()

                if let userCoord = locationManager.userLocation {
                    MapCircle(center: userCoord, radius: searchRadius * 1000) // km ➝ m
                        .foregroundStyle(.blue.opacity(0.03))
                        .stroke(.blue.opacity(0.6), lineWidth: 1)
                }

                ForEach(events.filter { $0.location != nil }) { event in
                    Annotation(event.name, coordinate: event.location!) {
                        Button(action: {
                            selectedEvent = event
                        }) {
                            Image(systemName: "mappin")
                                .font(.system(size: 38))
                                .foregroundColor(
                                    Color(hex: EventCategories.dict[event.categories.first ?? ""]?.color ?? "#FF0000")
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
                    fetchEvents()
                }
            }

            if isLoading {
                ProgressView("Chargement des événements...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }

            VStack(spacing: 12) {
                Button {
                    withAnimation {
                        isSearchExpanded = true
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }

                Button(action: centerOnUser) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding()
        }
        .onAppear {
            centerOnUser()
        }
        .sheet(isPresented: $isSearchExpanded) {
            SearchBarEvents(
                searchText: $searchText,
                searchRadius: $searchRadius,
                selectedCategories: $selectedCategories,
                isSearchExpanded: $isSearchExpanded,
                onApply: fetchEvents,
                availableCategories: availableCategories
            )
            .presentationDetents([.fraction(0.7), .medium])
            .presentationDragIndicator(.visible)
        }
        
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }

    private func fetchEvents() {
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

                let allEvents = documents.compactMap { Event(document: $0) }

                if let userLocation = locationManager.userLocation {
                    events = allEvents.filter { event in
                        guard let loc = event.location else { return false }

                        let distance = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                            .distance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)) / 1000

                        let radiusOK = distance <= searchRadius
                        let categoryOK = selectedCategories.isEmpty || !selectedCategories.isDisjoint(with: event.categories)
                        let matchesSearch = searchText.isEmpty || event.name.lowercased().contains(searchText.lowercased())

                        return radiusOK && categoryOK && matchesSearch
                    }
                } else {
                    events = allEvents
                }

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

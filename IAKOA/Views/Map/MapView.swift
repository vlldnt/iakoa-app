import SwiftUI
import MapKit
import FirebaseFirestore
import CoreLocation
import Combine

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
    @State private var citySuggestions: [City] = []
    @State private var selectedCity: City? = nil
    @State private var cancellable: AnyCancellable?
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isFirstAppear = true

    // List of available categories for filters
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
            // Main map view with user and event annotations
            Map(position: $cameraPosition) {
                UserAnnotation()
                let centerCoord = selectedCity?.coordinates ?? locationManager.userLocation
                if let userCoord = centerCoord {
                    // Draw search radius circle
                    MapCircle(center: userCoord, radius: searchRadius * 1000)
                        .foregroundStyle(.blue.opacity(0.03))
                        .stroke(.blue.opacity(0.6), lineWidth: 1)
                }
                // Show event pins
                ForEach(events.filter { $0.location != nil }) { event in
                    Annotation(event.name, coordinate: event.location!) {
                        Button(action: {
                            selectedEvent = event
                        }) {
                            Image(systemName: "mappin")
                                .font(.system(size: 42))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                // On first appear, fetch events near user
                if isFirstAppear {
                    selectedCity = nil
                    searchText = ""
                    centerOnCityOrUser()
                    fetchEvents(useUserLocation: true)
                    isFirstAppear = false
                } else {
                    centerOnCityOrUser()
                }
            }

            // Top overlay: city search bar and suggestions
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        // City search text field
                        TextField("Entrez une ville", text: $searchText)
                            .padding(7)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.9)))
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                isSearchFieldFocused = false
                                if !searchText.isEmpty {
                                    fetchCitySuggestions(query: searchText)
                                } else {
                                    selectedCity = nil
                                    fetchEvents(useUserLocation: true)
                                }
                            }
                            .onChange(of: searchText) { _, newValue in
                                if newValue.isEmpty {
                                    selectedCity = nil
                                    fetchEvents(useUserLocation: true)
                                } else if !newValue.contains("(") {
                                    fetchCitySuggestions(query: newValue)
                                } else {
                                    citySuggestions = []
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Terminer") { isSearchFieldFocused = false }
                                }
                            }

                        // Clear search button
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                selectedCity = nil
                                citySuggestions = []
                                fetchEvents(useUserLocation: true)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.blueIakoa)
                                    .padding(4)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 50)
                    .padding(.bottom, 4)

                    // City suggestions dropdown
                    if !citySuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(citySuggestions.prefix(3), id: \.self) { city in
                                Button {
                                    let codePostal = city.codesPostaux.first ?? ""
                                    searchText = "\(city.nom) (\(codePostal))"
                                    selectedCity = city
                                    citySuggestions = []
                                    isSearchFieldFocused = false
                                    centerOnCityOrUser()
                                    fetchEvents()
                                } label: {
                                    HStack {
                                        Text("\(city.nom) (\(city.codesPostaux.first ?? ""))")
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal, 8)
                    }
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)

            // Bottom right: filter and location buttons
            VStack(alignment: .trailing, spacing: 12) {
                // Open filter sheet
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
                // Center on user and fetch nearby events
                Button(action: {
                    selectedCity = nil
                    searchText = ""
                    centerOnCityOrUser()
                    fetchEvents(useUserLocation: true)
                }) {
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
        // Filter sheet
        .sheet(isPresented: $isSearchExpanded) {
            SearchBarEvents(
                searchText: $searchText,
                searchRadius: $searchRadius,
                selectedCategories: $selectedCategories,
                isSearchExpanded: $isSearchExpanded,
                onApply: {
                    centerOnCityOrUser()
                    fetchEvents()
                },
                availableCategories: availableCategories
            )
            .presentationDetents([.fraction(0.7), .medium])
            .presentationDragIndicator(.visible)
        }
        // Event detail sheet
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }

    // Fetch events from Firestore, filter by location and category
    private func fetchEvents(useUserLocation: Bool = false) {
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
                let centerCoord: CLLocationCoordinate2D?
                if useUserLocation {
                    centerCoord = locationManager.userLocation
                } else {
                    centerCoord = selectedCity?.coordinates ?? locationManager.userLocation
                }
                if let center = centerCoord {
                    events = allEvents.filter { event in
                        guard let loc = event.location else { return false }
                        let distance = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                            .distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude)) / 1000
                        let radiusOK = distance <= searchRadius
                        let categoryOK = selectedCategories.isEmpty || !selectedCategories.isDisjoint(with: event.categories)
                        return radiusOK && categoryOK
                    }
                } else {
                    events = allEvents
                }
                isLoading = false
            }
        }
    }

    // Center the map on the selected city or user location
    private func centerOnCityOrUser() {
        if let city = selectedCity {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: city.coordinates,
                        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    )
                )
            }
        } else if let location = locationManager.userLocation {
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
                    )
                )
            }
        }
    }

    // Fetch city suggestions from the French government API
    private func fetchCitySuggestions(query: String) {
        guard query.count >= 2 else {
            citySuggestions = []
            return
        }
        let urlString = "https://geo.api.gouv.fr/communes?nom=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&fields=nom,codesPostaux,centre&boost=population&limit=10"
        guard let url = URL(string: urlString) else { return }
        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [City].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { cities in
                citySuggestions = Array(cities.prefix(3))
            }
    }
}

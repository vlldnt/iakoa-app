import SwiftUI
import CoreLocation
import FirebaseFirestore
import Combine

struct EventView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isCreator: Bool

    @State private var events: [Event] = []
    @State private var errorMessage: String? = nil
    @State private var isLoading = false

    @State private var favoriteEventIDs: Set<String> = []
    @State private var selectedEvent: Event? = nil

    @State private var searchText: String = ""
    @State private var showOnlyFreeEvents = false
    @State private var searchRadius: Double = 10
    @State private var selectedCategories: Set<String> = []
    @State private var isSearchExpanded = false
    @State private var selectedCity: City? = nil
    
    @FocusState private var isSearchFieldFocused: Bool
    @StateObject private var locationManager = LocationManagerTool()

    @State private var citySuggestions: [City] = []
    @State private var cancellable: AnyCancellable?

    private var eventCategories: [(key: String, label: String, icon: String, color: String)] {
        EventCategories.dict.map { key, value in
            (key: key, label: value.label, icon: value.icon, color: value.color)
        }
        .sorted { $0.label < $1.label }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                // Searchbar et filtres toujours en haut
                HStack(spacing: 8) {
                    Image("playstore")
                        .resizable()
                        .frame(height: 50)
                        .frame(width: 45)
                    TextField("Entrez une ville", text: $searchText)
                        .padding(7)
                        .autocorrectionDisabled(true)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .focused($isSearchFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Terminer") {
                                    isSearchFieldFocused = false
                                }
                            }
                        }
                        .onChange(of: searchText) { _, newValue in
                            if newValue.isEmpty {
                                selectedCity = nil
                                fetchEvents()
                            } else if newValue == "Ma position actuelle" {
                                selectedCity = nil
                                fetchEvents()
                            } else if !newValue.contains("(") {
                                fetchCitySuggestions(query: newValue)
                            } else {
                                citySuggestions = []
                            }
                        }

                    if !searchText.isEmpty || selectedCity != nil || !selectedCategories.isEmpty || searchRadius != 20 {
                        Button(action: {
                            searchText = ""
                            selectedCity = nil
                            selectedCategories = []
                            searchRadius = 20
                            citySuggestions = []
                            fetchEvents()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }

                    Button {
                        withAnimation { isSearchExpanded.toggle() }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .background(isSearchExpanded ? Color.blue.opacity(0.15) : Color.clear)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 25)

                // Suggérer "Ma position actuelle"
                if searchText.isEmpty || searchText == "Ma position actuelle" {
                    Button(action: {
                        searchText = "Ma position actuelle"
                        selectedCity = nil
                        citySuggestions = []
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        fetchEvents()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(Color.blueIakoa)
                            Text("Ma position actuelle")
                                .foregroundColor(Color.blueIakoa)
                                .font(.system(size: 16))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }

                if !citySuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(citySuggestions.prefix(3), id: \.self) { city in
                            CitySuggestionRow(city: city) {
                                let codePostal = city.codesPostaux.first ?? ""
                                searchText = "\(city.nom) (\(codePostal))"
                                selectedCity = city
                                citySuggestions = []
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                fetchEvents()
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if isSearchExpanded {
                    SearchBarEvents(
                        searchText: $searchText,
                        searchRadius: $searchRadius,
                        selectedCategories: $selectedCategories,
                        isSearchExpanded: $isSearchExpanded,
                        onApply: fetchEvents,
                        availableCategories: eventCategories
                    )
                }

                // Partie scrollable : liste ou message
                ScrollView {
                    if isLoading {
                        ProgressView("Chargement des événements...")
                            .padding()
                    } else if let error = errorMessage {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if events.isEmpty {
                        Text("Aucun événement trouvé.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(events) { event in
                                EventCard(
                                    event: event,
                                    isLoggedIn: isLoggedIn,
                                    isCreator: isCreator,
                                    isFavorite: favoriteEventIDs.contains(event.id),
                                    onFavoriteToggle: {
                                        toggleFavorite(event)
                                        EventServices.toggleFavorite(event: event)
                                    },
                                    onTap: { selectedEvent = event }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .refreshable {
                    fetchEvents()
                }
            }
            .onTapGesture {
                if isSearchExpanded {
                    withAnimation {
                        isSearchExpanded = false
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event) {
                    selectedEvent = nil
                    fetchEvents()
                }
            }
            .onAppear {
                fetchEvents()
            }
        }
    }

    private func fetchEvents() {
        isLoading = true
        errorMessage = nil
        events = []

        let coordinates: CLLocationCoordinate2D?

        if searchText == "Ma position actuelle" {
            coordinates = locationManager.userLocation
        } else {
            coordinates = selectedCity?.coordinates
        }

        EventServices.fetchEvents(
            searchText: "",
            cityCoordinates: coordinates,
            radiusInKm: searchRadius,
            selectedCategories: selectedCategories,
            showOnlyFree: showOnlyFreeEvents
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvents):
                    self.events = fetchedEvents
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func toggleFavorite(_ event: Event) {
        if favoriteEventIDs.contains(event.id) {
            favoriteEventIDs.remove(event.id)
        } else {
            favoriteEventIDs.insert(event.id)
        }
    }

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
                self.citySuggestions = Array(cities.prefix(3))
            }
    }
}

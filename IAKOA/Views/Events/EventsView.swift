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
            VStack(spacing: 4) {
                // Searchbar et filtres toujours en haut
                HStack(spacing: 8) {
                    Image("playstore")
                        .resizable()
                        .frame(width: 45, height: 50)

                    TextField("Entrez une ville", text: $searchText)
                        .padding(7)
                        .autocorrectionDisabled(true)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .focused($isSearchFieldFocused)
                        .onChange(of: searchText) { _, newValue in
                            if newValue.isEmpty || newValue == "Ma position actuelle" {
                                selectedCity = nil
                                fetchEvents()
                            } else if !newValue.contains("(") {
                                fetchCitySuggestions(query: newValue)
                            } else {
                                citySuggestions = []
                            }
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Terminer") {
                                    isSearchFieldFocused = false
                                }
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
                            .padding(6)
                            .background(isSearchExpanded ? Color.blue.opacity(0.15) : Color.clear)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 25)


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
                                eventCard(event, isLoggedIn: isLoggedIn)
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

    private func eventCard(_ event: Event, isLoggedIn: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                if let firstImageLink = event.imagesLinks.first,
                   let url = URL(string: firstImageLink), !firstImageLink.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 130)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                            .frame(width: 170, height: 130)
                            .cornerRadius(12)
                    }
                }

                if isLoggedIn, !isCreator {
                    Button(action: {
                        toggleFavorite(event)
                    }) {
                        Image(systemName: favoriteEventIDs.contains(event.id) ? "heart.fill" : "heart")
                            .foregroundColor(favoriteEventIDs.contains(event.id) ? .red : .white)
                            .padding(8)
                            .clipShape(Circle())
                    }
                    .padding(6)
                }
            }
            .cornerRadius(15)
            .contentShape(Rectangle())

            Text(event.name)
                .font(.system(size: 12))
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(DateUtils.formattedDates(event.dates))
                .font(.system(size: 12))
                .fontWeight(.heavy)
                .foregroundColor(.blueIakoa)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Text(event.address)
                .font(.system(size: 8))
                .lineLimit(2)

            HStack {
                if event.pricing == 0 {
                    Text("Gratuit")
                        .bold()
                        .font(.system(size: 12))
                        .foregroundColor(Color.blueIakoa)
                } else {
                    (
                        Text("à partir de: ")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        + Text(String(format: "%.2f €", event.pricing))
                            .bold()
                            .font(.system(size: 12))
                            .foregroundColor(Color.blueIakoa)
                    )
                }
            }
        }
        .frame(maxHeight: 285, alignment: .top)
        .background(Color(.systemBackground))
        .onTapGesture {
            selectedEvent = event
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

struct CitySuggestionRow: View {
    let city: City
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(city.nom)
                        .bold()
                        .foregroundColor(Color.blueIakoa)
                        .font(.system(size: 16))

                    Text("(\(city.codesPostaux.first ?? ""))")
                        .foregroundColor(Color.blueIakoa)
                        .font(.system(size: 14))
                        .italic()
                }
                .padding(5)
                .padding(.horizontal, 65)

                Divider()
                    .background(Color(.systemGray2))
                    .padding(.horizontal, 65)
            }
            .background(Color.white)
        }
        .buttonStyle(.plain)
    }
}

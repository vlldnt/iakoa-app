// EventsView.swift
import SwiftUI
import CoreLocation
import FirebaseFirestore

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
    @State private var searchCity: String = ""
    @State private var searchRadius: Double = 10
    @State private var selectedCategories: Set<String> = []
    @State private var isSearchExpanded = false
    @State private var selectedCity: City? = nil

    @StateObject private var locationManager = LocationManagerTool()

    private var eventCategories: [(key: String, label: String, icon: String, color: String)] {
        EventCategories.dict.map { key, value in
            (key: key, label: value.label, icon: value.icon, color: value.color)
        }
        .sorted { $0.label < $1.label }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                HStack {
                    TextField("Rechercher un événement...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity)

                    Button {
                        withAnimation { isSearchExpanded.toggle() }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .padding(8)
                            .background(isSearchExpanded ? Color.blue.opacity(0.15) : Color.clear)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 4)
                }
                .padding(.horizontal)

                if isSearchExpanded {
                    SearchBarEvents(
                        searchText: $searchText,
                        searchCity: $searchCity,
                        searchRadius: $searchRadius,
                        selectedCategories: $selectedCategories,
                        onApply: fetchEvents,
                        availableCategories: eventCategories,
                        selectedCity: $selectedCity
                    )
                }

                Group {
                    if isLoading {
                        ProgressView("Chargement des événements...")
                    } else if let error = errorMessage {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if events.isEmpty {
                        Text("Aucun événement trouvé.")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(events) { event in
                                    eventCard(event, isLoggedIn: isLoggedIn)
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            fetchEvents()
                        }
                    }
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
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
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
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
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

        let coordinates = selectedCity?.coordinates ?? locationManager.userLocation

        EventServices.fetchEvents(
            searchText: searchText,
            cityCoordinates: coordinates,
            radiusInKm: selectedCity == nil ? nil : searchRadius,
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
}

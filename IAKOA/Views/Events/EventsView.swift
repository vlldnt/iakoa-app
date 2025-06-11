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
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Chargement des événements...")
                } else if let error = errorMessage {
                    Text("Erreur: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if events.isEmpty {
                    Text("Aucun événement disponible.")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                        LazyVGrid(columns: columns, spacing: 5) {
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
            .navigationTitle("Événements")

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
    
    private func eventCard(_ event: Event, isLoggedIn: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if let firstImageLink = event.imagesLinks.first,
                   let url = URL(string: firstImageLink), !firstImageLink.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                            .frame(height: 140)
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

            Text(event.address)
                .font(.system(size: 8))
                .lineLimit(2)

            Text(event.description)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                Text(formattedDate(event.date))
                    .font(.caption)
                    .font(.system(size: 6))
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer()

                if event.pricing == 0 {
                    Text("Gratuit")
                        .bold()
                        .font(.system(size: 10))
                        .foregroundColor(.blueIakoa)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    (
                        Text("Prix: ")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        + Text(String(format: "%.2f €", event.pricing))
                            .bold()
                            .font(.system(size: 10))
                            .foregroundColor(.blueIakoa)
                    )
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .frame(minHeight: 285, alignment: .top)
        .background(Color(.systemBackground))
        .onTapGesture {
            selectedEvent = event
        }
    }


    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM/yy HH:mm"
        return formatter.string(from: date)
    }
    
    private func fetchEvents() {
        isLoading = true
        EventServices.fetchEvents { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvents):
                    debugPrint("Events reçus: \(fetchedEvents.count)")
                    self.events = fetchedEvents
                    self.errorMessage = nil
                case .failure(let error):
                    debugPrint("Erreur fetchEvents: \(error.localizedDescription)")
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

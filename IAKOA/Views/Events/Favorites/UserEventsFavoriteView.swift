import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserEventsFavoriteView: View {
    @State private var favoriteEvents: [Event] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedEvent: Event?
    @State private var eventToDelete: Event?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Chargement...")
                } else if let errorMessage = errorMessage {
                    Text("Erreur : \(errorMessage)")
                        .foregroundColor(.red)
                } else if favoriteEvents.isEmpty {
                    Text("Aucun évènement favori.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(favoriteEvents) { event in
                                FavoriteEventCard(
                                    event: event,
                                    isImageOnRight: false,
                                    onDelete: {
                                        removeFavorite(event)
                                    },
                                    onTap: {
                                        selectedEvent = event
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Évènements favoris")
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, onClose: { selectedEvent = nil })
        }
        .onAppear(perform: loadFavorites)
    }

    private func loadFavorites() {
        UserServices.showFavorites { result in
            switch result {
            case .success(let favoriteIDs):
                fetchEventsFromIDs(ids: favoriteIDs)
            case .failure(let error):
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func fetchEventsFromIDs(ids: [String]) {
        guard !ids.isEmpty else {
            self.favoriteEvents = []
            self.isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("events").whereField(FieldPath.documentID(), in: ids).getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.favoriteEvents = snapshot?.documents.compactMap { doc in
                    Event(document: doc) // Assure-toi que ce init existe
                } ?? []
            }
            self.isLoading = false
        }
    }
    
    private func removeFavorite(_ event: Event) {
        isLoading = true
        UserServices.removeFavorite(eventID: event.id) { result in
            switch result {
            case .success:
                favoriteEvents.removeAll { $0.id == event.id }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

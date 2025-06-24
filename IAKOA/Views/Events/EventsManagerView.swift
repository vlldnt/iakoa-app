import SwiftUI

struct EventsManagerView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var showDeleteAlert = false
    @State private var eventToDelete: Event?
    @State private var selectedEvent: Event?
    @State private var eventToEdit: Event?

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack(spacing: 8) {
                        Image("playstore")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                        Text("Mes Événements")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)
                    }
                    if isLoading {
                        ProgressView("Chargement…")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text("❌ \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else if events.isEmpty {
                        Text("Aucun événement trouvé.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                    ManagerEventCard(
                                        event: event,
                                        isImageOnRight: index % 1 == 1,
                                        onEdit: {
                                            eventToEdit = event
                                        },
                                        onDelete: {
                                            eventToDelete = event
                                            showDeleteAlert = true
                                        },
                                        onTap: {
                                            selectedEvent = event
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            loadUserEvents()
                        }
                    }
                }
                if isDeleting {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView("Suppression…")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text(eventToDelete?.name ?? ""),
                    message: Text("Confirmez-vous la suppression de cet événement ?\nToutes les informations associées seront définitivement perdues."),
                    primaryButton: .destructive(Text("Supprimer")) {
                        guard let event = eventToDelete else { return }
                        isDeleting = true
                        EventServices.deleteEventIfOwner(event: event) { result in
                            DispatchQueue.main.async {
                                isDeleting = false
                                switch result {
                                case .success():
                                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                                        events.remove(at: index)
                                    }
                                case .failure(let error):
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Garder"))
                )
            }
            .onAppear(perform: loadUserEvents)
            .navigationBarHidden(true)
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, onClose: { selectedEvent = nil })
            }
            .sheet(item: $eventToEdit) { event in
                EventStepsUpdateView(
                    onUpdate: { loadUserEvents() },
                    eventToEdit: event
                )
            }
            .onDisappear {
                loadUserEvents()
            }
        }
    }
    
    private func loadUserEvents() {
        isLoading = true
        events = []
        errorMessage = nil

        EventServices.fetchEventsForCurrentUser { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvents):
                    self.events = fetchedEvents
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

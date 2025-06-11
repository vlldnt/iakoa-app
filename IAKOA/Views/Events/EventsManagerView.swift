import SwiftUI

struct EventsManagerView: View {

    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                Text("Mes Événements")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

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
                            ForEach(events, id: \.id) { event in
                                ManagerEventCard(event: event)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear(perform: loadUserEvents)
            .navigationBarHidden(true)
        }
    }

    private func loadUserEvents() {
        isLoading = true
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

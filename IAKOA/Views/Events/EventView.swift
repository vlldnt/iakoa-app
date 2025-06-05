import SwiftUI
import CoreLocation
import FirebaseFirestore
import Firebase

struct EventView: View {
    @State private var events: [Event] = []
    @State private var selectedEvent: Event? = nil
    @State private var errorMessage: String? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if let errorMessage = errorMessage {
                Text("Erreur : \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.name)
                            .font(.headline)
                            .bold()
                            .lineLimit(1)

                        Text(event.description)
                            .font(.subheadline)
                            .lineLimit(2)

                        Text(event.date, style: .date)
                            .font(.footnote)
                            .foregroundColor(.gray)

                        Text(event.pricing == 0 ? "Gratuit" : "\(Int(event.pricing)) €")
                            .font(.footnote)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .onTapGesture {
                        selectedEvent = event
                    }
                }
            }
            .padding()
        }
        .refreshable {
            fetchEvents()
        }
        .onAppear {
            fetchEvents()
        }
        .fullScreenCover(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }

    private func fetchEvents() {
        EventServices.fetchEvents { result in
            DispatchQueue.main.async {
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
}

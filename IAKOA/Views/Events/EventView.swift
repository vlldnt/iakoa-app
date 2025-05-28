
import SwiftUI
import CoreLocation
import FirebaseFirestore
import Firebase

struct EventView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var selectedEvent: Event? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.events) { event in
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
            viewModel.fetchEvents()
        }
        .onAppear {
            viewModel.fetchEvents()
        }
        .fullScreenCover(item: $selectedEvent) { event in
            EventDetailView(event: event) {
                selectedEvent = nil
            }
        }
    }
}

#Preview ("iPhone SE"){
    EventView()
}

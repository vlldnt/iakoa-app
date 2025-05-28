import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    let onClose: () -> Void
    
    @State private var cameraPosition: MapCameraPosition

        init(event: Event, onClose: @escaping () -> Void) {
            self.event = event
            self.onClose = onClose
            let coordinate = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            )))
        }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ZStack {
                    Image("playstore")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                    
                    HStack {
                        Button(action: {
                            onClose()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#2397FF"))
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                .padding(.bottom, 10)
                
                Image("image-duck")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 270)
                
                Text(event.name)
                    .font(.system(size: 22))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("Description:")
                        .font(.system(size: 14))
                        .bold()
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for more details
                    }) {
                        Text("Lien vers l'évènement")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                    }
                    .background(Color(hex: "#2397FF"))
                    .cornerRadius(10)
                }
                
                Text(event.description)
                    .font(.body)
                    .foregroundColor(Color(UIColor.systemGray))
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text(event.date, style: .date)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(event.pricing == 0 ? "Gratuit" : "\(Int(event.pricing)) €")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Map(position: $cameraPosition) {
                    Marker(event.name, coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude))
                }
                .frame(height: 200)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}


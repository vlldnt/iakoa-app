import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition = MapCameraPosition.automatic // Laisse l'utilisateur libre

    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation() // Affiche le point bleu de localisation
        }
        .mapControls {
            MapUserLocationButton() // Optionnel : bouton pour recadrer manuellement
        }
    }
}



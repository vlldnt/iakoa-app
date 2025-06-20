import Foundation
import CoreLocation

struct City: Identifiable, Codable, Hashable {
    let nom: String
    let codesPostaux: [String]
    let centre: Centre

    var id: String {
        "\(nom)-\(codesPostaux.first ?? "")"
    }

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centre.coordinates[1], longitude: centre.coordinates[0])
    }
}

struct Centre: Codable, Hashable {
    let type: String
    let coordinates: [Double]  // [longitude, latitude] comme retourné par l'API
}

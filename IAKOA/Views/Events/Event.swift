
import Foundation
import CoreLocation
import FirebaseFirestore

struct Event: Identifiable, Equatable {
    var id: String
    var creatorID: String
    var date: Date
    var description: String
    var facebookLink: String
    var instagramLink: String
    var location: CLLocationCoordinate2D
    var name: String
    var pricing: Double
    var websiteLink: String
    var xLink: String
    var youtubeLink: String

    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard
            let creatorID = data?["creatorID"] as? String,
            let timestamp = data?["date"] as? Timestamp,
            let description = data?["description"] as? String,
            let facebookLink = data?["facebookLink"] as? String,
            let instagramLink = data?["instagramLink"] as? String,
            let geoPoint = data?["location"] as? GeoPoint,
            let name = data?["name"] as? String,
            let pricing = data?["pricing"] as? Double,
            let websiteLink = data?["websiteLink"] as? String,
            let xLink = data?["xLink"] as? String,
            let youtubeLink = data?["youtubeLink"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.creatorID = creatorID
        self.date = timestamp.dateValue()
        self.description = description
        self.facebookLink = facebookLink
        self.instagramLink = instagramLink
        self.location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        self.name = name
        self.pricing = pricing
        self.websiteLink = websiteLink
        self.xLink = xLink
        self.youtubeLink = youtubeLink
    }

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

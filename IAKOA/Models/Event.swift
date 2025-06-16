import Foundation
import CoreLocation
import FirebaseFirestore

struct Event: Identifiable, Equatable {
    var id: String
    var creatorID: String
    var dates: [Date]
    var description: String
    var facebookLink: String
    var instagramLink: String
    var location: CLLocationCoordinate2D
    var name: String
    var pricing: Double
    var websiteLink: String
    var xLink: String
    var youtubeLink: String
    var imagesLinks: [String] = []
    var address: String
    var categories: [String] = []
    
    init(id: String,
         creatorID: String,
         dates: [Date],
         description: String,
         facebookLink: String,
         instagramLink: String,
         location: CLLocationCoordinate2D,
         name: String,
         pricing: Double,
         websiteLink: String,
         xLink: String,
         youtubeLink: String,
         imagesLinks: [String] = [],
         address: String,
         categories: [String] = []) {
        self.id = id
        self.creatorID = creatorID
        self.dates = dates
        self.description = description
        self.facebookLink = facebookLink
        self.instagramLink = instagramLink
        self.location = location
        self.name = name
        self.pricing = pricing
        self.websiteLink = websiteLink
        self.xLink = xLink
        self.youtubeLink = youtubeLink
        self.imagesLinks = imagesLinks
        self.address = address
        self.categories = categories
    }
    
    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard
            let creatorID = data?["creatorID"] as? String,
            let timestamps = data?["dates"] as? [Timestamp],
            let description = data?["description"] as? String,
            let facebookLink = data?["facebookLink"] as? String,
            let instagramLink = data?["instagramLink"] as? String,
            let geoPoint = data?["location"] as? GeoPoint,
            let name = data?["name"] as? String,
            let pricing = data?["pricing"] as? Double,
            let websiteLink = data?["websiteLink"] as? String,
            let xLink = data?["xLink"] as? String,
            let youtubeLink = data?["youtubeLink"] as? String,
            let imagesLinks = data?["imagesLinks"] as? [String],
            let address = data?["address"] as? String,
            let categories = data?["categories"] as? [String]
        else {
            return nil
        }
        
        self.id = document.documentID
        self.creatorID = creatorID
        self.dates = timestamps.map { $0.dateValue() }
        self.description = description
        self.facebookLink = facebookLink
        self.instagramLink = instagramLink
        self.location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        self.name = name
        self.pricing = pricing
        self.websiteLink = websiteLink
        self.xLink = xLink
        self.youtubeLink = youtubeLink
        self.imagesLinks = imagesLinks
        self.address = address
        self.categories = categories
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "creatorID": creatorID,
            "dates": dates.map { Timestamp(date: $0) },
            "description": description,
            "facebookLink": facebookLink,
            "instagramLink": instagramLink,
            "location": GeoPoint(latitude: location.latitude, longitude: location.longitude),
            "name": name,
            "pricing": pricing,
            "websiteLink": websiteLink,
            "xLink": xLink,
            "youtubeLink": youtubeLink,
            "imagesLinks": imagesLinks,
            "address": address,
            "categories": categories
        ]
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

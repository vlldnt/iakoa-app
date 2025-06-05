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
    var imagesLinks: [String] = []
    var address: String = ""
    
    init(id: String,
         creatorID: String,
         date: Date,
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
         address: String = "") {
        self.id = id
        self.creatorID = creatorID
        self.date = date
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
    }
    
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
            let youtubeLink = data?["youtubeLink"] as? String,
            let imagesLinks = data?["imagesLinks"] as? [String],
            let address = data?["address"] as? String
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
        self.imagesLinks = imagesLinks
        self.address = address
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "creatorID": creatorID,
            "date": Timestamp(date: date),
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
            "address": address
        ]
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

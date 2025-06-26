import Foundation
import FirebaseFirestore

// Define the User struct conforming to Identifiable (provides a unique 'id' property)
// and Codable (allows encoding/decoding to/from Firestore)
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var facebookLink: String = ""
    var instagramLink: String = ""
    var xLink: String = ""
    var youtubeLink: String = ""
    var website: String = ""
    var isCreator: Bool = false
    var favorites: [String] = []
    
    // Standard initializer to create an User instance manually
    init(id: String,
         name: String,
         email: String,
         facebookLink: String = "",
         instagramLink: String = "",
         xLink: String = "",
         youtubeLink: String = "",
         website: String = "",
         isCreator: Bool = false,
         favorites: [String] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.facebookLink = facebookLink
        self.instagramLink = instagramLink
        self.xLink = xLink
        self.youtubeLink = youtubeLink
        self.website = website
        self.isCreator = isCreator
        self.favorites = favorites
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            print("Pas de données")
            return nil
        }
        self.id = document.documentID
        self.name = data["name"] as? String ?? "Nom inconnu"
        self.email = data["email"] as? String ?? "Email inconnu"
        self.facebookLink = data["facebookLink"] as? String ?? ""
        self.instagramLink = data["instagramLink"] as? String ?? ""
        self.xLink = data["xLink"] as? String ?? ""
        self.youtubeLink = data["youtubeLink"] as? String ?? ""
        self.website = data["website"] as? String ?? ""
        self.isCreator = data["isCreator"] as? Bool ?? false
        self.favorites = data["favorites"] as? [String] ?? []
    }

    
    // Method to convert User instance to a dictionary for Firestore
    func toDictonary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "facebookLink": facebookLink,
            "instagramLink": instagramLink,
            "xLink": xLink,
            "youtubeLink": youtubeLink,
            "website": website,
            "isCreator": isCreator,
            "favorites": favorites
        ]
    }
}

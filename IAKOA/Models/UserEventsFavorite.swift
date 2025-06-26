import Foundation
import FirebaseFirestore

struct UserEventsFavorite: Identifiable, Codable {
    var id: String
    var userID: String
    var eventIDs: [String]
    
    init(id: String, userID: String, eventIDs: [String] = []) {
        self.id = id
        self.userID = userID
        self.eventIDs = eventIDs
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            print("Pas de données dans le document Firestore.")
            return nil
        }
        
        self.id = document.documentID
        self.userID = data["userID"] as? String ?? ""
        self.eventIDs = data["eventIDs"] as? [String] ?? []
    }

    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "eventIDs": eventIDs
        ]
    }
}

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct EventServices {
    static func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            print("Documents reçus: \(snapshot?.documents.count ?? 0)")
            let events = snapshot?.documents.compactMap { doc -> Event? in
                let event = Event(document: doc)
                if event == nil {
                    print("Event non créé pour doc id: \(doc.documentID), data: \(doc.data())")
                }
                return event
            } ?? []
            completion(.success(events))
        }
    }
    
    static func addEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        var data = event.toDictionary()
        data.removeValue(forKey: "id")
        db.collection("events").document(event.id).setData(event.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    static func fetchEventsForCurrentUser(completion: @escaping (Result<[Event], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 0)))
            return
        }
        print("UID utilisé pour la requête : \(userId)")
        
        let db = Firestore.firestore()
        db.collection("events").whereField("creatorID", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let events = snapshot?.documents.compactMap { doc in
                Event(document: doc)
            } ?? []
            completion(.success(events))
        }
    }

    static func deleteEvent(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("events").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

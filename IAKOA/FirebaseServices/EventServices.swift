import Foundation
import FirebaseFirestore

struct EventServices {
    static func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let events = snapshot?.documents.compactMap { Event(document: $0) } ?? []
            completion(.success(events))
        }
    }
    
    static func addEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
            let db = Firestore.firestore()
            db.collection("events").document(event.id).setData(event.toDictionary()) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
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

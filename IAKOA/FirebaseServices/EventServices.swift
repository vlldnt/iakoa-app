import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct EventServices {
    
    /// Fetch events from Firestore, with optional filters (text, location, radius, categories, free only)
    static func fetchEvents(
        searchText: String = "",
        cityCoordinates: CLLocationCoordinate2D? = nil,
        radiusInKm: Double? = nil,
        selectedCategories: Set<String> = [],
        showOnlyFree: Bool = false,
        completion: @escaping (Result<[Event], Error>) -> Void
    ) {
        let db = Firestore.firestore()
        var query: Query = db.collection("events")

        if showOnlyFree {
            query = query.whereField("pricing", isEqualTo: 0)
        }

        if !selectedCategories.isEmpty {
            query = query.whereField("categories", arrayContainsAny: Array(selectedCategories))
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let allEvents = snapshot?.documents.compactMap { Event(document: $0) } ?? []

            let filtered = allEvents.filter { event in
                let matchesText: Bool
                if cityCoordinates != nil {
                    matchesText = true
                } else {
                    matchesText = searchText.isEmpty || event.name.localizedCaseInsensitiveContains(searchText)
                }

                let matchesDistance: Bool
                if let center = cityCoordinates,
                   let location = event.location {
                    let eventLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
                    let distance = eventLoc.distance(from: centerLoc)
                    matchesDistance = radiusInKm == nil || distance <= radiusInKm! * 1000
                } else {
                    matchesDistance = true
                }

                return matchesText && matchesDistance
            }

            completion(.success(filtered))
        }
    }

    /// Add a new event to Firestore
    static func addEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        var data = event.toDictionary()
        data.removeValue(forKey: "id")
        db.collection("events").document(event.id).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Update an existing event in Firestore
    static func updateEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        var data = event.toDictionary()
        data.removeValue(forKey: "id")
        
        db.collection("events").document(event.id).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// Fetch all events created by the current user
    static func fetchEventsForCurrentUser(completion: @escaping (Result<[Event], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 0)))
            return
        }

        let db = Firestore.firestore()
        db.collection("events").whereField("creatorID", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let events = snapshot?.documents.compactMap { Event(document: $0) } ?? []
            completion(.success(events))
        }
    }

    /// Delete an event by its ID
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
    
    /// Delete an event only if the current user is the owner
    static func deleteEventIfOwner(event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté"])))
            return
        }
        
        guard event.creatorID == currentUserID else {
            completion(.failure(NSError(domain: "Unauthorized", code: 403, userInfo: [NSLocalizedDescriptionKey: "Vous n’êtes pas autorisé à supprimer cet événement"])))
            return
        }
        
        deleteEvent(id: event.id, completion: completion)
    }
    
    /// Toggle favorite status for an event for the current user
    func toggleFavoriteEvent(eventID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Utilisateur non connecté")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("userfavorites").document(userID)

        docRef.getDocument { document, error in
            if let error = error {
                return
                completion(.failure(error))
            }

            var eventIDs: [String] = []

            if let document = document, document.exists {
                let data = document.data()
                eventIDs = data?["eventIDs"] as? [String] ?? []
            }

            if eventIDs.contains(eventID) {
                eventIDs.removeAll { $0 == eventID }
            } else {
                eventIDs.append(eventID)
            }

            let updatedData: [String: Any] = [
                "userID": userID,
                "eventIDs": eventIDs
            ]

            docRef.setData(updatedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

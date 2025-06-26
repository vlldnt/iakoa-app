import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserServices {
    static func createOrUpdateUser(_ user: User, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        db.collection("users").document(user.id).setData(user.toDictonary(), merge: true) { error in
            completion?(error)
        }
    }
    
    static func fetchUser(uid: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let snapshot = snapshot, let user = User(document: snapshot) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    static func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "UserServices", code: 401, userInfo: [NSLocalizedDescriptionKey: "Aucun utilisateur connecté."])))
            return
        }
        let uid = user.uid
        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let db = Firestore.firestore()
                db.collection("users").document(uid).delete { dbError in
                    if let dbError = dbError {
                        completion(.failure(dbError))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    static func fetchIsCreator(completion: @escaping (Bool?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let creator = data["isCreator"] as? Bool {
                completion(creator)
            } else {
                completion(nil)
            }
        }
    }
    
    
    static func updateUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(user.id).setData(user.toDictonary(), merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    static func toggleFavorite(eventID: String, isFavorite: Bool, completion: ((Error?) -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion?(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté"]))
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        let update: [String: Any] = [
            "favorites": isFavorite
            ? FieldValue.arrayRemove([eventID])
            : FieldValue.arrayUnion([eventID])
        ]
        userRef.updateData(update, completion: completion)
    }
    
    static func showFavorites(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté"])))
        }
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }

            let favorites = snapshot?.data()?["favorites"] as? [String] ?? []
            completion(.success(favorites))
        }
    }
    
    static func removeFavorite(eventID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 0)))
            return
        }
        let docRef = Firestore.firestore().collection("users").document(userID)
        docRef.updateData([
            "favorites": FieldValue.arrayRemove([eventID])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

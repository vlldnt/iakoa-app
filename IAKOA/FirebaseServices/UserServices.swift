import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Étape 1 : Récupère tous les events créés par cet utilisateur
        db.collection("events").whereField("creatorID", isEqualTo: uid).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let batch = db.batch()
            var _: [() -> Void] = []
            var imageDeletionErrors: [Error] = []
            let dispatchGroup = DispatchGroup()

            // Étape 2 : Prépare suppression des documents + images
            querySnapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)

                if let images = document.data()["imagesLinks"] as? [String] {
                    for imageURL in images {
                        dispatchGroup.enter()
                        let storageRef = storage.reference(forURL: imageURL)
                        storageRef.delete { error in
                            if let error = error {
                                imageDeletionErrors.append(error)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            // Étape 3 : Commit la suppression Firestore
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                    return
                }

                // Étape 4 : Attendre suppression images
                dispatchGroup.notify(queue: .main) {
                    if !imageDeletionErrors.isEmpty {
                        completion(.failure(imageDeletionErrors.first!))
                        return
                    }

                    // Étape 5 : Supprime le document utilisateur
                    db.collection("users").document(uid).delete { dbError in
                        if let dbError = dbError {
                            completion(.failure(dbError))
                            return
                        }

                        // Étape 6 : Supprime le compte Firebase Auth
                        user.delete { authError in
                            if let authError = authError {
                                completion(.failure(authError))
                            } else {
                                completion(.success(()))
                            }
                        }
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
    
    /// Supprime toutes les images Firebase Storage à partir d'une liste de liens d'imagesLinks
    static func deleteImagesFromLinks(_ links: [String], completion: ((Error?) -> Void)? = nil) {
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        var lastError: Error? = nil

        for urlString in links {
            // Extraction du chemin Storage depuis l'URL
            if let range = urlString.range(of: "/o/"),
               let endRange = urlString.range(of: "?") {
                let encodedPath = urlString[range.upperBound..<endRange.lowerBound]
                if let storagePath = encodedPath.removingPercentEncoding {
                    let ref = storage.reference(withPath: storagePath)
                    dispatchGroup.enter()
                    ref.delete { error in
                        if let error = error {
                            lastError = error
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion?(lastError)
        }
    }
}

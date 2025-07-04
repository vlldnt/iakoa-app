import Foundation
import FirebaseAuth

struct AuthServices {
    /// Sign in a user with email and password
    static func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// Send a password reset email to the user
    static func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Register a new user with email and password
    static func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Log out the current user
    static func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Update the user's password after re-authenticating with the old password
    static func updatePassword(oldPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            let error = NSError(domain: "FirebaseAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté."])
            completion(.failure(error))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

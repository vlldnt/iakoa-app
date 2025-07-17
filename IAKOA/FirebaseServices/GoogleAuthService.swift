import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class GoogleAuthManager: ObservableObject {
    static let shared = GoogleAuthManager()

    func signInWithGoogle(completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing clientID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("No root view controller")
            return
        }

        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(user.uid)
                    userRef.getDocument { snapshot, error in
                        if let snapshot = snapshot, snapshot.exists {
                            completion(.success(user))
                        } else {
                            let defaultName = user.displayName ?? "Utilisateur\(Int.random(in: 1000...9999))"
                            let newUser = User(id: user.uid, name: defaultName, email: user.email ?? "")
                            UserServices.createOrUpdateUser(newUser) { _ in
                                completion(.success(user))
                            }
                        }
                    }
                }
            }
        }
    }
}

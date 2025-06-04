import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isLoggedIn = false
    @State private var isCreator = false

    var body: some View {
        TabView(selection: $selectedTab) {
            EventView()
                .tabItem {
                    Image(systemName: "bubbles.and.sparkles")
                    Text("Évènements")
                }
                .tag(0)

            Text("Favoris")
                .tabItem {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Favoris")
                }
                .tag(1)

            if isCreator {
                CreateEventView()
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Créer")
                    }
                    .tag(2)
            } else {
                MapView()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Carte")
                    }
                    .tag(2)
            }

            // Affichage du profil ou de l'écran d'authentification
            Group {
                if isLoggedIn {
                    ProfileView(isLoggedIn: $isLoggedIn, isCreator: $isCreator)
                } else {
                    AuthView(isLoggedIn: $isLoggedIn)
                }
            }
            .tabItem {
                Image(systemName: isLoggedIn ? "person.fill.checkmark" : "person.fill.xmark")
                Text("Profil")
            }
            .tag(3)
        }
        .onAppear {
            fetchUserState()
        }
        .onChange(of: isLoggedIn) {
            selectedTab = 3
            fetchUserState()
        }
    }

    private func fetchUserState() {
        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            isCreator = false
            return
        }

        isLoggedIn = true

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                isCreator = data?["isCreator"] as? Bool ?? false
            } else {
                isCreator = false
                print("Erreur de récupération Firestore : \(error?.localizedDescription ?? "Inconnu")")
            }
        }
    }
}

#Preview {
    ContentView()
}

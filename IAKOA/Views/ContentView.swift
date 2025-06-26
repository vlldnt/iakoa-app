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
            EventView(isLoggedIn: $isLoggedIn, isCreator: $isCreator)
                .tabItem {
                    Image(systemName: "bubbles.and.sparkles")
                    Text("Évènements")
                }
                .tag(0)
            
            Group {
                if isCreator {
                    EventsManagerView()
                } else {
                    if isLoggedIn {
                        UserEventsFavoriteView()
                    } else {
                        Button("Veuillez vous connecter") {
                            selectedTab = 3
                        }
                        .background(Color.gray.opacity(0.2))
                    }
                }
            }
            .tabItem {
                if isCreator {
                    Image(systemName: "pencil.and.outline")
                    Text("Gestionnaire")
                } else {
                    if isLoggedIn {
                        Image(systemName: "heart.fill")
                        Text("Favoris")
                    } else {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("Favoris")
                    }
                }
            }
            .tag(1)
        

            Group {
                if isCreator {
                    CreateView(selectedTab: $selectedTab)
                } else {
                    MapView()
                }
            }
            .tabItem {
                if isCreator {
                    Image(systemName: "plus")
                    Text("Créer")
                } else {
                    Image(systemName: "map")
                    Text("Carte")
                }
            }
            .tag(2)
            
            Group {
                if isLoggedIn {
                    ProfileView(isLoggedIn: $isLoggedIn, isCreator: $isCreator)
                } else {
                    AuthView(isLoggedIn: $isLoggedIn)
                }
            }
            .tabItem {
                Image(systemName: isLoggedIn ? "person.fill.checkmark" : "key")
                Text(isLoggedIn ? "Profil" : "Authentification")
            }
            .tag(3)
        }
        .onAppear {
            fetchUserState()
        }
        .onChange(of: isLoggedIn) { _, _ in
            selectedTab = 0
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

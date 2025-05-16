import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var isLoggedIn = false

    init() {
        FirebaseApp.configure()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Accueil")
                .tabItem {
                    Image(systemName: "house")
                    Text("Accueil")
                }
                .tag(0)

            Text("Favoris")
                .tabItem {
                    Image(systemName: "star")
                    Text("Favoris")
                }
                .tag(1)

            Text("Création d'un évènement")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Créer")
                }
                .tag(2)

            AuthView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profil")
                }
                .tag(3)
        }
        .onChange(of: isLoggedIn) {
            selectedTab = 0
        }
    }
}

#Preview {
    ContentView()
}

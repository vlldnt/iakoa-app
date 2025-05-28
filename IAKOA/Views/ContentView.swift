import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isLoggedIn = false

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

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

            CreateEventView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Créer")
                }
                .tag(2)

            Group {
                if isLoggedIn {
                    ProfileView(isLoggedIn: $isLoggedIn)
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
            isLoggedIn = Auth.auth().currentUser != nil
        }
        .onChange(of: isLoggedIn) {
            selectedTab = 3
        }
    }
}


#Preview {
    ContentView()
}

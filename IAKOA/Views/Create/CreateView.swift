import Foundation
import SwiftUI
import FirebaseAuth

struct CreateView: View {
    
    @Binding var selectedTab: Int
    @State private var showEventCreationView = false
    @State private var userInfo: User? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = userInfo {
                Text("👋 \(user.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Button("Créer un événement") {
                showEventCreationView = true
            }
            .font(.headline)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blueIakoa, lineWidth: 1)
            )
            
            Button("Gérer mes évènements") {
                selectedTab = 1
            }
            .font(.headline)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blueIakoa, lineWidth: 1)
            )
        }
        .padding()
        .onAppear {
            fetchUserInfo()
        }
        .sheet(isPresented: $showEventCreationView) {
            EventStepsCreationView()
        }
    }
    
    func fetchUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.fetchUser(uid: uid) { user in
            if let user = user {
                self.userInfo = user
            } else {
                print("Erreur : utilisateur introuvable.")
            }
        }
    }
}

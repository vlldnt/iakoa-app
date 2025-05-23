import SwiftUI
import FirebaseAuth
import Firebase

struct ProfileView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Bienvenue dans votre profil")
                .font(.title2)

            Button(action: {
                do {
                    try Auth.auth().signOut()
                    isLoggedIn = false
                } catch {
                    print("Erreur lors de la déconnexion : \(error.localizedDescription)")
                }
            }) {
                Text("Se déconnecter")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

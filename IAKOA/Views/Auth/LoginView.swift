import SwiftUI

struct LoginView: View {
    
    @Binding var isLoggedIn: Bool
    
    
    @StateObject private var googleAuthManager = GoogleAuthManager.shared

    @State private var selectedTab: AuthTab = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage: String = ""

    enum AuthTab {
        case login, signup
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Vous avez déjà un compte ?")
                .fontWeight(.regular)

            Group {
                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 42)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                SecureField("Mot de passe", text: $password)
                    .padding()
                    .frame(height: 42)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: {
                if email.isEmpty {
                    alertMessage = "Veuillez entrer votre adresse e-mail."
                    showAlert = true
                    return
                }
                AuthServices.resetPassword(email: email) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            alertMessage = "Un e-mail de réinitialisation a été envoyé à \(email)."
                        case .failure(let error):
                            alertMessage = "Erreur : \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                }
            }) {
                Text("Mot de passe oublié ?")
                    .font(.system(size: 12))
                    .foregroundColor(Color.blueIakoa)
            }
            .padding(.top, 4)

            Button(action: {
                AuthServices.signIn(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            alertMessage = "Connexion réussie"
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                        }
                        showAlert = true
                    }
                }
            }) {
                Text("Se connecter")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blueIakoa)
                    .cornerRadius(8)
            }

            HStack {
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                Text("ou avec")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
            }
            
            GoogleSignInButtonView(isLoggedIn: $isLoggedIn)
            
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notification"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Connexion réussie" {
                        isLoggedIn = true
                    }
                }
            )
        }
    }
}

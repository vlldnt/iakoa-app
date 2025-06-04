import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool

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
                resetPassword()
            }) {
                Text("Mot de passe oublié ?")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#2397FF"))
            }
            .padding(.top, 4)

            Button(action: {
                login()
            }) {
                Text("Se connecter")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2397FF"))
                    .cornerRadius(8)
            }

            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)

                Text("ou continuer avec")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }

            Button(action: {
                // Continuer avec Apple
            }) {
                HStack(spacing: 12) {
                    Image("apple-icon")
                        .resizable()
                        .frame(width: 35, height: 35)

                    Text("Continuer avec Apple")
                        .foregroundColor(.black)
                }
                .padding(7)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray4).opacity(0.8))
                .cornerRadius(8)
            }

            Button(action: {
                // Continuer avec Google
            }) {
                HStack(spacing: 12) {
                    Image("google-icon")
                        .resizable()
                        .frame(width: 35, height: 35)

                    Text("Continuer avec Google")
                        .foregroundColor(.black)
                }
                .padding(7)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray4).opacity(0.8))
                .cornerRadius(8)
            }
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

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = error.localizedDescription
                } else {
                    alertMessage = "Connexion réussie"
                }
                showAlert = true
            }
        }
    }

    func resetPassword() {
        guard !email.isEmpty else {
            alertMessage = "Veuillez entrer votre adresse e-mail."
            showAlert = true
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = "Erreur : \(error.localizedDescription)"
            } else {
                alertMessage = "Un e-mail de réinitialisation a été envoyé à \(email)."
            }
            showAlert = true
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}

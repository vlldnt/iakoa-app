import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool

    @State private var selectedTab: AuthTab = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false

    enum AuthTab {
        case login, signup
    }

    var body: some View {
        VStack(spacing: 23) {

            Text("Vous déjà avez un compte ?")
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
            .padding(.top, 16)

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
                // Action pour continuer avec Apple
            }) {
                HStack(spacing: 12) {
                    Image("apple-icon")
                        .resizable()
                        .frame(width: 35, height: 35)

                    Text("Continuer avec Apple")
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                }
                .padding(7)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray4).opacity(0.8))
                .cornerRadius(8)
            }

            Button(action: {
                // Action pour continuer avec Google
            }) {
                HStack(spacing: 12) {
                    Image("google-icon")
                        .resizable()
                        .frame(width: 35, height: 35)

                    Text("Continuer avec Google")
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                }
                .padding(7)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray4).opacity(0.8))
                .cornerRadius(8)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Connexion réussie"),
                message: Text("Vous êtes maintenant connecté."),
                dismissButton: .default(Text("Ok")) {
                    isLoggedIn = true
                }
            )
        }
    }

    private func tabButton(title: String, tab: AuthTab) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    selectedTab == tab ? Color(hex: "#2397FF") : Color(UIColor.systemGray5)
                )
                .cornerRadius(1)
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    showAlert = true
                }
                print("Successfully logged in!")
            }
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
    LoginView(isLoggedIn: .constant(false ))
}

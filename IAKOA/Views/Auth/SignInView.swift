import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Binding var isLoggedIn: Bool

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifiedPassword: String = ""

    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var shouldLogInAfterAlert = false

    var body: some View {
        VStack(spacing: 14) {
            Text("Vous n'avez pas encore de compte ?")
                .fontWeight(.regular)

            Group {
                TextField("Email", text: $email)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isValidEmail(email) ? Color.green : Color.clear, lineWidth: 2)
                    )

                SecureField("Mot de passe", text: $password)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isValidPassword ? Color.green : Color.clear, lineWidth: 2)
                    )

                SecureField("Vérifier le mot de passe", text: $verifiedPassword)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(passwordsMatch ? Color.green : Color.clear, lineWidth: 2)
                    )
            }
            .font(.subheadline)

            VStack(spacing: 5) {
                Text("L’email doit être valide. Le mot de passe doit contenir")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .italic()
                Text("au moins 8 caractères avec une majuscule et un chiffre.")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .italic()
            }

            Button(action: {
                AuthServices.signUp(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            alertTitle = "Succès"
                            alertMessage = "Compte créé avec succès. Vous êtes maintenant connecté."
                            shouldLogInAfterAlert = true
                        case .failure(let error):
                            alertTitle = "Erreur"
                            if let errorCode = AuthErrorCode(rawValue: (error as NSError).code),
                               errorCode == .emailAlreadyInUse {
                                alertMessage = "Cet email est déjà utilisé."
                            } else {
                                alertMessage = error.localizedDescription
                            }
                            shouldLogInAfterAlert = false
                        }
                        showAlert = true
                    }
                }
            }) {
                Text("Créer votre compte")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFormValid ? Color(hex: "#2397FF") : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!isFormValid)

            // Ligne de séparation
            HStack {
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                Text("ou créer avec")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
            }

            // Boutons sociaux
            HStack(spacing: 50) {
                Button(action: {}) {
                    Image("apple-icon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                Button(action: {}) {
                    Image("google-icon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            VStack {
                Text("Conditions d'utilisation.")
                    .bold()
                    .foregroundColor(.gray)
                    .font(.custom("Poppins-Regular", size: 10))
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if shouldLogInAfterAlert {
                        isLoggedIn = true
                    }
                }
            )
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        isValidEmail(email) &&
        passwordsMatch &&
        isValidPassword &&
        password.count >= 8
    }

    private var passwordsMatch: Bool {
        !verifiedPassword.isEmpty && verifiedPassword == password
    }

    private var isValidPassword: Bool {
        containsUppercase(password) && containsDigit(password)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func containsUppercase(_ text: String) -> Bool {
        let regex = ".*[A-Z]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    private func containsDigit(_ text: String) -> Bool {
        let regex = ".*[0-9]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

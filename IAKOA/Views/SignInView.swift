//
//  SignInView.swift
//  IAKOA
//
//  Created by Adrien V on 16/05/2025.
//


import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Binding var isLoggedIn: Bool

    @State private var selectedTab: AuthTab = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifiedPassword: String = ""
    @State private var showAlert = false

    enum AuthTab {
        case login, signup
    }

    var body: some View {
        VStack(spacing: 16) {
            // email / Passwords
            Text("Vous n'avez pas encore de compte ?")
                .fontWeight(.regular)

            Group {
                TextField("Email", text: $email)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)

                SecureField("Mot de passe", text: $password)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)

                SecureField("Verifier le mot de passe", text: $verifiedPassword)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            .font(.subheadline)
            
            // Verif data written
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    // Email valide
                    HStack(spacing: 4) {
                        Image(systemName: isValidEmail(email) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isValidEmail(email) ? .green : .red)
                            .opacity(email.isEmpty ? 0.3 : 1)
                        Text("Email valide")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    // Mot de passe confirmé
                    HStack(spacing: 4) {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(passwordsMatch ? .green : .red)
                            .opacity(verifiedPassword.isEmpty ? 0.3 : 1)
                        Text("Mot de passe confirmé")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }

                HStack(spacing: 16) {
                    // 1 majuscule min
                    HStack(spacing: 4) {
                        Image(systemName: containsUppercase(password) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(containsUppercase(password) ? .green : .red)
                            .opacity(password.isEmpty ? 0.3 : 1)
                        Text("Une majuscule")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    // ≥ 8 caractères
                    HStack(spacing: 4) {
                        Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(password.count >= 8 ? .green : .red)
                            .opacity(password.isEmpty ? 0.3 : 1)
                        Text("≥ 8 caractères")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    // 1 chiffre min
                    HStack(spacing: 4) {
                        Image(systemName: containsDigit(password) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(containsDigit(password) ? .green : .red)
                            .opacity(password.isEmpty ? 0.3 : 1)
                        Text("Un chiffre")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }





            Button(action: {
                signIn()
            }) {
                Text("Créer votre compte")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2397FF"))
                    .cornerRadius(8)
            }
            .padding(.top, 6)

            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)

                Text("ou créer avec")
                    .foregroundColor(.gray)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }

            HStack(spacing: 50) {
                Button(action: {
                    // Action With Apple
                }) {
                    Image("apple-icon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(10) // un peu d'espace autour de l'image pour la bordure
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: {
                    // Action With Google
                }) {
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
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Connexion réussie"),
                message: Text("Vous êtes maintenant connecté."),
                dismissButton: .default(Text("OK")) {
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
                .fontWeight(.regular)
                .foregroundColor(Color.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    selectedTab == tab ? Color(hex: "#2397FF") : Color(UIColor.systemGray5)
                )
                .cornerRadius(1)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    func containsUppercase(_ text: String) -> Bool {
        let uppercaseRegEx = ".*[A-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegEx)
        return predicate.evaluate(with: text)
    }

    func containsDigit(_ text: String) -> Bool {
        let digitRegEx = ".*[0-9]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", digitRegEx)
        return predicate.evaluate(with: text)
    }
    
    var passwordsMatch: Bool {
        !verifiedPassword.isEmpty && verifiedPassword == password
    }
    
    func signIn() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    showAlert = true
                }
                print("Compte crée avec succès.")
            }
        }
    }
}

#Preview {
    SignInView(isLoggedIn: .constant(false ))
}

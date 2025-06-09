import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                SecureField("Ancien mot de passe", text: $oldPassword)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .autocapitalization(.none)

                SecureField("Nouveau mot de passe", text: $newPassword)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isValidNewPassword ? Color.green : Color.clear, lineWidth: 2)
                    )

                SecureField("Confirmer le nouveau mot de passe", text: $confirmPassword)
                    .padding(.horizontal, 10)
                    .frame(height: 43)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(passwordsMatch ? Color.green : Color.clear, lineWidth: 2)
                    )

                VStack(spacing: 5) {
                    Text("Le mot de passe doit contenir au moins 8 caractères, une majuscule et un chiffre.")
                        .font(.system(size: 10))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .italic()
                }

                Button(action: {
                    updatePassword()
                }) {
                    Text("Changer le mot de passe")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid ? Color.blueIakoa : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isFormValid)

                Spacer()
            }
            .padding()
            .navigationTitle("Mot de passe")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Mot de passe mis à jour avec succès." {
                        dismiss()
                    }
                })
            }
        }
    }

    // MARK: - Validations
    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        isValidNewPassword &&
        passwordsMatch
    }

    private var isValidNewPassword: Bool {
        newPassword.count >= 8 &&
        containsUppercase(newPassword) &&
        containsDigit(newPassword)
    }

    private var passwordsMatch: Bool {
        !confirmPassword.isEmpty && confirmPassword == newPassword
    }

    private func containsUppercase(_ text: String) -> Bool {
        let regex = ".*[A-Z]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    private func containsDigit(_ text: String) -> Bool {
        let regex = ".*[0-9]+.*"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    // MARK: - Firebase Update
    private func updatePassword() {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            alertMessage = "Utilisateur non connecté."
            showAlert = true
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                alertMessage = "Ancien mot de passe incorrect : \(error.localizedDescription)"
                showAlert = true
            } else {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        alertMessage = "Erreur : \(error.localizedDescription)"
                    } else {
                        alertMessage = "Mot de passe mis à jour avec succès."
                    }
                    showAlert = true
                }
            }
        }
    }
}

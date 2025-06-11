import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    private var isFormValid: Bool {
        !oldPassword.isEmpty &&
        ChangePasswordValidator.isValid(password: newPassword) &&
        ChangePasswordValidator.passwordsMatch(newPassword, confirmPassword)
    }

    private var isValidNewPassword: Bool {
        ChangePasswordValidator.isValid(password: newPassword)
    }

    private var passwordsMatch: Bool {
        ChangePasswordValidator.passwordsMatch(newPassword, confirmPassword)
    }
    
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
                    AuthServices.updatePassword(oldPassword: oldPassword, newPassword: newPassword) { result in
                        switch result {
                        case .success:
                            alertMessage = "Mot de passe mis à jour avec succès."
                        case .failure(let error):
                            alertMessage = "Erreur : \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                    
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
}

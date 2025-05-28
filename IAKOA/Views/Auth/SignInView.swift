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
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifiedPassword: String = ""
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
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
                
                SecureField("Verifier le mot de passe", text: $verifiedPassword)
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
                Text("L’email doit être valide. Le mot de passe doit contenir ")
                    .font(.system(size: 10))
                    .foregroundColor(Color(UIColor.systemGray2))
                    .italic()
                Text("au moins 8 caractères avec une majuscule et un chiffre.")
                    .font(.system(size: 10))
                    .foregroundColor(Color(UIColor.systemGray2))
                    .italic()
            }

            Button(action: {
                signUp()
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
            
            // Divider with "or" text
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("ou créer avec")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Social login buttons
            HStack(spacing: 50) {
                Button(action: {
                    // Action With Apple
                }) {
                    Image("apple-icon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(10)
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
            
            // Terms and conditions
            VStack(spacing: 0) {
                Text("Conditions d'utilisation.")
                    .bold()
                    .foregroundColor(.gray)
                    .font(.custom("Poppins-Regular", size: 10))
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Form validation properties
    private var isFormValid: Bool {
        isValidEmail(email) &&
        passwordsMatch &&
        containsUppercase(password) &&
        password.count >= 8 &&
        containsDigit(password)
    }
    
    private var passwordsMatch: Bool {
        !verifiedPassword.isEmpty && verifiedPassword == password
    }
    
    // Validation functions
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    private func containsUppercase(_ text: String) -> Bool {
        let uppercaseRegEx = ".*[A-Z]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegEx)
        return predicate.evaluate(with: text)
    }

    private func containsDigit(_ text: String) -> Bool {
        let digitRegEx = ".*[0-9]+.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", digitRegEx)
        return predicate.evaluate(with: text)
    }
    var isValidPassword: Bool {
            containsDigit(password) && containsUppercase(password)
        }
    
    // SignUp function
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        alertTitle = "Erreur"
                        alertMessage = "Cet email est déjà utilisé."
                    default:
                        alertTitle = "Erreur"
                        alertMessage = error.localizedDescription
                    }
                } else {
                    alertTitle = "Erreur"
                    alertMessage = error.localizedDescription
                }
                isLoggedIn = false
                showAlert = true
            } else {
                alertTitle = "Succès"
                alertMessage = "Compte créé avec succès. Vous êtes maintenant connecté."
                isLoggedIn = true
                showAlert = true
            }
        }
    }


}

#Preview {
    SignInView(isLoggedIn: .constant(false))
}

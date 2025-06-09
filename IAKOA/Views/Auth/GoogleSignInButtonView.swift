//
//  GoogleSignInButtonView.swift
//  IAKOA
//
//  Created by Adrien V on 09/06/2025.
//


import SwiftUI
import FirebaseAuth

struct GoogleSignInButtonView: View {
    @StateObject private var authManager = GoogleAuthManager.shared
    @State private var showAlert = false
    @State private var userName = ""
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            Button(action: {
                authManager.signInWithGoogle { result in
                    switch result {
                    case .success(let user):
                        userName = user.displayName ?? "Utilisateur"
                        showAlert = true
                        isLoggedIn = true
                    case .failure(let error):
                        print("Erreur Google Sign-In: \(error.localizedDescription)")
                    }
                }
            }) {
                Image("google-icon")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
                
            .padding()
            .alert("Connexion réussie", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Bienvenue \(userName) !")
            }
        }
    }
}

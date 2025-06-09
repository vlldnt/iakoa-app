//
//  AppleSignInButtonView.swift
//  IAKOA
//
//  Created by Adrien V on 09/06/2025.
//


import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    @StateObject private var authManager = AppleAuthManager.shared
    @State private var showAlert = false
    @State private var userName = ""
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            SignInWithAppleButton(
                onRequest: { request in
                },
                onCompletion: { _ in
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            .cornerRadius(10)
            .onTapGesture {
                authManager.startSignInWithAppleFlow { result in
                    switch result {
                    case .success(let user):
                        userName = user.displayName ?? "Utilisateur Apple"
                        isLoggedIn = true
                        showAlert = true
                    case .failure(let error):
                        print("Erreur Apple Sign-In: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            .alert("Connexion réussie", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Bienvenue \(userName) !")
            }
        }
    }
}

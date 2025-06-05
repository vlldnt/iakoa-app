import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var name: String
    @Binding var facebookLink: String
    @Binding var instagramLink: String
    @Binding var xLink: String
    @Binding var youtubeLink: String
    @Binding var email: String
    @Binding var isCreator: Bool
    @Binding var website: String

    @State private var isLoading = false
    @State private var message: String = ""
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations personnelles")) {
                    TextField("Nom", text: $name)
                }

                Section(header: Text("Pseudos de vos Réseaux sociaux (facultatif)")) {
                    Tools.socialField(label: "Facebook", text: $facebookLink)
                    Tools.socialField(label: "Instagram", text: $instagramLink)
                    Tools.socialField(label: "YouTube", text: $youtubeLink)
                    Tools.socialField(label: "X (Twitter)", text: $xLink)
                    Tools.socialField(label: "Votre site", text: $website)
                }

                Section {
                    Toggle("Compte créateur", isOn: $isCreator)
                }

                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button(isLoading ? "En cours..." : "Mettre à jour") {
                        guard let uid = Auth.auth().currentUser?.uid else {
                            message = "Utilisateur non connecté"
                            return
                        }
                        if isCreator && name.trimmingCharacters(in: .whitespaces).isEmpty {
                            message = "Le nom est obligatoire pour un compte créateur."
                            return
                        }
                        message = ""
                        isLoading = true
                        let user = User(
                            id: uid,
                            name: name,
                            email: email,
                            facebookLink: facebookLink,
                            instagramLink: instagramLink,
                            xLink: xLink,
                            youtubeLink: youtubeLink,
                            website: website,
                            isCreator: isCreator
                        )
                        UserServices.updateUserProfile(user: user) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success:
                                    showSuccessAlert = true
                                case .failure(let error):
                                    message = "Erreur mise à jour: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Modifier profil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                UserServices.fetchIsCreator { creator in
                    if let creator = creator {
                        isCreator = creator
                    }
                }
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Profil mis à jour"),
                    message: Text("Vos informations ont bien été enregistrées."),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
}

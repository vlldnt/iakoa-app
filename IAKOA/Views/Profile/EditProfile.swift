import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
                    socialField(label: "Facebook", text: $facebookLink)
                    socialField(label: "Instagram", text: $instagramLink)
                    socialField(label: "YouTube", text: $youtubeLink)
                    socialField(label: "X (Twitter)", text: $xLink)
                    socialField(label: "Votre site", text: $website)
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
                        updateUserProfile()
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
                fetchIsCreator()
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

    // MARK: - Affichage des champs de réseaux sociaux
    func socialField(label: String, text: Binding<String>) -> some View {
        HStack {
            Text("\(label) :")
                .italic()
                .foregroundColor(.gray)
            TextField(label, text: text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(.black)
        }
    }

    // MARK: - Mise à jour profil
    func updateUserProfile() {
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

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "name": name,
            "facebookLink": facebookLink,
            "instagramLink": instagramLink,
            "youtubeLink": youtubeLink,
            "xLink": xLink,
            "email": email,
            "website": website,
            "isCreator": isCreator
        ]

        db.collection("users").document(uid).setData(data, merge: true) { error in
            isLoading = false
            if let error = error {
                message = "Erreur mise à jour: \(error.localizedDescription)"
            } else {
                showSuccessAlert = true
            }
        }
    }

    // MARK: - Charger si l'utilisateur est créateur
    func fetchIsCreator() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let creator = data["isCreator"] as? Bool {
                isCreator = creator
            }
        }
    }
}

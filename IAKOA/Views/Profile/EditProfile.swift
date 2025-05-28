import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var name: String
    @Binding var postalCode: Int
    @Binding var facebookLink: String
    @Binding var instagramLink: String
    @Binding var xLink: String
    @Binding var youtubeLink: String
    @Binding var email: String
    @Binding var isCreator: Bool
    
    @State private var isLoading = false
    @State private var message: String = ""
    
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations personnelles")) {
                    TextField("Nom", text: $name)
                    TextField("Code postal", value: $postalCode, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Réseaux sociaux (facultatif)")) {
                    TextField("Facebook", text: $facebookLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("Instagram", text: $instagramLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("YouTube", text: $youtubeLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("X (Twitter)", text: $xLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
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
    
    func updateUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Utilisateur non connecté"
            return
        }
        
        if isCreator && (name.trimmingCharacters(in: .whitespaces).isEmpty || postalCode == 0) {
            message = "Nom et code postal sont obligatoires pour un compte créateur."
            return
        }
        
        message = ""
        isLoading = true
        
        let db = Firestore.firestore()
        
        let roleString = isCreator ? "createur" : "normal"
        
        let data: [String: Any] = [
            "name": name,
            "postalCode": postalCode,
            "facebookLink": facebookLink,
            "instagramLink": instagramLink,
            "youtubeLink": youtubeLink,
            "xLink": xLink,
            "email": email,
            "role": roleString
        ]
        
        db.collection("Users").document(uid).setData(data, merge: true) { error in
            isLoading = false
            if let error = error {
                message = "Erreur mise à jour: \(error.localizedDescription)"
            } else {
                showSuccessAlert = true
            }
        }
    }
}

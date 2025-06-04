import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isCreator: Bool

    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var facebookLink: String = ""
    @State private var instagramLink: String = ""
    @State private var xLink: String = ""
    @State private var youtubeLink: String = ""
    @State private var email: String = ""
    @State private var website: String = ""

    @State private var isLoading = false
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var shouldLogout = false
    @State private var showChangePasswordView = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: HStack {
                    Text(email).bold()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Nom :")
                                .italic()
                                .foregroundColor(.gray)
                            Text(name)
                                .bold()
                                .foregroundColor(.black)
                        }

                        // Badge créateur / standard
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(isCreator ? .orange : .gray)
                            Text(isCreator ? "Compte créateur" : "Compte standard")
                                .foregroundColor(isCreator ? .orange : .gray)
                                .fontWeight(isCreator ? .semibold : .regular)
                        }
                        .padding(.top, 10)

                        if !facebookLink.isEmpty {
                            socialLinkRow(icon: "facebook-icon", username: facebookLink, type: "facebook")
                                .padding(.top, 10)
                        }
                        if !instagramLink.isEmpty {
                            socialLinkRow(icon: "instagram-icon", username: instagramLink, type: "instagram")
                                .padding(.top, 10)
                        }
                        if !youtubeLink.isEmpty {
                            socialLinkRow(icon: "youtube-icon", username: youtubeLink, type: "youtube")
                                .padding(.top, 10)
                        }
                        if !xLink.isEmpty {
                            socialLinkRow(icon: "x-icon", username: xLink, type: "x")
                                .padding(.top, 10)
                        }
                        if !website.isEmpty {
                            socialLinkRow(icon: "website-icon", username: website, type: "website")
                                .padding(.top, 10)
                        }
                    }
                }

                Section(header: Text("Paramètres du compte")) {
                    HStack {
                        Button("Modifier mon mot de passe") {
                            showChangePasswordView = true
                        }
                        .bold()
                        .sheet(isPresented: $showChangePasswordView) {
                            ChangePasswordView()
                        }
                        .buttonStyle(.borderedProminent)

                        Spacer()

                        Button("Modifier mes informations") {
                            showEditProfile = true
                        }
                        .buttonStyle(.bordered)
                        .bold()
                    }

                    LongPressLogoutButton(
                        showAlert: $showAlert,
                        alertText: $alertText,
                        onLogoutConfirmed: {
                            shouldLogout = true
                        }
                    )

                    LongPressDeleteAccountButton(
                        showAlert: $showAlert,
                        alertText: $alertText,
                        onDeleteConfirmed: {
                            shouldLogout = true
                        }
                    )
                }

                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Mon profil")
            .onAppear {
                loadUserData()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    name: $name,
                    facebookLink: $facebookLink,
                    instagramLink: $instagramLink,
                    xLink: $xLink,
                    youtubeLink: $youtubeLink,
                    email: $email,
                    isCreator: $isCreator,
                    website: $website
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Succès"),
                    message: Text(alertText),
                    dismissButton: .default(Text("OK")) {
                        if shouldLogout {
                            isLoggedIn = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }

    func socialLinkRow(icon: String, username: String, type: String) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 30, height: 30)
            Button(action: {
                openSocialLink(username: username, type: type)
            }) {
                Text(username)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(.blue)
            }
        }
    }

    func openSocialLink(username: String, type: String) {
        var appURL: URL?
        var webURL: URL?

        switch type {
        case "facebook":
            appURL = URL(string: "fb://profile/\(username)")
            webURL = URL(string: "https://facebook.com/\(username)")
        case "instagram":
            appURL = URL(string: "instagram://user?username=\(username)")
            webURL = URL(string: "https://instagram.com/\(username)")
        case "youtube":
            appURL = URL(string: "youtube://www.youtube.com/channel/\(username)")
            webURL = URL(string: "https://youtube.com/\(username)")
        case "x":
            appURL = URL(string: "twitter://user?screen_name=\(username)")
            webURL = URL(string: "https://x.com/\(username)")
        case "website":
            if let url = URL(string: username), UIApplication.shared.canOpenURL(url) {
                webURL = url
            } else if let url = URL(string: "https://\(username)"), UIApplication.shared.canOpenURL(url) {
                webURL = url
            }
        default:
            return
        }

        if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = webURL {
            UIApplication.shared.open(webURL)
        }
    }

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Utilisateur non connecté"
            return
        }

        isLoading = true

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        // 👇 Écoute les changements du document utilisateur en temps réel
        userRef.addSnapshotListener { snapshot, error in
            isLoading = false

            if let data = snapshot?.data(), error == nil {
                name = data["name"] as? String ?? ""
                facebookLink = data["facebookLink"] as? String ?? ""
                instagramLink = data["instagramLink"] as? String ?? ""
                youtubeLink = data["youtubeLink"] as? String ?? ""
                xLink = data["xLink"] as? String ?? ""
                website = data["website"] as? String ?? ""
                email = data["email"] as? String ?? Auth.auth().currentUser?.email ?? ""
                isCreator = data["isCreator"] as? Bool ?? false
            } else {
                message = "Erreur de chargement des données"
                email = Auth.auth().currentUser?.email ?? ""
            }
        }
    }

}
struct LongPressLogoutButton: View {
    @State private var progress: CGFloat = 0.0
    @State private var isPressing = false
    @State private var isLoggingOut = false

    @Binding var showAlert: Bool
    @Binding var alertText: String

    var onLogoutConfirmed: () -> Void

    let duration: Double = 1.0
    let cornerRadius: CGFloat = 12
    let width: CGFloat = 340
    let height: CGFloat = 40

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.red.opacity(0.3), lineWidth: 3)
                .frame(width: width, height: height)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.red)
                .frame(width: width * progress, height: height)
                .animation(.linear(duration: isPressing ? duration : 0.3), value: progress)
                .allowsHitTesting(false)

            Text(isPressing ? "Déconnexion..." : "Se déconnecter")
                .fontWeight(.semibold)
                .frame(width: width, height: height)
                .foregroundColor(progress > 0.5 ? .white : .red)
            
            
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressing {
                        isPressing = true
                        progress = 0.0
                        withAnimation(.linear(duration: duration)) {
                            progress = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            if isPressing {
                                logout()
                            }
                        }
                    }
                }
                .onEnded { _ in
                    isPressing = false
                    withAnimation(.easeOut(duration: 0.3)) {
                        progress = 0.0
                    }
                }
        )
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            alertText = "Déconnexion réussie."
            showAlert = true
            onLogoutConfirmed()
        } catch {
            alertText = "Erreur lors de la déconnexion : \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct LongPressDeleteAccountButton: View {
    @State private var progress: CGFloat = 0.0
    @State private var isPressing = false

    @Binding var showAlert: Bool
    @Binding var alertText: String

    var onDeleteConfirmed: () -> Void

    let duration: Double = 1.5
    let cornerRadius: CGFloat = 12
    let width: CGFloat = 340
    let height: CGFloat = 40
    let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // Bordure de fond (rouge clair)
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.red.opacity(0.3), lineWidth: lineWidth)
                .frame(width: width, height: height)

            // Bordure animée (rouge foncé) qui se remplit progressivement
            RoundedRectangle(cornerRadius: cornerRadius)
                .trim(from: 0, to: progress)
                .stroke(Color.red, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(0)) // Commence en haut
                .frame(width: width, height: height)
                .animation(.linear(duration: isPressing ? duration : 0.3), value: progress)
                .allowsHitTesting(false)

            Text(isPressing ? "Suppression..." : "Supprimer mon compte")
                .fontWeight(.semibold)
                .frame(width: width, height: height)
                .foregroundColor(.red)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressing {
                        isPressing = true
                        progress = 0.0
                        withAnimation(.linear(duration: duration)) {
                            progress = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            if isPressing {
                                deleteAccount()
                            }
                        }
                    }
                }
                .onEnded { _ in
                    isPressing = false
                    withAnimation(.easeOut(duration: 0.3)) {
                        progress = 0.0
                    }
                }
        )
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            alertText = "Aucun utilisateur connecté."
            showAlert = true
            return
        }

        let uid = user.uid
        user.delete { error in
            if let error = error {
                alertText = "Erreur lors de la suppression : \(error.localizedDescription)"
                showAlert = true
            } else {
                // Delete Firestore user document
                let db = Firestore.firestore()
                db.collection("users").document(uid).delete { dbError in
                    if let dbError = dbError {
                        alertText = "Compte supprimé, mais erreur lors de la suppression des données : \(dbError.localizedDescription)"
                    } else {
                        alertText = "Compte et données supprimés avec succès."
                        onDeleteConfirmed()
                    }
                    showAlert = true
                }
            }
        }
    }
}

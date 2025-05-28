import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Binding var isLoggedIn: Bool

    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var postalCode: Int = 0
    @State private var facebookLink: String = ""
    @State private var instagramLink: String = ""
    @State private var xLink: String = ""
    @State private var youtubeLink: String = ""
    @State private var email: String = ""
    @State private var isCreator: Bool = false

    @State private var isLoading = false
    @State private var message: String = ""

    @State private var showAlert = false
    @State private var alertText = ""
    @State private var shouldLogout = false

    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations personnelles")) {
                    Text("Nom: \(name)")
                    Text("Code postal: \(postalCode)")
                    Text("Email: \(email)")
                }

                Section(header: Text("Réseaux sociaux")) {
                    if !facebookLink.isEmpty {
                        socialLinkRow(icon: "facebook-icon", link: facebookLink)
                    }
                    if !instagramLink.isEmpty {
                        socialLinkRow(icon: "instagram-icon", link: instagramLink)
                    }
                    if !youtubeLink.isEmpty {
                        socialLinkRow(icon: "youtube-icon", link: youtubeLink)
                    }
                    if !xLink.isEmpty {
                        socialLinkRow(icon: "x-icon", link: xLink)
                    }
                }

                Section {
                    Button("Modifier mon profil") {
                        showEditProfile = true
                    }

                    LongPressLogoutButton(
                        showAlert: $showAlert,
                        alertText: $alertText,
                        onLogoutConfirmed: {
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
                    postalCode: $postalCode,
                    facebookLink: $facebookLink,
                    instagramLink: $instagramLink,
                    xLink: $xLink,
                    youtubeLink: $youtubeLink,
                    email: $email,
                    isCreator: $isCreator
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

    func socialLinkRow(icon: String, link: String) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 30, height: 30)
            Link(link, destination: URL(string: link)!)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Utilisateur non connecté"
            return
        }
        isLoading = true

        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(uid)

        userRef.getDocument { snapshot, error in
            isLoading = false
            if let data = snapshot?.data(), error == nil {
                name = data["name"] as? String ?? ""
                postalCode = data["postalCode"] as? Int ?? 0
                facebookLink = data["facebookLink"] as? String ?? ""
                instagramLink = data["instagramLink"] as? String ?? ""
                youtubeLink = data["youtubeLink"] as? String ?? ""
                xLink = data["xLink"] as? String ?? ""
                email = data["email"] as? String ?? Auth.auth().currentUser?.email ?? ""
                isCreator = data["role"] as? String == "createur"
            } else {
                message = "Aucune fiche utilisateur trouvée, vous pouvez en créer une."
                email = Auth.auth().currentUser?.email ?? ""
            }
        }
    }
}

struct LongPressLogoutButton: View {
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?

    @Binding var showAlert: Bool
    @Binding var alertText: String

    var onLogoutConfirmed: () -> Void

    let duration: Double = 1.0
    let interval: Double = 0.02

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                    .animation(.linear(duration: interval), value: progress)

                Image(systemName: "power")
                    .foregroundColor(.red)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        startProgress()
                    }
                    .onEnded { _ in
                        stopProgress()
                    }
            )

            Text("Appui long pour se déconnecter")
                .foregroundColor(.red)
                .font(.footnote)
        }
    }

    func startProgress() {
        if timer == nil {
            progress = 0.0
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                if progress < 1.0 {
                    progress += interval / duration
                } else {
                    timer?.invalidate()
                    timer = nil
                    logout()
                }
            }
        }
    }

    func stopProgress() {
        timer?.invalidate()
        timer = nil
        progress = 0.0
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

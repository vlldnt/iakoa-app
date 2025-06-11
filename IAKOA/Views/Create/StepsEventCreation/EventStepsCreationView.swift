import FirebaseAuth
import Firebase
import SwiftUI
import CoreLocation

struct EventStepsCreationView: View {
    @Environment(\.dismiss) private var dismiss
        
    @State private var step = 0
    @State private var selectedImages: [UIImage] = []
    
    @State private var event = Event(
        id: UUID().uuidString,
        creatorID: "",
        date: Date(),
        description: "",
        facebookLink: "",
        instagramLink: "",
        location: CLLocationCoordinate2D(),
        name: "",
        pricing: 0.0,
        websiteLink: "",
        xLink: "",
        youtubeLink: ""
    )
    
    var body: some View {
        VStack {
            TabView(selection: $step) {
                Step1BasicInfo(event: $event)
                    .tag(0)
                Step2LocationMedia(event: $event, selectedImages: $selectedImages)
                    .tag(1)
                Step3CategoriesLinks(event: $event)
                    .tag(2)
                Step4FinalReview(event: $event, selectedImages: $selectedImages)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            ZStack {
                VStack(spacing: 1) {
                    Text("\(step + 1) / 4")
                        .font(.headline)
                        .padding(.top)
                        .foregroundColor(.blueIakoa)
                    
                    HStack {
                        if step > 0 {
                            Button("Précédent") {
                                step -= 1
                            }
                            .frame(width: 80, height: 35)
                        } else {
                            Color.clear.frame(width: 80, height: 35)
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "clear")
                                .font(.title2)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        if step < 3 {
                            Button("Suivant") {
                                if step == 0 && !isStep1Valid {
                                    // Ne rien faire
                                } else {
                                    step += 1
                                }
                            }
                            .frame(width: 80, height: 35)
                            .disabled(step == 0 && !isStep1Valid)
                            .opacity(step == 0 && !isStep1Valid ? 0.5 : 1.0)
                        } else {
                            Color.clear.frame(width: 80, height: 35)
                        }
                    }
                }
                .frame(height: 90)
                .padding()
                .background(Color.white)
            }
            .onAppear {
                fetchUserInfo()
            }
        }
    }
    
    private func fetchUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.fetchUser(uid: uid) { user in
            if let user = user {
                self.event.facebookLink = user.facebookLink
                self.event.instagramLink = user.instagramLink
                self.event.xLink = user.xLink
                self.event.youtubeLink = user.youtubeLink
            } else {
                print("Erreur : impossible de récupérer les infos utilisateur.")
            }
        }
    }
    
    private var isStep1Valid: Bool {
        !event.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !event.description.trimmingCharacters(in: .whitespaces).isEmpty &&
        event.pricing > 0
    }
}

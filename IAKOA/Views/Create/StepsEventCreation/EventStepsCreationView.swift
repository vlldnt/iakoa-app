import FirebaseAuth
import Firebase
import SwiftUI
import PhotosUI
import CoreLocation

struct EventStepsCreationView: View {
    //Step 1:
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventCategories: [String] = []
    
    //Step 2:
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    
    // Step 3:
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showPhotoSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    
    //Users informations:
    @State private var facebookLink: String = ""
    @State private var instagramLink: String = ""
    @State private var xLink: String = ""
    @State private var youtubeLink: String = ""
    @State private var websiteLink: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var step: Int = 0
    
    @ObservedObject private var addressSearchService = AddressSearchService()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TabView(selection: $step) {
                Step1BasicInfo(eventName : $eventName,
                               eventDescription: $eventDescription,
                               eventCategories: $eventCategories)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            ZStack {
                VStack(spacing: 1) {
                    Text("\(step + 1) / 3")
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
                self.facebookLink = user.facebookLink
                self.instagramLink = user.instagramLink
                self.xLink = user.xLink
                self.youtubeLink = user.youtubeLink
                self.websiteLink = user.website
            } else {
                print("Erreur : impossible de récupérer les infos utilisateur.")
            }
        }
    }
    
    private var isStep1Valid: Bool {
        !eventName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventCategories.isEmpty
    }
    
    
}

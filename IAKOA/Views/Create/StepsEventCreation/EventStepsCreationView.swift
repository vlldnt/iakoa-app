import FirebaseAuth
import Firebase
import SwiftUI
import PhotosUI
import CoreLocation

struct EventStepsCreationView: View {
    // Step 1:
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventCategories: [String] = []

    // Step 2:
    @State private var eventDates: [Date] = []
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""

    // Step 3:
    @State private var selectedImages: [UIImage] = []
    @State private var websiteEvent: String = ""

    // User info:
    @State private var facebookLink: String = ""
    @State private var instagramLink: String = ""
    @State private var xLink: String = ""
    @State private var youtubeLink: String = ""
    @State private var websiteLink: String = ""

    @State private var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var shouldDismissAfterAlert = false

    @State private var step: Int = 0
    
    @ObservedObject private var addressSearchService = AddressSearchService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TabView(selection: $step) {
                Step1BasicInfo(
                    eventName : $eventName,
                    eventDescription: $eventDescription,
                    eventCategories: $eventCategories
                )
                .tag(0)

                Step2LocationMedia(
                    eventDates: $eventDates,
                    eventAddress: $eventAddress,
                    eventPrice: $eventPrice
                )
                .tag(1)

                Step3ImageSelector(selectedImages: $selectedImages, websiteEvent: $websiteEvent)
                .tag(2)

                Step4EventPreview(
                    eventName: $eventName,
                    eventDescription: $eventDescription,
                    eventCategories: $eventCategories,
                    eventDates: $eventDates,
                    eventAddress: $eventAddress,
                    eventPrice: $eventPrice,
                    selectedImages: $selectedImages,
                    facebookLink: $facebookLink,
                    instagramLink: $instagramLink,
                    xLink: $xLink,
                    youtubeLink: $youtubeLink,
                    websiteLink: $websiteLink,
                    websiteEvent: $websiteEvent,
                    onClose: { dismiss() }
                )
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
                                hideKeyboard()
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
                                hideKeyboard()
                                if step == 0 && !isStep1Valid {
                                    // Do nothing
                                } else {
                                    step += 1
                                }
                            }
                            .frame(width: 80, height: 35)
                            .disabled(!isCurrentStepValid)
                            .opacity(!isCurrentStepValid ? 0.5 : 1.0)
                        }

                        if step == 3 {
                            Button(action: {
                                EventCreationService.createEvent(
                                    eventName: eventName,
                                    eventAddress: eventAddress,
                                    eventDescription: eventDescription,
                                    eventDates: eventDates,
                                    eventCategories: eventCategories,
                                    eventPrice: eventPrice,
                                    selectedImages: selectedImages,
                                    facebookLink: facebookLink,
                                    instagramLink: instagramLink,
                                    xLink: xLink,
                                    youtubeLink: youtubeLink,
                                    websiteLink: websiteEvent,
                                    showAlert: { message in
                                        alertMessage = message
                                        showAlert = true
                                        shouldDismissAfterAlert = true
                                    },
                                    setLoading: { loading in
                                        isLoading = loading
                                    },
                                    dismiss: {
                                    }
                                )
                            }) {
                                Text(isLoading ? "Création..." : "Créer l'évènement")
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .bold()
                                    .background(Color.blueIakoa)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(isLoading)
                            .padding()
                        }
                    }
                }
                .frame(height: 42)
                .padding(8)
                .background(Color.white)
            }
        }

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Succès"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if shouldDismissAfterAlert {
                        dismiss()
                    }
                }
            )
        }
        .overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                        ProgressView("Création en cours...")
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
            }
        )
        .onAppear {
            fetchUserInfo()
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

    // Validation
    private var isCurrentStepValid: Bool {
        switch step {
        case 0: return isStep1Valid
        case 1: return isStep2Valid
        case 2: return isStep3Valid
        default: return true
        }
    }

    private var isStep1Valid: Bool {
        !eventName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventCategories.isEmpty
    }

    private var isStep2Valid: Bool {
        !eventAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventPrice.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isStep3Valid: Bool {
        !selectedImages.isEmpty
    }
}

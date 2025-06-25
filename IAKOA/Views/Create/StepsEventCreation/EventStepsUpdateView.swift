import FirebaseAuth
import Firebase
import SwiftUI
import PhotosUI
import CoreLocation

struct EventStepsUpdateView: View {
    // Callback pour notifier la mise à jour
    var onUpdate: (() -> Void)?

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

    // Links:
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

    var eventToEdit: Event?

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

            navigationControls
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Terminé") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Succès"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if shouldDismissAfterAlert {
                        dismiss()
                        onUpdate?()
                    }
                }
            )
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Mise à jour en cours…")
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            fetchUserInfo()
            if let event = eventToEdit {
                eventName = event.name
                eventDescription = event.description
                eventCategories = event.categories
                eventDates = event.dates
                eventAddress = event.address
                eventPrice = String(event.pricing)
                facebookLink = event.facebookLink
                instagramLink = event.instagramLink
                xLink = event.xLink
                youtubeLink = event.youtubeLink
                websiteLink = event.websiteLink
                loadImagesFromURLs(event.imagesLinks)
            }
        }
    }


    // MARK: - Navigation Buttons

    private var navigationControls: some View {
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
                            // Ne fait rien
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
                        guard let event = eventToEdit else { return }
                        EventUpdateService.updateEvent(
                            event: event,
                            name: eventName,
                            address: eventAddress,
                            description: eventDescription,
                            dates: eventDates,
                            categories: eventCategories,
                            price: eventPrice,
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
                                dismiss()
                                onUpdate?()
                            }
                        )
                    }) {
                        Text(isLoading ? "Mise à jour..." : "Mise à jour de l'évènement")
                            .frame(maxWidth: .infinity)
                            .padding()
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
    

    // MARK: - Helpers

    private func fetchUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserServices.fetchUser(uid: uid) { user in
            if let user = user {
                facebookLink = user.facebookLink
                instagramLink = user.instagramLink
                xLink = user.xLink
                youtubeLink = user.youtubeLink
                websiteLink = user.website
            } else {
                print("Erreur : impossible de récupérer les infos utilisateur.")
            }
        }
    }

    private func loadImagesFromURLs(_ urls: [String]) {
        selectedImages.removeAll()
        for urlString in urls {
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            selectedImages.append(image)
                        }
                    }
                }.resume()
            }
        }
    }

    // MARK: - Validation

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

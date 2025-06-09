import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import MapKit
import PhotosUI
import UIKit

struct CreateEventView: View {
    // MARK: - States formulaire
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    @State private var eventDescription: String = ""
    
    // MARK: - Images
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    // MARK: - UI States
    @State private var showPhotoSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    
    @State private var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Address Search
    @ObservedObject private var addressSearchService = AddressSearchService()
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Validation formulaire
    private var isFormValid: Bool {
        !eventName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(eventPrice) != nil && Double(eventPrice)! >= 0
    }
    
    var body: some View {
        VStack(spacing: 7) {
            Image("logo-iakoa")
                .resizable()
                .frame(width: 120, height: 34)
                .foregroundStyle(Color.blueIakoa)
            
            eventNameSection
            eventAddressSection
            eventDateSection
            eventDescriptionSection
            eventPriceSection
            
            // Affichage images sélectionnées max 3
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    if index < selectedImages.count {
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 115, height: 80)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .frame(width: 115, height: 80)
                            .background(Color.gray.opacity(0.05))
                    }
                }
            }
            .padding(.vertical, 8)
            
            Button {
                showPhotoSourceDialog = true
            } label: {
                Text("Ajouter des photos")
                    .frame(width: 150)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .disabled(selectedImages.count >= 3)
            .confirmationDialog("Ajouter une photo", isPresented: $showPhotoSourceDialog, titleVisibility: .visible) {
                Button("Appareil photo") { showCamera = true }
                Button("Photothèque") { showPhotosPicker = true }
                Button("Annuler", role: .cancel) {}
            }
            
            Button(action: {
                createEvent()
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Label("Créer mon évènement", systemImage: "plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid ? Color.blue.opacity(0.8) : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .bold()
                }
            }
            .padding(.top, 10)
            .disabled(!isFormValid || isLoading)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 10)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Information"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Évènement correctement créé !" {
                        dismiss()
                    }
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        
        // Présentation caméra
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                if let img = image, selectedImages.count < 3 {
                    selectedImages.append(img)
                }
                showCamera = false
            }
        }
        
        
        // Présentation PhotosPicker (photothèque)
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $photoPickerItems,
            maxSelectionCount: 3,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, newItems in
            Task {
                await loadSelectedImages(newItems)
            }
        }
    }
    
    // MARK: - Sections formulaire
    
    private var eventNameSection: some View {
        Group {
            Text("Nom")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            
            TextField("Nom de l'évènement", text: $eventName)
                .keyboardType(.default)
                .padding(8)
                .autocorrectionDisabled()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blueIakoa).opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(.bottom, 8)
        }
    }
    
    private var eventAddressSection: some View {
        Group {
            Text("Addresse")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            
            VStack(spacing: 0) {
                TextField("Adresse", text: $eventAddress)
                    .keyboardType(.default)
                    .padding(8)
                    .autocorrectionDisabled()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.bottom, 0)
                    .onChange(of: eventAddress) { _, newValue in
                        if newValue.count > 2 {
                            addressSearchService.updateSearch(query: newValue)
                        } else {
                            addressSearchService.searchResults = []
                        }
                    }
                
                addressSuggestionsList
            }
            .padding(.bottom, 8)
        }
    }
    
    private var eventDateSection: some View {
        HStack {
            Text("Date et heure")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            Spacer()
            DatePicker("", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "fr_FR"))
        }
        .padding(.bottom, 8)
    }
    
    private var eventDescriptionSection: some View {
        Group {
            Text("Description de votre évènement")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 9)
            TextEditor(text: $eventDescription)
                .font(.system(size: 14, weight: .regular))
                .keyboardType(.default)
                .frame(height: 100)
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.bottom, 8)
        }
    }
    
    private var eventPriceSection: some View {
        HStack(spacing: 4) {
            Text("Prix")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 60, alignment: .leading)
            
            TextField("en €", text: $eventPrice)
                .keyboardType(.decimalPad)
                .padding(8)
                .frame(width: 60)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.red.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.bottom, 8)
    }
    
    private var addressSuggestionsList: some View {
        Group {
            if !addressSearchService.searchResults.isEmpty {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(addressSearchService.searchResults.prefix(3), id: \.self) { completion in
                                AddressSuggestionRow(completion: completion) {
                                    eventAddress = completion.title + (completion.subtitle.isEmpty ? "" : ", \(completion.subtitle)")
                                    addressSearchService.searchResults = []
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    }
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .frame(height: 200)
            }
        }
    }
    
    // MARK: - Fonctions
    
    // Checks form, geocodes address, fetches user, uploads images, and creates event
    func createEvent() {
        guard let priceDouble = Double(eventPrice), priceDouble >= 0 else {
            alertMessage = "Le prix doit être un nombre valide supérieur ou égal à 0."
            showAlert = true
            return
        }
        
        guard !eventName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Merci de renseigner le nom de l'évènement."
            showAlert = true
            return
        }
        
        guard !eventAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Merci de renseigner une adresse."
            showAlert = true
            return
        }
        
        guard !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Merci de renseigner une description."
            showAlert = true
            return
        }
        
        isLoading = true
        alertMessage = ""
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(eventAddress) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Erreur de géocodage : \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                }
                return
            }
            
            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    alertMessage = "Adresse introuvable."
                    showAlert = true
                    isLoading = false
                }
                return
            }
            
            guard let user = Auth.auth().currentUser else {
                DispatchQueue.main.async {
                    alertMessage = "Utilisateur non connecté."
                    showAlert = true
                    isLoading = false
                }
                return
            }
            
            UserServices.fetchUser(uid: user.uid) { userObj in
                guard let userObj = userObj else {
                    DispatchQueue.main.async {
                        alertMessage = "Impossible de récupérer l'utilisateur."
                        showAlert = true
                        isLoading = false
                    }
                    return
                }
                guard userObj.isCreator else {
                    DispatchQueue.main.async {
                        alertMessage = "Seuls les créateurs peuvent créer un évènement."
                        showAlert = true
                        isLoading = false
                    }
                    return
                }
                
                uploadImages(selectedImages) { imageLinks in
                    let event = Event(
                        id: UUID().uuidString,
                        creatorID: userObj.id,
                        date: eventDate,
                        description: eventDescription,
                        facebookLink: userObj.facebookLink,
                        instagramLink: userObj.instagramLink,
                        location: location.coordinate,
                        name: eventName.isEmpty ? userObj.name : eventName,
                        pricing: priceDouble,
                        websiteLink: userObj.website,
                        xLink: userObj.xLink,
                        youtubeLink: userObj.youtubeLink,
                        imagesLinks: imageLinks,
                        address: eventAddress
                    )
                    
                    EventServices.addEvent(event) { result in
                        DispatchQueue.main.async {
                            isLoading = false
                            switch result {
                            case .success:
                                alertMessage = "Évènement correctement créé !"
                                showAlert = true
                                // Tu peux fermer la vue dans le bouton OK de l'alerte si tu veux
                            case .failure:
                                alertMessage = "Erreur lors de la création de l'évènement."
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Loads selected images from PhotosPicker
    @MainActor
    func loadSelectedImages(_ items: [PhotosPickerItem]) async {
        selectedImages = []
        
        for item in items.prefix(3) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               !selectedImages.contains(image),
               selectedImages.count < 3 {
                selectedImages.append(image)
            }
        }
    }
}

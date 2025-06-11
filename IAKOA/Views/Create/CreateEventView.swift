import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import MapKit
import PhotosUI
import UIKit

struct CreateEventView: View {
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    @State private var eventDescription: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showPhotoSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @ObservedObject private var addressSearchService = AddressSearchService()
    @Environment(\.dismiss) private var dismiss

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
                .padding(.bottom, 8)
            }

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
                EventCreationService.createEvent(
                    eventName: eventName,
                    eventAddress: eventAddress,
                    eventDescription: eventDescription,
                    eventDate: eventDate,
                    eventPrice: eventPrice,
                    selectedImages: selectedImages,
                    showAlert: { message in
                        alertMessage = message
                        showAlert = true
                    },
                    setLoading: { loading in
                        isLoading = loading
                    },
                    dismiss: {
                        dismiss()
                    }
                )
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
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                if let img = image, selectedImages.count < 3 {
                    selectedImages.append(img)
                }
                showCamera = false
            }
        }
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

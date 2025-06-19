import SwiftUI
import PhotosUI

struct Step3ImageSelector: View {
    @Binding var selectedImages: [UIImage]
    @State private var photoPickerItems: [PhotosPickerItem] = []

    @State private var showPhotoSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    
    let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Image principale (utilisée pour la vignette)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let mainImage = selectedImages.first {
                    Image(uiImage: mainImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)


            Text("Ajoutez jusqu'à 3 photos")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 80)
                            .clipped()
                            .cornerRadius(10)

                        Button(action: {
                            selectedImages.remove(at: index)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(x: 6, y: -6)
                    }
                }

                ForEach(selectedImages.count..<3, id: \.self) { _ in
                    Button(action: {
                        showPhotoSourceDialog = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .background(Color.gray.opacity(0.05))
                                .frame(width: 100, height: 80)
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            .confirmationDialog("Ajouter une photo", isPresented: $showPhotoSourceDialog) {
                Button("Appareil photo") { showCamera = true }
                Button("Mes photos") { showPhotosPicker = true }
                Button("Annuler", role: .cancel) {}
            }
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                if let image = image, selectedImages.count < 3 {
                    selectedImages.append(image)
                }
                showCamera = false
            }
        }
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $photoPickerItems,
            maxSelectionCount: 3 - selectedImages.count,
            matching: .images
        )
        .onChange(of: photoPickerItems) { _, newItems in
            Task {
                await loadSelectedImages(newItems)
            }
        }
    }

    @MainActor
    private func loadSelectedImages(_ items: [PhotosPickerItem]) async {
        for item in items.prefix(3 - selectedImages.count) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               selectedImages.count < 3 {
                selectedImages.append(image)
            }
        }
    }
}

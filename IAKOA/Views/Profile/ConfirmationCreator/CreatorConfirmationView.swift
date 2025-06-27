import SwiftUI
import PhotosUI

struct CreatorConfirmationView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var route: AnalysisResultRoute?
    @State private var rawSiren: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Confirmation du Créateur")
                    .font(.title)
                    .bold()

                SirenTextField(rawSiren: $rawSiren)
                    .padding(.horizontal)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(Text("Aucune image sélectionnée").foregroundColor(.gray))
                        .cornerRadius(12)
                }

                PhotosPicker("Choisir une photo", selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                self.selectedImage = image
                            }
                        }
                    }
                    .buttonStyle(.bordered)

                Button("Analyser l'image") {
                    if let image = selectedImage, rawSiren.count == 9 {
                        isAnalyzing = true
                        Task {
                            let result = await CreatorConfirmationFunctions.extractNumbers(from: image)
                            isAnalyzing = false
                            route = AnalysisResultRoute(
                                result: result,
                                enteredSiren: rawSiren
                            )
                        }
                    }
                }
                .disabled(selectedImage == nil || rawSiren.count != 9)
                .buttonStyle(.borderedProminent)

                if isAnalyzing {
                    ProgressView("Analyse en cours...")
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationDestination(item: $route) { route in
                AnalysisResultView(
                    result: route.result,
                    enteredSiren: route.enteredSiren
                )
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    struct AnalysisResultRoute: Hashable, Identifiable {
        let id = UUID()
        let result: String
        let enteredSiren: String
    }
}


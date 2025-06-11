import SwiftUI

struct Step2LocationMedia: View {
    @Binding var event: Event
    @Binding var selectedImages: [UIImage]
    @State private var showingImagePicker = false
    
    var body: some View {
        Form {
            Section(header: Text("Localisation & Médias")) {
                TextField("Adresse", text: $event.address)
                TextField("Facebook", text: $event.facebookLink)
                TextField("Instagram", text: $event.instagramLink)
                TextField("Site Web", text: $event.websiteLink)
            }
            
            Section(header: Text("Images")) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                            
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "plus")
                                    Text("Ajouter")
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    if let image = image {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}

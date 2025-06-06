import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import MapKit

struct CreateEventView: View {
    
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    @State private var eventDescription: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @ObservedObject private var addressSearchService = AddressSearchService()
    
    // Validation for required fields
    private var isFormValid: Bool {
        !eventName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(eventPrice) != nil && Double(eventPrice)! >= 0
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            Image("logo-iakoa")
                .resizable()
                .frame(width: 190, height: 54)
                .foregroundStyle(Color(hex: "#2397FF"))
                .padding(.bottom, 25)
            
            Group {
                Text("Nom")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 9)
                TextField("Nom de l'évènement", text: $eventName)
                    .keyboardType(.default)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#2397FF").opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.bottom, 10)
            }
            
            Group {
                Text("Adresse")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 9)
                
                // Address field with suggestions
                VStack(spacing: 0) {
                    TextField("Adresse", text: $eventAddress)
                        .keyboardType(.default)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 0)
                        .onChange(of: eventAddress) {
                            if eventAddress.count > 2 {
                                addressSearchService.updateSearch(query: eventAddress)
                            } else {
                                addressSearchService.searchResults = []
                            }
                        }
                    
                    addressSuggestionsList
                }
                .padding(.bottom, 10)
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
            .padding(.bottom, 10)
            
            Group {
                Text("Description de votre évènement")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 9)
                TextEditor(text: $eventDescription)
                    .keyboardType(.default)
                    .frame(height: 150)
                    .padding(8)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.bottom, 10)
            }
            
            HStack {
                Text("Prix")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 60, alignment: .leading)
                    .padding(.leading, 9)
                
                TextField("Prix en €", text: $eventPrice)
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.trailing, 190)
            }
            .padding(.bottom, 10)
            
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
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Extracted address suggestion list for better compiler performance
    private var addressSuggestionsList: some View {
        Group {
            if !addressSearchService.searchResults.isEmpty {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(addressSearchService.searchResults.prefix(3), id: \.self) { completion in
                                VStack(alignment: .leading) {
                                    Text(completion.title)
                                        .fontWeight(.medium)
                                    if !completion.subtitle.isEmpty {
                                        Text(completion.subtitle)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 60)
                                .background(Color.white)
                                .onTapGesture {
                                    eventAddress = completion.title + (completion.subtitle.isEmpty ? "" : ", \(completion.subtitle)")
                                    addressSearchService.searchResults = []
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                Divider()
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    }
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .frame(height: 200) // Fix height for the VStack
            }
        }
    }

    
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
                    imagesLinks: [],
                    address: eventAddress
                )
                
                EventServices.addEvent(event) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success:
                            alertMessage = "Évènement créé avec succès !"
                            showAlert = true
                            resetForm()
                        case .failure(let error):
                            alertMessage = "Erreur lors de la création : \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
    
    func resetForm() {
        eventName = ""
        eventDate = Date()
        eventAddress = ""
        eventPrice = ""
        eventDescription = ""
    }
}

#Preview {
    CreateEventView()
}

import Foundation
import FirebaseAuth
import CoreLocation
import UIKit

struct EventCreationService {
    static func createEvent(
        eventName: String,
        eventAddress: String,
        eventDescription: String,
        eventDates: [Date],
        eventCategories: [String],
        eventPrice: String,
        selectedImages: [UIImage],
        facebookLink: String,
        instagramLink: String,
        xLink: String,
        youtubeLink: String,
        websiteLink: String,
        showAlert: @escaping (String) -> Void,
        setLoading: @escaping (Bool) -> Void,
        dismiss: @escaping () -> Void
    ) {
        setLoading(true)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(eventAddress) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    showAlert("Erreur de géocodage : \(error.localizedDescription)")
                    setLoading(false)
                }
                return
            }
            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    showAlert("Adresse introuvable.")
                    setLoading(false)
                }
                return
            }
            let priceDouble = Double(eventPrice) ?? 0
            let event = Event(
                id: UUID().uuidString,
                creatorID: Auth.auth().currentUser?.uid ?? "",
                dates: eventDates,
                description: eventDescription,
                facebookLink: facebookLink,
                instagramLink: instagramLink,
                location: location.coordinate,
                name: eventName,
                pricing: priceDouble,
                websiteLink: websiteLink,
                xLink: xLink,
                youtubeLink: youtubeLink,
                imagesLinks: [],
                address: eventAddress,
                categories: eventCategories
            )
            uploadImages(selectedImages) { imageLinks in
                var eventWithImages = event
                eventWithImages.imagesLinks = imageLinks
                EventServices.addEvent(eventWithImages) { result in
                    DispatchQueue.main.async {
                        setLoading(false)
                        switch result {
                        case .success:
                            showAlert("Évènement correctement créé !")
                            dismiss()
                        case .failure:
                            showAlert("Erreur lors de la création de l'évènement.")
                        }
                    }
                }
            }
        }
    }
}

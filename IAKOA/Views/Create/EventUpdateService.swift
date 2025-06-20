import Foundation
import FirebaseAuth
import CoreLocation
import UIKit

struct EventUpdateService {
    static func updateEvent(
        event: Event,
        name: String,
        address: String,
        description: String,
        dates: [Date],
        categories: [String],
        price: String,
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
        geocoder.geocodeAddressString(address) { placemarks, error in
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

            let priceDouble = Double(price) ?? 0
            var updatedEvent = event
            updatedEvent.name = name
            updatedEvent.address = address
            updatedEvent.description = description
            updatedEvent.dates = dates
            updatedEvent.categories = categories
            updatedEvent.pricing = priceDouble
            updatedEvent.location = location.coordinate
            updatedEvent.facebookLink = facebookLink
            updatedEvent.instagramLink = instagramLink
            updatedEvent.xLink = xLink
            updatedEvent.youtubeLink = youtubeLink
            updatedEvent.websiteLink = websiteLink

            uploadImages(selectedImages) { imageLinks in
                updatedEvent.imagesLinks = imageLinks

                EventServices.updateEvent(updatedEvent) { result in
                    DispatchQueue.main.async {
                        setLoading(false)
                        switch result {
                        case .success:
                            showAlert("Évènement mis à jour avec succès !")
                            dismiss()
                        case .failure:
                            showAlert("Erreur lors de la mise à jour de l'évènement.")
                        }
                    }
                }
            }
        }
    }
}

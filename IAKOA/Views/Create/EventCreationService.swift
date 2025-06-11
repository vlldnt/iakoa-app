//
//  EventCreationService.swift
//  IAKOA
//
//  Created by Adrien V on 10/06/2025.
//


// EventCreationService.swift
import Foundation
import FirebaseAuth
import CoreLocation
import UIKit

struct EventCreationService {
    static func createEvent(
        eventName: String,
        eventAddress: String,
        eventDescription: String,
        eventDate: Date,
        eventPrice: String,
        selectedImages: [UIImage],
        showAlert: @escaping (String) -> Void,
        setLoading: @escaping (Bool) -> Void,
        dismiss: @escaping () -> Void
    ) {
        guard let priceDouble = Double(eventPrice), priceDouble >= 0 else {
            showAlert("Le prix doit être un nombre valide supérieur ou égal à 0.")
            return
        }
        guard !eventName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Merci de renseigner le nom de l'évènement.")
            return
        }
        guard !eventAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Merci de renseigner une adresse.")
            return
        }
        guard !eventDescription.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Merci de renseigner une description.")
            return
        }
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
            guard let user = Auth.auth().currentUser else {
                DispatchQueue.main.async {
                    showAlert("Utilisateur non connecté.")
                    setLoading(false)
                }
                return
            }
            UserServices.fetchUser(uid: user.uid) { userObj in
                guard let userObj = userObj else {
                    DispatchQueue.main.async {
                        showAlert("Impossible de récupérer l'utilisateur.")
                        setLoading(false)
                    }
                    return
                }
                guard userObj.isCreator else {
                    DispatchQueue.main.async {
                        showAlert("Seuls les créateurs peuvent créer un évènement.")
                        setLoading(false)
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
}

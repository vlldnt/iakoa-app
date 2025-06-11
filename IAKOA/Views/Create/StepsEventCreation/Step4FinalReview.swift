//
//  Step4FinalReview.swift
//  IAKOA
//
//  Created by Adrien V on 11/06/2025.
//


import SwiftUI

struct Step4FinalReview: View {
    @Binding var event: Event
    @Binding var selectedImages: [UIImage]
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text("Résumé").font(.title2).bold()
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Nom : \(event.name)")
                    Text("Description : \(event.description)")
                    Text("Adresse : \(event.address)")
                    Text("Prix : \(event.pricing, specifier: "%.2f") €")
                    Text("Date : \(event.date.formatted(.dateTime))")
                }
                .padding()
            }

            if isSubmitting {
                ProgressView("Création en cours...")
            } else {
                Button("Créer l'événement") {
                    createEvent()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("Info", isPresented: $showAlert, actions: {}, message: {
            Text(alertMessage)
        })
    }

    private func createEvent() {
        isSubmitting = true
        if event.imagesLinks.isEmpty && !selectedImages.isEmpty {
            uploadImages(selectedImages) { urls in
                event.imagesLinks = urls
                submitToFirestore()
            }
        } else {
            submitToFirestore()
        }
    }

    private func submitToFirestore() {
        EventServices.addEvent(event) { result in
            isSubmitting = false
            switch result {
            case .success:
                alertMessage = "Événement créé avec succès !"
            case .failure(let error):
                alertMessage = "Erreur : \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
}

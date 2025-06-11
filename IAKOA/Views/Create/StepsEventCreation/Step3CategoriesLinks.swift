//
//  Step3CategoriesLinks.swift
//  IAKOA
//
//  Created by Adrien V on 11/06/2025.
//


import SwiftUI

struct Step3CategoriesLinks: View {
    @Binding var event: Event

    var body: some View {
        Form {
            Section(header: Text("Réseaux & Catégories")) {
                TextField("Lien X", text: $event.xLink)
                TextField("Lien YouTube", text: $event.youtubeLink)

                TextField("Catégories (séparées par des virgules)", text: Binding(
                    get: { event.categories.joined(separator: ", ") },
                    set: { event.categories = $0.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) } }
                ))
            }
        }
    }
}

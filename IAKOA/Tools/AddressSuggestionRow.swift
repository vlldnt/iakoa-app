//
//  AddressSuggestionRow.swift
//  IAKOA
//
//  Created by Adrien V on 06/06/2025.
//


import SwiftUI
import MapKit

struct AddressSuggestionRow: View {
    let completion: MKLocalSearchCompletion
    let onSelect: () -> Void

    var body: some View {
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
        .onTapGesture { onSelect() }
        Divider()
    }
}

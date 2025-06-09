//
//  CreateView.swift
//  IAKOA
//
//  Created by Adrien V on 06/06/2025.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct CreateView: View {
    
    @State private var showEventCreationView = false
    
    var body: some View {
        VStack {
            Button("Nouvel évènement") {
                showEventCreationView = true
                // Action for creating an event
            }
            .font(.headline)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blueIakoa, lineWidth: 1))
        }
        .sheet(isPresented: $showEventCreationView) {
            NavigationStack {
                CreateEventView()
            }
        }
    }
}

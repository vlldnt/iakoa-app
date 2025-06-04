//
//  IAKOAApp.swift
//  IAKOA
//
//  Created by Adrien V on 24/04/2025.
//

import SwiftUI
import Firebase

@main
struct IAKOAApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateEventView: View {
    
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var eventPrice: String = ""
    @State private var eventDescription: String = ""
    
    var body: some View {
        Text("Hello, World!")
    }
}
